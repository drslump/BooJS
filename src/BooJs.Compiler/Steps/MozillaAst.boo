namespace BooJs.Compiler.Steps

import Boo.Lang.Compiler.Steps

import BooJs.Compiler.CompilerContext as JsCompilerContext
import BooJs.Compiler.Visitors(MozillaAstVisitor)


class MozillaAst(AbstractFastVisitorCompilerStep):
"""
Transforms the Boo AST into a Mozilla AST
"""
    _visitor = MozillaAstVisitor()


    override def Run():
        return if len(Errors)

        # Transform the Boo AST into a Mozilla AST
        cntx = Context as JsCompilerContext
        cntx.MozillaUnit = _visitor.Run(CompileUnit)


        /*
        TODO: Add support for embedded Javascript
        TODO: Allow the generation of code or AST in boojs
        TODO: Implement proof of concept for fixed stack traces


        writer = System.IO.StringWriter()
        printer = Moz.SourceMapPrinter(writer)
        printer.Visit(_return)
        print printer.SrcMap.ToJSON()
        print '----------------------------------[ Moz.Printer ]-'
        print writer.ToString()

        json = Moz.Serializer.Serialize(_return)
        print json
        #_return = Moz.Serializer.Deserialize(json)
        #result = engine.Evaluate('escodegen.generate(' + json + ')')
        #print '------------------------------------[ Escodegen ]-'
        #print result
        */
