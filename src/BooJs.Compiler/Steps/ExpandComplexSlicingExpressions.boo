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

        if not IsComplexSlicing(node):
            return

        if IsTargetOfAssignment(node):
            Error(CompilerErrorFactory.NotImplemented(node, 'Assignments to complex slicing expressions is not supported'))
            return

        if len(node.Indices) > 1:
            Error(CompilerErrorFactory.NotImplemented(node, 'Multidimmensional indices are not supported'))
            return

        CompleteOmittedExpressions(node)
        ExpandComplexSlicing(node)

    def CompleteOmittedExpressions(node as SlicingExpression):
        for idx in node.Indices:
            idx.Begin = CodeBuilder.CreateIntegerLiteral(0) if idx.Begin == OmittedExpression.Default
            idx.End = CodeBuilder.CreateNullLiteral() if idx.End == OmittedExpression.Default

    def ExpandComplexSlicing(node as SlicingExpression):
        type = GetExpressionType(node.Target)
        if IsString(type) or IsList(type) or type.IsArray:
            slice = node.Indices[0]

            # Handle negative literal integers, but only if the expression is a reference or a literal
            if not slice.End and not slice.Step \
               and slice.Begin isa IntegerLiteralExpression \
               and (node.Target isa ReferenceExpression or node.Target isa LiteralExpression):
                val = -(slice.Begin as IntegerLiteralExpression).Value
                slice.Begin = [| $(node.Target).length - $val |]
                return

            mie = [| Boo.Lang.slice($(node.Target), $(slice.Begin)) |]
            if not IsNullOrOmitted(slice.End):
                mie.Arguments.Add(slice.End)
            if not IsNullOrOmitted(slice.Step):
                mie.Arguments.Add(slice.Step)

            node.ParentNode.Replace(node, mie)
        else:
            NotImplemented(node, 'complex slicing for anything but lists, arrays and strings is not supported')


        /*
        if IsString(targetType):
            ExpandComplexStringSlicing(node)
        elif IsList(targetType):
            ExpandComplexListSlicing(node)
        elif targetType.IsArray:
            ExpandComplexArraySlicing(node)
        else:
            NotImplemented(node, "complex slicing for anything but lists, arrays and strings");
        */


/*
    def ExpandComplexListSlicing(node as SlicingExpression):
        slice = node.Indices[0]

        mie as MethodInvocationExpression
        if IsNullOrOmitted(slice.End):
            mie = CodeBuilder.CreateMethodInvocation(node.Target, MethodCache.List_GetRange1)
            mie.Arguments.Add(slice.Begin)
        else:
            mie = CodeBuilder.CreateMethodInvocation(node.Target, MethodCache.List_GetRange2)
            mie.Arguments.Add(slice.Begin)
            mie.Arguments.Add(slice.End)
            
        node.ParentNode.Replace(node, mie)

    def ExpandComplexArraySlicing(node as SlicingExpression):
        if len(node.Indices) > 1:
            mie as MethodInvocationExpression
            computeEnd = ArrayLiteralExpression()
            collapse = ArrayLiteralExpression()
            ranges = ArrayLiteralExpression()
            for idx in node.Indices:
                ranges.Items.Add(idx.Begin)
                if idx.End == null:
                    end = BinaryExpression(BinaryOperatorType.Addition, idx.Begin, IntegerLiteralExpression(1))
                    ranges.Items.Add(end)
                    BindExpressionType(end, GetExpressionType(idx.Begin))
                    computeEnd.Items.Add(BoolLiteralExpression(false))
                    collapse.Items.Add(BoolLiteralExpression(true))
                elif idx.End == OmittedExpression.Default:
                    end = IntegerLiteralExpression(0)
                    ranges.Items.Add(end)
                    BindExpressionType(end, GetExpressionType(idx.Begin))
                    computeEnd.Items.Add(BoolLiteralExpression(true))
                    collapse.Items.Add(BoolLiteralExpression(false))
                else:
                    ranges.Items.Add(idx.End)
                    computeEnd.Items.Add(BoolLiteralExpression(false))
                    collapse.Items.Add(BoolLiteralExpression(false))

            mie = CodeBuilder.CreateMethodInvocation(MethodCache.RuntimeServices_GetMultiDimensionalRange1, node.Target, ranges)
            mie.Arguments.Add(computeEnd)
            mie.Arguments.Add(collapse)

            BindExpressionType(ranges, TypeSystemServices.Map(typeof((int))))
            BindExpressionType(computeEnd, TypeSystemServices.Map(typeof(bool)))
            BindExpressionType(collapse, TypeSystemServices.Map(typeof(bool)))
            node.ParentNode.Replace(node, mie)
        else:      
            slice = node.Indices[0]
            mie = (CodeBuilder.CreateMethodInvocation(MethodCache.RuntimeServices_GetRange1, node.Target, slice.Begin)
                if IsNullOrOmitted(slice.End)
                else CodeBuilder.CreateMethodInvocation(MethodCache.RuntimeServices_GetRange2, node.Target, slice.Begin, slice.End)
            )
            node.ParentNode.Replace(node, mie)

    def ComplexStringSlicingExpressionFor(node as SlicingExpression) as MethodInvocationExpression:
        slice = node.Indices[0]
        if IsNullOrOmitted(slice.End):
            if NeedsNormalization(slice.Begin):
                mie = CodeBuilder.CreateEvalInvocation(node.LexicalInfo)
                mie.ExpressionType = TypeSystemServices.StringType

                temp = DeclareTempLocal(TypeSystemServices.StringType)
                mie.Arguments.Add(
                    CodeBuilder.CreateAssignment(
                        CodeBuilder.CreateReference(temp),
                        node.Target))

                mie.Arguments.Add(
                    CodeBuilder.CreateMethodInvocation(
                        CodeBuilder.CreateReference(temp),
                        MethodCache.String_Substring_Int,
                        CodeBuilder.CreateMethodInvocation(
                            MethodCache.RuntimeServices_NormalizeStringIndex,
                            CodeBuilder.CreateReference(temp),
                            slice.Begin)))

                return mie;
                
            return CodeBuilder.CreateMethodInvocation(node.Target, MethodCache.String_Substring_Int, slice.Begin)
            
        return CodeBuilder.CreateMethodInvocation(MethodCache.RuntimeServices_Mid, node.Target, slice.Begin, slice.End)

    def ExpandComplexStringSlicing(node as SlicingExpression):
        node.ParentNode.Replace(node, ComplexStringSlicingExpressionFor(node));

    private _methodCache as EnvironmentProvision[of RuntimeMethodCache]
    protected MethodCache as RuntimeMethodCache:
        get: return _methodCache.Instance

    def Dispose():
        _methodCache = EnvironmentProvision[of RuntimeMethodCache]()
        super()
*/

    def IsNullOrOmitted(expression as Expression) as bool:
        return expression == null or expression == OmittedExpression.Default

    def NeedsNormalization(index as Expression) as bool:
        return index.NodeType != NodeType.IntegerLiteralExpression or (index as IntegerLiteralExpression).Value < 0;


    def IsAssignableFrom(expectedType as IType, actualType as IType) as bool:
        return TypeCompatibilityRules.IsAssignableFrom(expectedType, actualType)

    def DeclareTempLocal(localType as IType) as InternalLocal:
        return CodeBuilder.DeclareTempLocal(CurrentMethod, localType)
