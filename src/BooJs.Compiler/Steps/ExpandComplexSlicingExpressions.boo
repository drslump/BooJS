namespace BooJs.Compiler.Steps

from Boo.Lang.Compiler.Ast import *
from Boo.Lang.Compiler import CompilerErrorFactory, CompilerContext
from Boo.Lang.Compiler.Steps import AbstractFastVisitorCompilerStep
from Boo.Lang.Compiler.TypeSystem import IType, IMethod
from Boo.Lang.Compiler.TypeSystem.Services import TypeCompatibilityRules


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


    _slice1 as IMethod
    _slice2 as IMethod
    _slice3 as IMethod
    _sliceSet as IMethod

    def Initialize(context as CompilerContext):
        super(context)

        # Resolve the slice methods and cache them
        _slice1 = NameResolutionService.ResolveMethod(TypeSystemServices.RuntimeServicesType, 'slice1')
        _slice2 = NameResolutionService.ResolveMethod(TypeSystemServices.RuntimeServicesType, 'slice2')
        _slice3 = NameResolutionService.ResolveMethod(TypeSystemServices.RuntimeServicesType, 'slice3')
        _sliceSet = NameResolutionService.ResolveMethod(TypeSystemServices.RuntimeServicesType, 'sliceSet')

    # Implement Boo 0.9.6's AstNodePredicates
    def IsComplexSlicing(node as SlicingExpression) as bool:
        return node.Indices.Contains({idx| IsComplexSlice(idx)})

    def IsComplexSlice(slice as Slice) as bool:
        # Only literal positive integers are considered not complex
        if not slice.End and not slice.Step and slice.Begin isa IntegerLiteralExpression:
            return (slice.Begin as IntegerLiteralExpression).Value < 0
        return true

    def IsTargetOfAssignment(node as Expression) as bool:
        parentExpression = node.ParentNode as BinaryExpression
        return false if not parentExpression
        return node == parentExpression.Left and AstUtil.IsAssignment(parentExpression)

    def IsNullOrOmitted(expression as Expression) as bool:
        return expression == null or expression == OmittedExpression.Default

    def IsAssignableFrom(expectedType as IType, actualType as IType) as bool:
        return TypeCompatibilityRules.IsAssignableFrom(expectedType, actualType)

    def IsString(target as IType) as bool:
        return TypeSystemServices.StringType == target

    def IsList(target as IType) as bool:
        return IsAssignableFrom(TypeSystemServices.ListType, target)

    def OnSlicingExpression(node as SlicingExpression):
        super(node)

        if len(node.Indices) > 1:
            Error(CompilerErrorFactory.NotImplemented(node, 'Multidimensional indices are not supported'))
            return
        elif not IsComplexSlicing(node):
            return

        CompleteOmittedExpressions(node)           
        ExpandComplexSlicing(node)

    def CompleteOmittedExpressions(node as SlicingExpression):
        for idx in node.Indices:
            if IsNullOrOmitted(idx.Begin):
                idx.Begin = CodeBuilder.CreateIntegerLiteral(0)
                # HACK: When begin is omitted end may be null instead of omitted
                idx.End = CodeBuilder.CreateNullLiteral() if IsNullOrOmitted(idx.End)
            elif idx.End and idx.End == OmittedExpression.Default:
                idx.End = CodeBuilder.CreateNullLiteral()


    def ExpandComplexSlicing(node as SlicingExpression):
        type = GetExpressionType(node.Target)

        unless IsString(type) or IsList(type) or type.IsArray:
            NotImplemented(node, 'complex slicing for anything but lists, arrays and strings is not supported')

        slice = node.Indices[0]

        # Handle negative literal integers, but only if the expression is a reference
        if not slice.End and not slice.Step \
           and slice.Begin isa IntegerLiteralExpression \
           and node.Target isa ReferenceExpression:
            val = -(slice.Begin as IntegerLiteralExpression).Value
            if IsString(type) or type.IsArray:
                slice.Begin = [| $(node.Target).length - $val |]
            else:
                slice.Begin = [| Boo.len($(node.Target)) - $val |]
            return

        if IsTargetOfAssignment(node):
            # Use slice setter from the runtime (only needed to handle negative values)
            # TODO: Issue a warning if the node is inside a loop (performance)
            rhs = (node.ParentNode as BinaryExpression).Right
            mie = CodeBuilder.CreateMethodInvocation(_sliceSet, node.Target, slice.Begin, rhs)
        else:
            # Use slice getter from the runtime
            if slice.End is null and slice.Step is null:
                mie = CodeBuilder.CreateMethodInvocation(_slice1, node.Target, slice.Begin)
            elif IsNullOrOmitted(slice.Step):
                mie = CodeBuilder.CreateMethodInvocation(_slice2, node.Target, slice.Begin, slice.End)
            else:
                mie = CodeBuilder.CreateMethodInvocation(_slice3, node.Target, slice.Begin, slice.End)
                mie.Arguments.Add(slice.Step)

        mie.LexicalInfo = node.LexicalInfo
        node.ParentNode.Replace(node, mie)
