namespace BooJs.Compiler.Steps

import Boo.Lang.Compiler.Ast
import Boo.Lang.Compiler.Steps
import Boo.Lang.PatternMatching


class NormalizeClosures(AbstractFastVisitorCompilerStep):
"""
    Detect locals inside closures and assign them to the parent method
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
        if method = node.Body.ParentNode as Method:
            ientity = method.Entity as Boo.Lang.Compiler.TypeSystem.Internal.InternalMethod
            if ientity and ientity.IsGenerator:
                node['locals'] = method.Locals

        super(node)
        _nodes.Pop()

    def OnBinaryExpression(node as BinaryExpression):
        if node.Operator == BinaryOperatorType.Assign:
            name = node.Left.ToString()
            if name =~ /^\$locals\.\$/:
                name = name.Substring(len('$locals.$'))

            name = name.Split(char('.'))[0]
            name = name.Split(char('['))[0]

            exists = false
            for n in _nodes:
                exists = ExistsVariable(n, name)
                break if exists

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

                if blk.ContainsAnnotation('locals'):
                    return (blk['locals'] as LocalCollection).Contains({local as Local| local.Name == name})

            case m=Method():
                return true if m.Parameters.Contains({param as ParameterDeclaration| param.Name == name})
                return true if m.Locals.Contains({local as Local| local.Name == name})
            otherwise:
                return false

        return false
