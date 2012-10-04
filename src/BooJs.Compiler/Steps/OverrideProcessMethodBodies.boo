namespace BooJs.Compiler.Steps

import Boo.Lang.Compiler.Steps
import Boo.Lang.Compiler.Ast
import Boo.Lang.Compiler.TypeSystem

import Boo.Lang.Environments

class OverrideProcessMethodBodies(ProcessMethodBodiesWithDuckTyping):
""" Overrides some methods of the step to skip some modification made originally
"""
    override def Initialize(context as Boo.Lang.Compiler.CompilerContext):
        super(context)

    override def LeaveUnaryExpression(node as UnaryExpression):
        # Increment/Decrement operators are resolved using a fairly complex eval. Since
        # JS supports this operators natively we can simplify the case by just binding
        # the correct type to the expression.
        if node.Operator in (UnaryOperatorType.Increment, UnaryOperatorType.Decrement,
                             UnaryOperatorType.PostDecrement, UnaryOperatorType.PostIncrement):
            # TODO: This doesn't take into account any operator overloading logic

            # Bind the type of the operand to the operation
            node.ExpressionType = GetExpressionType(node.Operand)
            return

        # Fall back to the original logic
        super(node)

    override def ProcessBuiltinInvocation(node as MethodInvocationExpression, func as BuiltinFunction):
        # Replace len(val) with val.length
        if func.FunctionType == BuiltinFunctionType.Len:
            target = node.Arguments[0]
            result = MemberReferenceExpression(node.LexicalInfo, target, 'length')
            result.ExpressionType = TypeSystemServices.IntType

            node.ParentNode.Replace(node, result)
            return

        super(node, func)

    override def LeaveDeclarationStatement(node as DeclarationStatement):
        # If the declaration has been annotated as global via the `global` macro
        # we must avoid generating a declaration for it, either removing it
        # or just setting a value to it if the used supplied an initializer
        decl = node.Declaration
        if decl.ContainsAnnotation('global'):
            if not decl.Type:
                decl.Type = CodeBuilder.CreateTypeReference(decl.LexicalInfo, TypeSystemServices.DuckType)

            type = GetType(decl.Type)
            entity as Internal.InternalLocal = DeclareLocal(node, decl.Name, type, false)
            entity.OriginalDeclaration = decl

            if node.Initializer:
                node.ReplaceBy(
                    ExpressionStatement(
                        CodeBuilder.CreateAssignment(
                            node.LexicalInfo,
                            CodeBuilder.CreateReference(entity),
                            node.Initializer)
                        )
                    )
            else:
                (node.ParentNode as Block).Statements.Remove(node)

            return

        super(node)

    override def LeaveSlicingExpression(node as SlicingExpression):
        # Slicing over lists gets transformed to a method call
        print 'SLICING A:', node, node.NodeType

        super(node)

        #if node.Target isa MemberReferenceExpression:
        #    target = node.Target as MemberReferenceExpression
        #    if target.Name == 'Item':
        #        node.Target = target.Target

        print 'SLICING B:', node, node.NodeType

