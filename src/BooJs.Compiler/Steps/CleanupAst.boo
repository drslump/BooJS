namespace BooJs.Compiler.Steps

import Boo.Lang.Compiler
import Boo.Lang.Compiler.Ast
import Boo.Lang.Compiler.Steps

import Boo.Lang.Environments
import Boo.Lang.Compiler.TypeSystem.Services.RuntimeMethodCache as BooRuntimeMethodCache
import BooJs.Compiler.TypeSystem(RuntimeMethodCache)
import BooJs.Lang.Extensions


class CleanupAst(AbstractTransformerCompilerStep):
"""
    Clean up the AST before printing it:

        - Remove unneeded nodes
        - Convert builtins and runtime references
        - Apply transform attributes
"""
    [getter(MethodCache)]
    private _methodCache as RuntimeMethodCache

    [getter(BooMethodCache)]
    private _booMethodCache as BooRuntimeMethodCache


    protected def GetAttribute[of T(System.Attribute)](node as Node) as T:
        entity = node.Entity as TypeSystem.IExternalEntity
        return (GetAttribute[of T](entity) if entity else null as T)

    protected def GetAttribute[of T(System.Attribute)](entity as TypeSystem.IExternalEntity) as T:
        return System.Attribute.GetCustomAttribute(entity.MemberInfo, typeof(T))

    protected def IsBuiltin(node as Node) as bool:
        entity = node.Entity as TypeSystem.Reflection.ExternalType
        return false if not entity
        return true if entity.Type is TypeSystemServices.BuiltinsType
        return entity.DeclaringType == TypeSystemServices.BuiltinsType


    def Initialize(context as CompilerContext):
        super(context)

        _methodCache = EnvironmentProvision[of RuntimeMethodCache]()
        _booMethodCache = EnvironmentProvision[of BooRuntimeMethodCache]()

    def EnterModule(node as Module):
        if node.Name == 'CompilerGenerated':
            RemoveCurrentNode()
            return false

        return true

    def EnterClassDefinition(node as ClassDefinition):
        if node.Name == 'CompilerGeneratedExtensions':
            RemoveCurrentNode()
            return false
        return true

    def EnterMethod(node as Method):
        # Filter locals to remove duplicates
        found = ['$locals']
        remove = List[of Local]()
        for local in node.Locals:
            if local.Name in found:
                remove.Push(local)
            else:
                found.Push(local.Name)

        for local in remove:
            node.Locals.Remove(local)

        return true

    def OnExpressionStatement(node as ExpressionStatement):
        # Ignore the assignment of locals produced by closures instrumentation
        be = node.Expression as BinaryExpression
        if be and be.Operator == BinaryOperatorType.Assign and be.Left.ToString() == '$locals':
            RemoveCurrentNode
            return

        Visit node.Expression

    def OnReferenceExpression(node as ReferenceExpression):
        attr = GetAttribute[of JsAliasAttribute](node)
        if attr:
            refexp = ReferenceExpression(attr.Value, LexicalInfo: node.LexicalInfo)
            Visit refexp
            ReplaceCurrentNode refexp
            return

        # Check for builtins references
        if IsBuiltin(node):
            name = node.Name.Split(char('.'))[-1]
            ReplaceCurrentNode [| Boo.$(ReferenceExpression(Name: name)) |].withLexicalInfoFrom(node)
            return

        # Members of the module are placed in the top scope
        ientity = node.Entity as TypeSystem.IMember
        if ientity and ientity.DeclaringType and ientity.DeclaringType.IsClass and ientity.DeclaringType.IsFinal:
            name = node.Name.Split(char('.'))[-1]
            ReplaceCurrentNode [| $(ReferenceExpression(Name: name)) |].withLexicalInfoFrom(node)
            return

        # TODO: Check name for invalid chars?


    def OnMemberReferenceExpression(node as MemberReferenceExpression):
        attr = GetAttribute[of JsAliasAttribute](node)
        if attr:
            refexp = ReferenceExpression(attr.Value, LexicalInfo: node.LexicalInfo)
            Visit refexp
            ReplaceCurrentNode refexp
            return

        # Convert from `$locals.$variable` to `variable`
        if node.Target.ToString() == '$locals':
            refexp = ReferenceExpression(node.Name[1:], LexicalInfo: node.LexicalInfo)
            Visit refexp
            ReplaceCurrentNode refexp
            return

        # Members of the module are placed in the top scope
        ientity = node.Target.Entity as TypeSystem.Internal.AbstractInternalType
        if node.Target.IsSynthetic and ientity and ientity.IsClass and ientity.IsFinal:
            refexp = ReferenceExpression(node.Name, LexicalInfo: node.LexicalInfo)
            Visit refexp
            ReplaceCurrentNode refexp
            return

        # Check for builtins references
        if IsBuiltin(node.Target):
            node.Target = [| Boo |].withLexicalInfoFrom(node.Target)

        # TODO: Check if the property name is a valid javascript ident and if not use ['xxx'] syntax

        super(node)

    def OnMethodInvocationExpression(node as MethodInvocationExpression):
        # Convert JsTransform attribute metadata to an AST annotation
        if not node.ContainsAnnotation('JsTransform'):
            attr = GetAttribute[of JsTransformAttribute.AsmTransformAttribute](node.Target)
            if attr:
                node.Annotate('JsTransform', attr.Value)

        super(node)

    def OnUnlessStatement(node as UnlessStatement):
    """ Negate the condition to convert it into a simple if statement
    """
        ifst = IfStatement(LexicalInfo: node.LexicalInfo)
        ifst.Condition = UnaryExpression(
            Operator: UnaryOperatorType.LogicalNot,
            Operand: node.Condition,
            LexicalInfo: node.LexicalInfo
        )
        ifst.TrueBlock = node.Block

        ReplaceCurrentNode ifst

