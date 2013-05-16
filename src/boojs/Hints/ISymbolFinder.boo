""" 
Defines the interface for pluggable external symbol finders.
"""
namespace boojs.Hints

import Boo.Lang.Compiler.TypeSystem(IEntity)


interface ISymbolFinder:
""" Allows to inspect external assemblies for information about entities.
"""
    def LoadAssembly(fname as string) as bool
    def Reset()
    def GetSourceLocation(entity as IEntity) as string


