namespace BooJs.Compiler.Visitors

import Boo.Lang.Environments
import Boo.Lang.Compiler.Ast
import Boo.Lang.Compiler.TypeSystem
import Boo.Lang.PatternMatching

import BooJs.Compiler.Utils
import BooJs.Compiler.TypeSystem(RuntimeMethodCache)
import BooJs.Compiler.Mozilla as Moz


class MozillaAstVisitor(FastDepthFirstVisitor):
"""
Transforms a Boo AST into a Mozilla AST
"""
    # Holds the latest conversion from a Boo node to a Moz node
    _return as Moz.Node

    protected def Return(node as Moz.Node):
        _return = node

    protected def Apply(node as Node) as Moz.Node:
        _return = null
        Visit node
        return _return

    protected def loc(node as Node):
        obj = Moz.SourceLocation()
        obj.source = node.LexicalInfo.FileName
        obj.start = Moz.SourceLocation.Position(line: node.LexicalInfo.Line, column: node.LexicalInfo.Column-1)

        # Compute an approximate end position if not available
        if node.EndSourceLocation and node.EndSourceLocation.Line >= 0:
            line, column = (node.EndSourceLocation.Line, node.EndSourceLocation.Column-1)
        else:
            parts = node.ToCodeString().Split(char('\n'))
            line, column = (node.LexicalInfo.Line, node.LexicalInfo.Column-1)
            if len(parts) > 1:
                line += len(parts) - 1
                column = 0
            column += len(parts[-1])

        obj.end = Moz.SourceLocation.Position(line: line, column: column)

        return obj

    def Run(node as Node) as Moz.Node:
        Visit node
        return _return

    def OnBoolLiteralExpression(node as BoolLiteralExpression):
        Return Moz.Literal(loc: loc(node), value: node.Value)

    def OnNullLiteralExpression(node as NullLiteralExpression):
        Return Moz.Literal(loc: loc(node), value: null)

    def OnIntegerLiteralExpression(node as IntegerLiteralExpression):
        n as Moz.IExpression
        if node.Value < 0:
            n = Moz.Literal(loc: loc(node), value: -node.Value)
            n = Moz.UnaryExpression(loc: loc(node), operator: '-', argument: n)
         else:
            n = Moz.Literal(loc: loc(node), value: node.Value)

        Return n

    def OnDoubleLiteralExpression(node as DoubleLiteralExpression):
        n as Moz.IExpression
        if node.Value < 0:
            n = Moz.Literal(loc: loc(node), value: -node.Value)
            n = Moz.UnaryExpression(loc: loc(node), operator: '-', argument: n)
         else:
            n = Moz.Literal(loc: loc(node), value: node.Value)

        Return n

    def OnStringLiteralExpression(node as StringLiteralExpression):
        Return Moz.Literal(loc: loc(node), value: node.Value)

    def OnRELiteralExpression(node as RELiteralExpression):
        Return Moz.Literal(loc: loc(node), value: node.Value, regexp: true)

    def OnSelfLiteralExpression(node as SelfLiteralExpression):
        Return Moz.ThisExpression(loc: loc(node))

    def OnListLiteralExpression(node as ListLiteralExpression):
        n = Moz.ArrayExpression(loc: loc(node))
        for itm in node.Items:
            exp = Apply(itm)
            n.elements.Add(exp)
        Return n

    def OnHashLiteralExpression(node as HashLiteralExpression):
        n = Moz.ObjectExpression(loc: loc(node))
        for pair in node.Items:
            prop = Moz.ObjectExpression.Prop(key: Apply(pair.First), value: Apply(pair.Second))
            n.properties.Add(prop)
        Return n

    def OnEnumDefinition(node as EnumDefinition):
        # Create an object with the enum values
        o = Moz.ObjectExpression(loc: loc(node))
        for member as EnumMember in node.Members:
            assert member.Initializer != null, 'Enum definition without an initializer value!'
            o.properties.Add(
                Moz.ObjectExpression.Prop(
                    key: Moz.Literal(value: member.Name), 
                    value: Apply(member.Initializer)
                )
            )

        # Assign the object to a variable
        v = Moz.VariableDeclarator(loc: loc(node))
        v.id = Moz.Identifier(loc: loc(node), name: node.FullName)
        v.init = o
        n = Moz.VariableDeclaration(loc: loc(node), kind: 'var')
        n.declarations.Add(v)

        Return n

    def OnModule(node as Module):
        n = Moz.Program(loc: loc(node))

        deps = List of Moz.IExpression() { Moz.Literal('exports'), Moz.Literal('Boo') }
        refs = List of Moz.IPattern() { Moz.Identifier('exports'), Moz.Identifier('Boo') }

        # Get namespace mapping annotations
        mapping as Hash = node['nsmapping']
        asmrefs as Hash = node['nsasmrefs']

        for ns in mapping.Keys:
            if ns in asmrefs:
                context().TraceInfo('Namespace mapping {0} => {1}', ns, mapping[ns] + ':' + asmrefs[ns])
                deps.Add( Moz.Literal(ns + ':' + asmrefs[ns]) )
            else:
                context().TraceInfo('Namespace mapping {0} => {1}', ns, mapping[ns])
                deps.Add( Moz.Literal(ns) )
            refs.Add( Moz.Identifier(mapping[ns]) )

        # Use Boo.define to bootstrap the module contents
        call = Moz.CallExpression()
        call.callee = Moz.MemberExpression(
            object: Moz.Identifier(name: 'Boo'),
            property: Moz.Identifier(name: 'define')
        )
        call.arguments.Add(Moz.Literal(value: (node.Namespace.ToString() if node.Namespace else '')))
        call.arguments.Add(Moz.ArrayExpression(elements: deps))
        fn = Moz.FunctionExpression(params: refs, body: Moz.BlockStatement())
        call.arguments.Add(fn)
        n.body.Add(Moz.ExpressionStatement(call))

        st as Moz.IStatement
        for member in node.Members:
            st = Apply(member)
            if st is null:
                continue

            if st isa Moz.BlockStatement:
                fn.body.body += (st as Moz.BlockStatement).body
            else:
                fn.body.body.Add(st)

        # Export public symbols
        members = TypeMemberCollection()
        for member in node.Members:
            if member.IsSynthetic and member.Name.EndsWith('Module'):
                members.AddRange((member as ClassDefinition).Members)
            else:
                members.Add(member)

        for member in members:
            continue unless member.IsPublic and not member.IsInternal

            expr = Moz.BinaryExpression(
                left: Moz.MemberExpression(
                    object: Moz.Identifier('exports'),
                    property: Moz.Identifier(member.Name)
                ),
                operator: '=',
                right: Moz.Identifier(member.Name)
            )

            st = Moz.ExpressionStatement(expr)
            fn.body.body.Add(st)

        if not node.Globals.IsEmpty:
            rcall = Moz.CallExpression()
            rcall.callee = Moz.MemberExpression(
                object: Moz.Identifier(name: 'Boo'),
                property: Moz.Identifier(name: 'require')
            )
            # Clone the deps list replacing 'exports' by the namespace
            deps = deps.GetRange(0, len(deps))
            deps[0] = Moz.Literal(node.Namespace or '')
            rcall.arguments.Add(Moz.ArrayExpression(elements: deps))
            fn = Moz.FunctionExpression(params: refs, body: Moz.BlockStatement())
            rcall.arguments.Add(fn)
            n.body.Add(Moz.ExpressionStatement(rcall))

            for global in node.Globals.Statements:
                st = Apply(global)
                fn.body.body.Add(st)

        #n['module'] = node
        Return n

    def OnClassDefinition(node as ClassDefinition):
        n = Moz.BlockStatement()

        # Detect module class and output its members directly
        if node.IsSynthetic and node.IsFinal and node.Name.EndsWith('Module'):
            members = [m for m in node.Members if m.NodeType != NodeType.Constructor]
            st as Moz.IStatement
            for member in members:
                match Apply(member):
                    case null:
                        continue
                    case bs=Moz.BlockStatement():
                        n.body += bs.body
                    case _:
                        n.body.Add(_)
                        
            Return n
            return

        # TODO: Handle visibility (internals should not be exposed)

        # Bar = (function (__super__) {
        #     // Constructor
        #     function Bar() {
        #         // Allow the intantiation without using the `new` operator (TODO: do we really want this?)
        #         if (!(this instanceof Bar)) { 
        #             return new (Function.prototype.bind.apply(Bar, [this].concat(Array.prototype.slice.call(arguments)) )); 
        #         }
        #
        #         // Initialize fields (TODO: can this be moved to the prototype? at least the non private ones)
        #         this.field = '';
        #
        #         // Bind instance methods (TODO: Support annotation to avoid binding)
        #         this.foo = Boo.bind(this.foo, this);
        #
        #         // Constructor code (TODO: how to handle overloads?)
        #         // ...
        #     }
        #
        #     // Setup inheritance
        #     Bar.prototype = Boo.create(__super__.prototype);
        #     Bar.prototype.constructor = Bar;
        #
        #     // Reflect metadata
        #     Bar.prototype.$boo$interfaces = [IEnumerator];
        #
        #     // Instance members
        #     Bar.prototype.foo = function Bar$foo() {
        #         __super__.prototype.foo.call(this);
        #     };
        #
        #
        #     // Inherit "static" properties (TODO: Is this actually needed?)
        #     for (var prop in __super__) {
        #         if (__super__.hasOwnProperty(prop)) {
        #             Bar[prop] = __super__[prop];
        #         }
        #     }
        #
        #     // Static members
        #     Bar.bars = function Bar$bars() {};
        #
        #     // Static constructor
        #     // ...
        #
        #     return Bar;
        # })(Foo);

        block = Moz.BlockStatement()

        # js: function Bar() {}
        cons = Moz.FunctionDeclaration(loc: loc(node))
        cons.body = Moz.BlockStatement()
        cons.id = Moz.Identifier(node.Name)
        block.body.Add(cons)


        # Initialize fields
        # TODO: Shouldn't fields with primitive initializers be moved to the prototype?
        # TODO: Boo already moves field initialization to the constructors
        for f as Field in [m for m in node.Members if m.NodeType == NodeType.Field]:
            assign = Moz.AssignmentExpression(operator:'=')
            assign.left = Moz.Identifier(loc:loc(f), name:'this.' + f.Name)
            assign.right = Apply(f.Initializer)
            cons.body.body.Add(Moz.ExpressionStatement(assign))

        # Handle constructors
        members = [m for m in node.Members if m.NodeType == NodeType.Constructor]
        for c as Constructor in members:
            continue if not c
            cons.body.body.Add(Apply(c))

        # Static members
        # js: Bar.sbar = function Bar_sbar (arg) { }
        members = [m for m in node.Members if m.NodeType == NodeType.Method and m.IsStatic]
        for method as Method in members:
            assign = Moz.AssignmentExpression(operator:'=')
            assign.left = Moz.Identifier(name:node.Name + '.' + method.Name)
            fn = Apply(method) as Moz.FunctionDeclaration
            assign.right = Moz.FunctionExpression(
                loc: fn.loc,
                id: Moz.Identifier((node.Name + '.' + fn.id.name).Replace('.', '_')),
                params: fn.params,
                body: fn.body
            )
            block.body.Add(Moz.ExpressionStatement(assign))

        # Setup inheritance
        # js: Bar.prototype = Boo.create(Foo.prototype)
        assign = Moz.AssignmentExpression(operator:'=')
        assign.left = Moz.Identifier(name:node.Name + '.prototype')
        assign.right = Moz.CallExpression()
        (assign.right as Moz.CallExpression).callee = Moz.Identifier('Boo.create')
        (assign.right as Moz.CallExpression).arguments.Add(
            Moz.Identifier(
                ('Object' if typeSystem().IsSystemObject(node.BaseTypes.First.Entity) 
                    else node.BaseTypes.First.Entity.FullName) + '.prototype'
            )
        )
        block.body.Add(Moz.ExpressionStatement(assign))

        # js: Bar.prototype.constructor = Bar
        assign = Moz.AssignmentExpression(operator:'=')
        assign.left = Moz.Identifier(name:node.Name + '.prototype.constructor')
        assign.right = Moz.Identifier(name:node.Name)
        block.body.Add(Moz.ExpressionStatement(assign))

        # Metadata
        # js: Bar.prototype.$boo$interfaces = [ IEnumerable ]
        interfaces = Moz.ArrayExpression()
        for t in node.BaseTypes:
            continue if t is node.BaseTypes.First
            continue if typeSystem().IsSystemObject(t.Entity)
            interfaces.elements.Add(
                Moz.Identifier(t.Entity.FullName)
            )
        assign = Moz.AssignmentExpression(operator:'=')
        assign.left = Moz.Identifier(name:node.Name + '.prototype.$boo$interfaces')
        assign.right = interfaces
        block.body.Add(Moz.ExpressionStatement(assign))

        # Instance members
        # js: Bar.prototype.bar = function Bar$bar (arg) { }
        members = [m for m in node.Members if m.NodeType == NodeType.Method and not m.IsStatic]
        for method as Method in members:
            assign = Moz.AssignmentExpression(operator:'=')
            assign.left = Moz.Identifier(name:node.Name + '.prototype.' + method.Name)
            fn = Apply(method) as Moz.FunctionDeclaration
            assign.right = Moz.FunctionExpression(
                loc: fn.loc,
                id: Moz.Identifier((node.Name + '.' + fn.id.name).Replace('.', '$')),
                params: fn.params,
                body: fn.body
            )
            block.body.Add(Moz.ExpressionStatement(assign))


        # Wrap everything in a self calling function and assign to a variable
        # js: Bar = (function(){ })()
        decl = Moz.VariableDeclarator(loc:loc(node))
        decl.id = Moz.Identifier(node.Name)
        decl.init = Moz.CallExpression(callee: Moz.FunctionExpression(body:block))
        decl_st = Moz.VariableDeclaration(loc:loc(node), kind:'var')
        decl_st.declarations.Add(decl)

        Return decl_st

    def OnField(node as Field):
        pass

    def OnConstructor(node as Constructor):
        OnMethod(node)
        return

        ifst = Moz.IfStatement()
        # TODO: Apply test based on arguments and constructor parameters
        ifst.test = Moz.Identifier(name:'true')

        ifst.consequent = Apply(node.Body)

        Return ifst

    def OnMethod(node as Method):
        n = Moz.FunctionDeclaration(loc: loc(node))
        n.id = Moz.Identifier(loc: loc(node), name: node.Name)
        for param in node.Parameters:
            p = Moz.Identifier(loc: loc(param), name: param.Name)
            n.params.Add(p)

        n.body = Apply(node.Body)
        Return n

    def OnDeclarationStatement(node as DeclarationStatement):
        # TODO: Generate type annotated comments
        v = Moz.VariableDeclarator(loc: loc(node))
        v.id = Moz.Identifier(name: node.Declaration.Name)
        v.init = Apply(node.Initializer)

        vd = Moz.VariableDeclaration(loc: loc(node), kind: 'var')
        vd.declarations.Add(v)
        Return vd

    def OnBlock(node as Block):
        b = Moz.BlockStatement(loc: loc(node))
        for st in node.Statements:
            mst = Apply(st) as Moz.IStatement
            if mst:
                b.body.Add(mst)

        Return b

    def OnExpressionStatement(node as ExpressionStatement):
        n = Moz.ExpressionStatement(loc: loc(node))
        n.expression = Apply(node.Expression)
        Return n

    def OnReturnStatement(node as ReturnStatement):
        n = Moz.ReturnStatement(loc: loc(node))
        n.argument = Apply(node.Expression)
        Return n

    def OnIfStatement(node as IfStatement):

        ifst = Moz.IfStatement(loc: loc(node))
        ifst.test = Apply(node.Condition)
        ifst.consequent = Apply(node.TrueBlock)
        if node.FalseBlock and not node.FalseBlock.IsEmpty:
            blk = node.FalseBlock
            if len(blk.Statements) == 1 and blk.FirstStatement isa IfStatement:
                ifst.alternate = Apply(blk.FirstStatement)
            else:
                ifst.alternate = Apply(blk)

        Return ifst

    def OnForStatement(node as ForStatement):
        # TODO: Optimize range(items.length) to cache the length value

        # Only those for statements iterating over simple `range` should have survived
        mie = node.Iterator as MethodInvocationExpression
        if len(mie.Arguments) == 1:
            start = Moz.Literal(0)
            length = Apply(mie.Arguments[0])
        else:
            start = Apply(mie.Arguments[0])
            length = Apply(mie.Arguments[1])

        index = Moz.Identifier(node.Declarations[0].Name)

        fst = Moz.ForStatement(loc: loc(node))
        fst.init = Moz.AssignmentExpression(
            left: index,
            operator: '=',
            right: start
        )
        fst.test = Moz.BinaryExpression(
            left: index,
            operator: '<',
            right: length
        )
        fst.update = Moz.UpdateExpression(
            argument: index,
            operator: '++',
            prefix: false
        )

        fst.body = Apply(node.Block)
        Return fst

    def OnWhileStatement(node as WhileStatement):
        wst = Moz.WhileStatement(loc: loc(node))
        wst.test = Apply(node.Condition)
        wst.body = Apply(node.Block)

        Return wst

    def OnTryStatement(node as TryStatement):


        n = Moz.TryStatement(loc: loc(node))
        n.block = Apply(node.ProtectedBlock)

        assert len(node.ExceptionHandlers) <= 1, 'Multiple exceptions handlers should be processed in previous steps'
        if len(node.ExceptionHandlers):
            hdl = node.ExceptionHandlers[0]
            h = Moz.CatchClause(loc: loc(hdl))
            h.param = Moz.Identifier(loc: loc(hdl.Declaration), name: hdl.Declaration.Name)
            h.body = Apply(hdl.Block)
            n.handlers.Add(h)

        if node.EnsureBlock:
            n.finalizer = Apply(node.EnsureBlock)

        Return n

    def OnBreakStatement(node as BreakStatement):
        Return Moz.BreakStatement(loc: loc(node))

    def OnContinueStatement(node as ContinueStatement):
        Return Moz.ContinueStatement(loc: loc(node))

    def OnLabelStatement(node as LabelStatement):
        n = Moz.LabeledStatement(loc: loc(node))
        n.label = Moz.Identifier(loc: loc(node), name: node.Name)

        # In Mozilla AST labels are always associated with a statement.
        stmts = (node.ParentNode as Block).Statements
        idx = stmts.IndexOf(node)
        st = stmts[idx + 1]
        stmts.RemoveAt(idx + 1)

        if st.NodeType not in (NodeType.ForStatement, NodeType.WhileStatement):
            raise 'Javascript only allows label on looping statements'
        n.body = Apply(st)

        Return n

    def OnGotoStatement(node as GotoStatement):
        n = Moz.ContinueStatement(loc: loc(node))
        n.label = Moz.Identifier(loc: loc(node.Label), name: node.Label.Name)
        Return n

    def OnRaiseStatement(node as RaiseStatement):
        # TODO: Move this to clean step
        /*
        if false and Context.Parameters.Debug:
            n = Moz.CallExpression(loc: loc(node))
            n.callee = Moz.MemberExpression(
                loc: loc(node),
                object: Moz.Identifier(name: 'Boo'),
                property: Moz.Identifier(name: 'raise')
            )
            # TODO: We should make sure it's a constructor
            if node.Exception isa MethodInvocationExpression:
                c = Moz.NewExpression(loc: loc(node.Exception))
                c._constructor = Apply(node.Exception)
                n.arguments.Add(c)
            else:
                n.arguments.Add(Apply(node.Exception))

            lex = node.Exception.LexicalInfo
            n.arguments.Add(Moz.Literal(value: lex.FileName))
            n.arguments.Add(Moz.Literal(value: lex.Line))

            Return Moz.ExpressionStatement(loc: loc(node), expression: n)
        else:
        */
        t = Moz.ThrowStatement(loc: loc(node))
        t.argument = Apply(node.Exception)
        # TODO: We should make sure it's a constructor
        /*
        if false and node.Exception isa MethodInvocationExpression:
            c = Moz.NewExpression(loc: loc(node.Exception))
            c._constructor = Apply(node.Exception)
            t.argument = c
        else:
        */

        Return t

    def OnReferenceExpression(node as ReferenceExpression):
        Return Moz.Identifier(loc: loc(node), name: node.Name)

    def OnMemberReferenceExpression(node as MemberReferenceExpression):
        n = Moz.MemberExpression(loc: loc(node), property: Moz.Identifier(loc: loc(node), name: node.Name))
        n.object = Apply(node.Target)
        Return n

    def OnConditionalExpression(node as ConditionalExpression):
    """ Convert to the ternary operator.
            (10 if true else 20)  -->  true ? 10 : 20
    """
        c = Moz.ConditionalExpression(loc: loc(node))
        c.test = Apply(node.Condition)
        c.consequent = Apply(node.TrueValue)
        c.alternate = Apply(node.FalseValue)
        Return c

    def OnSlicingExpression(node as SlicingExpression):
        n = Moz.MemberExpression(
            loc: loc(node),
            object: Apply(node.Target),
            property: Apply(node.Indices[0].Begin),
            computed: true
        )

        Return n

    def OnMacroStatement(node as MacroStatement):
        # Special handling for switch/case constructs (used in generators)
        if node.Name == 'switch':
            switch = Moz.SwitchStatement(loc: loc(node))
            switch.discriminant = Apply(node.Arguments[0])
            for casemacro as MacroStatement in node.Body.Statements:
                assert casemacro isa MacroStatement

                case = Moz.SwitchCase(loc: loc(casemacro))
                case.test = Apply(casemacro.Arguments[0])
                for st in casemacro.Body.Statements:
                    case.consequent.Add(Apply(st))

                switch.cases.Add(case)

            Return switch
        else:
            raise 'Macro statements should have been already resolved'


    def OnMethodInvocationExpression(node as MethodInvocationExpression):

        # Detect constructors
        if node.ContainsAnnotation('constructor') or \
           node.Target.Entity isa IConstructor and not isFactory(node.Target):
            c = Moz.NewExpression(loc: loc(node))
            c._constructor = Apply(node.Target)
            for arg in node.Arguments:
                c.arguments.Add(Apply(arg))
            Return c
        # Detect sequences
        elif node.Target.ToString() == '@':
            s = Moz.SequenceExpression(loc: loc(node))
            for arg in node.Arguments:
                s.expressions.Add(Apply(arg))
            Return s

        else:
            n = Moz.CallExpression(loc: loc(node))
            n.callee = Apply(node.Target)
            for arg in node.Arguments:
                n.arguments.Add(Apply(arg))

            # Detect calls to eval() with a simple string argument to define a
            # verbatim version of the expression.
            # cache = my(RuntimeMethodCache)
            cache = My[of RuntimeMethodCache].Instance
            if node.Target.Entity is cache.Eval and \
               len(node.Arguments) == 1 and \
               node.Arguments[0].NodeType == NodeType.StringLiteralExpression:
                n.verbatim = (node.Arguments[0] as StringLiteralExpression).Value

            Return n

    def OnBlockExpression(node as BlockExpression):
        n = Moz.FunctionExpression(loc: loc(node))
        for param in node.Parameters:
            p = Moz.Identifier(loc: loc(param), name: param.Name)
            n.params.Add(p)

        n.body = Apply(node.Body)
        Return n

    def OnBinaryExpression(node as BinaryExpression):
        n = Moz.BinaryExpression(loc: loc(node))
        match node.Operator:
            case BinaryOperatorType.ReferenceEquality:
                if NodeType.NullLiteralExpression in (node.Left.NodeType, node.Right.NodeType):
                    Return(ProcessIsNull(node))
                    return

                n.operator = '==='
            case BinaryOperatorType.ReferenceInequality:
                if NodeType.NullLiteralExpression in (node.Left.NodeType, node.Right.NodeType):
                    ue = Moz.UnaryExpression(loc: loc(node), operator: '!')
                    ue.argument = ProcessIsNull(node)
                    Return ue
                    return

                n.operator = '!=='

            case BinaryOperatorType.Equality:
                n.operator = '=='
            case BinaryOperatorType.Inequality:
                n.operator = '!='

            case BinaryOperatorType.Member:
                n.operator = 'in'
            case BinaryOperatorType.Addition:
                n.operator = '+'
            case BinaryOperatorType.Subtraction:
                n.operator = '-'
            case BinaryOperatorType.Multiply:
                n.operator = '*'
            case BinaryOperatorType.Division:
                n.operator = '/'
            case BinaryOperatorType.Modulus:
                n.operator = '%'
            case BinaryOperatorType.BitwiseAnd:
                n.operator = '&'
            case BinaryOperatorType.BitwiseOr:
                n.operator = '|'
            case BinaryOperatorType.ExclusiveOr:
                n.operator = '^'
            case BinaryOperatorType.GreaterThan:
                n.operator = '>'
            case BinaryOperatorType.GreaterThanOrEqual:
                n.operator = '>='
            case BinaryOperatorType.LessThan:
                n.operator = '<'
            case BinaryOperatorType.LessThanOrEqual:
                n.operator = '<='
            case BinaryOperatorType.ShiftLeft:
                n.operator = '<<'
            case BinaryOperatorType.ShiftRight:
                n.operator = '>>'

            case BinaryOperatorType.Assign:
                n = Moz.AssignmentExpression(loc: loc(node), operator: '=')
            case BinaryOperatorType.InPlaceBitwiseAnd:
                n = Moz.AssignmentExpression(loc: loc(node), operator: '&=')
            case BinaryOperatorType.InPlaceBitwiseOr:
                n = Moz.AssignmentExpression(loc: loc(node), operator: '|=')
            case BinaryOperatorType.InPlaceExclusiveOr:
                n = Moz.AssignmentExpression(loc: loc(node), operator: '^=')

            case BinaryOperatorType.And:
                n = Moz.LogicalExpression(loc: loc(node), operator: '&&')
            case BinaryOperatorType.Or:
                n = Moz.LogicalExpression(loc: loc(node), operator: '||')


            otherwise:
                raise 'Operator not supported ' + node.Operator

        n.left = Apply(node.Left)
        n.right = Apply(node.Right)
        Return n

    def OnUnaryExpression(node as UnaryExpression):
        match node.Operator:
            case UnaryOperatorType.UnaryNegation:
                n = Moz.UnaryExpression(loc: loc(node), operator: '-')
            case UnaryOperatorType.LogicalNot:
                n = Moz.UnaryExpression(loc: loc(node), operator: '!')
            case UnaryOperatorType.OnesComplement:
                n = Moz.UnaryExpression(loc: loc(node), operator: '~')
            case UnaryOperatorType.Increment:
                n = Moz.UpdateExpression(loc: loc(node), operator: '++', prefix: true)
            case UnaryOperatorType.Decrement:
                n = Moz.UpdateExpression(loc: loc(node), operator: '--', prefix: true)
            case UnaryOperatorType.PostIncrement:
                n = Moz.UpdateExpression(loc: loc(node), operator: '++', prefix: false)
            case UnaryOperatorType.PostDecrement:
                n = Moz.UpdateExpression(loc: loc(node), operator: '--', prefix: false)
            otherwise:
                raise 'Operator not supported ' + node.Operator

        n.argument = Apply(node.Operand)
        Return n

    protected def ProcessIsNull(node as BinaryExpression) as Moz.IExpression:
        itm = (node.Right if node.Left.NodeType == NodeType.NullLiteralExpression else node.Left)
        call = Moz.CallExpression(loc: loc(node))
        call.callee = Moz.Identifier('Boo.isNull')
        call.arguments.Add(Apply(itm))
        return call
