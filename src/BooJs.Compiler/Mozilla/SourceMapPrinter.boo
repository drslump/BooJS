namespace BooJs.Compiler.Mozilla

import System.IO(TextWriter)
import BooJs.Compiler.SourceMap(MapBuilder)


class SourceMapPrinter(JsPrinter):

    [getter(SrcMap)]
    protected _srcmap as MapBuilder

    def constructor(writer as TextWriter):
        super(writer)
        _srcmap = MapBuilder()

    override def Visit(node as Node):
        if node and node.loc:
            identifier = node as Identifier
            ident = (identifier.name if identifier else null)
            pos as Position = node.loc.start
            SrcMap.Map(node.loc.source, pos.line-1, pos.column, _line, _column, ident)

        super(node)

    override def OnProgram(node as Program):
        super(node)

        # Add source map to the runtime
        # TODO: Only do this in debug mode
        # TODO: Use multiple source map format to only issue this once per assembly
        srcmap = SrcMap.ToHash()

        hash = ObjectExpression()
        hash.properties.Add( ObjectExpressionProp('version', Literal(srcmap['version'])) )
        hash.properties.Add( ObjectExpressionProp('file', Literal(srcmap['file'])) )

        arr = ArrayExpression()
        for item in srcmap['sources']:
            arr.elements.Add(Literal(item))
        hash.properties.Add(ObjectExpressionProp('sources', arr))

        arr = ArrayExpression()
        for name in srcmap['names']:
            arr.elements.Add(Literal(name))
        hash.properties.Add(ObjectExpressionProp('names', arr))

        hash.properties.Add(ObjectExpressionProp('mappings', Literal(srcmap['mappings'])))

        call = CallExpression()
        call.callee = MemberExpression(
            object: Identifier(name: 'Boo'),
            property: Identifier(name: 'sourcemap')
        )
        call.arguments.Add(hash)

        Visit ExpressionStatement(call)
