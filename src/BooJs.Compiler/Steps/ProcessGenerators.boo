namespace BooJs.Compiler.Steps

import System
import Boo.Lang.Compiler(CompilerErrorFactory)
import Boo.Lang.Compiler.Ast
import Boo.Lang.Compiler.Steps
import Boo.Lang.Compiler.TypeSystem.Internal
import Boo.Lang.PatternMatching


class ProcessGenerators(AbstractTransformerCompilerStep):
"""
    Specialized step to process generators replacing Boo's one. Code is 
    transformed into a reentrant state machine, allowing to halt execution
    where a yield is found and resume later on from that same point.

    TODO: Support yielding inside conditional statements
"""
    static final REF_VALUE = ReferenceExpression(Name:'_value_')
    static final REF_ERROR = ReferenceExpression(Name:'_error_')
    static final REF_STATE = ReferenceExpression(Name:'_state_')
    static final REF_EXCEPT = ReferenceExpression(Name:'_except_')
    static final REF_ENSURE = ReferenceExpression(Name:'_ensure_')
    static final REF_STATEMACHINE = ReferenceExpression(Name:'statemachine')
    static final JUMP = GotoStatement(Label: REF_STATEMACHINE)

    class TransformGenerator(FastDepthFirstVisitor):
        [getter(States)]
        _states = StatementCollection()

        property State as int = 0

        Current as Block:
            get: return States[State]

        def constructor():
            CreateState()

        def CreateState():
            block = Block()
            States.Add(block)
            return len(States)-1

        def OnExpressionStatement(node as ExpressionStatement):
            Current.Add(node)

        def OnForStatement(node as ForStatement):
            Current.Add(node)

        def OnYieldStatement(node as YieldStatement):
            if node.GetAncestor(NodeType.IfStatement) or node.GetAncestor(NodeType.UnlessStatement):
                raise CompilerErrorFactory.NotImplemented(node, 'Yield is not currently supported inside if or unless statements')

            # Create a re-entry state
            nextstate = CreateState()

            # Setup jump to next state and return value
            Current.Add([| $REF_STATE = $nextstate |])
            Current.Add([| return $(node.Expression) |])

            # Continue in the re-entry state
            State = nextstate

        def OnReturnStatement(node as ReturnStatement):
            if node.GetAncestor(NodeType.IfStatement) or node.GetAncestor(NodeType.UnlessStatement):
                raise CompilerErrorFactory.NotImplemented(node, 'Return is not currently supported inside if or unless statements')

            # If it has an expression just handle as a yield
            if node.Expression:
                ynode = YieldStatement(node.LexicalInfo, Expression: node.Expression)
                OnYieldStatement(ynode)
            # Otherwise just create a new state where the generator terminates
            else:
                nextstate = CreateState()
                Current.Add([| $REF_STATE = $nextstate |])
                if State != nextstate - 1:
                    Current.Add(JUMP)
                State = nextstate

            # At this point we want to always stop the generator
            Current.Add([| raise Boo.STOP |])

        def OnWhileStatement(node as WhileStatement):
            # Loop always starts in a new step
            loopstate = CreateState()

            # Make sure the current state ends up in the loop one
            Current.Add([| $REF_STATE = $(loopstate) |])
            if State != loopstate - 1:
                Current.Add(JUMP)

            # Process the loop body
            State = loopstate
            Visit node.Block

            # Go back to the start of the loop to check if we have more iterations left
            Current.Add([| $REF_STATE = $(loopstate) |])
            Current.Add(JUMP)

            # Create new step for exiting the loop but don't use it yet
            exitstate = CreateState()

            # Check if we should skip the loop by negating the condition
            State = loopstate
            ifs = [|
                if not $(node.Condition):
                    $REF_STATE = $exitstate
                    $JUMP
            |]
            # Place it as the first statement in the loop state
            Current.Insert(0, ifs)

            # Continue in the exit step previously created
            State = exitstate

        def OnTryStatement(node as TryStatement):
            # A try block always initiates an state
            trystate = CreateState()

            # Make sure the current state ends up in the new one
            Current.Add([| $REF_STATE = $(trystate) |])
            if State != trystate - 1:
                Current.Add(JUMP)

            State = trystate

            # Register ensure block
            if node.EnsureBlock:
                Current.Add([| $(REF_ENSURE).push( $(BlockExpression(Body: node.EnsureBlock)) ) |])

            Visit node.ProtectedBlock

            # Create a new state for the exception handler
            exceptstate = CreateState()
            # Create a new state for exiting the try/except block
            afterstate = CreateState()

            # Skip the exception handler state
            Current.Add( [| $REF_STATE = $afterstate |] )
            if State != afterstate - 1:
                Current.Add(JUMP)

            if not node.ExceptionHandlers.IsEmpty:
                # Register the states covered by this protected block
                State = trystate
                Current.Insert(0, [| $(REF_EXCEPT).push($exceptstate) |])

                # Produce the exception handler
                State = exceptstate
                Visit node.ExceptionHandlers

                # Make sure we end up in the after state
                Current.Add([| $REF_STATE = $afterstate |])
                if State != afterstate - 1:
                    Current.Add(JUMP)                

            # Continue in the after state
            State = afterstate

            # Execute ensure block after we reach the end of the protected block
            if node.EnsureBlock:
                Current.Add( [| $(REF_ENSURE).pop()() |] )

        def OnUnlessStatement(node as UnlessStatement):
        """ We just include them in the current state, no special processing is performed
            currently. This means that neither yield nor return statements can be used inside.
        """
            super(node)
            Current.Add(node)

        def OnIfStatement(node as IfStatement):
        """ We just include them in the current state, no special processing is performed
            currently. This means that neither yield nor return statements can be used inside.
        """
            super(node)
            Current.Add(node)


    override def Run():
        if len(Errors) > 0:
            return
        Visit CompileUnit

    def HasTryStatement(node as Block) as bool:
        for st in node.Statements:
            match st:
                case TryStatement():
                    return true
                case wst=WhileStatement():
                    return HasTryStatement(wst.Block)
                case ist=IfStatement():
                    return HasTryStatement(ist.TrueBlock) or HasTryStatement(ist.FalseBlock)
                case bst=Block():
                    return HasTryStatement(bst)
                otherwise:
                    continue

        return false

    override def EnterMethod(node as Method):
    """ NOTE: We just handle methods. Boo will create generators in a separate method event for 
              block expressions. We will later remove them but since right now their body references
              the same node, we can just work with them and block expressions will be automatically
              updated too.
    """
        # Types should be already resolved so we can just check if it was flagged as a generator 
        entity = node.Entity as InternalMethod
        return entity and entity.IsGenerator

    override def LeaveMethod(node as Method):
        has_try = HasTryStatement(node.Body)

        # Transform the method body into a list of states
        transformer = TransformGenerator()
        transformer.OnBlock(node.Body)

        # Remove the original method contents
        node.Body.Clear()
        # Create a new local to keep the current step of the generator
        CodeBuilder.DeclareLocal(node, REF_STATE.Name, TypeSystemServices.IntType)
        node.Body.Add( CodeBuilder.CreateAssignment(REF_STATE, IntegerLiteralExpression(0)) )
        if has_try:
            CodeBuilder.DeclareLocal(node, REF_EXCEPT.Name, TypeSystemServices.ArrayType)
            CodeBuilder.DeclareLocal(node, REF_ENSURE.Name, TypeSystemServices.ArrayType)
            node.Body.Add( CodeBuilder.CreateAssignment(REF_EXCEPT, ListLiteralExpression()) )
            node.Body.Add( CodeBuilder.CreateAssignment(REF_ENSURE, ListLiteralExpression()) )

        # Add value check to first state
        valuecheck = [|
            if $REF_VALUE is not Boo.UNDEF or $REF_ERROR is not Boo.UNDEF:
                raise TypeError('Generator not started yet, unable to process sent value/error')
        |]
        (transformer.States[0] as Block).Insert(0, valuecheck)

        # Wrap the steps into a switch/case construct
        switch = MacroStatement(Name: 'switch')
        switch.Arguments.Add(REF_STATE)
        for idx as int, step as Block in enumerate(transformer.States):
            case = MacroStatement()
            case.Name = 'case'
            case.Arguments.Add(IntegerLiteralExpression(idx))
            case.Body = step
            switch.Body.Add(case)

        statemachine as Statement
        statemachine = [|
            # NOTE: To simplify we will raise the sent error from the top of the generator
            #       function and not from the current step. Unless real world scenarios show
            #       that it's desirable to have it raised from more exact locations, it doesn't
            #       seem to have a great value added in contrast to its cost.
            if $REF_ERROR:
                raise $REF_ERROR

            $switch

            # Set the state to an impossible value
            $REF_STATE = -1
        |]

        # Wrap the state machine to support exception handling
        if has_try:
            statemachine = [|
                try:
                    $statemachine
                except:
                    if $(REF_EXCEPT).length:
                        $REF_ERROR = null  # Make sure any reported error is removed
                        $REF_STATE = $(REF_EXCEPT).pop()
                        goto statemachine

                    # Position the generator to the terminating state
                    $REF_STATE = -1

                    # Ensure all finally blocks are executed
                    while $(REF_ENSURE).length:
                        $(REF_ENSURE).pop()()

                    # Re-raise the exception
                    raise _ex_
            |]

        # Make the method return a generator
        generator = [|
            return Boo.generator do($REF_VALUE, $REF_ERROR):
                :statemachine
                $statemachine
                # If the execution reaches the end we want to notify the stop of the iteration
                raise Boo.STOP
        |]

        node.Body.Add(generator)
