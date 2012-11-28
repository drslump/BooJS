namespace BooJs.Compiler.SourceMap

import System.Collections.Generic(Dictionary)
import System.Web.Script.Serialization(JavaScriptSerializer) from 'System.Web.Extensions'


class MapBuilder:

    final static VERSION = 3

    [Property(SourceRoot)]
    sourceRoot as string

    [Property(File)]
    file as string

    sources = List[of string]()
    names = List[of string]()
    mappings = List[of string]()
    segments = List[of string]()

    last_source as int
    last_target_column as int
    last_target_line as int
    last_name as int
    last_source_column as int
    last_source_line as int

    def Map(source as string, sline as int, scolumn as int, tline as int, tcolumn as int, ident as string):
        # Adjust lines
        while last_target_line < tline:
            last_target_line++
            if len(segments):
                mappings.Add(segments.Join(','))
                segments.Clear()
                last_target_column = 0
            else:
                mappings.Add('')

        # The generated column
        segment = Base64VLQ.encode(tcolumn - last_target_column)
        last_target_column = tcolumn

        # The source file
        sources.AddUnique(source)
        idx = sources.IndexOf(source)
        segment += Base64VLQ.encode(idx - last_source)
        last_source = idx

        # The source line and column
        segment += Base64VLQ.encode(sline - last_source_line)
        last_source_line = sline
        segment += Base64VLQ.encode(scolumn - last_source_column)
        last_source_column = scolumn

        if ident:
            names.AddUnique(ident)
            idx = names.IndexOf(ident)
            segment += Base64VLQ.encode(idx - last_name)
            last_name = idx

        segments.Add(segment)


    def ToDict():
        # Make sure we have added all the segments
        if len(segments):
            mappings.Add(segments.Join(','))

        d = Dictionary[of string,object]()
        d.Add('version', VERSION)
        d.Add('file', file)
        d.Add('sourceRoot', SourceRoot) if SourceRoot
        d.Add('sources', sources.ToArray())
        d.Add('names', names.ToArray())
        d.Add('mappings', mappings.Join(';'))

        return d

    def ToJSON() as string:
        js = JavaScriptSerializer()
        return js.Serialize(ToDict())
