namespace BooJs.Compiler.Steps

import Boo.Lang.Compiler.Ast
import Boo.Lang.Compiler.Steps

class NormalizeClosures(AbstractFastVisitorCompilerStep):
"""
    Detect locals inside closures and assign them to the parent method
"""

    def OnMethod(m as Method):
        # TODO: Improve the algorithm to support all cases
        # TODO: Handle closures passed in as arguments to method calls
        FindClosureLocals(m.Body, m)

    private def FindClosureLocals(block as Block, method as Method):
    """ Find assignments of \$locals.\$<name> to define these as local variables """
        for st in block.Statements:
            if st isa Block:
                FindClosureLocals(st, method)
            #elif st isa Method:
            #    FindClosureLocals((st as Method).Body, st as Method)
            elif st isa BlockExpression:
                FindClosureLocals((st as BlockExpression).Body, method)
            elif st isa ExpressionStatement:
                es = st as ExpressionStatement
                if es.Expression isa BinaryExpression:
                    be = es.Expression as BinaryExpression

                    # Process closures assigned to variables
                    if be.Right isa BlockExpression:
                        FindClosureLocals((be.Right as BlockExpression).Body, method)

                    if be.Operator == BinaryOperatorType.Assign:
                        name = be.Left.ToString()
                        if /^\$locals\.\$/.IsMatch(name):
                            name = name.Substring(len('$locals.$'))

                            # Check if it's been defined as a parameter to the method
                            parent = block.ParentNode
                            while parent and not parent isa BlockExpression and not parent isa Method:
                                parent = parent.ParentNode
                            if parent isa BlockExpression:
                                params = (parent as BlockExpression).Parameters
                            elif parent isa Method:
                                params = (parent as Method).Parameters
                            else:
                                raise 'Expected a parent Method or BlockExpression'

                            if params.Contains({param as ParameterDeclaration| param.Name == name}):
                                continue

                            CodeBuilder.DeclareLocal(method, name, GetType(be.Left))
