import System
import Nancy
import Nancy.Hosting.Self


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

            print Request.Body.ToString()

            return {'foo': 'bar'}



// initialize an instance of NancyHost (found in the Nancy.Hosting.Self package)
host = NancyHost(Uri("http://localhost:12345"))
host.Start()

Console.WriteLine('Server started... [press any key to exit]')

Console.ReadKey()
Console.WriteLine('Quiting server...')

host.Stop()
