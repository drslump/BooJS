namespace BooJs.Compiler.Steps

import Boo.Lang.Compiler.Ast
import Boo.Lang.Compiler.Steps

class ProcessTry(AbstractTransformerCompilerStep):
"""
    Process try/except/ensure statements

    The main difference between Boo and JS is that in Boo we can define multiple except
    blocks and also offers a failure block. This modification will reduce the number of excepts
    to just one, including the additional branching as if conditions inside it.

        try:
            raise 'error'
        except a == b:
            print 'Exception cached when a==b'
        except as Exception:
            print 'Exception catched'
        except e as Exception:
            print e.ToString()
        except e:
            print e.message
        failure:
            print 'failed (but not catched)'
        ensure:
            pass

        --- gets converted to ---

        try:
            raise 'error'
        except __e:
            if a == b:                  # except a==b
                print 'Exception cached when a==b'
            elif __e isa Exception:     # except as Exception
                print 'Exception catched'
            elif __e isa Exception:     # except e as Exception
                e = __e
                print e.ToString()
            elif true:                  # except e
                e = __e
                print e.message
            else:                       # failure
                print 'failed (but not catched)'
                raise __e
        ensure:
            print 'run if all ok or not catched'
"""

    # Keep track of enclosing method
    protected _method as Method
    
    def OnMethod(node as Method):
        last = _method
        _method = node
        super(node)
        _method = last

    def OnTryStatement(node as TryStatement):

        # Add failure as the last handler if present
        if node.FailureBlock:
            handler = ExceptionHandler(node.FailureBlock.LexicalInfo)
            handler.Block = node.FailureBlock
            # Rethrow again the error
            handler.Block.Add([| raise __e |])
            node.ExceptionHandlers.Add(handler)
            node.FailureBlock = null

        if len(node.ExceptionHandlers):
            # Generate the parent handler to capture the exception in a variable
            handler = ExceptionHandler()
            handler.Declaration = Declaration(Name:'__e')
            block = handler.Block

            for hdl in node.ExceptionHandlers:

                cond = IfStatement(hdl.LexicalInfo)
                block.Add(cond)

                # except e as Exception
                if hdl.Declaration and hdl.Declaration.Name and hdl.Declaration.Type:
                    _method.Locals.Add(Local(hdl.Declaration, false))
                    reference = ReferenceExpression(hdl.Declaration.LexicalInfo, Name: hdl.Declaration.Name)
                    cond.Condition = [| __e isa $(hdl.Declaration.Type) and $reference = __e |]
                # except e
                elif hdl.Declaration and hdl.Declaration.Name:
                    _method.Locals.Add(Local(hdl.Declaration, false))
                    reference = ReferenceExpression(hdl.Declaration.LexicalInfo, Name: hdl.Declaration.Name)
                    cond.Condition = [| $reference = __e |]
                # except as Exception
                elif hdl.Declaration and hdl.Declaration.Type:
                    cond.Condition = [| __e isa $(hdl.Declaration.Type) |]
                else:
                    cond.Condition = [| true |]

                # update the condition if we are filtering
                if hdl.FilterCondition:
                    cond.Condition = [| $(cond.Condition) and $(hdl.FilterCondition) |]

                # Add the statements to the condition
                cond.TrueBlock = hdl.Block
                block = cond.FalseBlock = Block()


            # Replace original handlers with the generated one
            node.ExceptionHandlers.Clear()
            node.ExceptionHandlers.Add(handler)

        # Recurse into the single handler and the ensure block
        Visit node.ProtectedBlock
        Visit node.ExceptionHandlers
        Visit node.EnsureBlock

    override def OnRaiseStatement(node as RaiseStatement):
        # If no exception is given just launch the captured one
        if not node.Exception:
            node.Exception = [| __e |]
