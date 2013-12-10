namespace boojs

from System.IO import Directory, Path
from Boo.Lang.Useful.CommandLine import *

class CommandLine(AbstractCommandLine):

    [getter(Classpaths)]
    _classpaths = List[of string]()

    [getter(References)]
    _references = List[of string]()

    _sourceFiles = List[of string]()

    _srcDirs = List[of string]()

    property Defines = {}

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
        get: return len(self._sourceFiles) > 0 or len(self._srcDirs) > 0

    [Option("Output {filename}", ShortForm: "o", LongForm: "out")]
    public OutputDirectory = "."

    [Option("Select a pipeline (boo or js prints code)", ShortForm: 'p', LongForm: "pipeline")]
    public Pipeline as string

    [Option("Enables duck typing.", LongForm: "ducky")]
    public Ducky = false

    [Option("Enables writing debug symbols.", LongForm: "debug")]
    public Debug = false

    [Option("Enables verbose mode.", ShortForm: "v", LongForm: "verbose")]
    public Verbose = false

    [Option("Embeds types metadata into the generated file (on by default).", LongForm: "embedtypes")]
    public EmbedTypes = true

    [Option("References the specified {assembly}", ShortForm: 'r', LongForm: "reference", MaxOccurs: int.MaxValue)]
    def AddReference(reference as string):
        if not reference:
            raise CommandLineException("No reference supplied (ie: -r:my.project.reference)")

        _references.AddUnique(Unquote(reference))

    [Option("Includes all *.boo files from {directory}", LongForm: "srcdir", MaxOccurs: int.MaxValue)]
    def AddSourceDir(srcDir as string):
        _srcDirs.AddUnique(Path.GetFullPath(srcDir))

    [Option('Defines a {symbol} with an optional value (=val)', ShortForm: 'D', LongForm: 'define', MaxOccurs: int.MaxValue)]
    def AddDefine(define as string):
        pair = define.Split(char('='))
        if len(pair) == 1:
            Defines[pair[0]] = pair[0]
        else:
            Defines[pair[0]] = pair[1]

    [Option("Specify an output {file} where to generate source map (- to embed)", LongForm: "srcmap")]
    public SourceMap as string = null
    [Option("Root {prefix} for source map files", LongForm: "srcmap-root")]
    public SourceMapRoot as string = null

    # TODO: Add option to launch external program on compilation failure
    [Option("Watch files and recompile", ShortForm: "w", LongForm: "watch")]
    public Watch as bool = false

    [Option("Display this help and exit", LongForm: "help")]
    public DoHelp = false


    [Argument]
    def AddSourceFile([required] sourceFile as string):
        _sourceFiles.Add(sourceFile)


    def Unquote(path as string):
        if path.StartsWith('"') or path.StartsWith("'"):
            return path[1:-1]
        return path
