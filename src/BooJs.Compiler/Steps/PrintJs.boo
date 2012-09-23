namespace BooJs.Compiler.Steps

import Boo.Lang.Compiler.Steps
import Boo.Lang.Compiler.Ast
import Boo.Lang.Compiler

import BooJs.Compiler.SourceMap


class BooJsPrinterVisitor(Visitors.TextEmitter):

    _context as CompilerContext
    
    srcmap as MapBuilder

    def constructor(writer as System.IO.TextWriter):
        super(writer)
        IndentText = '  '

        srcmap = MapBuilder()

    def Initialize(context as CompilerContext):
        _context = context

    def Print(ast as CompileUnit):
        OnCompileUnit(ast)
        
        WriteLine '//@ sourceMappingURL=map.js.map'
        print 'var map = ' + srcmap.ToString()

    def WriteLine():
        srcmap.NewLine()
        super.WriteLine()
        
    def Write(str as string):
        srcmap.Column += str.Length
        super.Write(str)

    def Map(node as Node):
    """ Maps the given node lexical info to the current position in the generated file
    """
        srcmap.Segment(node)

    def OnBoolLiteralExpression(node as BoolLiteralExpression):
        Write( ('true' if node.Value else 'false') )

    def OnNullLiteralExpression(node as NullLiteralExpression):
        Write 'null'

    def OnModule(node as Module):

        # HACK: ProcessMethodBodies step is too complex so we opt for reversing some
        #       of the stuff it does instead of modifying it. Here we just ignore 
        #       any modules it generates to support 'dynamic' features at runtime
        if node.Name == 'CompilerGenerated':
            WriteLine
            Write '/*** CompilerGenerated ***********************'
            WriteLine

        Visit(node.Namespace)

        if node.Imports.Count > 0:
            Visit(node.Imports)
            WriteLine()

        for member in node.Members:
            Visit(member)
            WriteLine()

        if node.Globals:
            Visit(node.Globals.Statements)

        if node.Name == 'CompilerGenerated':
            WriteLine '*** /CompilerGenerated **********************/'

    def WriteLocals(locals as LocalCollection):
    """ Write locals ensuring they are not repeated """
        found = []
        for local in locals:
            continue if local.Name == '$locals'
            continue if local.Name in found
            found.Push(local.Name)
            Visit local

    def WriteBlockLocals(b as BlockExpression):
    """ Find and write locals found in a block expression """
        locals = LocalCollection()

        def finder(stmts as StatementCollection):
            for st in stmts:
                if st isa Block:
                    finder((st as Block).Statements)
                elif st isa BlockExpression:
                    finder((st as BlockExpression).Body.Statements)
                elif st isa ExpressionStatement:
                    # All this mess is to find out if we're declaring a local variable
                    es = st as ExpressionStatement
                    if es.Expression isa BinaryExpression:
                        be = es.Expression as BinaryExpression
                        if be.Operator == BinaryOperatorType.Assign:
                            entity = be.Left.Entity
                            if entity isa TypeSystem.Internal.InternalLocal:
                                if (entity as TypeSystem.Internal.InternalLocal).IsExplicit:
                                    local = Local()
                                    local.Name = be.Left.ToString()
                                    locals.Add(local)

        finder(b.Body.Statements)
        WriteLocals(locals)


    def OnMethod(m as Method):

        # Types are already resolved so we can just check if it was flagged as a generator 
        entity as TypeSystem.Internal.InternalMethod = m.Entity
        if entity.IsGenerator:
            print 'Generator'

        if m.IsRuntime:
            WriteIndented('// runtime')
            WriteLine()

        if /^\$\w+\$closure\$\d+/.IsMatch(m.Name):
            print 'Skipping closure method', m.Name
            return


        # HACK!!! Find assignments of $locals.$<name> to define these as local variables
        # TODO: Improve the algorithm to support all cases
        # TODO: Move to a separate step
        def FindClosureLocals(block as Block):
            # TODO: Handle closures passed in as arguments to method calls
            for st in block.Statements:
                if st isa Block:
                    FindClosureLocals(st)
                elif st isa Method:
                    FindClosureLocals((st as Method).Body)
                elif st isa BlockExpression:
                    FindClosureLocals((st as BlockExpression).Body)
                elif st isa ExpressionStatement:
                    es = st as ExpressionStatement
                    if es.Expression isa BinaryExpression:
                        be = es.Expression as BinaryExpression

                        # Process closures assigned to variables
                        if be.Right isa BlockExpression:
                            FindClosureLocals((be.Right as BlockExpression).Body)

                        if be.Operator == BinaryOperatorType.Assign:
                            if /^\$locals\.\$/.IsMatch(be.Left.ToString()):
                                str = be.Left.ToString()
                                parts = str.Split(char('.'))
                                local = Local()
                                local.Name = parts[1][1:]
                                m.Locals.Add(local)

        FindClosureLocals(m.Body)

        # HACK: If we detect the Main method we just output its statements
        if m.Name == 'Main':
            WriteLocals(m.Locals)
            Visit m.Body
            return

        WriteCallableDefinitionHeader('function ', m)
        WriteOpenBrace
        WriteLocals(m.Locals)
        Visit m.Body
        WriteCloseBrace

    def OnSlicingExpression(node as SlicingExpression):
        if len(node.Indices) != 1:
            raise 'Only one index is supported when slicing'

        Visit node.Target
        Write '['
        Visit node.Indices[0]
        Write ']'

    def OnUnpackStatement(node as UnpackStatement):
        raise 'Unpack should be performed in its own step'

    def OnBlockExpression(node as BlockExpression):
    """ Javascript has native support for closures thus the conversion is very simple.
    """
        Write 'function('
        if len(node.Parameters):
            WriteCommaSeparatedList(node.Parameters)
        Write ')'
        if node.Body.IsEmpty:
            Write '{}'
        else:
            WriteOpenBrace
            WriteBlockLocals(node)
            Visit node.Body.Statements
            WriteCloseBrace false

    def WriteOpenBrace():
        Write '{'
        WriteLine
        Indent
        WriteIndented

    def WriteCloseBrace(cr as bool):
        Dedent
        WriteIndented
        Write '}'
        WriteLine if cr
        WriteLine if cr
    
    def WriteCloseBrace():
        WriteCloseBrace(true)

    def WriteAnnotation(str as string):
        lines = str.Split("\n"[0])
        if len(lines) == 1:
            Write '/** ' + str + ' */'
        else:
            WriteLine '/**'
            for ln in lines:
                WriteIndented ' * '
                Write ln
                WriteLine
            WriteIndented ' */'


    def OnLocal(node as Local):
        # HACK: We should find a better way to compare the type. If it matches 
        #       the special global type (ie: jQuery as global) then we avoid defining
        #       it, which would shadow the global variable
        #ilocal = node.Entity as Boo.Lang.Compiler.TypeSystem.ITypedEntity
        #if ilocal.Type.ToString() == 'Boojs.Lang.global':
        #    return

        entity = node.Entity as TypeSystem.ITypedEntity

        # TODO: Add proper type annotations
        WriteIndented
        if entity:
            WriteAnnotation "@type {$(entity.Type)}"
            Write ' '

        # Initialize value types to avoid them being 'undefined'
        if entity and entity.Type.FullName in ('int', 'uint', 'double'):
            Write "var $(node.Name) = 0;"
        elif entity and entity.Type.FullName in ('bool'):
            Write "var $(node.Name) = false;"
        elif entity and entity.Type.FullName in ('string'):
            Write "var $(node.Name) = '';"
        else:
            Write "var $(node.Name);"
        WriteLine

    def OnReferenceExpression(node as ReferenceExpression):
        # TODO: Check name for invalid chars?
        Map node

        if node.Entity isa Boo.Lang.Compiler.TypeSystem.Reflection.ExternalType:
            Write 'Boo.Types.'

        Write node.Name

    def OnDeclarationStatement(node as DeclarationStatement):
        WriteIndented 'var '
        Map node
        Write node.Declaration.Name
        if node.Initializer:
            Write ' = '
            Visit node.Initializer
        WriteLine ';'

    def OnIfStatement(node as IfStatement):

        last_had_braces = false

        def IsElIf(block as Block):
            return false if not block
            return false if block.Statements.Count != 1
            return block.Statements[0] isa IfStatement

        def WriteCondBlock(keyword, node as IfStatement):
            Write keyword + ' ('
            Visit node.Condition
            Write ') '
            if len(node.TrueBlock.Statements):
                WriteOpenBrace 
                last_had_braces = true
                Visit(node.TrueBlock.Statements)
            else:
                WritePass

        WriteIndented
        WriteCondBlock('if', node)

        block = node.FalseBlock
        while IsElIf(block):
            stmt as IfStatement = block.Statements[0]        
            if last_had_braces:
                WriteCloseBrace false
                WriteCondBlock(' else if', stmt)
            else:
                WriteCondBlock('else if', stmt)
            block = stmt.FalseBlock

        if block:
            if last_had_braces:
                last_had_braces = false
                WriteCloseBrace false
                WriteIndented ' else '
            else:
                WriteIndented 'else '

            if len(block.Statements) > 1:
                WriteOpenBrace
                last_had_braces = true
                Visit block.Statements
            elif len(block.Statements) == 1:
                Visit block.Statements
            else:
                Write '{}'
                WriteLine

        WriteCloseBrace if last_had_braces 

    def WritePass():
        WriteLine '"pass";'

    def OnConditionalExpression(node as ConditionalExpression):
    """ Convert to the ternary operator.
            (10 if true else 20)  -->  true ? 10 : 20
    """
        WriteWithOptionalParens node.Condition
        Write ' ? '
        WriteWithOptionalParens node.TrueValue
        Write ' : '
        WriteWithOptionalParens node.FalseValue
        
    def WriteWithOptionalParens(node as Node):
        parens = NeedsParensAround(node)
        if parens:
            WriteWithParens(node)
        else:
            Visit node

    def WriteWithParens(node as Node):
        Write '('
        Visit node
        Write ')'


    def OnTryStatement(node as TryStatement):

        WriteIndented
        Write 'try '
        WriteOpenBrace
        Visit node.ProtectedBlock

        assert 1 == len(node.ExceptionHandlers)

        hdl = node.ExceptionHandlers[0]
        WriteCloseBrace false
        Write " catch ($(hdl.Declaration.Name)) "
        WriteOpenBrace

        Visit hdl.Block

        if node.EnsureBlock:
            WriteCloseBrace false
            Write ' finally '
            WriteOpenBrace
            Visit node.EnsureBlock

        WriteCloseBrace


    def OnListLiteralExpression(node as ListLiteralExpression):
    """ The List type in Boo '[,,,]' is equivalent to the JS array
    """
        WriteDelimitedCommaSeparatedList('[', node.Items, ']')

    def OnArrayLiteralExpression(node as ArrayLiteralExpression):
    """ Arrays in Boo '(,,,)' are immutable but we convert them to plain JS arrays anyway
    """
        WriteDelimitedCommaSeparatedList('[', node.Items, ']')

    def OnHashLiteralExpression(node as HashLiteralExpression):
    """ Hashes are plain Javascript objects
    """
        is_short = len(node.Items) < 3
        if is_short:
            Write '{'
        else:
            WriteOpenBrace

        first = true
        for pair as ExpressionPair in node.Items:
            if not first:
                Write ', '
                if not is_short:
                    WriteLine
                    WriteIndented

            Visit pair.First
            Write ': '
            Visit pair.Second
            first = false
        
        if is_short:
            Write '}'
        else:
            WriteCloseBrace(node.ParentNode.NodeType != NodeType.MethodInvocationExpression)

    def WriteDelimitedCommaSeparatedList(opening, list as Expression*, closing):
        Write(opening)
        WriteCommaSeparatedList(list)
        Write(closing)

    def OnLabelStatement(node as LabelStatement):
        Map node
        WriteIndented "$(node.Name):"

    def OnGotoStatement(node as GotoStatement):
        WriteIndented
        Map node
        Write "continue $(node.Label.Name);"
        WriteLine

    def OnSelfLiteralExpression(node as SelfLiteralExpression):
        Map node
        Write 'this'

    def OnCharLiteralExpression(node as CharLiteralExpression):
    """ Chars in JS are strings of length 1 """
        Map node
        WriteStringLiteral(node.Value)

    def OnStringLiteralExpression(node as StringLiteralExpression):
        Map node
        WriteStringLiteral(node.Value)

    def OnRELiteralExpression(node as RELiteralExpression):
    """ Almost a direct translation to Javascript regexp literals. The only modification
        is that we ignore whitespace to allow the regexps to be somehow more readable while
        Boo's handling is to escape it as part of the match.

            / foo | bar /i  ->  /foo|bar/i
            @/ foo | bar /  ->  /foo|bar/i
    """
        re = node.Value

        start = re.IndexOf('/')
        stop = re.LastIndexOf('/')

        mod = re[stop:]
        re = re[start:stop]

        # Ignore white space
        re = /\s|\t/.Replace(re, '')

        # Javascript does not support the single-line modifier (dot matches new lines).
        # We emulate it by converting dots to the [\s\S] expression in the regex.
        # NOTE: The algorithm will break when a dot is preceeded by an escaped back slash (\\.)
        if mod.Contains('s'):
            re = /(?<!\\)\./.Replace(re, '[\\s\\S]')
            mod = mod.Replace('s', '')

        Map node
        Write "$re$mod"

    def OnIntegerLiteralExpression(node as IntegerLiteralExpression):
        Map node
        Write(node.Value.ToString())

    def OnDoubleLiteralExpression(node as DoubleLiteralExpression):
        Map node
        Write(node.Value.ToString("########0.0##########"))



    def OnTypeDefinition(node as TypeDefinition):
        print 'TypeDefinition: ', node

    def OnCallableDefinition(node as CallableDefinition):
        print 'Callable Definition: ', node

    def OnCallableTypeReference(node as CallableTypeReference):
        print 'Callable Type Reference: ', node

    def OnGenericTypeDefinitionReference(node as GenericTypeDefinitionReference):
        print 'Generic Type Definition Reference: ', node


    def OnExpressionStatement(node as ExpressionStatement):
        # Ignore the assignment of locals produced by closures instrumentation
        if node.Expression isa BinaryExpression:
            expr = node.Expression as BinaryExpression
            if expr.Operator == BinaryOperatorType.Assign:
                str = expr.Left.ToString()
                return if str == '$locals'

        WriteIndented
        Visit node.Expression
        Visit node.Modifier
        Write ';'
        WriteLine

    def OnExpressionInterpolationExpression(node as ExpressionInterpolationExpression):
    """ We build either as string concatenation or as a literal array and then join it to form the string
            "foo \$bar" => 'foo' + bar
            "foo \$bar \$baz" -> ['foo', bar, ' ', baz].join('')
    """
        use_join = len(node.Expressions) > 3
        concat_str = (', ' if use_join else ' + ')
    
        Write '[' if use_join
        first = true
        for arg in node.Expressions:
            if arg.NodeType == NodeType.StringLiteralExpression:
                value = (arg as StringLiteralExpression).Value
                continue if not len(value)
                Write concat_str if not first
                WriteStringLiteral((arg as StringLiteralExpression).Value)
            else:
                # TODO: Use parens around expressions if needed
                Write concat_str if not first
                Visit(arg)

            first = false

        Write "].join('')" if use_join

    def OnMemberReferenceExpression(node as MemberReferenceExpression):
        # TODO: Check if the property name is a valid javascript ident and if not use ['xxx'] syntax

        # If the target is the `global` object skip it
        if node.Target.NodeType == NodeType.ReferenceExpression:
            target = node.Target as ReferenceExpression
            if target.Name == 'global':
                Write node.Name
                return
            elif target.Name == 'BooJs.Lang.BuiltinsModule':
                Write 'Boo.' + node.Name
                return
            # Check if it's a class. If so skip it by now
            # TODO: THIS DOESN'T WORK!!!
            elif false and target.ExpressionType and target.ExpressionType.BaseType.IsClass:
                Write node.Name
                return

        # Remove the $locals.$ prefix from closure variables
        if node.Target.ToString() == '$locals':
            Write node.Name[1:]
            return

        # Check if a node is bound to the main class
        def RefsMainClass(node as Node):
            if not node or not node.Entity:
                return false

            if not node.Entity isa TypeSystem.Internal.InternalClass:
                return false

            entity = node.Entity as TypeSystem.Internal.InternalClass
            if not entity.IsClass or not entity.TypeDefinition:
                return false

            defnode = entity.TypeDefinition as ClassDefinition
            if defnode.IsNested or not defnode.EnclosingModule:
                return false

            return true

        # Checks if a node is bound to a builtin type
        def RefsBuiltIn(node as Node):
            if not node or not node.Entity:
                return false

            return node.Entity.EntityType == TypeSystem.EntityType.BuiltinFunction


        if node.Target:
            print 'TARGET: ', node.Target
            print 'TARGET IsSynthetic', node.Target.IsSynthetic

            entity = node.Target.Entity
            if entity:
                print 'TARGET Entity', entity
                print 'TARGET Entity NodeType', entity.EntityType
                #if entity isa TypeSystem.ITypedEntity:
                #    typed = entity as TypeSystem.ITypedEntity
                #    print 'TARGET IsModule', typed.IsModule
                #    print 'TARGET IsClass', typed.IsClass
                #    print 'TARGET IsFinal', typed.IsFinal
                #    print 'TARGET TypeDefinition', typed.TypeDefinition  # Ast Node

        # Skip the target if it's the MainClass injected by Boo
        # TODO: Move to step
        if not RefsMainClass(node.Target):
            Visit node.Target
            Write '.'

        if RefsBuiltIn(node.Target):
            print 'BUILT IN', node.Target

        Map node
        Write node.Name

        # System
        # .IsSynthetic == false
        # .Entity isa TypeSystem.Core.ResolvedNamespaces, TypeSystem.Core.AbstractNamespace
        # .Entity.EntityType == Namespace



    def OnMethodInvocationExpression(node as MethodInvocationExpression):

        # TODO: We can use something like this to know which overloaded method we are calling
        /*
        print 'Target: ', node.Target.Entity
        entity as TypeSystem.IEntityWithParameters = node.Target.Entity
        if entity:
            # TODO: Check varargs varargsun
            i = 0
            for param as TypeSystem.IParameter in entity.GetParameters():
                print 'Arg: ', node.Arguments[i]
                print 'Param: ', param
                print 'Param.Type: ', param.Type
                i++
        */


        
        # HACK: Boo converts the equality comparison to a runtime call for those atoms
        #       without an static type on the complex ProcessMethodBodies step.
        #       Instead of changing that step we undo the transformation since it's
        #       much simpler although very dirty :(
        # TODO: Although we keep this hack it should be moved to its own dedicated step

        def UndoOperatorInvocation(node as MethodInvocationExpression, operator as BinaryOperatorType):
            expr = BinaryExpression(node.LexicalInfo)
            expr.Operator = operator
            expr.Left = node.Arguments[0]
            expr.Right = node.Arguments[1]
            Visit expr

        tref = node.Target.ToString()
        if tref == 'Boo.Lang.Runtime.RuntimeServices.EqualityOperator':
            UndoOperatorInvocation(node, BinaryOperatorType.Equality)
            return
        elif tref == 'Boo.Lang.Runtime.RuntimeServices.op_Match':
            UndoOperatorInvocation(node, BinaryOperatorType.Match)
            return
        elif tref == 'Boo.Lang.Runtime.RuntimeServices.op_NotMatch':
            UndoOperatorInvocation(node, BinaryOperatorType.NotMatch)
            return
        elif tref == 'Boo.Lang.Runtime.RuntimeServices.op_Member':
            UndoOperatorInvocation(node, BinaryOperatorType.Member)
            return
        elif tref == 'Boo.Lang.Runtime.RuntimeServices.op_NotMember':
            UndoOperatorInvocation(node, BinaryOperatorType.NotMember)
            return
        elif tref == 'Boo.Lang.Runtime.RuntimeServices.op_Modulus':
            Write 'Boo.op_Modulus('
            Visit node.Arguments[0]
            Write ', '
            Visit node.Arguments[1]
            Write ')'
            return
        elif tref == 'Boo.Lang.Runtime.RuntimeServices.op_Addition':
            Write 'Boo.op_Addition('
            Visit node.Arguments[0]
            Write ', '
            Visit node.Arguments[1]
            Write ')'
            return
        elif tref == 'Boo.Lang.Runtime.RuntimeServices.op_Multiply':
            Write 'Boo.op_Multiply('
            Visit node.Arguments[0]
            Write ', '
            Visit node.Arguments[1]
            Write ')'
            return
        elif tref == 'Boo.Lang.Runtime.RuntimeServices.GetEnumerable':
            Visit node.Arguments[0]
            return
        elif tref == 'Boo.Lang.Runtime.RuntimeServices.GetRange1':
            # TODO: HACK! this call has been found in compiler generated code
            Visit node.Arguments[0]
            Write '.slice('
            Visit node.Arguments[1]
            Write ')'
            return
        elif tref == '__initobj__':
            if len(node.Arguments) > 1:
                Visit node.Arguments[0]
                Write ' = '
                Visit node.Arguments[1]
                Write ';'
            return
        elif tref =~ 'Boo.Lang.Runtime.RuntimeServices':
            raise "Found a RuntimeServices invocation: $tref"
        #elif tref == 'BooJs.Lang.BuiltinsModule.array':
        #    Write 'Boo.array('
        #    Visi"' + node.Arguments[0] + '", '
        #    Visit node.Arguments[1]
        #    Write ')'
        #    return
        elif tref =~ /^BooJs\.Lang\.BuiltinsModule\./:
            # TODO: This is a HACK!!!
            Write 'Boo.' + tref.Substring(len('BooJs.Lang.BuiltinsModule.')) + '('
            WriteCommaSeparatedList node.Arguments
            Write ')'
            return

        # Revert: CompilerGenerated.__FooModule_foo$callable0$7_9__(xxx, __addressof__(FooModule.$foo$closure$1))
        if len(node.Arguments) == 2:
            arg = node.Arguments[1]
            if arg.NodeType == NodeType.MethodInvocationExpression:
                method as MethodInvocationExpression = arg
                if '__addressof__' == method.Target.ToString():
                    arg = method.Arguments[0]
                    Write "/*CLOSURE: $arg*/"


        # Convert: closure.Invoke() -> closure()
        if node.Target isa MemberReferenceExpression:
            target = node.Target as MemberReferenceExpression
            if target.Name == 'Invoke' and target.ExpressionType isa Boo.Lang.Compiler.TypeSystem.Core.AnonymousCallableType:
                node.Target = target.Target

            elif target.Name == 'Call' and target.ExpressionType isa TypeSystem.Core.AnonymousCallableType:
                # Here the arguments are passed in as a list. We undo this to pass them normally.
                node.Target = target.Target
                for arg in (node.Arguments[0] as ArrayLiteralExpression).Items:
                    node.Arguments.Add(arg)
                node.Arguments.RemoveAt(0)


            # HACK: Dirty way to convert back hash access to use index based syntax instead of method calls
            # TODO: Move this to a compiler step
            elif target.Name == 'get_Item':
                Visit target.Target
                Write '['
                Visit node.Arguments[0]
                Write ']'
                return
            elif target.Name == 'set_Item':
                Visit target.Target
                Write '['
                Visit node.Arguments[0]
                Write '] = '
                Visit node.Arguments[1]
                return


        # "Eval" calls take the form:
        #
        #    @( stmt1, stmt2, ...., return_stmt )
        #
        # so we can convert them to a self invoking anonymous function that returns the last
        # argument.
        #
        # Note: New variables are declared in the enclosing scope not wrapped in the anonymous
        #       function.
        #
        if '@' == node.Target.ToString():
            Write '(function(){ '
            # Execute statements passed as arguments
            l = len(node.Arguments)
            for i in range(l):
                # Return the result of the last statement
                if i == l-1:
                    Write 'return '
                Visit node.Arguments[i]
                Write '; '
            Write '})()'
            return

        Visit node.Target
        Write '('
        WriteCommaSeparatedList node.Arguments

        # TODO: What to do with named arguments?
        # Although Boo doesn't support the definition of named params it does support
        # their use when calling methods. If the method is a constructor then it automatically
        # sets those properties:
        #  Foo(x:1, y:10)   ->  function Foo(){ this.x = 1; this.y = 10
         
        #if len(node.NamedArguments):
        #    if len(node.Arguments):
        #        Write ', '
        #    WriteCommaSeparatedList node.NamedArguments

        Write ')'

    def OnReturnStatement(node as ReturnStatement):
        WriteIndented 'return '
        Visit node.Expression
        WriteLine ';'

    def OnRaiseStatement(node as RaiseStatement):
        WriteIndented 'throw '
        if node.Exception isa MethodInvocationExpression:
            Write 'new '
        Visit node.Exception
        WriteLine

    def OnWhileStatement(node as WhileStatement):
        WriteIndented 'while ('
        Visit node.Condition
        Write ') '
        WriteOpenBrace
        Visit node.Block
        WriteCloseBrace

    def OnUnlessStatement(node as UnlessStatement):
        WriteIndented 'if (! '
        WriteWithOptionalParens node.Condition
        Write ') '
        WriteOpenBrace
        Visit(node.Block)
        WriteCloseBrace

    def OnBreakStatement(node as BreakStatement):
        WriteIndented
        Map node
        WriteLine 'break;'

    def OnContinueStatement(node as ContinueStatement):
        WriteIndented 
        Map node
        WriteLine 'continue;'

    def OnCastExpression(node as CastExpression):
        print 'Cast: ', node
        Write 'Boo.cast('
        Visit node.Target
        Write ', '
        Visit node.Type
        Write ')'

    def OnTryCastExpression(node as TryCastExpression):
        # TODO: Don't we have to check if the cast needs special actions?
        Write 'Boo.trycast('
        Visit node.Target
        Write ', '
        Visit node.Type
        Write ')'

    def OnUnaryExpression(node as UnaryExpression):
        # Make sure negation applies correctly to its operand
        if node.Operator == UnaryOperatorType.LogicalNot:
            Write '!('
            Visit node.Operand
            Write ')'
            return

        Write '(' if NeedsParensAround(node)

        isPostOp = AstUtil.IsPostUnaryOperator(node.Operator)
        Write GetUnaryOperatorText(node.Operator) if not isPostOp
        parens = NeedsParensAround(node.Operand)
        Write '(' if parens
        Visit node.Operand
        Write ')' if parens
        Write GetUnaryOperatorText(node.Operator) if isPostOp

        Write ')' if NeedsParensAround(node)

    def GetUnaryOperatorText(op as UnaryOperatorType):
        # TODO: In ProcessMethod.ExpandSimpleIncrementDecrement this is expanded
        if op == UnaryOperatorType.PostIncrement or op == UnaryOperatorType.Increment:
            return '++'
        # TODO: In ProcessMethod.ExpandSimpleIncrementDecrement this is expanded
        elif op == UnaryOperatorType.PostDecrement or op == UnaryOperatorType.Decrement:
            return '--'
        elif op == UnaryOperatorType.UnaryNegation:
            return '-'
        elif op == UnaryOperatorType.LogicalNot:
            return '!'
        elif op == UnaryOperatorType.OnesComplement:
            return '~'
        elif op == UnaryOperatorType.Explode:
            raise 'Explode operator "*" is not supported'
        elif op == UnaryOperatorType.AddressOf:
            raise 'AddressOf operator "&" is not supported' 
        elif op == UnaryOperatorType.Indirection:
            raise 'Indirection operator "*" is not supported'
        else:
            raise 'Invalid operator "' + op + '"'

    def BinaryAssign(node as BinaryExpression):
        # Wrap in parens if it's an assigment inside an expression
        parens = not node.ParentNode isa Statement
        Write '(' if parens

        Visit node.Left
        Write ' = '
        Visit node.Right

        Write ')' if parens

    def BinaryExponentiation(node as BinaryExpression):
        Write 'Math.pow('
        Visit node.Left
        Write ', '
        Visit node.Right
        Write ')'

    def BinaryMatch(node as BinaryExpression):
        /*
        type = TypeSystem.TypeSystemServices.GetExpressionType(node.Right)
        if type.ToString() == 'BooJs.Lang.RegExp':
            Visit node.Right
            Write '.test('
            Visit node.Left
            Write ')'
            return

        # handle strings
        Write '(-1 !== '
        Visit node.Left
        Write '.indexOf('
        Visit node.Right
        Write '))'
        */

        type = TypeSystem.TypeSystemServices.GetExpressionType(node.Right)
        if type.FullName == 'BooJs.Lang.RegExp':
            Visit node.Right
        else: #if type.FullName == 'String':
            Write '(new RegExp('
            Visit node.Right
            Write '))'

        Write '.test('
        Visit node.Left
        Write ')'


    def OnBinaryExpression(node as BinaryExpression):

        if node.Operator == BinaryOperatorType.Assign:
            BinaryAssign(node)
        elif node.Operator == BinaryOperatorType.Exponentiation:
            BinaryExponentiation(node)
        elif node.Operator == BinaryOperatorType.Match: # a =~ b
            BinaryMatch(node)
        elif node.Operator == BinaryOperatorType.NotMatch: # a !~ b
            # TODO: If we have a runtime we can match regexp too
            Write '(-1 === '
            Visit node.Left
            Write '.indexOf('
            Visit node.Right
            Write '))'
        elif node.Operator == BinaryOperatorType.NotMember: # a not in b -> !(a in b)
            Write '!('
            Visit node.Left
            Write ' in '
            Visit node.Right
            Write ')'
        elif node.Operator == BinaryOperatorType.TypeTest: # a isa type -> typeof a === 'type'  OR  a instanceof type
            # isa rhs is encoded in a typeof expression
            if node.Right isa TypeofExpression \
            and (node.Right as TypeofExpression).Type isa SimpleTypeReference:
                # TODO: We need to convert type names to JS ones somewhere
                # TODO: Shall we also check for instanceof Number, String, Array... ???
                type = (node.Right as TypeofExpression).Type as SimpleTypeReference

                if type.Name.IndexOf('Error') >= 0:
                    Visit node.Left
                    Write ' instanceof '
                    Visit node.Right
                else:
                    Write 'typeof '
                    Visit node.Left
                    Write " === "
                    if type.Name == 'bool':
                        Write "'boolean'"
                    elif type.Name == 'int' or type.Name == 'uint' or type.Name == 'double':
                        Write "'number'"
                    elif type.Name == 'void':
                        Write "'undefined'"
                    elif type.Name == 'callable':
                        Write "'function'"
                    else:
                        Write "'$(type.Name)'"

            else:
                Visit node.Left
                Write ' instanceof '
                Visit node.Right

        else:
            parens = NeedsParensAround(node)
            Write '(' if parens
            Visit node.Left
            Write " "
            Write GetBinaryOperatorText(node.Operator)
            Write " "
            Visit node.Right
            Write ')' if parens

    def OnSimpleTypeReference(node as SimpleTypeReference):
        # TODO: Why is this happending?
        if node.ToString() == 'System.Object' or node.ToString() == 'object' or node.ToString() == 'System.MulticastDelegate':
            print 'WARNING: SimpleTypeReference = ', node
            return

        if node.Name.IndexOf('BooJs.Lang.') == 0:
            Write node.Name.Substring('BooJs.Lang.'.Length)
        else:
            Write 'Boo.Types.' + node.Name


    def GetBinaryOperatorText(op as BinaryOperatorType):

        return '=' if op == BinaryOperatorType.Assign
        # Note: We use equality in value and type in JS
        return '==' if op == BinaryOperatorType.Equality
        return '!=' if op == BinaryOperatorType.Inequality
        return '+' if op == BinaryOperatorType.Addition
        return '-' if op == BinaryOperatorType.Subtraction
        return '*' if op == BinaryOperatorType.Multiply
        return '/' if op == BinaryOperatorType.Division
        return '%' if op == BinaryOperatorType.Modulus
        return '+=' if op == BinaryOperatorType.InPlaceAddition
        return '-=' if op == BinaryOperatorType.InPlaceSubtraction
        return '*=' if op == BinaryOperatorType.InPlaceMultiply
        return '%=' if op == BinaryOperatorType.InPlaceModulus
        return '/=' if op == BinaryOperatorType.InPlaceDivision
        return '&=' if op == BinaryOperatorType.InPlaceBitwiseAnd
        return '|=' if op == BinaryOperatorType.InPlaceBitwiseOr
        return '^=' if op == BinaryOperatorType.InPlaceExclusiveOr
        return '>' if op == BinaryOperatorType.GreaterThan
        return '>=' if op == BinaryOperatorType.GreaterThanOrEqual
        return '<' if op == BinaryOperatorType.LessThan
        return '<=' if op == BinaryOperatorType.LessThanOrEqual

        # TODO: Does it work most of the time???
        return 'in' if op == BinaryOperatorType.Member

        return '===' if op == BinaryOperatorType.ReferenceEquality
        return '!==' if op == BinaryOperatorType.ReferenceInequality

        return 'instanceof' if op == BinaryOperatorType.TypeTest
        return '||' if op == BinaryOperatorType.Or
        return '&&' if op == BinaryOperatorType.And

        return '|' if op == BinaryOperatorType.BitwiseOr
        return '&' if op == BinaryOperatorType.BitwiseAnd
        return '^' if op == BinaryOperatorType.ExclusiveOr
        return '<<' if op == BinaryOperatorType.ShiftLeft
        return '>>' if op == BinaryOperatorType.ShiftRight
        return '<<=' if op == BinaryOperatorType.InPlaceShiftLeft
        return '>>=' if op == BinaryOperatorType.InPlaceShiftRight

        raise 'Operator $(op) is not implemented'

    def NeedsParensAround(node as Expression):
        return true if node.ParentNode and node.ParentNode.NodeType == NodeType.MemberReferenceExpression  # (--1).toString()
        t = node.NodeType
        return false if t == NodeType.StringLiteralExpression
        return false if t == NodeType.CharLiteralExpression
        return false if t == NodeType.BoolLiteralExpression
        return false if t == NodeType.IntegerLiteralExpression
        return false if t == NodeType.DoubleLiteralExpression
        return false if t == NodeType.NullLiteralExpression
        return false if t == NodeType.ReferenceExpression
        return false if t == NodeType.ListLiteralExpression
        return false if t == NodeType.ArrayLiteralExpression
        return false if t == NodeType.MethodInvocationExpression
        return false if t == NodeType.UnaryExpression
        
        # TODO: Not very sure about this
        if node.ParentNode:
            t = node.ParentNode.NodeType
            return false if t == NodeType.ExpressionStatement
            #return false if t == NodeType.IfStatement
            #return false if t == NodeType.WhileStatement
            #return false if t == NodeType.UnlessStatement

        return true


    def WriteCallableDefinitionHeader(keyword as string, node as CallableDefinition):
        # TODO: Inspect params and return to generate type annotations for Closure
        WriteIndented keyword
        Map node
        Write node.Name
        WriteParameterList(node.Parameters, '(', ')')

    def WriteParameterList(params as ParameterDeclarationCollection, st, ed):
        Write(st)
        i = 0
        for param in params:
            if i > 0:
                Write(', ')
            Visit(param)
            i++
        Write(ed)

    def OnParameterDeclaration(p as ParameterDeclaration):
        #if p.IsParamArray: Write("*")
        Map(p)
        Write(p.Name);


    def OnEnumDefinition(node as EnumDefinition):
        # TODO: Prefix with namespace
        Write 'var '

        Map node
        Write "$(node.FullName) = "
        WriteOpenBrace
        first = true
        for member as EnumMember in node.Members:
            assert member.Initializer != null, 'Enum definition without an initializer value!'
            WriteLine ',' if not first
            WriteIndented
            Map member
            Write member.Name
            Write ': '
            Visit member.Initializer
            first = false
            
        WriteLine
        WriteCloseBrace

    def OnClassDefinition(node as ClassDefinition):
        for member as TypeMember in node.Members:
            Visit member

        return

        Write "$(node.Name) = function()"
        WriteOpenBrace

        if len(node.BaseTypes):
            Write '/* extends '
            WriteCommaSeparatedList(node.BaseTypes)
            Write '*/'
            WriteLine

        statics = []
        methods = []
        for member as TypeMember in node.Members:
            # Static members are defined outside the constructor
            if member.IsStatic:
                statics.Push(member)
                continue

            # Call the constructor method
            if member isa Constructor:
                WriteIndented 'this.constructor.apply(this, arguments);'
                WriteLine

            # Collect to define the prototype
            if member isa Method:
                methods.Push(member)
                continue

            WriteIndented 
            Visit(member)
            WriteLine()

        WriteCloseBrace

        # Setup the static fields
        for member as TypeMember in statics:
            # Inline the static constructor
            if member isa Constructor:
                Visit((member as Constructor).Body)
                continue

            WriteIndented "$(member.FullName) = "
            Visit(member)
            WriteLine

        # Setup prototype
        for member as TypeMember in methods:
            WriteIndented member.DeclaringType.FullName
            Write ".prototype.$(member.Name) = "
            Visit(member)
            WriteLine



    def OnField(f as Field):
        # Not supported
        return

    def OnConstructor(node as Constructor):
        # Not supported
        return


    def WriteTypeDefinition(keyword, node as TypeDefinition):
        raise 'This is not yet implemented'

        #WriteAttributes(node.Attributes, true)
        #WriteModifiers(node)
        WriteIndented 
        Write keyword
        Write ' '

        splice = node.ParentNode as SpliceTypeMember
        if splice:
            #WriteSplicedExpression(splice.NameExpression)
            pass
        else:
            Write(node.Name)

        #if len(node.GenericParameters):
        #    WriteGenericParameterList(node.GenericParameters);

        if len(node.BaseTypes):
            Write("(")
            WriteCommaSeparatedList(node.BaseTypes)
            Write(")")

        WriteLine(":")
        if len(node.Members):
            for member as TypeMember in node.Members:
                print member.NodeType
                Visit(member)
                WriteLine()
        else:
            Write 'pass'

    def OnExpressionPair(pair as ExpressionPair):
        Visit pair.First
        Write ': '
        Visit pair.Second


    def WriteStringLiteral(text as string):
        WriteStringLiteral text, "'"

    def WriteStringLiteral(text as string, quote as string):
        Write quote
        WriteStringContent text, quote
        Write quote

    def WriteStringContent(text as string, quote as string):
        for ch in text:
            str = ch.ToString()  # Convet to string from char
            if str == '\r':
                Write '\\r'
            elif str == '\n':
                Write '\\n'
            elif str == '\t':
                Write '\\t'
            elif str == '\0':
                Write '\\0'
            elif str == '\\':
                Write '\\\\'
            elif str == "'" and str == quote:
                Write "\\'"
            elif str == '"' and str == quote:
                Write '\\"'
            else:
                Write(str)




class PrintBooJs(PrintBoo):

    override def Run():
        visitor = BooJsPrinterVisitor(OutputWriter)
        visitor.Initialize(Context)
        visitor.Print(CompileUnit);


