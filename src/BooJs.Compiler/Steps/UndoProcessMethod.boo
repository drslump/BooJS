namespace BooJs.Compiler.Steps

import Boo.Lang.Compiler.Ast
import Boo.Lang.Compiler.Steps

class UndoProcessMethod(AbstractTransformerCompilerStep):
"""
    Boo's ProcessMethodBodies performs some quite complex computations to 
    infer types and to support 'dynamic' features using a non dynamic version
    of the CLI. 

    This step tries to undo some of the changes performed to the AST in order
    to have a cleaner way to generate Javascript which is fully dynamic.
"""
    
    override def Run():
        if len(Errors) > 0:
            return
        Visit CompileUnit

    override def EnterMethod(node as Method):
    """ Remove the injected \$locals variable
    """
        for local in node.Locals:
            if local.Name == '$locals':
                node.Locals.Remove(local)
                break
        return true

    def EnterExpressionStatement(node as ExpressionStatement):
    """ Remove the assignment of the closure instance to the \$locals variable
            \$locals = FooModule.\$foo\$locals\$3()
    """
        if node.Expression.NodeType != NodeType.BinaryExpression:
            return true

        expr as BinaryExpression = node.Expression
        if expr.Operator == BinaryOperatorType.Assign:
            if expr.Left.ToString() == '$locals':
                RemoveCurrentNode
                return false

        return true

    def OnMethodInvocationExpression(node as MethodInvocationExpression):
    """ Fix closure invocations
            \$locals.\$foo.Invoke(1)  ->  foo(1)
    """
        if node.Target.NodeType != NodeType.MemberReferenceExpression:
            return

        target as MemberReferenceExpression = node.Target
        # Check if we come from a $locals
        while true:
            if target.Target.NodeType != NodeType.MemberReferenceExpression:
                if target.Target.ToString() == '$locals':
                    Visit target
                    # Remove injected Invoke calls
                    if (node.Target as MemberReferenceExpression).Name == 'Invoke':
                        target = node.Target
                        node.Replace(target, target.Target)
                break

            target = target.Target


    def EnterMemberReferenceExpression(node as MemberReferenceExpression):
    """ Fix closure references
            \$locals.\$foo = 1  ->  foo = 1
    """
        if node.Target.ToString() != '$locals':
            return true

        name = node.Name[1:]
        reference = ReferenceExpression(node.LexicalInfo)
        reference.Name = name
        node.ParentNode.Replace(node, reference)

        # Go up to the containing function to insert this as a global
        parent = node.ParentNode
        while parent:
            if parent.NodeType == NodeType.Method:
                # Check if we have already added it to the method Locals
                found = false
                for local in (parent as Method).Locals:
                    if local.Name == name:
                        found = true

                if not found:
                    CodeBuilder.DeclareLocal(parent, name, GetType(node))
                break

            parent = parent.ParentNode

        return false


    override def LeaveRaiseStatement(node as RaiseStatement):
        # Boo allows to re-raise an exception by omitting the exception argument. We always capture
        # the exception in `__e` so we just define it for empty raise statements.
        # TODO: Move this to ProcessTry ???
        if not node.Exception:
            node.Exception = [| __e |]

        # Boo wraps the raising of literals with System.Exception. We have to undo
        # that transformation to issue Javascript's native Error one.
        if node.Exception.NodeType == NodeType.MethodInvocationExpression:
            ex = node.Exception as MethodInvocationExpression
            if ex.Target.ToString() == 'System.Exception':
                ex.Target = [| Error |]
