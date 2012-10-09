namespace BooJs.Compiler.Steps

import Boo.Lang.Compiler.Ast
import Boo.Lang.Compiler.Steps

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
        super(node)
        _nodes.Pop()

    def OnBinaryExpression(node as BinaryExpression):
        if node.Operator == BinaryOperatorType.Assign:
            name = node.Left.ToString()
            if /^\$locals\.\$/.IsMatch(name):
                name = name.Substring(len('$locals.$'))

            name = name.Split(char('.'))[0]
            name = name.Split(char('['))[0]

            exists = false
            for n in _nodes:
                if ExistsVariable(n, name):
                    exists = true
                    break

            if not exists:
                try:
                    type = GetType(node.Left)
                except:
                    type = TypeSystemServices.ObjectType
                CodeBuilder.DeclareLocal(_method, name, type)

        Visit node.Left
        Visit node.Right

    private def ExistsVariable(node as Node, name) as bool:
        if node isa BlockExpression:
            params = (node as BlockExpression).Parameters
            if params.Contains({param as ParameterDeclaration| param.Name == name}):
                return true

        if node isa Method:
            params = (node as Method).Parameters
            if params.Contains({param as ParameterDeclaration| param.Name == name}):
                return true
            locals = (node as Method).Locals
            if locals.Contains({local as Local| local.Name == name}):
                return true

        return false

