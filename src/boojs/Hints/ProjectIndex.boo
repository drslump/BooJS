namespace boojs.Hints

import System(StringComparison)
import System.Linq.Enumerable

import Boo.Lang.Environments
import Boo.Lang.Compiler(BooCompiler, CompilerContext, Steps, IO)
import Boo.Lang.Compiler.Pipelines as BooPipelines
import Boo.Lang.Compiler.Ast
import Boo.Lang.Compiler.TypeSystem
import Boo.Lang.Compiler.TypeSystem.Core
import Boo.Lang.PatternMatching

import BooJs.Compiler(newBooJsCompiler, Pipelines)


class ProjectIndex:

    [getter(Context)]
    _context as CompilerContext

    _compiler as BooCompiler
    _parser as BooCompiler
    _implicitNamespaces as List

    static def Boo():
        compiler = BooCompiler()
        compiler.Parameters.Pipeline = BooPipelines.ResolveExpressions(BreakOnErrors: false)

        parser = BooCompiler()
        parser.Parameters.Pipeline = BooPipelines.Parse() { Steps.IntroduceModuleClasses() }
        implicitNamespaces = ["Boo.Lang", "Boo.Lang.Builtins"]

        return ProjectIndex(compiler, parser, implicitNamespaces)

    static def BooJs():
        compiler = newBooJsCompiler(Pipelines.ResolveExpressions(BreakOnErrors: false))
        parser = newBooJsCompiler(Pipelines.Parse() { Steps.IntroduceModuleClasses() })
        implicitNamespaces = [
            'BooJs.Lang',
            'BooJs.Lang.Builtins',
            'BooJs.Lang.Globals',
            'BooJs.Lang.Macros',
            'Boo.Lang.PatternMatching'
        ]

        return ProjectIndex(compiler, parser, implicitNamespaces)

    def constructor(compiler as BooCompiler, parser as BooCompiler, implicitNamespaces as List):
        _compiler = compiler
        _parser = parser
        _implicitNamespaces = implicitNamespaces

    virtual def AddReference(assembly as System.Reflection.Assembly):
        _compiler.Parameters.References.Add(assembly)

    virtual def AddReference(reference as string):
        asm = _compiler.Parameters.LoadAssembly(reference, true)
        _compiler.Parameters.References.Add(asm)

    virtual def WithParser(fname as string, code as string, action as System.Action[of Module]):
        input = _parser.Parameters.Input
        input.Add(IO.StringInput(fname, code))
        try:
            _context = _parser.Run()
            ActiveEnvironment.With(_context.Environment) do:
                action(GetModuleForFileFromContext(_context, fname))
        ensure:
            input.Clear()

    virtual def WithCompiler(fname as string, code as string, action as System.Action[of Module]):
        input = _compiler.Parameters.Input
        input.Add(IO.StringInput(fname, code))
        try:
            _context = _compiler.Run()
            ActiveEnvironment.With(_context.Environment) do:
                action(GetModuleForFileFromContext(_context, fname))
        ensure:
            input.Clear()

    private def GetModuleForFileFromContext(context as CompilerContext, fileName as string):
        for m in context.CompileUnit.Modules:
            return m if m.LexicalInfo.FileName == fileName
        return null


class LocationFinder(DepthFirstVisitor):
    _entity as Boo.Lang.Compiler.TypeSystem.IEntity
    _line as int
    _column as int

    def constructor(line as int, column as int):
        _line = line
        _column = column

    def FindIn(root as Node):
        VisitAllowingCancellation(root)
        return _entity

    override def Visit(node as Node):
        if node and not node.IsSynthetic and node.LexicalInfo is not null and node.Entity is not null:
            if node.LexicalInfo.Line == _line and node.LexicalInfo.Column == _column:
                _entity = node.Entity
                Cancel()

        super(node)


class CursorLocationFinder(DepthFirstVisitor):

    _node as Expression

    def FindIn(root as Node):
        VisitAllowingCancellation(root)
        return _node

    override def LeaveMemberReferenceExpression(node as MemberReferenceExpression):
        if node.Name == '__cursor_location__':
            Found(node)

    protected def Found(node):
        _node = node
        Cancel()


