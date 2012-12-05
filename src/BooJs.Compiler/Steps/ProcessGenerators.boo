namespace BooJs.Compiler.Steps

import System
import Boo.Lang.Compiler.Ast
import Boo.Lang.Compiler.Steps
import Boo.Lang.Compiler.TypeSystem.Internal
import Boo.Lang.PatternMatching

class ProcessGenerators(AbstractTransformerCompilerStep):
"""
    Specialized step to process generators replacing Boo's one.
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

        def OnForStatement(node as ForStatement):
            Current.Add(node)

        def OnYieldStatement(node as YieldStatement):
            # Create a re-entry state
            nextstate = CreateState()

            # Setup jump to next state and return value
            Current.Add([| __state = $(nextstate) |])
            Current.Add([| return $(node.Expression) |])

            # Continue in the re-entry state
            State = nextstate

        def OnReturnStatement(node as ReturnStatement):
            # If it has an expression just handle as a yield
            if node.Expression:
                ynode = YieldStatement(node.LexicalInfo, Expression: node.Expression)
                OnYieldStatement(ynode)
            # Otherwise just create a new state where the generator terminates
            else:
                nextstate = CreateState()
                Current.Add([| __state = $(nextstate) |])
                State = nextstate

            # At this point we want to always stop the generator
            Current.Add([| raise Boo.STOP |])

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
            catchst = [| $exceptstate |]
            for state in range(trystate, exceptstate):
                catchst = [| __catch[$state] = $catchst |]
            tryblock.Insert(0, catchst)

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
        # Types should be already resolved so we can just check if it was flagged as a generator 
        entity = node.Entity as InternalMethod
        return entity and entity.IsGenerator

    override def LeaveMethod(node as Method):

        has_try = HasTryStatement(node.Body)

        # Transform the method body into a list of states
        transformer = TransformGenerator()
        transformer.OnBlock(node.Body)

        # If the method is a closure we look for the original method node to declare locals in it
        method = node
        if node.IsSynthetic:
            for member in (node.ParentNode as TypeDefinition).Members:
                if member.LexicalInfo.Equals(node.LexicalInfo):
                    method = member
                    break

        # Remove the original method contents
        node.Body.Clear()
        # Create a new local to keep the current step of the generator
        CodeBuilder.DeclareLocal(method, '__state', TypeSystemServices.IntType)
        if has_try:
            CodeBuilder.DeclareLocal(method, '__catch', TypeSystemServices.HashType)
            CodeBuilder.DeclareLocal(method, '__final', TypeSystemServices.ArrayType)
            node.Body.Add( CodeBuilder.CreateAssignment(ReferenceExpression('__catch'), HashLiteralExpression()) )
            node.Body.Add( CodeBuilder.CreateAssignment(ReferenceExpression('__final'), ListLiteralExpression()) )

        # Add value check to first state
        valuecheck = [|
            if __value is not Boo.UNDEF or __error is not Boo.UNDEF:
                raise TypeError('Generator not started yet, unable to process sent value/error')
        |]
        (transformer.States[0] as Block).Insert(0, valuecheck)

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
            if __error:
                raise __error

            $switch

            # Set the state to an imposible value
            __state = -1
            raise Boo.STOP
        |]

        # Wrap the state machine to support exception handling
        if has_try:
            statemachine = [|
                try:
                    $statemachine
                except:
                    if __state in __catch:
                        __error = null  # Make sure any reported error is removed
                        __state = __catch[__state]
                        goto statemachine

                    # Position the generator to the terminating state
                    __state = -1

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
