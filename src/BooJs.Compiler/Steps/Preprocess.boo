namespace BooJs.Compiler.Steps

import Boo.Lang.Compiler
import Boo.Lang.Compiler.Steps
import Boo.Lang.Compiler.IO


# TODO: Add support for actual preprocessors and pragmas
class Preprocess(AbstractCompilerStep):

    override def Run():

        processed = List[of ICompilerInput]()
        for input in Parameters.Input:
            mod = ModifySafeMemberAccess(input)
            processed.Add(mod)

        Parameters.Input.Clear()
        Parameters.Input.Extend(processed)


    private def ModifySafeMemberAccess(input as ICompilerInput):

        ch = SafeMemberAccess.UNICODE_CHAR
        using reader = input.Open():
            output = System.IO.StringWriter()

            while (line = reader.ReadLine()) is not null:
                # Use a unicode letter to ensure compiler lexical info matches
                line = line.Replace('?.', ch + '.')
                line = line.Replace('?[', ch + '[')
                line = line.Replace('?(', ch + '(')
                output.WriteLine(line)

        return StringInput(input.Name, output.ToString())