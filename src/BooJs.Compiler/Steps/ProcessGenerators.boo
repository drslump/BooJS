namespace BooJs.Compiler.Steps

import System
import Boo.Lang.Compiler.Ast
import Boo.Lang.Compiler.Steps
import Boo.Lang.Compiler.TypeSystem.Internal

class ProcessGenerators(AbstractTransformerCompilerStep):
"""
    Specialized step to process generators to replace Boo's original one.

    TODO: Step to run just before this one that converts all loops to while ones
          if the method is a generator

    TODO: In order to support nested generators we most probably will
          need to keep some kind to state

"""
    _state = 0
    _states as StatementCollection
    _current as Block

    override def Run():
        if len(Errors) > 0:
            return
        Visit CompileUnit

    override def EnterMethod(node as Method):
        print "EnterMethod"

        # Types should be already resolved so we can just check if it was flagged as a generator 
        entity as InternalMethod = node.Entity
        if not entity.IsGenerator:
            return false
        # If it's a generator inside another one stop with an error
        elif _state:
            raise 'Nested generators are not supported'

        print 'GENERATOR: ', node
        
        # Create a collection to hold the states (case X: ...)
        _states = StatementCollection()
        # Start by defining the first state
        CreateState()

        return true

    def LeaveMethod(node as Method):

        placeholder = [| 'PLACEHOLDER' |]

        # We convert the function into a factory by wrapping the contents in 
        # closure and handling it to a runtime helper method.
        # Since we are creating a closure but we already defined the locals
        # above we'll let the Javascript engine take care of keeping the state.
        # TODO: Can't we simply use: return {next:function(){ ... }  ???
        closure = [| 
            $(CreateDeclaration('__state', 1))
            return Boo.generator def():
                # Wrap the statements in a loop so we can use continue/break inside
                # in order to perform a goto. We also need to label to it since we
                # are going to use also a switch statement below.
                :__loop
                while true:
                    # Setup a switch statement to allow jumping to a specific statement 
                    # when the closure is executed.
                    # NOTE: We define switch as if it was a macro since Boo doesn't have it
                    switch __state:
                        $placeholder

                        # Just exit from the switch statement in the last step
                        case 0:
                            break
                        # Check that nothing wrong happened when executing the code
                        default:
                            raise 'Boo.Js: invalid state in state machine #' + __state

                    # Notify the runtime helper that the generator has finished
                    return Boo.STOP
        |]

        print closure
        print '----------'

        # The placeholder structure is Block(Statements=[PLACEHOLDER,])
        placeholder_st = placeholder.ParentNode as Statement
        placeholder_block = placeholder_st.ParentNode as Block
        statements = placeholder_block.Statements

        # Insert the instrumented statements in the placeholder
        index = statements.IndexOf(placeholder_st)
        statements.RemoveAt(index)
        for stmt in _states:
            statements.Insert(index, stmt)
            index++

        print closure

        # Replace the body of the method with the instrumented version
        node.Body.Statements = closure.Statements

        # Reset the processor state
        ResetProcessor()


    def ResetProcessor():
        _state = 0
        _states = null
        _current = null

    def Add(node as Expression):
        _current.Add(node)

    def Add(node as Statement):
        _current.Add(node)

    def CreateState() as Block:
        _state++
        case = MacroStatement(Name: 'case', Body: Block())
        case.Arguments.Add([| $_state |])
        _states.Add(case)
        _current = case.Body

    def OnExpressionStatement(node as ExpressionStatement):
        print "OnExpressionStatement", node
        return unless _state
        Add(node)

    def OnDeclarationStatement(node as DeclarationStatement):
        return unless _state
        Add(node)

    def OnUnpackStatement(node as UnpackStatement):
        return unless _state
        Add(node)

    def OnYieldStatement(node as YieldStatement):
        return unless _state

        # Point to the next step
        Add([| __step = $(_state + 1) |])

        # Return the value
        Add([| return $(node.Expression) |])

        # Setup the next step entry point
        CreateState()


    def EnterForStatement(node as ForStatement):
        return false unless _state
        # TODO: If there is no yield in the loop we can process it normally
        #       We need a `yield` finder since we will also need this for If
        return true

    def OnForStatement(node as ForStatement):
    """ To simplify the generator we convert the for loops to while ones in a 
        previous step. In the case of the `for x in y` style we just obtain 
        the keys as an array before starting the loop and then just iterate over it.
        Note: when issuing a `continue` in a for loop is expected that the increment
        is executed, thus the increment should be evaluated before the condition, and
        it's not clear how to do this except for this which is quite verbose :(
        
          done = false
          while (true):
            if not done:
              increment++
              done = true
            if not condition:
              break
            ...

    """
        return unless _state

        raise 'For loops are not implemented for generators'
        /*
        if node.OrBlock:
            raise 'Or blocks are not supported in generators'
        if node.ThenBlock:
            raise 'Then blocks are not supported in generators'
        */

    def EnterWhileStatement(node as WhileStatement):
        # TODO: If there is no yield in the loop we can process it normally
        #       We need a `yield` finder since we will also need this for If

        return unless _state

        # New step to check the condition
        CreateState()

        initial_state = _state

        # Create the loop condition and a placeholder to later fill the final step
        final_step_holder = [| __step = null |]
        cond = [| 
            if not ($(node.Condition)):
                $final_step_holder
                goto __loop
        |]
        Add cond

        # Process the contents of the loop
        Visit node.Block

        # Enter a new state, if reached we go back to check the loop condition
        CreateState
        Add [| __step = $initial_state |]
        Add( GotoStatement(Label:[| __loop |]) )

        # This state is now outside the loop
        CreateState
        # Now we know the state where the loop ends
        final_step_holder.Right = [| $_state |]

        return false

    #def OnIfStatement(node as IfStatement):
    #    Visit(node)
        




    def CreateDeclaration(name as string, initializer as int):
        return DeclarationStatement(Declaration(Name: name), [| $initializer |])

    def EnterMacroStatement(node as MacroStatement):
        print 'MACRO', node




