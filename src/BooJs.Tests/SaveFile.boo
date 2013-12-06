namespace BooJs.Tests

import BooJs.Tests.Support

import NUnit.Framework

import System.IO(File, StringWriter)
import Boo.Lang.Compiler.IO(StringInput)
import BooJs.Compiler
import BooJs.Compiler.Pipelines

[TestFixture]
class SaveFileTest:

    static CODE = 'enum Foo:\n\tone\n\ttwo\n\tthree\n\nfoo = Foo.two\n'


    def setup_compiler(code as string):
        comp = newBooJsCompiler(Pipelines.SaveJs())
        comp.Parameters.Debug = true

        src = StringInput('code', code)
        comp.Parameters.Input.Add(src)

        return comp

    [Test]
    def embedded_assembly():
        comp = setup_compiler(CODE)
        (comp.Parameters as CompilerParameters).EmbedAssembly = true
        result = comp.Run()

        content = File.ReadAllText(result.GeneratedAssemblyFileName)
        print content
        assert content.IndexOf('//# booAssembly') >= 0

        asm = comp.Parameters.LoadAssembly(result.GeneratedAssemblyFileName)
        assert asm isa Boo.Lang.Compiler.TypeSystem.Reflection.IAssemblyReference

    [Test]
    def non_embedded_assembly():
        comp = setup_compiler(CODE)
        (comp.Parameters as CompilerParameters).EmbedAssembly = false
        result = comp.Run()

        content = File.ReadAllText(result.GeneratedAssemblyFileName)
        assert content.IndexOf('//# booAssembly') == -1

    [Test]
    def generate_sourcemap():
        comp = setup_compiler(CODE)
        (comp.Parameters as CompilerParameters).SourceMap = ''
        result = comp.Run()

        content = File.ReadAllText(result.GeneratedAssemblyFileName)
        assert content.IndexOf('//# sourceMappingURL') >= 0

        content = File.ReadAllText(result.GeneratedAssemblyFileName + '.map')
        assert content.IndexOf(result.GeneratedAssemblyFileName) >= 0

    [Test]
    def generate_sourcemap_custom_name():
        comp = setup_compiler(CODE)
        (comp.Parameters as CompilerParameters).SourceMap = 'srcmap.map'
        result = comp.Run()

        content = File.ReadAllText(result.GeneratedAssemblyFileName)
        assert content.IndexOf('//# sourceMappingURL=srcmap.map') >= 0

        content = File.ReadAllText((comp.Parameters as CompilerParameters).SourceMap)
        assert content.IndexOf(result.GeneratedAssemblyFileName) >= 0
