namespace boojs

import Boo.Ide.ProjectIndex as BooProjectIndex
import Boo.Lang.Compiler(BooCompiler, CompilerContext, Steps)
import Boo.Lang.Compiler.Ast(Module)
import BooJs.Compiler(newBooJsCompiler, Pipelines)


class ProjectIndex(BooProjectIndex):

    public Context as CompilerContext

    def constructor():
        compiler = newBooJsCompiler(Pipelines.ResolveExpressions(BreakOnErrors: false))
        parser = newBooJsCompiler(Pipelines.Parse() { Steps.IntroduceModuleClasses() })
        implicitNamespaces = [
            'BooJs.Lang',
            'BooJs.Lang.Builtins',
            'BooJs.Lang.Globals',
            'BooJs.Lang.Macros',
            'Boo.Lang.PatternMatching'
        ]

        self(compiler, parser, implicitNamespaces)

    def constructor(compiler as BooCompiler, parser as BooCompiler, implicitNamespaces as List):
        # Keep a copy around for the compiler context
        compiler.Parameters.Pipeline.After += def(pipeline, args):
            self.Context = args.Context
        parser.Parameters.Pipeline.After += def(pipeline, args):
            self.Context = args.Context

        super(compiler, parser, implicitNamespaces)

    new virtual def WithModule(fname as string, contents as string, action as System.Action[of Module]):
        # HACK: Call the original private method
        mi = typeof(BooProjectIndex).GetMethod('WithModule', BindingFlags.NonPublic | BindingFlags.Instance)
        mi.Invoke(self, (fname, contents, action))
