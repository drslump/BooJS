namespace BooJs.Compiler.Steps

from Boo.Lang.Compiler.Ast import *
from Boo.Lang.Compiler.Steps import AbstractTransformerCompilerStep


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
        except _ex_:
            if a == b:                  # except a==b
                print 'Exception cached when a==b'
            elif _ex_ isa Exception:     # except as Exception
                print 'Exception catched'
            elif _ex_ isa Exception:     # except e as Exception
                e = _ex_
                print e.ToString()
            elif true:                  # except e
                e = _ex_
                print e.message
            else:                       # failure
                print 'failed (but not catched)'
                raise _ex_
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
            handler.Block.Add([| raise _ex_ |])
            node.ExceptionHandlers.Add(handler)
            node.FailureBlock = null

        if len(node.ExceptionHandlers):
            # Generate the parent handler to capture the exception in a variable
            handler = ExceptionHandler()
            handler.Declaration = Declaration(Name:'_ex_')
            block = handler.Block

            for hdl in node.ExceptionHandlers:

                cond = IfStatement(hdl.LexicalInfo)
                block.Add(cond)

                # except e as Exception
                if hdl.Declaration and hdl.Declaration.Name and hdl.Declaration.Type:
                    _method.Locals.Add(Local(hdl.Declaration, false))
                    reference = ReferenceExpression(hdl.Declaration.LexicalInfo, Name: hdl.Declaration.Name)
                    cond.Condition = [| _ex_ isa $(hdl.Declaration.Type) and $reference = _ex_ |]
                # except e
                elif hdl.Declaration and hdl.Declaration.Name:
                    _method.Locals.Add(Local(hdl.Declaration, false))
                    reference = ReferenceExpression(hdl.Declaration.LexicalInfo, Name: hdl.Declaration.Name)
                    cond.Condition = [| $reference = _ex_ |]
                # except as Exception
                elif hdl.Declaration and hdl.Declaration.Type:
                    cond.Condition = [| _ex_ isa $(hdl.Declaration.Type) |]
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
            node.Exception = [| _ex_ |]
