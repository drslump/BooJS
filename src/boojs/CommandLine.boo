namespace boojs

import System.IO
import Boo.Lang.Useful.CommandLine from Boo.Lang.Useful

class CommandLine(AbstractCommandLine):
    
    [getter(Classpaths)]
    _classpaths = List[of string]()
    
    [getter(References)]
    _references = List[of string]()
    
    _sourceFiles = List[of string]()
    
    _srcDirs = List[of string]()

    def constructor(argv):
        Parse(argv)
        
    def SourceFiles():
        
        for srcFile as string in _sourceFiles:
            yield srcFile
            
        for srcDir in _srcDirs:
            for fname in Directory.GetFiles(srcDir, "*.boo"):
                continue unless fname.EndsWith("boo")
                yield fname
        
    IsValid:
        get: return self.HintsServer or len(self._sourceFiles) > 0 or len(self._srcDirs) > 0
        
    [Option("Output directory", ShortForm: "o", LongForm: "out")]
    public OutputDirectory = "."
        
    [Option("Prints the resulting bytecode to stdout (js, boo).", ShortForm: 'p', LongForm: "print")]
    public PrintCode = false
    
    [Option("Enables duck typing.", LongForm: "ducky")]
    public Ducky = false
    
    [Option("Enables writing debug symbols.", LongForm: "debug")]
    public Debug = false
    
    [Option("Enables verbose mode.", LongForm: "verbose")]
    public Verbose = false
    
    [Option("Embeds the types metadata assembly into the generated file (enabled by default).", LongForm: "embedasm")]
    public EmbedAssembly = true

    [Option("References the specified {assembly}", ShortForm: 'r', LongForm: "reference", MaxOccurs: int.MaxValue)]
    def AddReference(reference as string):
        if not reference:
            raise CommandLineException("No reference supplied (ie: -r:my.project.reference)")

        _references.AddUnique(Unquote(reference))

    [Option("Includes all *.boo files from {srcdir}", LongForm: "srcdir", MaxOccurs: int.MaxValue)]
    def AddSourceDir(srcDir as string):
        _srcDirs.AddUnique(Path.GetFullPath(srcDir))

    [Option("Specify an output file where to generate source map", LongForm: "sourcemap")]
    public SourceMap as string = null
    [Option("Root prefix for source map files", LongForm: "sourcemap-root")]
    public SourceMapRoot as string = null

    # TODO: Add option to launch external program on compilation failure
    [Option("Watch files and recompile", ShortForm: "w", LongForm: "watch")]
    public Watch as bool = false

    [Option("Display this help and exit", LongForm: "help")]
    public DoHelp = false

    [Option("Launch the compiler in hints mode", LongForm: "hints-server")]
    public HintsServer as bool = false

    [Option("Make hints mode compatible with standard Boo", LongForm: "hints-boo")]
    public HintsBoo as bool = false

    [Argument]
    def AddSourceFile([required] sourceFile as string):
        _sourceFiles.Add(sourceFile)


    def Unquote(path as string):
        if path.StartsWith('"') or path.StartsWith("'"):
            return path[1:-1]
        return path
