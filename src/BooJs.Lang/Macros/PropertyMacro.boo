# Direct port of the Boo macro (macros are sealed so we can't inherit from it)

namespace BooJs.Lang.Macros

import Boo.Lang.Compiler.Ast


macro property:

    raise "property <name> [as type] [= initialValue]" unless PropertyMacroParser.IsValidProperty(property)
    
    argument = property.Arguments[0]
    initializationForm = argument as BinaryExpression
    if initializationForm is not null:
        declaration = initializationForm.Left
        initializer = initializationForm.Right
    else:
        declaration = argument
        initializer = null
        
    name = PropertyMacroParser.PropertyNameFrom(declaration)
    type = PropertyMacroParser.PropertyTypeFrom(declaration)
    backingField = ReferenceExpression(Name: Context.GetUniqueName(name.ToString()))
        
    prototype = [|
    
        class _:
        
            private $backingField as $type = $initializer
            
            $name:
                get: return $backingField
                set: $backingField = value
    |]
    
    yieldAll prototype.Members
    

internal static class PropertyMacroParser:
    
    def PropertyNameFrom(e as Expression) as ReferenceExpression:
        declaration = e as TryCastExpression
        if declaration is not null:
            return declaration.Target
        return e
        
    def PropertyTypeFrom(e as Expression):
        declaration = e as TryCastExpression
        if declaration is not null:
            return declaration.Type
        return null
        
    def IsValidProperty(property as MacroStatement):
        if len(property.Arguments) != 1:
            return false
        if not property.Body.IsEmpty:
            return false
        argument = property.Arguments[0]
        initializationForm = argument as BinaryExpression
        if initializationForm is not null:
            if initializationForm.Operator != BinaryOperatorType.Assign:
                return false
            return IsValidPropertyDeclaration(initializationForm.Left)
        return IsValidPropertyDeclaration(argument)
        
    def IsValidPropertyDeclaration(e as Expression):
        if e.NodeType == NodeType.ReferenceExpression:
            return true
        declaration = e as TryCastExpression
        if declaration is null: return false
        return declaration.Target.NodeType == NodeType.ReferenceExpression
