namespace BooJs.Compiler.TypeSystem

from Boo.Lang.Environments import my
from Boo.Lang.Compiler.TypeSystem import EntityType
from Boo.Lang.Compiler.TypeSystem.Services import InvocationTypeInferenceRules as BooBase, NameResolutionService
from Boo.Lang.Compiler.Ast import MethodInvocationExpression


class InvocationTypeInferenceRules(BooBase):

    def constructor():
        super()

        # HACK: We expect the array(Iterable) to be the first overload. This
        #       should be exposed as an attribute so we can target it with ease.
        nrs = my(NameResolutionService)
        method = nrs.ResolveMethod(TypeSystemServices.BuiltinsType, 'array')

        RegisterTypeInferenceRuleFor(method) def (invocation as MethodInvocationExpression, method):
            type = TypeSystemServices.GetEnumeratorItemType(TypeSystemServices.GetExpressionType(invocation.Arguments[0]))
            if type == null or type == TypeSystemServices.ObjectType:
                return null

            return type.MakeArrayType(1)

