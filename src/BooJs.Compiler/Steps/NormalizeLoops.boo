namespace BooJs.Compiler.Steps

import System
import Boo.Lang.Compiler.Ast
import Boo.Lang.Compiler.Steps
import Boo.Lang.Compiler.TypeSystem

class NormalizeLoops(AbstractTransformerCompilerStep):
"""
    Normalize loops

    TODO: Improve transformations, for example by skipping the creation of __ref
          if the iterable is already a reference.
          Fully optimize the range case.
"""

    # If set to true uses a runtime helper to perform the iteration
    SIMPLE_LOOPS = true

    override def Run():
        if len(Errors) > 0:
            return
        Visit CompileUnit

    def OnForStatement(node as ForStatement):
    """
        The current implementation is very naive, it won't inspect the type system to 
        choose a proper loop strategy. This should be done in the future using a compiler
        step.

        Normalization algorithm:

            for v in range(0, 10, 1): ...
            ---
            v=0-1
            while v<10:
                v++
                ...

            for v in list_array: ...
            ---
            __ref = list_array
            __len = __ref.length
            __i = 0
            while __i < __len:
                v = __ref[__i++]
                ...

            for k in hash: ...
            ---
            __keys = []
            for __k in hash: __keys.push(__k)
            __i = 0
            __len = __keys.length
            while __i < __len:
                k = __keys[__i++]
                ...
            ---
            # With runtime support
            for k in Boo.keys(hash):
                v = hash[k]
            ---
            # Translated to
            __ref = Boo.keys(hash)
            __len = __ref.length
            __i = 0
            while __i < __len:
                v = __ref[__i++]

            for v in duck: ...
            ---
            Boo.each(hash, {v| ...}, self)

            for v in generator: ...
            ---
            while (v = generator.next()) is not Boo.STOP:
                ...

        Boo's for statement does not allow to specify a receiving variable for the key like it's 
        done in CoffeeScript (for v,k in hash), however it allows to defines multiple variables
        for unpacking. So the solution is to disable the support for unpacking and use it instead
        to obtain the key.

            for v,k in obj: ...
            ---
            Boo.each(obj, {v,k| ...}, self)
    """
        # Visit the loop block to process nested loops
        # TODO: This doesn't play nice with nested loops in Boo.each
        #Visit node.Block

        # TODO: When using Boo.each() we need to convert a `continue` to a `return` and a
        #       `break` to a `return Boo.STOP`.

        # Override unpacking
        if len(node.Declarations) >= 2:
            DesugarizeOrThenBlocks(node)
            ProcessContinueBreak(node.Block)

            decl1 = ReferenceExpression(Name: node.Declarations[0].Name)
            decl2 = ReferenceExpression(Name: node.Declarations[1].Name)
            loop = [|
                Block:
                    Boo.each( $(node.Iterator) ) do( $decl1, $decl2 ):
                        $(node.Block)
            |].Body

        # Simplified form
        elif SIMPLE_LOOPS:
            DesugarizeOrThenBlocks(node)
            ProcessContinueBreak(node.Block)

            decl = ReferenceExpression(Name:node.Declarations[0].Name)
            loop = [|
                Block:
                    Boo.each( $(node.Iterator) ) do( $decl ):
                        $(node.Block)
            |].Body

        # Type based forms
        else:
            decl = ReferenceExpression(Name:node.Declarations[0].Name)

            # Try range optimization
            loop = OptimizeRange(decl, node)
            if not loop:

                # Get the type of the iterable
                type = typeOf(node.Iterator)

                #print node.Iterator
                #print type

                # Array -> (2, 3, 4)
                if type.IsArray:
                    #print type, 'IsArray'
                    loop = MakeLoopForArray(decl, node.Iterator, node.Block)

                # String -> "abcde"
                elif type == TypeSystemServices.StringType:
                    #print type, 'STRING!'
                    raise "Iterating over strings is not supported. Use `str.split('')`"

                # List -> [2, 3, 4]
                elif type == TypeSystemServices.ListType:
                    #print type, 'List'
                    loop = MakeLoopForList(decl, node.Iterator, node.Block)

                # Generators (yield)
                elif TypeSystemServices.IsGenericGeneratorReturnType(type):
                    #print type, 'Generator!'
                    loop = MakeLoopForGenerator(decl, node.Iterator, node.Block)

                elif TypeSystemServices.GetGenericEnumerableItemType(type):
                    # TODO: What use do we have for these?
                    print type, 'Generics!'
                    loop = MakeLoopForList(decl, node.Iterator, node.Block)

                # Hashes, Ducky and IEnumerable
                elif TypeSystemServices.IsDuckType(type) \
                or TypeSystemServices.GetEnumeratorItemType(type):
                    #print type, 'Enumerable!'
                    loop = MakeLoopForEnumerable(decl, node.Iterator, node.Block)

                else:
                    print type, 'WARNING: Not enumerable!!!'
                    raise 'Iterable not valid'


        loop.LexicalInfo = node.LexicalInfo

        # Replace the for node with the new loop and visit it
        parent = node.ParentNode as Block
        idx = parent.Statements.IndexOf(node)
        RemoveCurrentNode
        parent.Statements.Insert(idx, loop)
        Visit loop

    def MakeLoopForArray(decl as ReferenceExpression, iter as Expression, block as Block):
        _ref = TempLocal(block, TypeSystemServices.ArrayType, 'ref')
        _len = TempLocal(block, TypeSystemServices.IntType, 'len')
        _i = TempLocal(block, TypeSystemServices.IntType, 'i')

        loop = [|
            $_ref = $iter
            $_len = $_ref.length
            $_i = 0
            while $_i < $_len:
                $decl = $_ref[$_i++]
                $block
        |]

        return loop

    def MakeLoopForList(decl as ReferenceExpression, iter as Expression, block as Block):
    """ Lists are transformed just like arrays """
        return MakeLoopForArray(decl, iter, block)

    def MakeLoopForEnumerable(decl as ReferenceExpression, iter as Expression, block as Block):
    """ Enumerables in general are iterated with the help of the runtime """
        loop = [|
            Block:
                Boo.each( $iter ) do($decl):
                    $block
        |].Body

        return loop

    def MakeLoopForGenerator(decl as ReferenceExpression, iter as Expression, block as Block):
    """ Consumes a generator """

        _ref = TempLocal(block, TypeSystemServices.IEnumerableGenericType, 'ref')

        loop = [|
            $_ref = $iter
            while ($decl = $_ref.next()) is not Boo.STOP:
                $block
        |]

        return loop


    def TempLocal(node as Node, type as IType, name as string):
    """ Defines a new temporary variable in the enclosing method or block expression
    """
        # Find the enclosing method
        parent = node
        while parent:
            if parent isa Method:
                return TempLocalInMethod(parent, type, name)
            elif parent isa BlockExpression:
                return TempLocalInBlock(parent, type, name)
            parent = parent.ParentNode

        raise 'No parent Method or BlockExpression found'

    def TempLocalInMethod(method as Method, type as IType, name as string):
        def exists(name):
            found = false
            for local in method.Locals:
                if local.Name == name:
                    found = true
                    break
            return found

        # Find a name that doesn't exists
        cnt = 1
        name = '__' + name
        while exists(name):
            name = name + cnt
            cnt++

        # Reference the local in the method
        CodeBuilder.DeclareLocal(method, name, type)
        return ReferenceExpression(Name:name)

    def TempLocalInBlock(block as BlockExpression, type as IType, name as string):

        def exists(name):
            for st in block.Body.Statements:
                if st isa DeclarationStatement \
                and (st as DeclarationStatement).Declaration.Name == name:
                    return true
            return false

        # Find a name that doesn't exists
        cnt = 1
        name = '__' + name
        while exists(name):
            name = name + cnt
            cnt++

        # Inject the variable declaration
        decl = DeclarationStatement(Declaration:Declaration(name, SimpleTypeReference(type.Name)))
        block.Body.Insert(0, decl)
        return ReferenceExpression(Name:name)


    def ProcessContinueBreak(node as Block):
    """ Replaces the continue keyword with a return and the break one with a return of Boo.STOP
    """
        return if not node
        for st in node.Statements:
            if st.NodeType == NodeType.ContinueStatement:
                node.Statements.Replace(st, [| return |])
            elif st.NodeType == NodeType.BreakStatement:
                node.Statements.Replace(st, [| return Boo.STOP |])
            elif st.NodeType == NodeType.Block:
                ProcessContinueBreak(st)
            elif st.NodeType == NodeType.IfStatement:
                ProcessContinueBreak((st as IfStatement).TrueBlock)
                ProcessContinueBreak((st as IfStatement).FalseBlock)
            elif st.NodeType == NodeType.ForStatement:
                ProcessContinueBreak((st as ForStatement).OrBlock)
                ProcessContinueBreak((st as ForStatement).ThenBlock)
            elif st.NodeType == NodeType.WhileStatement:
                ProcessContinueBreak((st as WhileStatement).OrBlock)
                ProcessContinueBreak((st as WhileStatement).ThenBlock)

    def ProcessBreakForThenFlag(node as Block, flag as string):
    """ Signals the use of the break keyword by setting a flag
    """
        return if not node

        for st in node.Statements.ToArray():
            if st.NodeType == NodeType.BreakStatement:
                idx = node.Statements.IndexOf(st)
                reference = ReferenceExpression(Name: flag)
                stmt = ExpressionStatement(Expression:[| $reference = true |])
                node.Statements.Insert(idx, stmt)
            elif st.NodeType == NodeType.Block:
                ProcessBreakForThenFlag(st, flag)
            elif st.NodeType == NodeType.IfStatement:
                ProcessBreakForThenFlag((st as IfStatement).TrueBlock, flag)
                ProcessBreakForThenFlag((st as IfStatement).FalseBlock, flag)
            elif st.NodeType == NodeType.ForStatement:
                ProcessBreakForThenFlag((st as ForStatement).OrBlock, flag)
                ProcessBreakForThenFlag((st as ForStatement).ThenBlock, flag)
            elif st.NodeType == NodeType.WhileStatement:
                ProcessBreakForThenFlag((st as WhileStatement).OrBlock, flag)
                ProcessBreakForThenFlag((st as WhileStatement).ThenBlock, flag)



    def OptimizeRange(decl as ReferenceExpression, node as ForStatement):
    """ Avoids the need to evaluate range as a generator for the simplest case 
    """
        if not node.Iterator isa MethodInvocationExpression:
            return null

        m = node.Iterator as MethodInvocationExpression
        if m.Target.ToString() != 'Boojs.Lang.BuiltinsModule.range':
            return null
        if len(m.Arguments) != 1:
            return null

        return [|
            $decl = -1
            while $decl < $(m.Arguments[0]):
                $(decl)++
                $(node.Block)
        |]


    def OnWhileStatement(node as WhileStatement):
        Visit node.Block
        DesugarizeOrThenBlocks(node)


    def DesugarizeOrThenBlocks(node as WhileStatement):
    """ Converts `or:` and `then:` blocks into simple ifs
    """
        if node.ThenBlock:
            # Check for nested before modifying it
            Visit node.ThenBlock

            ProcessThenBlock(node, node.Block, node.ThenBlock)
            node.ThenBlock = null

        if node.OrBlock:
            # Check for nested before modifying it
            Visit node.OrBlock

            ProcessOrBlock(node, node.Block, node.OrBlock)
            node.OrBlock = null

    def DesugarizeOrThenBlocks(node as ForStatement):
    """ Converts `or:` and `then:` blocks into simple ifs
    """
        if node.ThenBlock:
            # Check for nested before modifying it
            Visit node.ThenBlock

            ProcessThenBlock(node, node.Block, node.ThenBlock)
            node.ThenBlock = null

        if node.OrBlock:
            # Check for nested before modifying it
            Visit node.OrBlock

            ProcessOrBlock(node, node.Block, node.OrBlock)
            node.OrBlock = null


    def ProcessThenBlock(node as Statement, body as Block, block as Block):
        stmts = (node.ParentNode as Block).Statements

        # Setup a flag in the parent block
        watch_name = Context.GetUniqueName('then')
        watch_ref = ReferenceExpression(watch_name)
        watch_decl = DeclarationStatement(
            Declaration:Declaration(Name:watch_name),
            Initializer:BoolLiteralExpression(Value:false)
        )
        node_idx = stmts.IndexOf(node)
        stmts.Insert(node_idx, watch_decl)

        # Trigger the flag if the loop is entered
        ProcessBreakForThenFlag(body, watch_name)

        # Check if the loop exited normally (no break)
        cond = [|
            if not $watch_ref:
                $(block)
        |]
        node_idx = stmts.IndexOf(node)
        stmts.Insert(node_idx+1, cond)


    def ProcessOrBlock(node as Statement, body as Block, block as Block):
        stmts = (node.ParentNode as Block).Statements

        # Setup a flag in the parent block
        watch_name = Context.GetUniqueName('or')
        watch_ref = ReferenceExpression(watch_name)
        watch_decl = DeclarationStatement(
            Declaration:Declaration(Name:watch_name),
            Initializer:BoolLiteralExpression(Value:false)
        )
        node_idx = stmts.IndexOf(node)
        stmts.Insert(node_idx++, watch_decl)

        # Trigger the flag if the loop is entered
        body.Statements.Insert(
            0,
            ExpressionStatement(
                Expression:[| $watch_ref = true |]
            )
        )

        # Check if the loop was not entered at all
        cond = [|
            if not $watch_ref:
                $(block)
        |]
        node_idx = stmts.IndexOf(node)
        stmts.Insert(node_idx+1, cond)