/*
    def CreateLocal(method as Method, name as string, initializer):

        def ProcessStatements(statements as StatementCollection):
            for stmt in statements: 
                print '/*', stmt.NodeType, '*/'

                # Non flow control statements can be placed in the current step
                # without problems
                if stmt.NodeType == NodeType.ExpressionStatement:
                    Visit(stmt)

                # Once we reach a yield we prepare to return the value
                elif stmt.NodeType == NodeType.YieldStatement:
                    # Point to the next step
                    step++
                    WriteIndented '$step$ = ' + step + ';'
                    WriteLine

                    # Return the value
                    WriteIndented 'return '
                    Visit( (stmt as YieldStatement).Expression )
                    WriteLine ';'

                    # Setup the next step entry point
                    Dedent
                    WriteIndented 'case ' + step + ':'
                    WriteLine
                    Indent

                elif stmt.NodeType == NodeType.WhileStatement:
                    # New step to check the condition
                    step++
                    cond_step = step
                    Dedent
                    WriteIndented 'case ' + step + ':'
                    WriteLine
                    Indent
                    
                    # Check if the reversed condition applies
                    WriteIndented 
                    Write 'if (!('
                    Visit( (stmt as WhileStatement).Condition )
                    WriteIndented
                    Write ')) {'
                    WriteLine
                    Indent
                    # Exit the while loop
                    # TODO: This surely breaks with nested flows
                    WriteIndented '$step$ = ' + (step+1) + ';'
                    WriteLine
                    WriteIndented 'continue $loop$;'
                    WriteLine
                    Dedent
                    WriteIndented
                    Write '}'
                    WriteLine

                    ProcessStatements( (stmt as WhileStatement).Block.Statements )

                    step++
                    Dedent
                    WriteIndented 'case ' + step + ':'
                    WriteLine
                    Indent
                    WriteIndented '$step$ = ' + cond_step + ';'
                    WriteLine
                    WriteIndented 'goto $step$;'

        ProcessStatements(m.Body.Statements)
*/
