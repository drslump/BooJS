namespace BooJs.Compiler.Steps

from Boo.Lang.Compiler import CompilerErrorFactory
from Boo.Lang.Compiler.Ast import *
from Boo.Lang.Compiler.Steps import AbstractTransformerCompilerStep
from Boo.Lang.Compiler.TypeSystem.Internal import *
from Boo.Lang.PatternMatching import *


class ProcessGenerators(AbstractTransformerCompilerStep):
"""
    Specialized step to process generators replacing Boo's one. Code is 
    transformed into a reentrant state machine, allowing to halt execution
    where a yield is found and resume later on from that same point.

    While in Boo yield is an statement the transformed code supports sending
    values and errors from the outer context, making them work as coroutines
    and allowing advanced use cases like Async/Await.
    Every initialized generator accepts two arguments (_value_ and _error_),
    that can be used to communicate with it, if an _error_ is given the
    generator will raise it. For _value_ there is no direct support but
    it can be used by macros to implement complex patterns.

    The generated code is convoluted but pretty fast on modern browsers, it
    runs roughly at half the speed of an user land forEach implementation
    and about 70% the speed of Firefox's native generators.
    http://jsperf.com/boojs-generator-loop

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

            # Add value check to first state
            valuecheck = [|
                if $REF_VALUE is not Boo.UNDEF or $REF_ERROR is not Boo.UNDEF:
                    raise TypeError('Generator not started yet, unable to process sent value/error')
            |]
            Current.Add(valuecheck)

        def CreateState():
            block = Block()
            States.Add(block)
            return len(States)-1

        def OnYieldStatement(node as YieldStatement):
            # Create a re-entry state
            nextstate = CreateState()

            # Setup jump to next state and return value
            Current.Add([| $REF_STATE = $nextstate |])
            Current.Add([| return $(node.Expression) |])

            # Continue in the re-entry state
            State = nextstate

        def OnReturnStatement(node as ReturnStatement):
            # Make sure the generator is stopped even if re-entered
            Current.Add([| $REF_STATE = -1 |])
            Current.Add(node)

        def OnRaiseStatement(node as RaiseStatement):
            # Make sure the generator is stopped even if re-entered
            Current.Add([| $REF_STATE = -1 |])
            Current.Add(node)

        def OnExpressionStatement(node as ExpressionStatement):
            Current.Add(node)

        def OnForStatement(node as ForStatement):
            # We assume that loops with yields where converted to while statements
            Current.Add(node)

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
            # A try block always initiates an state. This simplifies a bit the
            # mapping of protected blocks.
            trystate = CreateState()

            # Make sure the current state ends up in the new one
            # TODO: Is this ever needed?
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

            unless node.ExceptionHandlers.IsEmpty:
                # Register the states covered by this protected block
                State = trystate
                Current.Insert(0, [| $(REF_EXCEPT).push($exceptstate) |])

                # Produce the exception handler
                State = exceptstate
                # HACK: Assign the value to the global ex holder
                Current.Add([| _ex_ = $(REF_VALUE) |])

                Visit node.ExceptionHandlers

                # HACK: If we reached the end add a new guard so we pop it in afterstate
                #       This avoids creating a specific state for the it.
                Current.Add([| $(REF_EXCEPT).push(-1) |])

                # Make sure we end up in the after state
                Current.Add([| $REF_STATE = $afterstate |])
                if State != afterstate - 1:
                    Current.Add(JUMP)

                # Remove the guard once we are out of the except block
                State = afterstate
                Current.Add([| $(REF_EXCEPT).pop() |])

            # Continue in the after state
            State = afterstate

            # Execute ensure block after we reach the end of the protected block
            if node.EnsureBlock:
                Current.Add( [| $(REF_ENSURE).pop()() |] )

            # We need to make absolutely sure we jump out to a clean state
            # NOTE: nested try/except blocks may have created new states
            nextstate = CreateState()
            Current.Add([| $REF_STATE = $nextstate |])
            if State != nextstate - 1:
                Current.Add(JUMP)

            State = nextstate

        def OnUnlessStatement(node as UnlessStatement):
            # We just convert to a negated IfStatement
            ifnode = IfStatement(node.LexicalInfo)
            ifnode.Condition = [| not $(node.Condition) |]
            ifnode.TrueBlock = node.Block
            Visit(ifnode)

        def OnIfStatement(node as IfStatement):
            # Optimize common case of simple if without else clause
            if not node.FalseBlock or node.FalseBlock.IsEmpty:
                placeholder = ExpressionStatement()
                block = [|
                    if not $(node.Condition):
                        $placeholder
                        $JUMP
                |]
                Current.Add(block)

                # Dump the conditional block
                Visit(node.TrueBlock)

                # Create an exit state and setup the jump
                exitstate = CreateState()
                placeholder.Expression = [| $REF_STATE = $exitstate |]
                State = exitstate
                return

            truestate = CreateState()
            falsestate = CreateState()
            block = [|
                if $(node.Condition):
                    $REF_STATE = $truestate
                    $JUMP
                else:
                    $REF_STATE = $falsestate
                    $JUMP
            |]
            Current.Add(block)

            State = truestate
            Visit(node.TrueBlock)
            truestate = State

            State = falsestate
            Visit(node.FalseBlock)
            falsestate = State

            exitstate = CreateState()

            # Point true and false blocks to the exit
            State = truestate
            Current.Add([| $REF_STATE = $exitstate |])
            if State != exitstate - 1:
                Current.Add(JUMP)
            State = falsestate
            Current.Add([| $REF_STATE = $exitstate |])
            if State != exitstate - 1:
                Current.Add(JUMP)

            # Continue in the exit state
            State = exitstate


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
    """ NOTE: We just handle methods. Boo will create generators in a separate method even for 
              block expressions. We will later remove them but since right now their body references
              the same node, we can just work with them and block expressions will be automatically
              updated too.
    """
        # Types should be already resolved so we can just check if it was flagged as a generator 
        entity = node.Entity as InternalMethod
        return entity and entity.IsGenerator

    override def LeaveMethod(node as Method):
        has_try = HasTryStatement(node.Body)

        # Transform the method body into a state machine
        transformer = TransformGenerator()
        transformer.OnBlock(node.Body)

        # Remove the original method contents
        node.Body.Clear()
        # Create a new local to keep the current state of the generator
        CodeBuilder.DeclareLocal(node, REF_STATE.Name, TypeSystemServices.IntType)
        node.Body.Add( CodeBuilder.CreateAssignment(REF_STATE, IntegerLiteralExpression(0)) )
        if has_try:
            CodeBuilder.DeclareLocal(node, REF_EXCEPT.Name, TypeSystemServices.ArrayType)
            CodeBuilder.DeclareLocal(node, REF_ENSURE.Name, TypeSystemServices.ArrayType)
            node.Body.Add( CodeBuilder.CreateAssignment(REF_EXCEPT, ListLiteralExpression()) )
            node.Body.Add( CodeBuilder.CreateAssignment(REF_ENSURE, ListLiteralExpression()) )

        # Wrap the steps into a switch/case construct
        # TODO: Use Boo's native switch construct
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
            #       function and not from the current state. Unless real world scenarios show
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
                    # HACK: Assign the exception to _value_ so we can work with it
                    #       in a matched except block or override it from the ensures
                    $REF_VALUE = _ex_

                    if $(REF_EXCEPT).length:
                        $REF_ERROR = null  # Make sure any reported error is removed
                        $REF_STATE = $(REF_EXCEPT).pop()
                        goto statemachine

                    # Position the generator to the terminating state
                    $REF_STATE = -1

                    # Ensure all finally blocks are executed before exiting
                    # NOTE: Any error raised inside an ensure block overrides the previous
                    while $(REF_ENSURE).length:
                        try:
                            $(REF_ENSURE).pop()()
                        except:
                            $REF_VALUE = _ex_

                    # Re-raise the exception
                    raise $REF_VALUE
            |]

        # Make the method return a generator
        generator = [|
            # Wrap the state machine with the runtime helper
            return Boo.generator do($REF_VALUE, $REF_ERROR):
                :statemachine
                $statemachine
                # If the execution reaches the end we want to notify the stop of the iteration
                raise Boo.STOP
        |]

        node.Body.Add(generator)
