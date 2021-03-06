namespace BooJs.Lang.Extensions

from System import AttributeUsageAttribute, AttributeTargets, ArgumentNullException, Enum

from Boo.Lang.Compiler import AbstractAstAttribute, TypeSystem
from Boo.Lang.Compiler.Ast import *
from Boo.Lang.Parser import BooParser


[AttributeUsage(AttributeTargets.All ^ AttributeTargets.Assembly)]
class TransformAttribute(AbstractAstAttribute):
"""
    Allows to transform the AST of the annotated member when referencing it.

    [Transform( parseInt($2 / $1) )]
    def int_divide(a as int, b as int):
        pass

    int_divide(10, Math.floor(val))
    ---
    parseInt(Math.floor(val) / 10)
"""
    class TransformAsmAttribute(System.Attribute):
        public Type as string
        public Ast as string

        def constructor(type as string, ast as string):
            Type = type
            Ast = ast

    internal class PlaceholderResolver(DepthFirstTransformer):
    """ Looks for splice expressions, replacing them with the given arguments
        based on the number used. 0 references the target while 1-N reference
        the arguments.
    """
        _target as Expression
        _args as ExpressionCollection

        def constructor(target as Expression, args as ExpressionCollection):
            _target = target
            _args = args

        def OnSpliceExpression(node as SpliceExpression):
            number = node.Expression as IntegerLiteralExpression
            return if not number
            idx = number.Value
            if idx == 0:
                if _target isa MemberReferenceExpression:
                    ReplaceCurrentNode((_target as MemberReferenceExpression).Target)
                else:
                    ReplaceCurrentNode _target
            elif idx > 0 and idx <= len(_args):
                ReplaceCurrentNode _args[idx - 1]
            else:
                raise 'Invalid placeholder number ' + idx


    expr as Expression

    static supported = {
        NodeType.StringLiteralExpression: typeof(StringLiteralExpression),
        NodeType.IntegerLiteralExpression: typeof(IntegerLiteralExpression),
        NodeType.DoubleLiteralExpression: typeof(DoubleLiteralExpression),
        NodeType.UnaryExpression: typeof(UnaryExpression),
        NodeType.BinaryExpression: typeof(BinaryExpression),
        NodeType.ReferenceExpression: typeof(ReferenceExpression),
        NodeType.MemberReferenceExpression: typeof(MemberReferenceExpression),
        NodeType.MethodInvocationExpression: typeof(MethodInvocationExpression),
        NodeType.SlicingExpression: typeof(SlicingExpression),
        NodeType.ConditionalExpression: typeof(ConditionalExpression),
    }

    def constructor(expr as Expression):
        if expr is null:
            raise ArgumentNullException('expr')
        self.expr = expr

    override def Apply(node as Node):
        anode = node as INodeWithAttributes
        if not anode:
            raise 'Unsupported attribute target: ' + node.NodeType

        if expr.NodeType not in supported:
            raise 'Transforms to type {0} are not supported' % (expr.NodeType, )

        # Attach an attribute with the serialization
        attr = Attribute()
        attr.Name = self.GetType().FullName + '.TransformAsmAttribute'
        attr.Arguments.Add(StringLiteralExpression(expr.NodeType.ToString()))
        attr.Arguments.Add(StringLiteralExpression(expr.ToCodeString()))

        anode.Attributes.Add(attr)

    static def HasAttribute(node as Node) as bool:
        entity = node.Entity as TypeSystem.IExternalEntity
        if entity and entity.MemberInfo:
            attr = System.Attribute.GetCustomAttribute(entity.MemberInfo, typeof(TransformAsmAttribute), false)
        return attr is not null

    static def Deserialize(node as Node) as Node:
        entity = node.Entity as TypeSystem.IExternalEntity
        raise 'Node does not contain the transform attribute metadata' if not entity

        attr = System.Attribute.GetCustomAttribute(entity.MemberInfo, typeof(TransformAsmAttribute), false)
        return Deserialize(attr)

    static def Deserialize(attr as TransformAsmAttribute) as Node:
        type as NodeType = Enum.Parse(NodeType, attr.Type)
        if not type or type not in supported:
            raise 'Unsupported Transform serialized node type: {0}' % (attr.Type,)

        # TODO: Cache deserialization results

        # Use Boo's Parser to obtain an AST back from the attribute
        cu = BooParser.ParseString('code', attr.Ast)
        est = cu.Modules[0].Globals.FirstStatement as ExpressionStatement
        # Plain references come as a Macro statement
        if not est:
            mst = cu.Modules[0].Globals.FirstStatement as MacroStatement
            return ReferenceExpression(mst.Name)

        return est.Expression

    static def Resolve(ast as Node, target as Expression, args as ExpressionCollection) as Node:
        # Parse the expression replacing placeholders
        resolver = PlaceholderResolver(target, args)
        ast.LexicalInfo = target.LexicalInfo
        resolver.Visit(ast)
        return ast

    static def Resolve(target as Expression, args as ExpressionCollection) as Node:
        ast = Deserialize(target)
        return Resolve(ast, target, args)
