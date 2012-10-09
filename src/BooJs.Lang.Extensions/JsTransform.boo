namespace BooJs.Lang.Extensions

import System
import Boo.Lang.Compiler
import Boo.Lang.Compiler.Ast

[AttributeUsage(AttributeTargets.Method | AttributeTargets.Constructor | AttributeTargets.Class)]
class JsTransformAttribute(AbstractAstAttribute):
""" Allows to transform the AST of the annotated member

    [JsTransform( parseInt($2 / $1) )]
    def int_divide(a as int, b as int):
        pass

    int_divide(10, Math.floor(val))
    ---
    parseInt(Math.floor(val) / 10)
"""
    class AsmTransformAttribute(System.Attribute):
        public Value as string
        def constructor(v as string):
            Value = v


    expr as Expression

    def constructor(expr as Expression):
        if expr is null:
            raise ArgumentNullException('expr')
        self.expr = expr

    override def Apply(node as Node):
        m = node as Method
        if not m:
            raise 'Node not supported'

        attr = Ast.Attribute()
        attr.Name = 'BooJs.Lang.Extensions.JsTransformAttribute.AsmTransform'
        if expr isa StringLiteralExpression:
            attr.Arguments.Add(expr)
        else:
            code = expr.ToCodeString()
            code = /\$\(?(\d+)\)?/.Replace(code, "$$$1")
            attr.Arguments.Add(StringLiteralExpression(code))

        m.Attributes.Add(attr)
