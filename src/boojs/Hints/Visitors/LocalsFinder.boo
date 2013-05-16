namespace boojs.Hints.Visitors

import System(StringComparison)
import System.IO(Path)
import Boo.Lang.Compiler.Ast
import Boo.Lang.Compiler.TypeSystem(IEntity)


class LocalsFinder(FastDepthFirstVisitor):
""" Collects information about local entities available at a given
    line number in a file.
"""
    _filename as string
    _line as int
    _results as List of IEntity

    def constructor(filename as string, line as int):
        _filename = Path.GetFullPath(filename)
        _line = line

    def FindIn(root as Node):
        _results = List of IEntity()
        Visit(root)
        return _results

    override def OnMethod(method as Method):
        AddMethodParams(method)
        Visit method.Body

    override def OnConstructor(method as Constructor):
        AddMethodParams(method)
        Visit method.Body

    override def OnBlockExpression(node as BlockExpression):
        return if node.LexicalInfo is null
        return if _line < node.LexicalInfo.Line
        return if _line > GetEndLine(node.Body) + 1

        for param in node.Parameters:
            _results.Add(param.Entity)

        Visit node.Body

    override def OnForStatement(node as ForStatement):
        return if node.LexicalInfo is null
        return if _line < node.LexicalInfo.Line
        return if _line > GetEndLine(node.Block) + 1

        for decl in node.Declarations:
            _results.Add(decl.Entity)

    protected def GetEndLine(block as Block):
        last = block.LastStatement
        return (last.LexicalInfo.Line if last else block.LexicalInfo.Line)

    protected def AddMethodParams(method as Method):
        if method.LexicalInfo is null: return
        if _line < method.LexicalInfo.Line or _line > method.EndSourceLocation.Line: return
        if not method.LexicalInfo.FullPath.Equals(_filename, StringComparison.OrdinalIgnoreCase): return

        for param in method.Parameters:
            _results.Add(param.Entity)
        for local in method.Locals:
            if _line >= local.LexicalInfo.Line:
                _results.Add(local.Entity)
