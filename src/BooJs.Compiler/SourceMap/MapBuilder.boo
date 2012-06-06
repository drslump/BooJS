namespace BooJs.Compiler.SourceMap

import Boo.Lang.Compiler.Ast

class MapBuilder:

    final static VERSION = 3

    [Property(Column)]
    column = 0

    [Property(File)]
    file as string

    [Property(SourceRoot)]
    sourceRoot as string

    sources as List[of string]
    names as List[of string]
    mappings as List[of string]

    segments as List[of string]

    def constructor():
        sources = List[of string]()
        names = List[of string]()
        mappings = List[of string]()
        segments = List[of string]()

    def AddSource(source as string):
        sources.Add(source)

    def NewLine():
        column = 0
        if len(segments):
            mappings.Add(segments.Join(','))
            segments.Clear()
        else:
            mappings.Add('')

    def Segment(node as Node):

        # Extract the name from the node if suitable
        if node isa ReferenceExpression:
            name = (node as ReferenceExpression).Name
            names.AddUnique(name)
            Segment(node.LexicalInfo, name)
        else:
            Segment(node.LexicalInfo, null)

    def Segment(lex as LexicalInfo, name as string):
        # The generated column
        segment = Base64VLQ.encode(column)

        # The source file
        idx = sources.IndexOf(lex.FileName)
        segment += Base64VLQ.encode(idx)

        # The source line and column
        segment += Base64VLQ.encode(lex.Line)
        segment += Base64VLQ.encode(lex.Column)

        if name is not null:
            idx = names.IndexOf(name)
            segment += Base64VLQ.encode(idx)

        segments.Add(segment)

    def ToString():
        return """{
            version: $(VERSION),
            file: "$(file)",
            sourceRoot: "$(sourceRoot)",
            sources: ["$(sources.Join('", "'))"],
            names: ["$(names.Join('", "'))"],
            mappings: "$(mappings.Join(';'))"
        }"""

