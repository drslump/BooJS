namespace BooJs.Compiler.Steps

import System
import Boo.Lang.Compiler.Ast
import Boo.Lang.Compiler.Steps
import Boo.Lang.Compiler.TypeSystem.Internal

class ProcessGenerators(AbstractTransformerCompilerStep):
"""
    Specialized step to process generators to replace Boo's original one.

    TODO: State to run just before this one that converts all loops to while ones
          if the method is a generator
"""
    class TransformGenerator(FastDepthFirstVisitor):
        [getter(States)]
        _states = StatementCollection()

        [property(State)]
        _state as int = 0

        Current as Block:
            get: return States[State]

        _statemachinelabel = ReferenceExpression('statemachine')
        _gotostatemachine = GotoStatement(Label: _statemachinelabel)

        def constructor():
            CreateState()

        def CreateState():
            block = Block()
            States.Add(block)
            return len(States)-1

        def OnExpressionStatement(node as ExpressionStatement):
            Current.Add(node)

        def OnYieldStatement(node as YieldStatement):
            # Create a re-entry state
            nextstate = CreateState()

            # Setup jump to next state and return value
            Current.Add([| __state = $(nextstate) |])
            Current.Add([| return $(node.Expression) |])

            # Continue in the re-entry state
            State = nextstate

        def OnWhileStatement(node as WhileStatement):
            # Loop always starts in a new step
            State = loopstate = CreateState()

            # Create new step for exiting the loop but don't use it yet
            exitstate = CreateState()

            # Check if we should skip the loop by negating the condition
            ifs = [|
                if not $(node.Condition):
                    __state = $(exitstate)
                    $(_gotostatemachine)
            |]
            Current.Add(ifs)

            # Process the loop body
            Visit node.Block

            # Go back to the start of the loop to check if we have more iterations left
            Current.Add([| __state = $(loopstate) |])
            Current.Add(_gotostatemachine)

            # Continue in the exit step previously created
            State = exitstate

        def OnTryStatement(node as TryStatement):
            # A try block always initiates an state
            State = trystate = CreateState()

            # Register ensure block
            if node.EnsureBlock:
                Current.Add([| __final.push( $(BlockExpression(Body: node.EnsureBlock)) ) |])

            Visit node.ProtectedBlock

            # Execute ensure block after we reach the end of the protected block
            if node.EnsureBlock:
                Current.Add( [| __final.pop()() |] )

            # Create a new state for the exception handler
            exceptstate = CreateState()

            # Register the states covered by this protected block
            tryblock = States[trystate] as Block
            for state in range(trystate, exceptstate):
                tryblock.Insert(0, [| __catch[$state] = $exceptstate |] )

            # Create a new state for exiting the try/except block
            afterstate = CreateState()

            # Skip the exception handler state
            Current.Add( [| __state = $afterstate |] )
            Current.Add(_gotostatemachine)

            # Produce the exception handler
            State = exceptstate
            Visit node.ExceptionHandlers

            # Continue in the after state
            State = afterstate


        def Terminate():
            # Create an exit point
            exitstate = CreateState()

            # Direct the current state to the exit point
            Current.Add([| __state = $(exitstate) |])
            Current.Add(_gotostatemachine)

            # Define the exit strategy
            State = exitstate
            Current.Add( [| raise Boo.STOP |] )



    override def Run():
        if len(Errors) > 0:
            return
        Visit CompileUnit

    def HasTryStatement(node as Block) as bool:
        for st in node.Statements:
            return true if st.NodeType == NodeType.TryStatement
            if wst = st as WhileStatement:
                return true if HasTryStatement(wst.Block)
            elif ist = st as IfStatement:
                return true if HasTryStatement(ist.TrueBlock) or HasTryStatement(ist.FalseBlock)

        return false

    override def EnterMethod(node as Method):
        # Types should be already resolved so we can just check if it was flagged as a generator 
        entity = node.Entity as InternalMethod
        return entity and entity.IsGenerator

    override def LeaveMethod(node as Method):

        has_try = HasTryStatement(node.Body)

        # Transform the method body into a list of states
        transformer = TransformGenerator()
        transformer.OnBlock(node.Body)
        transformer.Terminate()

        # Remove the original method contents
        node.Body.Clear()
        # Create a new local to keep the current step of the generator
        CodeBuilder.DeclareLocal(node, '__state', TypeSystemServices.IntType)
        if has_try:
            CodeBuilder.DeclareLocal(node, '__catch', TypeSystemServices.HashType)
            CodeBuilder.DeclareLocal(node, '__final', TypeSystemServices.ArrayType)
            node.Body.Add( CodeBuilder.CreateAssignment(ReferenceExpression('__catch'), HashLiteralExpression()) )
            node.Body.Add( CodeBuilder.CreateAssignment(ReferenceExpression('__final'), ListLiteralExpression()) )

        # Wrap the steps into a switch/case construct
        switch = MacroStatement(Name: 'switch')
        switch.Arguments.Add(ReferenceExpression('__state'))
        for idx as int, step as Block in enumerate(transformer.States):
            case = MacroStatement()
            case.Name = 'case'
            case.Arguments.Add(IntegerLiteralExpression(idx))
            case.Body = step
            switch.Body.Add(case)

        statemachine as Statement
        statemachine = [|
            #console.log('<STATE: ' + __state + '>')
            if __error:
                raise __error

            $switch
        |]

        # Wrap the state machine to support exception handling
        if has_try:
            statemachine = [|
                try:
                    $statemachine
                except:
                    if __e is not Boo.STOP and __state in __catch:
                        __error = null  # Make sure any reported error is removed
                        __state = __catch[__state]
                        goto statemachine

                    # Position the generator to its last state
                    __state = $(len(transformer.States)-1)

                    # Ensure all finally blocks are executed
                    while __final.length:
                        __final.pop()()

                    # Re-raise the exception
                    raise __e
            |]

        # Make the method return a generator
        generator = [|
            return Boo.generator do(__value, __error):
                :statemachine
                $statemachine
        |]
        node.Body.Add(generator)
