namespace BooJs.Compiler.Steps

import Boo.Lang.Compiler.Ast
import Boo.Lang.Compiler.Steps
import Boo.Lang.Compiler.TypeSystem(Ambiguous, Internal, EntityType)


class MethodOverloading(AbstractFastVisitorCompilerStep):
"""
Method overloading is performed by suffixing the original method name with a unique
identifier to ensure there are no name collisions in the generated javascript code.

    def foo(s as string):
    def foo(i as int):
    foo(10)
    ---
    def foo$0(s as string):
    def foo$1(i as int):
    foo$1(10)
"""
    def OnMethod(node as Method):
        cls = node.DeclaringType
        if not cls.ContainsAnnotation('method-overload-{0}' % node.Name):
            cls.Annotate('method-overload-{0}' % node.Name)
            overloads = [m for m in cls.Members if m.Name == node.Name]
            if len(overloads) > 1:
                # Create a new method with the original name to raise an error if called
                m = node.CloneNode()
                cls.Members.Insert(cls.Members.IndexOf(node), m)
                m.Parameters.Clear()
                m.Body.Clear()
                m.Body.Add([| raise 'Overloaded method' |])
                Visit m

                # Rename overloads to include a unique suffix
                for i, m in enumerate(overloads):
                    m.Name += '$' + i

        super(node)

    def OnMethodInvocationExpression(node as MethodInvocationExpression):
        return unless node.Target isa ReferenceExpression
        target = node.Target as ReferenceExpression
        ent = target.Entity as Internal.InternalMethod
        if ent:
            target.Name = ent.Name
