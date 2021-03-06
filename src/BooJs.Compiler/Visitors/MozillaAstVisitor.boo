namespace BooJs.Compiler.Visitors

from Boo.Lang.Environments import My
from Boo.Lang.Compiler.Ast import *
from Boo.Lang.Compiler.TypeSystem import *
from Boo.Lang.PatternMatching import *

from BooJs.Compiler.Utils import *
from BooJs.Compiler import UniqueNameProvider, Mozilla as Moz
from BooJs.Compiler.TypeSystem import RuntimeMethodCache


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

    def OnCompileUnit(node as CompileUnit):
        p = Moz.Program()
        for mod in node.Modules:
            Visit(mod)
            for st in (_return as Moz.BlockStatement).body:
                p.body.Add(st)
        Return p

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
    """ If it's inside a constructor we keep the `self` identifier since they
        act as a factory. Otherwise we create a `this` keyword
    """
        if node.GetAncestor[of Constructor]() or node.GetAncestor[of BlockExpression]():
            Return Moz.Identifier(loc: loc(node), 'self')
        else:
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
        Return CreateVar(node, node.Name, o)

    protected def CreateVar(node as Node, name as string, value as Moz.IExpression):
        v = Moz.VariableDeclarator(loc: loc(node))
        v.id = Moz.Identifier(loc: loc(node), name)
        v.init = value
        n = Moz.VariableDeclaration(loc: loc(node), kind: 'var')
        n.declarations.Add(v)
        return n

    protected def CreateAssign(loc as Moz.SourceLocation, ident as string, value as Moz.IExpression):
        a = Moz.AssignmentExpression(loc: loc, operator:'=')
        a.left = Moz.Identifier(loc: loc, name: ident)
        a.right = value
        return a

    def OnModule(node as Module):
        n = Moz.BlockStatement(loc: loc(node))

        deps = List of Moz.IExpression() { Moz.Literal('Boo') }
        refs = List of Moz.IPattern() { Moz.Identifier('Boo') }

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
        call.arguments.Add(Moz.Literal(value: (node.Namespace.Name if node.Namespace else '')))
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
        # js: exports.symbol = symbol
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
            rcall.arguments.Add(Moz.ArrayExpression(elements: deps))
            fn = Moz.FunctionExpression(params: refs, body: Moz.BlockStatement())
            rcall.arguments.Add(fn)
            n.body.Add(Moz.ExpressionStatement(rcall))

            for global in node.Globals.Statements:
                st = Apply(global)
                fn.body.body.Add(st)

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

        # Bar = (function (_super_) {
        #     // Constructor
        #     function Bar(_init_) {
        #         // Call constructor (for calls from JS or duck code)
        #         // TODO: Use `this instanceof Bar` test instead?
        #         if (_init_ !== Boo.INIT)
        #             return Boo.overload(arguments, [ [], ['string', 'int'] ], [Foo.ctor$0, Foo.ctor$1]);
        #
        #         // Initialize fields (TODO: can this be moved to the prototype?)
        #         this.field = '';
        #
        #         // Bind public instance methods (NOTE: also inherited) (TODO: Support annotation to avoid binding)
        #         this.foo = Boo.bind(this.foo, this);
        #     }
        #
        #     // Inherit "static" members
        #     Boo.extend(Bar, _super_);
        #
        #     // Static constructor factories (called from typed code)
        #     Bar.ctor$0 = function Bar$ctor$0() {
        #         var self = this instanceof Foo ? this : new Foo(Boo.INIT);
        #         // Call parent constructor
        #         _super_.call(self);
        #         // Call constructor overload
        #         Bar.ctor$1.call(self, 'foo')
        #         // constructor logic
        #         ...
        #         return self;
        #     }
        #
        #     // Static members
        #     Bar.bars = function Bar$$bars() {};
        #
        #     // Setup inheritance (TODO: move this into Boo.extend?)
        #     Bar.prototype = Boo.create(_super_.prototype);
        #     Bar.prototype.constructor = Bar;
        #
        #     // Reflect metadata
        #     Bar.prototype.$boo$interfaces = [IEnumerator];
        #     Bar.prototype.$boo$super = _super_
        #
        #     // Alias static members to instance (for JavaScript access)
        #     // TODO: Shall we differ from Boo an only allow static access on type?
        #     Bar.prototype.bars = Bar.bars;
        #     
        #     // Instance members
        #     Bar.prototype.foo = function Bar$foo() {
        #         // Call parent method
        #         _super_.prototype.foo.call(this);
        #     };
        #
        #     // Static constructor logic (in .Net this only runs when the type is first accessed)
        #     ...
        #
        #     return Bar;
        # })(Foo);

        # TODO: Support constructor overloading
        constructors = [c for c in node.Members if c.NodeType == NodeType.Constructor]
        if len(constructors) > 1:
            raise "Constructor overloading not supported yet"

        block = Moz.BlockStatement()

        # Constructor
        # js: function Bar(_init_) {}
        cons = Moz.FunctionDeclaration(loc: loc(node))
        cons.params = List[of Moz.IPattern]() { Moz.Identifier('_init_') }
        cons.body = Moz.BlockStatement()
        cons.id = Moz.Identifier(node.Name)
        block.Add(cons)

        # Call constructor factory
        # js: if (_init_ !== Boo.INIT) return Boo.overload(arguments, [ ... ], [ cons$0, cons$1 ])
        ifst = Moz.IfStatement(loc: loc(node))
        ifst.test = Moz.BinaryExpression(
            operator: '!==',
            left: Moz.Identifier('_init_'),
            right: Moz.Identifier('Boo.INIT')
        )
        # TODO: Build a proper overload call
        ifst.consequent = Moz.ReturnStatement(
            argument: Moz.CallExpression(
                callee: Moz.Identifier(node.Name + '.constructor.apply'),
                arguments: List[of Moz.IExpression]() {
                    Moz.Literal(value: null),
                    Moz.Identifier('arguments')
                }
            )
            # argument: Moz.CallExpression(
            #     callee: Moz.Identifier('Boo.overload'),
            #     arguments: List[of Moz.IExpression]() {
            #         Moz.Identifier('arguments'),
            #         Moz.Literal(value: []),
            #         Moz.Literal(value: [])
            #     }
            # )
        )
        cons.body.Add(ifst)

        # Call parent constructor
        ce = Moz.CallExpression(
            callee: Moz.Identifier('_super_.apply'),
            arguments: List[of Moz.IExpression]() {
                Moz.ThisExpression(),
                Moz.Identifier('arguments')
            }
        )
        cons.body.Add(ce)

        # Bind instance methods
        # js: this.foo = Boo.bind(this.foo, this);
        for m in node.Members:
            continue unless m.NodeType == NodeType.Method and not m.IsStatic
            assign = CreateAssign(loc(m), "this.$(m.Name)", Moz.CallExpression(
                Moz.Identifier('Boo.bind'),
                Moz.MemberExpression(
                    object: Moz.ThisExpression(),
                    property: Moz.Identifier(m.Name)
                ),
                Moz.ThisExpression()
            ))
            cons.body.Add(assign)

        # Events
        # TODO: Do it properly (ie: static events?)
        for e as Event in [m for m in node.Members if m.NodeType == NodeType.Event]:
            assign = CreateAssign(loc(e), "this.$(e.Name)", null)
            assign.right = Moz.CallExpression(callee: Moz.Identifier('Boo.event'))
            cons.body.Add(assign)

        # Initialize fields
        # TODO: Shouldn't fields with primitive initializers be moved to the prototype?
        # TODO: Boo already moves field initialization to the constructors
        for f as Field in [m for m in node.Members if m.NodeType == NodeType.Field]:
            if f.Initializer:
                assign = CreateAssign(loc(f), "this.$(f.Name)", Apply(f.Initializer))
                cons.body.Add(assign)
            else:
                # TODO: Define fields according to their default values for each type
                assign = CreateAssign(loc(f), "this.$(f.Name)", Moz.Literal(null))
                cons.body.Add(assign)

        # Inherit "static" members from the parent type
        # js: Boo.extend(Bar, _super_)
        block.Add(Moz.CallExpression(
            Moz.Identifier('Boo.extend'),
            Moz.Identifier(node.Name),
            Moz.Identifier('_super_')
        ))

        # Include constructor factories as private scoped functions
        members = [m for m in node.Members if m.NodeType == NodeType.Constructor]
        for c as Constructor in members:
            continue if not c

            assign = CreateAssign(loc(node), "$(node.Name).$(c.Name)", null)
            fn = Apply(c) as Moz.FunctionDeclaration
            assign.right = Moz.FunctionExpression(
                loc: fn.loc,
                id: Moz.Identifier(node.FullName.Replace('.', '$') + '$$' + c.Name),
                params: fn.params,
                body: fn.body
            )
            block.Add(assign)

        # Static members
        # js: Bar.sbar = function Bar$$sbar (arg) { }
        # TODO: Handle static fields too!
        for m in node.Members:
            continue unless m.NodeType == NodeType.Method and m.IsStatic
            assign = CreateAssign(loc(m), "$(node.Name).$(m.Name)", null)
            fn = Apply(m) as Moz.FunctionDeclaration
            assign.right = Moz.FunctionExpression(
                loc: fn.loc,
                id: Moz.Identifier(node.FullName.Replace('.', '$') + '$$' + m.Name),
                params: fn.params,
                body: fn.body
            )
            block.Add(assign)

        # Setup inheritance
        # js: Bar.prototype = Boo.create(_super_.prototype)
        assign = CreateAssign(loc(node), "$(node.Name).prototype", Moz.CallExpression(
            Moz.Identifier('Boo.create'),
            Moz.Identifier('_super_.prototype')
        ))
        block.Add(assign)
        # js: Bar.prototype.constructor = Bar
        assign = CreateAssign(loc(node), "$(node.Name).prototype.constructor", Moz.Identifier(node.Name))
        block.Add(assign)

        # Metadata
        # js: Bar.prototype.$boo$interfaces = [ IEnumerable ]
        interfaces = Moz.ArrayExpression()
        for t in node.BaseTypes:
            continue if t is node.BaseTypes.First
            continue if typeSystem().IsSystemObject(t.Entity)
            interfaces.elements.Add(
                Moz.Identifier(t.Entity.FullName)
            )
        assign = CreateAssign(loc(node), node.Name + '.prototype.$boo$interfaces', interfaces)
        block.Add(assign)
        # js: Bar.prototype.$boo$super = _super_
        assign = CreateAssign(loc(node), node.Name + '.prototype.$boo$super', Moz.Identifier('_super_'))
        block.Add(assign)

        # Alias static members to instance (for JavaScript access)
        # js: Bar.prototype.bars = Bar.bars;
        # TODO: Shall we differ from Boo an only allow static access on type?
        for m in node.Members:
            continue unless m.NodeType == NodeType.Method and m.IsStatic
            assign = CreateAssign(loc(m), node.Name + '.prototype.' + m.Name, Moz.Identifier(node.Name + '.' + m.Name))
            block.Add(assign)

        # Instance members
        # js: Bar.prototype.bar = function Bar$bar (arg) { }
        members = [m for m in node.Members if m.NodeType == NodeType.Method and not m.IsStatic]
        for method as Method in members:
            assign = CreateAssign(loc(node), node.Name + '.prototype.' + method.Name, null)
            fn = Apply(method) as Moz.FunctionDeclaration
            assign.right = Moz.FunctionExpression(
                loc: fn.loc,
                id: Moz.Identifier(node.FullName.Replace('.', '$') + '$' + fn.id.name),
                params: fn.params,
                body: fn.body
            )
            block.Add(assign)

        # Instance properties
        # TODO: Can we generate actual JavaScript properties too?
        members = [m for m in node.Members if m.NodeType == NodeType.Property and not m.IsStatic]
        for prop as Property in members:
            if prop.Getter:
                assign = CreateAssign(loc(prop.Getter), node.Name + '.prototype.get_' + prop.Name, null)
                fn = Apply(prop.Getter) as Moz.FunctionDeclaration
                assign.right = Moz.FunctionExpression(
                    loc: fn.loc,
                    id: Moz.Identifier(node.FullName.Replace('.', '$') + '$' + fn.id.name),
                    params: fn.params,
                    body: fn.body
                )
                block.Add(assign)
            if prop.Setter:
                assign = CreateAssign(loc(prop.Setter), node.Name + '.prototype.set_' + prop.Name, null)
                fn = Apply(prop.Setter) as Moz.FunctionDeclaration
                assign.right = Moz.FunctionExpression(
                    loc: fn.loc,
                    id: Moz.Identifier(node.FullName.Replace('.', '$') + '$' + fn.id.name),
                    params: fn.params,
                    body: fn.body
                )
                block.Add(assign)

        # TODO: Include static constructor logic to run when creating the type


        # Wrap everything in a self calling function and assign to a variable
        # js: Bar = (function(_super_){ ... return Bar; })(Object)
        block.body.Add(
            Moz.ReturnStatement(argument: Moz.Identifier(node.Name))
        )

        func = Moz.FunctionExpression(body:block)
        func.params = List of Moz.IPattern() { Moz.Identifier('_super_') }
        call = Moz.CallExpression(callee:func)
        call.arguments.Add(
            Moz.Identifier(
                ('Object' if typeSystem().IsSystemObject(node.BaseTypes.First.Entity) 
                    # TODO: The reference should take into account imported namespaces
                    else node.BaseTypes.First.Entity.FullName)
            )
        )

        Return CreateVar(node, node.Name, call)

    def OnField(node as Field):
        # This is basically to support `const` (static fields in the module class)
        if node.IsStatic:
            if ent = node.Entity as IField:
                init = Moz.Literal(ent.StaticValue)
            elif node.Initializer:
                init = Apply(node.Initializer)
            Return CreateVar(node, node.Name, init)

    def OnConstructor(node as Constructor):
        n = Moz.FunctionDeclaration(loc: loc(node))
        n.id = Moz.Identifier(loc: loc(node), name: node.FullName.Replace('.', '$'))
        for param in node.Parameters:
            p = Moz.Identifier(loc: loc(param), name: param.Name)
            n.params.Add(p)

        n.body = Apply(node.Body)

        // js: var self = this instanceof Foo ? this : new Foo(Boo.INIT);
        n.body.body.Insert(0, CreateVar(
            node,
            'self',
            Moz.ConditionalExpression(
                test: Moz.BinaryExpression(
                    operator: 'instanceof',
                    left: Moz.ThisExpression(),
                    right: Moz.Identifier(node.DeclaringType.Name)
                ),
                consequent: Moz.ThisExpression(),
                alternate: Moz.NewExpression(
                    _constructor: Moz.Identifier(node.DeclaringType.Name),
                    arguments: List[of Moz.IExpression]() {
                        Moz.Identifier('Boo.INIT')
                    }
                )
            )
        ))
        // js: return self
        n.body.Add(
            Moz.ReturnStatement(
                argument: Moz.Identifier('self')
            )
        )

        Return n

    def OnMethod(node as Method):
        n = Moz.FunctionDeclaration(loc: loc(node))
        n.id = Moz.Identifier(loc: loc(node), name: node.Name)
        for param in node.Parameters:
            p = Moz.Identifier(loc: loc(param), name: param.Name)
            n.params.Add(p)

        n.body = Apply(node.Body)

        # HACK: Dirty hack to reference the instance from inside block expressions
        # TODO: Properly implement this by checking if the method actually contains block expressions
        n.body.body.Insert(0, CreateVar(node, 'self', Moz.ThisExpression()))

        Return n

    def OnDeclarationStatement(node as DeclarationStatement):
        # TODO: Generate type annotated comments
        Return CreateVar(node, node.Declaration.Name, Apply(node.Initializer))

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

        if node.GetAncestor[of BlockExpression]():
            n.argument = Apply(node.Expression)
        # Inside constructors always return `self`
        elif node.GetAncestor[of Constructor]():
            n.argument = Moz.Identifier('self')
        else:
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
        # TODO: Optimize range(f, t) and range(f, t, s)
        #       for (i=f; (s > 0 && i < t) || (s < 0 && i > t); i += s)

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
        fst.init = CreateAssign(loc(node), index.name, start)
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

    def OnSuperLiteralExpression(node as SuperLiteralExpression):
        n = Moz.Identifier('_super_')
        Return n

    def OnMethodInvocationExpression(node as MethodInvocationExpression):

        # Detect constructors
        if node.ContainsAnnotation('constructor') or \
           node.Target.Entity and node.Target.Entity.EntityType == EntityType.Constructor and not isFactory(node.Target):
            # TODO: Check if we know for sure there is a constructor factory
            c = Moz.NewExpression(loc: loc(node))
            c._constructor = Apply(node.Target)
            for arg in node.Arguments:
                c.arguments.Add(Apply(arg))
            Return c
            # ce = Moz.CallExpression(loc: loc(node))
            # ce.callee = Moz.MemberExpression(
            #     object: Apply(node.Target),
            #     property: Moz.Identifier('constructor')
            # )
            # for arg in node.Arguments:
            #     ce.arguments.Add(Apply(arg))
            # Return ce
        # Detect sequences
        elif node.Target.ToString() == '@':
            s = Moz.SequenceExpression(loc: loc(node))
            for arg in node.Arguments:
                s.expressions.Add(Apply(arg))
            Return s
        # Detect super()
        elif node.Target.NodeType == NodeType.SuperLiteralExpression:
            method = node.GetAncestor[of Method]()
            n = Moz.CallExpression(loc: loc(node))
            n.callee = Moz.Identifier('_super_.prototype.' + method.Name + '.call')
            n.arguments.Add(Moz.ThisExpression())
            for arg in node.Arguments:
                n.arguments.Add(Apply(arg))
            Return n

        else:
            n = Moz.CallExpression(loc: loc(node))
            n.callee = Apply(node.Target)
            for arg in node.Arguments:
                n.arguments.Add(Apply(arg))

            # Detect calls to eval()
            cache = My[of RuntimeMethodCache].Instance
            if node.Target.Entity is cache.Eval:
                n.callee = Moz.Identifier('eval')
                # Check if we can use verbatim code for the node
                if node.ContainsAnnotation('verbatim') and \
                   arg = node.Arguments.First and arg.NodeType == NodeType.StringLiteralExpression:
                    n.verbatim = (arg as StringLiteralExpression).Value

            Return n

    def OnBlockExpression(node as BlockExpression):
        n = Moz.FunctionExpression(loc: loc(node))
        for param in node.Parameters:
            p = Moz.Identifier(loc: loc(param), name: param.Name)
            n.params.Add(p)

        n.body = Apply(node.Body)
        Return n

    def OnBinaryExpression(node as BinaryExpression):
        # TODO: Do we actually get these inplace operators?
        match node.Operator:
            case BinaryOperatorType.InPlaceAddition:
                node.Right = [| $(node.Left) + $(node.Right) |]
                node.Operator = BinaryOperatorType.Assign
            case BinaryOperatorType.InPlaceDivision:
                node.Right = [| $(node.Left) / $(node.Right) |]
                node.Operator = BinaryOperatorType.Assign
            case BinaryOperatorType.InPlaceModulus:
                node.Right = [| $(node.Left) % $(node.Right) |]
                node.Operator = BinaryOperatorType.Assign
            case BinaryOperatorType.InPlaceMultiply:
                node.Right = [| $(node.Left) * $(node.Right) |]
                node.Operator = BinaryOperatorType.Assign
            case BinaryOperatorType.InPlaceSubtraction:
                node.Right = [| $(node.Left) - $(node.Right) |]
                node.Operator = BinaryOperatorType.Assign
            case BinaryOperatorType.InPlaceBitwiseAnd:
                node.Right = [| $(node.Left) & $(node.Right) |]
                node.Operator = BinaryOperatorType.Assign
            case BinaryOperatorType.InPlaceBitwiseOr:
                node.Right = [| $(node.Left) | $(node.Right) |]
                node.Operator = BinaryOperatorType.Assign
            case BinaryOperatorType.InPlaceExclusiveOr:
                node.Right = [| $(node.Left) ^ $(node.Right) |]
                node.Operator = BinaryOperatorType.Assign
            case BinaryOperatorType.InPlaceShiftLeft:
                node.Right = [| $(node.Left) << $(node.Right) |]
                node.Operator = BinaryOperatorType.Assign
            case BinaryOperatorType.InPlaceShiftRight:
                node.Right = [| $(node.Left) >> $(node.Right) |]
                node.Operator = BinaryOperatorType.Assign
            otherwise:
                pass


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
                
            case BinaryOperatorType.And:
                n = Moz.LogicalExpression(loc: loc(node), operator: '&&')
            case BinaryOperatorType.Or:
                n = Moz.LogicalExpression(loc: loc(node), operator: '||')

            case BinaryOperatorType.Assign:
                # HACK: Don't know why the setter is not automatically converted to a call.
                #       We have to perform the conversion here. It probably needs more work.
                if node.Left.Entity and node.Left.Entity.EntityType == EntityType.Property:
                    mre = node.Left as MemberReferenceExpression
                    ce = Moz.CallExpression(
                        Moz.MemberExpression(
                            Apply(mre.Target),
                            'set_' + mre.Name
                        ),
                        Apply(node.Right),
                        loc: loc(node)
                    )
                    Return ce
                    return
                n = Moz.AssignmentExpression(loc: loc(node), operator: '=')

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
