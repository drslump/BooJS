namespace BooJs.Compiler.Steps

import Boo.Lang.Compiler(CompilerErrorFactory)
import Boo.Lang.Compiler.Ast
import Boo.Lang.Compiler.Steps
import Boo.Lang.Compiler.TypeSystem
import Boo.Lang.Compiler.TypeSystem.Internal
import Boo.Lang.Compiler.TypeSystem.Services
import Boo.Lang.Environments

# MonoDevelop perfoms the compilation using its own Boo assemblies which do not contain this class
# We have to replicate the whole class here to allow compilation from the IDE and from msbuild
#import Boo.Lang.Compiler.Steps.ExpandComplexSlicingExpressions as BooStep


class ExpandComplexSlicingExpressions(AbstractFastVisitorCompilerStep):

    # Implement Boo 0.9.6's MethodTrackingVisitorCompilerStep
    [getter(CurrentMethod)]
    private _currentMethod as Method

    def OnMethod(node as Method):
        _currentMethod = node
        super(node)

    def OnConstructor(node as Constructor):
        _currentMethod = node
        super(node)
        
    
    # Implement Boo 0.9.6's AstNodePredicates
    def IsComplexSlicing(node as SlicingExpression) as bool:
        return node.Indices.Contains({idx| IsComplexSlice(idx)})
        
    def IsTargetOfAssignment(node as Expression) as bool:
        parentExpression = node.ParentNode as BinaryExpression
        return false if not parentExpression
        return node == parentExpression.Left and AstUtil.IsAssignment(parentExpression)

    def IsComplexSlice(slice as Slice) as bool:
        # Only literal positive integers are considered not complex
        if not slice.End and not slice.Step and slice.Begin isa IntegerLiteralExpression:
            return (slice.Begin as IntegerLiteralExpression).Value < 0
        return true


    def IsString(target as IType) as bool:
        return TypeSystemServices.StringType == target

    def IsList(target as IType) as bool:
        return IsAssignableFrom(TypeSystemServices.ListType, target)


    def OnSlicingExpression(node as SlicingExpression):
        super(node)

        if len(node.Indices) > 1:
            Error(CompilerErrorFactory.NotImplemented(node, 'Multidimmensional indices are not supported'))
            return
        elif IsTargetOfAssignment(node):
            Error(CompilerErrorFactory.NotImplemented(node, 'Assignments to complex slicing expressions is not supported'))
            return
        elif not IsComplexSlicing(node):
            return

        CompleteOmittedExpressions(node)
        ExpandComplexSlicing(node)

    def CompleteOmittedExpressions(node as SlicingExpression):
        for idx in node.Indices:
            idx.Begin = CodeBuilder.CreateIntegerLiteral(0) if idx.Begin == OmittedExpression.Default
            idx.End = CodeBuilder.CreateNullLiteral() if idx.End == OmittedExpression.Default

    def ExpandComplexSlicing(node as SlicingExpression):
        # HACK: We're placing this step before types are bound to the references, thus we don't
        #       know at this point what type it is.
        type = GetExpressionType(node.Target)
        if true or IsString(type) or IsList(type) or type.IsArray:
            slice = node.Indices[0]

            # Handle negative literal integers, but only if the expression is a reference or a literal
            if not slice.End and not slice.Step \
               and slice.Begin isa IntegerLiteralExpression \
               and (node.Target isa ReferenceExpression or node.Target isa LiteralExpression):
                val = -(slice.Begin as IntegerLiteralExpression).Value
                slice.Begin = [| $(node.Target).length - $val |]
                return

            m = NameResolutionService.ResolveMethod(typeof(BooJs.Lang.RuntimeHelpers), 'slice')
            mie = CodeBuilder.CreateMethodInvocation(m, node.Target, slice.Begin)
            if not IsNullOrOmitted(slice.End):
                mie.Arguments.Add(slice.End)
            if not IsNullOrOmitted(slice.Step):
                mie.Arguments.Add(slice.Step)

            node.ParentNode.Replace(node, mie)
        else:
            NotImplemented(node, 'complex slicing for anything but lists, arrays and strings is not supported')

    def IsNullOrOmitted(expression as Expression) as bool:
        return expression == null or expression == OmittedExpression.Default

    def IsAssignableFrom(expectedType as IType, actualType as IType) as bool:
        return TypeCompatibilityRules.IsAssignableFrom(expectedType, actualType)

