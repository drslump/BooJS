namespace boojs.Hints

import Boo.Lang.Compiler.Ast
import Boo.Lang.Compiler.TypeSystem
import Boo.Lang.Compiler.TypeSystem.Reflection


def fullNameOf(type as System.Type):
    fullName = type.FullName
    if string.IsNullOrEmpty(fullName):
        return type.Name
    return fullName

def describeGenericType(type as System.Type):
    parameterList = join(describeBooType(t) for t in type.GetGenericArguments(), ', ')
    definition = type.GetGenericTypeDefinition()
    if definition == typeof(System.Collections.Generic.IEnumerable of *):
        return "$parameterList*"
    fullName = fullNameOf(definition)
    simpleName = fullName[:fullName.IndexOf('`')]
    return "$simpleName[of $parameterList]"

def describeBooType(type as System.Type) as string:
    return '(' + describeBooType(type.GetElementType()) + ')' if type.IsArray
    return "object" if object is type
    return "string" if string is type
    return "void" if void is type
    return "bool" if bool is type
    return "byte" if byte is type
    return "char" if char is type
    return "sbyte" if sbyte is type
    return "short" if short is type
    return "ushort" if ushort is type
    return "int" if int is type
    return "uint" if uint is type
    return "long" if long is type
    return "ulong" if ulong is type
    return "single" if single is type
    return "double" if double is type
    return "date" if date is type
    return "timespan" if timespan is type
    return "regex" if regex is type
    return describeGenericType(type) if type.IsGenericType
    return fullNameOf(type)

def describeReturnType(t as TypeReference):
    return "" if t is null
    external = t.Entity as ExternalType
    if external is not null:
        return ' as ' + describeBooType(external.ActualType)
    return " as ${t}" if t is not null

def describeParam(p as ParameterDeclaration):
    return p.Name + describeReturnType(p.Type)

def describeParams(parameters as ParameterDeclarationCollection):
    return join(describeParam(p) for p in parameters, ', ')

def docStringFor(entity as IEntity):
    target = entity as IInternalEntity
    if target is not null and not string.IsNullOrEmpty(target.Node.Documentation):
        return target.Node.Documentation
    return null
