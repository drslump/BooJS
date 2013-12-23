namespace BooJs.Compiler.TypeSystem

from Boo.Lang.Compiler.TypeSystem import BooCodeBuilder, IMember, IMethod, IProperty
from Boo.Lang.Compiler.TypeSystem.Internal import InternalTypeSystemProvider
from Boo.Lang.Compiler.Ast import *
from Boo.Lang.Environments import my


class BooJsCodeBuilder(BooCodeBuilder):
""" TODO: This doesn't work. The methods in BooCodeBuilder are not virtual so it's 
          not possible to modify their behaviour even if we use this custom type in 
          the environment.
"""

    new def CreateStub(node as ClassDefinition, member as IMember) as TypeMember:
        baseMethod = member as IMethod
        if null != baseMethod:
            return CreateMethodStub(baseMethod)

        property = member as IProperty
        if null != property:
            return CreatePropertyStub(node, property)

        return null

    new protected def CreateMethodStub(baseMethod as IMethod) as Method:
        stub = CreateMethodFromPrototype(baseMethod, TypeSystemServices.GetAccess(baseMethod) | TypeMemberModifiers.Virtual);

        notImplementedException = MethodInvocationExpression(
            Target: MemberReferenceExpression(ReferenceExpression("Boo"), "NotImplementedError")
        )
        stub.Body.Statements.Add(
            RaiseStatement(notImplementedException, LexicalInfo: LexicalInfo.Empty)
        )

        return stub

    new protected def CreatePropertyStub(node as ClassDefinition, baseProperty as IProperty) as Property:
        //try to complete partial implementation if any
        property = node.Members[baseProperty.Name] as Property
        if null == property:
            property = Property(LexicalInfo.Empty)
            property.Name = baseProperty.Name
            property.Modifiers = TypeSystemServices.GetAccess(baseProperty) | TypeMemberModifiers.Virtual
            property.IsSynthetic = true
            DeclareParameters(property, baseProperty.GetParameters(), (0 if baseProperty.IsStatic else 1))
            property.Type = CreateTypeReference(baseProperty.Type)

        if property.Getter == null and null != baseProperty.GetGetMethod():
            property.Getter = CreateMethodStub(baseProperty.GetGetMethod())

        if property.Setter == null and null != baseProperty.GetSetMethod():
            property.Setter = CreateMethodStub(baseProperty.GetSetMethod())

        my(InternalTypeSystemProvider).EntityFor(property)
        return property
