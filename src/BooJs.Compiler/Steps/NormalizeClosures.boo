namespace BooJs.Compiler.Steps

import Boo.Lang.Compiler.Ast
import Boo.Lang.Compiler.Steps
import Boo.Lang.Compiler.TypeSystem.Internal(InternalMethod)
import Boo.Lang.PatternMatching


class NormalizeClosures(AbstractFastVisitorCompilerStep):
""" Detect locals inside closures and assigns them to the parent method

    Boo doesn't allow declaration of locals inside block expressions, they all
    must be bound to the closest containing method. This means that variables
    inside block expressions (anonymous functions) leak to the containing scope.

    In BooJs we make an exception to this rule for block expressions derived from
    a generator. While in Boo they are converted to methods in BooJs we keep them
    as block expressions, to allow them to keep their context we can't allow for 
    them to leak their state variables to the outer scope.
"""
    _method as Method
    _nodes = []

    def OnMethod(node as Method):
        _method = node
        _nodes.Push(node)
        super(node)
        _nodes.Pop()

    def OnBlockExpression(node as BlockExpression):
        _nodes.Push(node)

        # Check if the block expression is bound to a generator method
        # Since we haven't yet removed the original Boo transformation of 
        # generators into methods, we just check if that generated method
        # is flagged as a generator.
        if method = node.Body.ParentNode as Method:
            if (method.Entity as InternalMethod).IsGenerator:
                node['locals'] = method.Locals

        super(node)
        _nodes.Pop()

    def OnBinaryExpression(node as BinaryExpression):
        # Check variable assignments
        if node.Operator == BinaryOperatorType.Assign:
            # Obtain the root name of the expression
            name = node.Left.ToString()
            if name =~ /^\$locals\.\$/:
                name = name.Substring(len('$locals.$'))

            name = name.Split(char('.'))[0]
            name = name.Split(char('['))[0]

            # Check if the variable already exists in one of the enclosing scopes
            exists = false
            for n in _nodes:
                exists = ExistsVariable(n, name)
                break if exists

            # Create a new local from the assignment details
            if not exists:
                try:
                    type = GetType(node.Left)
                except:
                    type = TypeSystemServices.ObjectType
                CodeBuilder.DeclareLocal(_method, name, type)

        Visit node.Left
        Visit node.Right

    private def ExistsVariable(node as Node, name) as bool:
        match node:
            case blk=BlockExpression():
                params = blk.Parameters
                return true if blk.Parameters.Contains({param as ParameterDeclaration| param.Name == name})
                # If it comes from a generator it will actually have locals
                if blk.ContainsAnnotation('locals'):
                    return (blk['locals'] as LocalCollection).Contains({local as Local| local.Name == name})

            case m=Method():
                return true if m.Parameters.Contains({param as ParameterDeclaration| param.Name == name})
                return true if m.Locals.Contains({local as Local| local.Name == name})
            otherwise:
                return false

        return false
