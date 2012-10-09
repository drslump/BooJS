namespace BooJs.Compiler.Steps

import Boo.Lang.Compiler.Ast
import Boo.Lang.Compiler.Steps

class NormalizeGeneratorExpression(AbstractTransformerCompilerStep):
"""
    Converts generator expressions to a simpler format:

        ( i*2 for i in range(3) )
        ---
        { __gen = []; for i in range(3): __gen.push(i*2); return __gen }()
"""
    def LeaveGeneratorExpression(node as GeneratorExpression):
        # ( i*2 for i as int in range(3) )  =>  ( expression for declarations in iterator if filter )

        # Build a loop statement with the details from the generator
        loop = ForStatement()
        loop.Declarations = node.Declarations
        loop.Iterator = node.Iterator
        if not node.Filter:
            loop.Block = [|
                block:
                    _gen.push($(node.Expression))
            |].Body
        else:
            loop.Block = [|
                block:
                    _gen.push($(node.Expression)) if $(node.Filter.Condition)
            |].Body

        # Build the body of the anonymous function
        body = [|
            block:
                $loop
                return _gen
        |].Body

        # Replace the generator expression with the result of executing the anonymous function
        ReplaceCurrentNode([| { _gen as Array | $(body) }([]) |])
