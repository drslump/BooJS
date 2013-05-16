import System
import Nancy
import Nancy.Hosting.Self
import Nancy.Helpers


import Boo.Lang.Compiler.IO
import BooJs.Compiler


class Main(NancyModule):
    def constructor():
        pipeline = Pipelines.PrintJs()
        comp = newBooJsCompiler(pipeline)
        comp.Parameters.Debug = true
        comp.Parameters.Ducky = false
        comp.Parameters.Strict = false


        Get["/"] = { x | return "Hello World" }

        Post['/autocomplete'] = do(x):

            form = Request.Form as duck
            filename = HttpUtility.UrlDecode(form['filename'].Value)
            code = HttpUtility.UrlDecode(form['code'].Value)

            line as int
            column as int
            int.TryParse(form['line'].Value, line)
            int.TryParse(form['column'].Value, column)

            print filename, line, column
            print code


            hints = DynamicDictionary()
            return hints

        Post['/compile'] = do(x):

            form = Request.Form as duck
            print form['foo']

            input = StringInput('code', form['foo'])
            comp.Parameters.Input.Clear()
            comp.Parameters.Input.Add(input)

            comp.Parameters.OutputWriter = System.IO.StringWriter()

            result = comp.Run()
            code = comp.Parameters.OutputWriter.ToString()

            return {
                'javascript': code,
                'errors': result.Errors,
                'warnings': result.Warnings
            } 


// initialize an instance of NancyHost (found in the Nancy.Hosting.Self package)
host = NancyHost(Uri("http://localhost:12345"))
host.Start()

Console.WriteLine('Server started... [press any key to exit]')

Console.ReadKey()
Console.WriteLine('Quiting server...')

host.Stop()
