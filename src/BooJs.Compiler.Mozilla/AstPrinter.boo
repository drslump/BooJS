namespace BooJs.Compiler.Mozilla

from System.IO import TextWriter


class AstPrinter(Printer):
"""
    Writes a JSON representation of the Mozilla AST

    TODO: Regular expressions are not generated correctly
"""

    def constructor(writer as TextWriter):
        super(writer)

    override def Visit(node as Node):
        json = Serializer.Serialize(node)
        Writer.Write(json)
