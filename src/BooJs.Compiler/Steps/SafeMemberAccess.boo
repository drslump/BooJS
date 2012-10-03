namespace BooJs.Compiler.Steps

import Boo.Lang.Compiler
import Boo.Lang.Compiler.Ast
import Boo.Lang.Compiler.Steps
import Boo.Lang.Compiler.IO


class SafeMemberAccess(AbstractTransformerCompilerStep):
"""
This implementations is a big of a hack, since we preprocess the source code
before the parser processes it to adapt the syntax in a first step to finally
generate the proper AST in a second one.

IMPORTANT: This step must be placed before AND after the Parsing step

  a = foo?.bar
  (foo.bar if foo != null else null)

  a = foo?.bar?.baz
  (_ref.baz if (_ref=foo.bar if foo != null else null) != null else null)
  (foo.bar.baz if (foo.bar if foo != null else null) != null else null)

  a = foo?.bar?[2]
  (foo.bar[2] if (foo.bar if foo != null else null) != null else null)

  a = foo?.bar?()
  (foo.bar() if (foo.bar if foo != null else null) != null else null)

Boo supports unicode letters as part of an identifier, we preprocess the source file
replacing occurrences of `?` followed by `.`, `[`, or `(` with an unicode equivalent
which we can easily detect later to modify the expression into using the ternary operator.
To keep the syntax compatible in all use cases, the unicode character is included as a
member of the original target. The transformation looks like this:

    a = foo?.bar?()
    a = foo.ʔ.bar.ʔ()


The algorithm for the code generation is roughly this:
    - Get a MemberReference, MethodInvocation or Slicing expression
    - Go back thru its Target chain until we find a safe member access reference
    - Remove the unicode reference from the target chain
    - Recurse on the target
    - Convert the expression to (expr if target else null)
"""

    final public static UNICODE_CHAR = char('\u0294')      # LATIN LETTER GLOTTAL STOP "ʔ"


    override def Run():
        # First time we run before the source is actually parsed
        if not CompileUnit.ContainsAnnotation(SafeMemberAccess):
            CompileUnit.Annotate(SafeMemberAccess)
            processed = List[of ICompilerInput]()
            for input in Parameters.Input:
                mod = PreprocessSafeMemberAccess(input)
                processed.Add(mod)

            Parameters.Input.Clear()
            Parameters.Input.Extend(processed)
        else:
            Visit CompileUnit if not len(Errors)

    protected def PreprocessSafeMemberAccess(input as ICompilerInput):
        ch = SafeMemberAccess.UNICODE_CHAR
        using reader = input.Open():
            output = System.IO.StringWriter()

            while (line = reader.ReadLine()) is not null:
                line = line.Replace('?.', '.' + ch + '.')
                line = line.Replace('?[', '.' + ch + '[')
                line = line.Replace('?(', '.' + ch + '(')
                output.WriteLine(line)

        return StringInput(input.Name, output.ToString())


    def OnMemberReferenceExpression(node as MemberReferenceExpression):
        repl = ApplyTernary(node)
        if repl is not node:
            ReplaceCurrentNode repl

    def OnMethodInvocationExpression(node as MethodInvocationExpression):
        repl = ApplyTernary(node)
        if repl is not node:
            ReplaceCurrentNode repl

    def OnSlicingExpression(node as SlicingExpression):
        repl = ApplyTernary(node)
        if repl is not node:
            ReplaceCurrentNode repl

    def ApplyTernary(expr as Expression) as Expression:
        last as duck
        target = expr
        while target:
            if target isa ReferenceExpression:
                refexp = target as ReferenceExpression
                if refexp and refexp.Name == UNICODE_CHAR.ToString():
                    prev = (target as MemberReferenceExpression).Target
                    last.Target = prev

                    repl = ApplyTernary(prev)
                    return [| ($expr if $repl is not null else null) |].withLexicalInfoFrom(expr)

            last = target
            if target isa MemberReferenceExpression:
                target = (target as MemberReferenceExpression).Target
            elif target isa MethodInvocationExpression:
                target = (target as MethodInvocationExpression).Target
            elif target isa SlicingExpression:
                target = (target as SlicingExpression).Target
            else:
                target = null

        return expr
