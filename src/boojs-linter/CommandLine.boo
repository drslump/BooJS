namespace boojs

import System.IO
import Boo.Lang.Useful.CommandLine from Boo.Lang.Useful

class CommandLine(AbstractCommandLine):

    _srcFiles = List[of string]()
    _srcDirs = List[of string]()

    def constructor(argv):
        Parse(argv)
        
    def SourceFiles():

        for srcFile as string in _srcFiles:
            yield srcFile
            
        for srcDir in _srcDirs:
            for fname in Directory.GetFiles(srcDir, "*.boo"):
                continue unless fname.EndsWith("boo")
                yield fname
        
    IsValid:
        get: return len(self._srcFiles) > 0 or len(self._srcDirs) > 0
        
    [Option("Enables verbose mode.", ShortForm: "v", LongForm: "verbose")]
    public Verbose = false

    [Option("display this help and exit", ShortForm: "h", LongForm: "help")]
    public DoHelp = false
        
    [Argument]
    def AddSourceFile([required] sourceFile as string):
        if System.IO.Directory.Exists(sourceFile):
            _srcDirs.AddUnique(sourceFile)
        else:
            _srcFiles.Add(sourceFile)