class LocalAccumulator(FastDepthFirstVisitor):
    _filename as string
    _line as int
    _results as System.Collections.Generic.List of IEntity

    def constructor(filename as string, line as int):
        _filename = System.IO.Path.GetFullPath(filename)
        _line = line

    def FindIn(root as Node):
        _results = System.Collections.Generic.List of IEntity()
        Visit(root)
        return _results

    override def OnMethod(method as Method):
        AddMethodParams(method)
        Visit method.Body

    override def OnConstructor(method as Constructor):
        AddMethodParams(method)
        Visit method.Body

    override def OnBlockExpression(node as BlockExpression):
        return if node.LexicalInfo is null
        return if _line < node.LexicalInfo.Line
        return if _line > GetEndLine(node.Body) + 1

        for param in node.Parameters:
            _results.Add(param.Entity)

        Visit node.Body

    override def OnForStatement(node as ForStatement):
        return if node.LexicalInfo is null
        return if _line < node.LexicalInfo.Line
        return if _line > GetEndLine(node.Block) + 1

        for decl in node.Declarations:
            _results.Add(decl.Entity)

    protected def GetEndLine(block as Block):
        last = block.LastStatement
        return (last.LexicalInfo.Line if last else block.LexicalInfo.Line)

    private def AddMethodParams(method as Method):
        if method.LexicalInfo is null: return
        if _line < method.LexicalInfo.Line or _line > method.EndSourceLocation.Line: return
        if not method.LexicalInfo.FullPath.Equals(_filename, StringComparison.OrdinalIgnoreCase): return

        for local in method.Locals:
            _results.Add(local.Entity)
        for param in method.Parameters:
            _results.Add(param.Entity)


static class CompletionProposer:

    def ForExpression(expression as Expression):
        match expression:
            case MemberReferenceExpression(Target: target=Expression(ExpressionType)):
                match target.Entity:
                    case ns=INamespace(EntityType: EntityType.Namespace):
                        members = ns.GetMembers()
                    case IType():
                        members = StaticMembersOf(ExpressionType)
                    otherwise:
                        parent = expression.GetAncestor[of TypeDefinition]()
                        members = InstanceMembersOf(ExpressionType, parent.Entity)

                membersByName = members.GroupBy({ member | member.Name })
                for member in membersByName:
                    yield Entities.EntityFromList(member.ToList())
            otherwise:
                pass

    def InstanceMembersOf(type as IType, parent as IType):
        for member in AccessibleMembersOf(type, parent):
            match member:
                case IAccessibleMember(IsStatic):
                    yield member unless IsStatic
                otherwise:
                    yield member

    def StaticMembersOf(type as IType):
        for member in AccessibleMembersOf(type, null):
            match member:
                case IAccessibleMember(IsStatic):
                    yield member if IsStatic
                otherwise:
                    yield member

    def AccessibleMembersOf(type as IType, parent as IType):
        currentType = type
        while currentType is not null:
            is_same = parent == currentType
            is_subclass = parent and parent.IsSubclassOf(currentType)

            for member in currentType.GetMembers():
                if IsSpecialName(member.Name):
                    continue
                match member:
                    case IConstructor():
                        continue
                    case IEvent():
                        yield member
                    case IAccessibleMember(IsPublic, IsProtected):
                        if is_same or IsPublic or (IsProtected and is_subclass):
                            yield member
                    otherwise:
                        continue
            if currentType.IsInterface:
                currentType = (currentType.GetInterfaces() as IType*).FirstOrDefault() or my(TypeSystemServices).ObjectType
            else:
                currentType = currentType.BaseType

    _specialPrefixes = { "get_": 1, "set_": 1, "add_": 1, "remove_": 1, "op_": 1 }

    def IsSpecialName(name as string):
        index = name.IndexOf('_')
        return false if index < 0

        prefix = name[:index + 1]
        return prefix in _specialPrefixes
