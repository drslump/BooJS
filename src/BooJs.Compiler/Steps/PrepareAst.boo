namespace BooJs.Compiler.Steps

import Boo.Lang.Compiler
from Boo.Lang.Compiler.Ast import *
from Boo.Lang.Compiler.Steps import AbstractTransformerCompilerStep, IntroduceModuleClasses

from Boo.Lang.Environments import EnvironmentProvision
from Boo.Lang.Compiler.TypeSystem import EntityType
from Boo.Lang.Compiler.TypeSystem.Services import RuntimeMethodCache as BooRuntimeMethodCache
from Boo.Lang.Compiler.TypeSystem.Reflection import ExternalType
from BooJs.Compiler.TypeSystem import RuntimeMethodCache
from BooJs.Lang.Extensions import TransformAttribute, VarArgsAttribute

from System.Runtime.CompilerServices import CompilerGeneratedAttribute, CompilerGlobalScopeAttribute


class PrepareAst(AbstractTransformerCompilerStep):
"""
    Prepare the AST for its conversion to Javascript

        - Remove unneeded nodes
        - Convert builtins and runtime references

"""
    [getter(MethodCache)]
    private _methodCache as RuntimeMethodCache

    [getter(BooMethodCache)]
    private _booMethodCache as BooRuntimeMethodCache


    protected def HasAttribute[of T(System.Attribute)](node as Node):
        if ent = node.Entity as TypeSystem.IExternalEntity:
            return (HasAttribute[of T](ent) if ent else null as T)
        
        if anode = node as INodeWithAttributes:
            targetAttr = TypeSystemServices.Map(T)
            for attr in anode.Attributes:
                ctor = TypeSystemServices.GetEntity(attr) as TypeSystem.IConstructor
                if ctor and targetAttr == ctor.DeclaringType:
                    return true

        return false

    protected def HasAttribute[of T(System.Attribute)](entity as TypeSystem.IExternalEntity):
        return System.Attribute.GetCustomAttribute(entity.MemberInfo, typeof(T)) != null

    protected def IsCompilerGenerated(node as Node):
        return HasAttribute[of CompilerGeneratedAttribute](node)

    protected def IsBuiltin(node as Node) as bool:
        entity = node.Entity as TypeSystem.Reflection.ExternalType
        if not entity and centity = node.Entity as TypeSystem.ExternalMethod:
            entity = centity.DeclaringType

        return false if not entity
        return true if entity.Type is TypeSystemServices.BuiltinsType
        return entity.DeclaringType == TypeSystemServices.BuiltinsType

    protected def IsGlobal(node as Node) as bool:
        if entity = node.Entity as TypeSystem.Reflection.ExternalType:
            return entity.ActualType.Namespace == 'BooJs.Lang.Globals'

        return false

    def Initialize(context as CompilerContext):
        super(context)

        _methodCache = EnvironmentProvision[of RuntimeMethodCache]()
        _booMethodCache = EnvironmentProvision[of BooRuntimeMethodCache]()

    def EnterModule(node as Module):
        if IsCompilerGenerated(node):
            RemoveCurrentNode()
            return false

        # TODO: Is this still needed?
        if node.Name == 'CompilerGenerated':
            RemoveCurrentNode()
            return false

        return true

    def EnterClassDefinition(node as ClassDefinition):
        if IsCompilerGenerated(node):
            RemoveCurrentNode()
            return false

        # TODO: Is this still needed?
        if node.Name == 'CompilerGeneratedExtensions':
            RemoveCurrentNode()
            return false

        return true

    def OnExpressionStatement(node as ExpressionStatement):
        # Ignore the assignment of locals produced by closures instrumentation
        be = node.Expression as BinaryExpression
        if be and be.Operator == BinaryOperatorType.Assign and be.Left.ToString() == '$locals':
            RemoveCurrentNode
            return

        # Ignore initialization value calls (__initobj__). We do it elsewhere.
        mie = node.Expression as MethodInvocationExpression
        if mie and mie.Target.Entity == TypeSystem.BuiltinFunction.InitValueType:
            RemoveCurrentNode
            return

        super(node)

    protected def ProcessReference(node as ReferenceExpression) as Node:
        # Primitive type references
        if entity = node.Entity as ExternalType and TypeSystemServices.IsLiteralPrimitive(entity):
            return StringLiteralExpression(node.LexicalInfo, entity.FullName)

        # Check for builtins references
        if IsBuiltin(node):
            name = node.Name.Split(char('.'))[-1]
            refe = [| Boo.$(ReferenceExpression(Name: name)) |].withLexicalInfoFrom(node)
            refe.Entity = node.Entity
            return refe

        # Entities in the Global namespace are never prefixed
        if IsGlobal(node):
            node.Name = node.Name.Split(char('.'))[-1]
            return node

        # Members of the module are placed in the top scope
        intEntity = node.Entity as TypeSystem.IInternalEntity
        if intEntity and intEntity.EntityType in (EntityType.Type, EntityType.Constructor):
            # Detect module class
            if HasAttribute[of CompilerGlobalScopeAttribute](intEntity.Node):
                node.Name = 'exports'
                return node
            # Prefix type references in the same module with exports
            if intEntity.Node.LexicalInfo.FullPath == node.LexicalInfo.FullPath:
                mre = MemberReferenceExpression(
                    node.LexicalInfo,
                    Target: [| exports |],
                    Name: node.Name,
                    Entity: node.Entity,
                    ExpressionType: node.ExpressionType
                )
                return mre

        # Special handling for extension methods
        intMethod = node.Entity as TypeSystem.Internal.InternalMethod
        if intMethod and intMethod.IsExtension:
            if intMethod.Node.LexicalInfo.FullPath == node.LexicalInfo.FullPath:
                node.Name = 'exports.' + intMethod.Name 
                return node

        return node

    def OnReferenceExpression(node as ReferenceExpression):
        # Apply Transform attribute metadata to generate the output AST node
        if TransformAttribute.HasAttribute(node):
            result = TransformAttribute.Resolve(node, null)
            ReplaceCurrentNode Visit(result)
            return

        ReplaceCurrentNode ProcessReference(node)

    def OnMemberReferenceExpression(node as MemberReferenceExpression):
        # Apply Transform attribute metadata to generate the output AST node
        if TransformAttribute.HasAttribute(node):
            result = TransformAttribute.Resolve(node, null)
            Visit result
            ReplaceCurrentNode result
            return

        # Convert from `$locals.$variable` to `variable`
        if node.Target.NodeType == NodeType.ReferenceExpression:
            if (node.Target as ReferenceExpression).Name == '$locals':
                refexp = ReferenceExpression(node.Name[1:], LexicalInfo: node.LexicalInfo)
                ReplaceCurrentNode refexp
                return

        # Check for builtins references
        if IsBuiltin(node.Target):
            node.Target = [| Boo |].withLexicalInfoFrom(node.Target)

        super(node)

    def OnMethodInvocationExpression(node as MethodInvocationExpression):
        # Apply Transform attribute metadata to generate the output AST node
        if TransformAttribute.HasAttribute(node.Target):
            result = TransformAttribute.Resolve(node.Target, node.Arguments)
            result = VisitNode(result)
            ReplaceCurrentNode result
            return

        # Handle vararg attribute
        if HasAttribute[of VarArgsAttribute](node.Target) and not node.ContainsAnnotation('varargs-processed'):
            node['varargs-processed'] = true
            // Common case where the only param is already an array
            if len(node.Arguments) == 1 and node.Arguments.Last isa ListLiteralExpression:
                last = node.Arguments.Last as ListLiteralExpression
                node.Arguments.Remove(last)
                for itm in last.Items:
                    node.Arguments.Add(itm)
                    
                Visit(node.Arguments)
                return

            // Use .apply to call the method: ref.apply(target, [one, two].concat(params))
            params = ListLiteralExpression()
            for i in range(0, len(node.Arguments)-1):
                params.Items.Add( node.Arguments[i] )
            mie = [| $(params).concat($(node.Arguments.Last)) |]
            if node.Target isa MemberReferenceExpression:
                target = (node.Target as MemberReferenceExpression).Target
            else:
                target = [| Boo.UNDEF |]
            node = [| $(node.Target).apply($target, $mie) |]
            ReplaceCurrentNode node


        /*
        rts = TypeSystemServices.RuntimeType
        rtsInvoke = ResolveMethod(rts, 'Invoke')
        rtsInvokeCallable = ResolveMethod(rts, 'InvokeCallable')
        rtsInvokeBinaryOperator = ResolveMethod(rts, 'InvokeBinaryOperator')
        rtsInvokeUnaryOperator = ResolveMethod(rts, 'InvokeUnaryOperator')
        rtsSetProperty = ResolveMethod(rts, 'SetProperty')
        rtsGetProperty = ResolveMethod(rts, 'GetProperty')
        rtsSetSlice = ResolveMethod(rts, 'SetSlice')
        rtsGetSlice = ResolveMethod(rts, 'GetSlice')
        */

        # Undo binary operator overloads
        if node.Target.Entity == MethodCache.InvokeBinaryOperator:

            # Convert it back into a binary expression
            be = BinaryExpression(node.LexicalInfo)
            be.ExpressionType = node.ExpressionType
            be.Left = node.Arguments[1]
            be.Right = node.Arguments[2]

            # Remove the op_ to find the operator type
            operator = (node.Arguments[0] as StringLiteralExpression).Value[3:]
            be.Operator = System.Enum.Parse(BinaryOperatorType, operator)

            ReplaceCurrentNode Visit(be)
            return

        # Undo unary operator overloads
        if node.Target.Entity == MethodCache.InvokeUnaryOperator:
            # Convert it back into a unary expression
            ue = UnaryExpression(node.LexicalInfo)
            ue.ExpressionType = node.ExpressionType
            ue.Operand = node.Arguments[1]

            # Remove the op_ to find the operator type
            operator = (node.Arguments[0] as StringLiteralExpression).Value[3:]
            ue.Operator = System.Enum.Parse(UnaryOperatorType, operator)

            ReplaceCurrentNode Visit(ue)
            return

        super(node)

    protected def LocalsToDecls(locals as LocalCollection):
        # Convert locals back to simple declaration statements
        found = ['$locals']
        for local in locals:
            # Avoid duplicates
            if local.Name is null or local.Name in found:
                continue

            found.Push(local.Name)

            decl = Declaration(LexicalInfo: local.LexicalInfo)
            decl.Name = local.Name

            # Detect local type
            initializer as Expression = NullLiteralExpression()
            entity = local.Entity as TypeSystem.Internal.InternalLocal
            if entity:
                if entity.OriginalDeclaration:
                    # Skip declarations for those flagged as global
                    continue if entity.OriginalDeclaration.ContainsAnnotation('global')
                    decl.Type = entity.OriginalDeclaration.Type
                else:
                    # TODO: Can we generate proper type annotations with this?
                    decl.Type = SimpleTypeReference(Entity: entity)

                # Initialize with a default value
                if TypeSystemServices.IsNumber(entity.Type):
                    initializer = IntegerLiteralExpression(0)
                elif entity.Type == TypeSystemServices.TimeSpanType:
                    initializer = IntegerLiteralExpression(0)
                elif entity.Type == TypeSystemServices.BoolType:
                    initializer = BoolLiteralExpression(false)
                elif entity.Type == TypeSystemServices.StringType:
                    initializer = StringLiteralExpression('')

            yield DeclarationStatement(LexicalInfo: local.LexicalInfo, Declaration: decl, Initializer: initializer)

    def OnBlockExpression(node as BlockExpression):
    """ Convert locals annotation to declarations.
        Boo AST does not allow to attach locals to block expressions but we
        need them in some cases, here we convert those local nodes to variable
        declarations.
    """
        if node.ContainsAnnotation('locals'):
            for st in LocalsToDecls(node['locals']):
                node.Body.Insert(0, st)
            node.RemoveAnnotation('locals')

        Visit node.Body

    def EnterMethod(node as Method):
        # Skip compiler generated methods
        if node.IsSynthetic and node.IsInternal:
            RemoveCurrentNode
            return false
        return true

    def OnMethod(node as Method):
    """ Process locals and detect the Main method to move its statements into the Module globals
    """
        for st in LocalsToDecls(node.Locals):
            node.Body.Insert(0, st)

        # Detect the Main method and move its statements to the Module globals
        if IsEntryPoint(node):
            Visit node.Body
            node.EnclosingModule.Globals = node.Body
            RemoveCurrentNode
            return

        # TODO: Why do we need to call Visit and super to process the contents?
        Visit(node.Body)
        super(node)

    def IsEntryPoint(node as Method):
        # Note: We cannot use ContextAnnotations.GetEntryPoint(Context) to detect
        # the entry point since when emitting the assembly and loading it again 
        # we might have to clone the AST and then the node instance is different.
        # TODO: Is this still the case?
        return node.Name == IntroduceModuleClasses.EntryPointMethodName \
               and node.IsSynthetic and node.IsStatic and node.IsPrivate

    def OnCastExpression(node as CastExpression):
        mie = [| Boo.$(ReferenceExpression('cast'))() |]
        mie.LexicalInfo = node.LexicalInfo
        mie.Arguments.Add(node.Target)
        ReplaceCurrentNode( ProcessCast(mie, node.Type) )

    def OnTryCastExpression(node as TryCastExpression):
        mie = [| Boo.trycast() |]
        mie.LexicalInfo = node.LexicalInfo
        mie.Arguments.Add(node.Target)
        ReplaceCurrentNode( ProcessCast(mie, node.Type) )

    protected def ProcessCast(mie as MethodInvocationExpression, type as Node) as MethodInvocationExpression:
        if not type isa Expression:
            type = TypeofExpression(type.LexicalInfo, type)

        mie.Arguments.Add(type)
        return Visit(mie)

    def OnCharLiteralExpression(node as CharLiteralExpression):
    """ There is no char type in BooJs. char('c') and char(int) are converted to a string of length 1
    """
        ReplaceCurrentNode StringLiteralExpression(LexicalInfo: node.LexicalInfo, Value: node.Value)

    def OnRELiteralExpression(node as RELiteralExpression):
    """ Almost a direct translation to Javascript regexp literals. The only modification
        is that we ignore whitespace to allow the regexps to be somehow more readable while
        Boo's handling is to escape it as part of the match.

            / foo | bar /i  ->  /foo|bar/i
            @/ foo | bar /  ->  /foo|bar/i

        TODO: The ones prefixed with @ should be preprocessed to support new lines
    """
        re = node.Value
        start = re.IndexOf('/')
        stop = re.LastIndexOf('/')

        modifier = re[stop:]
        re = re[start:stop]

        # Ignore white space
        re = /\s+/.Replace(re, '')

        # Javascript does not support the single-line modifier (dot matches new lines).
        # We emulate it by converting dots to the [\s\S] expression in the regex.
        # NOTE: The algorithm will break when a dot is preceeded by an escaped back slash (\\.)
        if modifier.Contains('s'):
            re = /(?<!\\)\./.Replace(re, '[\\s\\S]')
            modifier = modifier.Replace('s', '')

        node.Value = re + modifier

    def OnArrayLiteralExpression(node as ArrayLiteralExpression):
    """ In BooJs arrays are muttable (Boo's Lists)
    """
        super(node)
        list = ListLiteralExpression(node.LexicalInfo, Items: node.Items)
        ReplaceCurrentNode list

    def OnUnlessStatement(node as UnlessStatement):
    """ Negate the condition to convert it into a simple if statement
    """
        ifst = IfStatement(LexicalInfo: node.LexicalInfo)
        ifst.Condition = UnaryExpression(
            Operator: UnaryOperatorType.LogicalNot,
            Operand: node.Condition,
            LexicalInfo: node.LexicalInfo
        )
        ifst.TrueBlock = node.Block

        ReplaceCurrentNode ifst

    def OnBinaryExpression(node as BinaryExpression):
        if node.Operator == BinaryOperatorType.TypeTest:
            mie = MethodInvocationExpression(node.LexicalInfo)
            mie.Target = ReferenceExpression(node.LexicalInfo, 'Boo.isa')
            mie.Arguments.Add(node.Left)
            mie.Arguments.Add(node.Right)
            Visit mie.Arguments
            ReplaceCurrentNode mie
            return

        super(node)

    def OnTypeofExpression(node as TypeofExpression):
        if st = node.Type as SimpleTypeReference:

            # Primitives are just enclosed as strings
            if TypeSystemServices.IsPrimitive(st.Name):
                ReplaceCurrentNode StringLiteralExpression(node.LexicalInfo, st.Name)
                return

            # If we have an entity use it
            if exent = st.Entity as TypeSystem.Reflection.ExternalType:
                refe = CodeBuilder.CreateReference(node.LexicalInfo, exent.ActualType)
                ReplaceCurrentNode ProcessReference(refe)
                return

            # Just rely on the type name
            refe = ReferenceExpression(node.LexicalInfo, st.Name)
            ReplaceCurrentNode ProcessReference(refe)

        elif node.Type isa ArrayTypeReference:

            refe = CodeBuilder.CreateReference(node.LexicalInfo, TypeSystemServices.ArrayType)
            ReplaceCurrentNode ProcessReference(refe)
            return

        else:
            raise 'Unsupported TypeReference: ' + node.Type + ' (' + node.Type.NodeType + ')'

    static _negated_binary_ops = {
        BinaryOperatorType.ReferenceEquality: BinaryOperatorType.ReferenceInequality,
        BinaryOperatorType.ReferenceInequality: BinaryOperatorType.ReferenceEquality,
        BinaryOperatorType.Equality: BinaryOperatorType.Inequality,
        BinaryOperatorType.Inequality: BinaryOperatorType.Equality,
        BinaryOperatorType.GreaterThan: BinaryOperatorType.LessThanOrEqual,
        BinaryOperatorType.GreaterThanOrEqual: BinaryOperatorType.LessThan,
        BinaryOperatorType.LessThan: BinaryOperatorType.GreaterThanOrEqual,
        BinaryOperatorType.LessThanOrEqual: BinaryOperatorType.GreaterThan,
    }

    def OnUnaryExpression(node as UnaryExpression):
    """ Fold logical not expressions to simplify the generated code. This is
        specially useful for normalizing `unless` conditions converted to `if not`
    """
        if node.Operator == UnaryOperatorType.LogicalNot:
            # not(not(expr)) -> expr
            if ue = node.Operand as UnaryExpression and ue.Operator == UnaryOperatorType.LogicalNot:
                ReplaceCurrentNode Visit(ue.Operand)
                return

            # not i != 10 -> i == 10
            if be = node.Operand as BinaryExpression:
                if be.Operator in _negated_binary_ops:
                    be.Operator = _negated_binary_ops[be.Operator]
                    ReplaceCurrentNode Visit(be)
                    return

        super(node)

    def OnBlock(node as Block):
    """ Flatten nested blocks. During the code transformation steps we may
        have introduced nested blocks as statements.
    """
        Visit node.Statements

        ofs = 0
        while ofs < len(node.Statements):
            st = node.Statements[ofs]
            if st.NodeType == NodeType.Block:
                node.Statements.Remove(st)
                for st2 in (st as Block).Statements:
                    node.Statements.Insert(ofs, st2)
                    ofs++
            else:
                ofs++

