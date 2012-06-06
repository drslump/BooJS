import System
import System.IO
#using System.Collections.Generic;
import System.Collections
#using System.Text;
#using System.IO;
#using System.Reflection;


for de as DictionaryEntry in Environment.GetEnvironmentVariables():
    print "$(de.Key) = $(de.Value)"

basePath = AppDomain.CurrentDomain.BaseDirectory
print "watching: $basePath"

fsw = FileSystemWatcher(basePath)
#fsw.Changed += FileSystemEventHandler(fsw_Changed);
fsw.Created += FileSystemEventHandler({sender, e as FileSystemEventArgs| print "Created: $(e.ChangeType) - $(e.FullPath)" })
#fsw.Deleted += new FileSystemEventHandler(fsw_Deleted);
#fsw.Error += new ErrorEventHandler(fsw_Error);
#fsw.Renamed += new RenamedEventHandler(fsw_Renamed);
fsw.EnableRaisingEvents = true
fsw.IncludeSubdirectories = true

while true:
    result = fsw.WaitForChanged(WatcherChangeTypes.All, 10000)
    print( ('Time out' if result.TimedOut else "hmmm") )

/*
        static void fsw_Renamed(object sender, RenamedEventArgs e)
        {
            Console.WriteLine("({0}): {1} | {2}", MethodInfo.GetCurrentMethod().Name, e.ChangeType, e.FullPath);
        }

        static void fsw_Error(object sender, ErrorEventArgs e)
        {
            Console.WriteLine("({0}): {1}", MethodInfo.GetCurrentMethod().Name, e.GetException().Message);
        }

        static void fsw_Deleted(object sender, FileSystemEventArgs e)
        {
            Console.WriteLine("({0}): {1} | {2}", MethodInfo.GetCurrentMethod().Name, e.ChangeType, e.FullPath);
        }

        static void fsw_Created(object sender, FileSystemEventArgs e)
        {
            Console.WriteLine("({0}): {1} | {2}", MethodInfo.GetCurrentMethod().Name, e.ChangeType, e.FullPath);
        }

        static void fsw_Changed(object sender, FileSystemEventArgs e)
        {
            Console.WriteLine("({0}): {1} | {2}", MethodInfo.GetCurrentMethod().Name, e.ChangeType, e.FullPath);
        }
    }
}

*/
