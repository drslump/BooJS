namespace boojs.Hints

import Boo.Lang.Environments
import Boo.Lang.Compiler
import Boo.Lang.Compiler.Ast
import Boo.Lang.Compiler.TypeSystem

import Boo.Lang.PatternMatching

/*
class ExpressionResolution:

    static def ForCodeString(code as string):
        cu = Boo.Lang.Parser.BooParser.ParseString('code', code)
        return ForCompileUnit(cu)

    static def ForCompileUnit(originalCompileUnit as CompileUnit):
        compiler = BooCompiler()
        compiler.Parameters.Pipeline = Pipelines.ResolveExpressions(BreakOnErrors: false)
        ctx = compiler.Run(originalCompileUnit.CloneNode())
        return ExpressionResolution(originalCompileUnit, ctx)

    [getter(OriginalCompileUnit)] _originalCompileUnit as CompileUnit
    _ctx as CompilerContext

    private def constructor(originalCompileUnit, ctx):
        _originalCompileUnit = originalCompileUnit
        _ctx = ctx

    NodeInformationProvider:
        get: return NodeInformationProvider(_ctx.CompileUnit)

    def RunInResolvedCompilerContext(action as System.Action):
        _ctx.Environment.Run(action)


class NodeInformationProvider(DepthFirstVisitor):
""" Provides information about a node.
"""
    _compileUnit as CompileUnit

    def constructor(resolvedCompileUnit as CompileUnit):
        _compileUnit = resolvedCompileUnit

    def ElementFor(node as Node):
        node = Resolve(node)
        if node is null:
            return SymbolsMessage.Unknown

        match node.Entity:
            case l=ILocalEntity(Name: name, Type: t):
                return SymbolsMessage.Symbol(
                    node: 'local',
                    name: name,
                    type: ToString(t),
                    info: node.GetAncestor[of Method]().FullName,
                    doc: DocStringFor(l)
                )
            case c=IConstructor():
                return AddLexicalInfo(c, SymbolsMessage.Symbol(
                    node: 'constructor',
                    name: c.Name,
                    type: c.ToString(),
                    doc: DocStringFor(c, c.DeclaringType)
                ))
            case m=IMethod():
                return AddLexicalInfo(m, SymbolsMessage.Symbol(
                    node: 'method',
                    name: m.Name,
                    type: m.ToString(),
                    info: ToString(m.ReturnType),
                    doc: DocStringFor(m)
                ))
            case f=IField(FullName: name, Type: t):
                return AddLexicalInfo(f, SymbolsMessage.Symbol(
                    node: 'field',
                    name: name,
                    type: ToString(c),
                    doc: DocStringFor(f)
                ))
            case p=IProperty(FullName: name, Type: t):
                return AddLexicalInfo(p, SymbolsMessage.Symbol(
                    node: 'property',
                    name: name,
                    type: ToString(t),
                    doc: DocStringFor(p)
                ))
            case e=IEvent(FullName: name, Type: t):
                return AddLexicalInfo(e, SymbolsMessage.Symbol(
                    node: 'event',
                    name: name,
                    type: ToString(t),
                    doc: DocStringFor(e)
                ))
            case t=IType():
                return AddLexicalInfo(t, SymbolsMessage.Symbol(
                    node: 'itype',
                    type: ToString(t),
                    doc: DocStringFor(t)
                ))
            case te=ITypedEntity(Type: t):
                return AddLexicalInfo(te, SymbolsMessage.Symbol(
                    node: 'itypedentity',
                    type: ToString(te),
                    doc: DocStringFor(te)
                ))
            otherwise:
                return SymbolsMessage.Unknown

    private def AddLexicalInfo(entity as IEntity, info as SymbolsMessage.Symbol):
        intern = entity as IInternalEntity
        if intern:
            info.file = intern.Node.LexicalInfo.FileName
            info.line = intern.Node.LexicalInfo.Line
            info.column = intern.Node.LexicalInfo.Column

        return info

    def TooltipFor(node as Node):
        node = Resolve(node)
        if node is null:
            return "?"

        match node.Entity:
            case l=ILocalEntity(Name: name, Type: t):
                return FormatHoverText("${name} as ${ToString(t)} - ${node.GetAncestor[of Method]().FullName}", DocStringFor(l))
            case c=IConstructor():
                return FormatHoverText("${c.ToString()}", DocStringFor(c, c.DeclaringType))
            case m=IMethod():
                return FormatHoverText("${m.ToString()} as ${ToString(m.ReturnType)}", DocStringFor(m))
            case f=IField(FullName: name, Type: t):
                return FormatHoverText("${name} as ${ToString(t)}",  DocStringFor(f))
            case p=IProperty(FullName: name, Type: t):
                return FormatHoverText("${name} as ${ToString(t)}",  DocStringFor(p))
            case e=IEvent(FullName: name, Type: t):
                return FormatHoverText("${name} as ${ToString(t)}",  DocStringFor(e))
            case t=IType():
                return FormatHoverText(ToString(t), DocStringFor(t))
            case te=ITypedEntity(Type: t):
                return FormatHoverText(ToString(t), DocStringFor(te))
            otherwise:
                return "?"

    def FormatHoverText(header as string, docstring as string):
        result = " ${header} "
        if not string.IsNullOrEmpty(docstring):
            docstring = docstring.Replace("\n", "<br/>")
            result += "<br/><br/> ${docstring} <br/> "
        return result

    def DocStringFor(*entities as (IEntity)):
        for entity in entities:
            target = entity as IInternalEntity
            if target is not null and not string.IsNullOrEmpty(target.Node.Documentation):
                return target.Node.Documentation
        return null

    def NamespaceAt(node as Node) as INamespace:
        match EntityFor(node):
            case type=IType():
                return type
            case ITypedEntity(Type: type):
                return type
            case ns=INamespace():
                return ns
            otherwise:
                return null

    def EntityFor(node as Node) as IEntity:
        resolvedNode = Resolve(node)
        if resolvedNode is null:
            return null
        return resolvedNode.Entity

    def ToString(type as IType):
        match type:
            case IType(EntityType: EntityType.Error):
                return "?"
            case ct=ICallableType():
                return ct.GetSignature().ToString()
            otherwise:
                return type.FullName

    def Resolve(node as Node):
        _found = null
        _lookingFor = node.LexicalInfo
        VisitAllowingCancellation(_compileUnit)
        return _found

    _found as Node
    _lookingFor as LexicalInfo

    override def OnReferenceExpression(node as ReferenceExpression):
        MatchNode(node)

    override def LeaveMemberReferenceExpression(node as MemberReferenceExpression):
        MatchNode(node)

    override def OnSimpleTypeReference(node as SimpleTypeReference):
        MatchNode(node)

    private def MatchNode(node as Node):
        if node.LexicalInfo is _lookingFor:
            _found = node
            Cancel()
*/