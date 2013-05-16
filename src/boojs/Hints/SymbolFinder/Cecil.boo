"""
Plugin for Cecil based functionality.

This file should be compiled into its own assembly, it will be loaded dynamically
in order to use its functionality if available.
"""
namespace boojs.Hints.SymbolFinder

import boojs.Hints(ISymbolFinder)
import Boo.Lang.PatternMatching
import Boo.Lang.Compiler.TypeSystem
import Mono.Cecil


class Cecil(ISymbolFinder):

    _assemblies = List[of AssemblyDefinition]()

    def LoadAssembly(fname as string):
        asm = AssemblyDefinition.ReadAssembly(fname)
        path = asm.MainModule.FullyQualifiedName
        if not System.IO.File.Exists(path + '.mdb'):
            return false

        reader = Mdb.MdbReaderProvider().GetSymbolReader(asm.MainModule, path)
        asm.MainModule.ReadSymbols(reader)
        _assemblies.Add(asm)

        return true

    def Reset():
        _assemblies.Clear()

    def GetSourceLocation(entity as IEntity):
    """ Find location information for the given entity.
        Returns null if we couldn't find any information or a string with 
        the following format: '/path/to/file:line:column'
    """
        def find_seq(m as MethodDefinition):
            return unless m.HasBody
            seq = m.Body.Instructions[0].SequencePoint
            return unless seq and seq.Document
            # Target the previous line
            return '{0}:{1}:{2}' % (
                seq.Document.Url,
                seq.StartLine - 1,
                seq.StartColumn + 1)

        # Internal entities provide their lexical information in their node
        if ie = entity as IInternalEntity:
            return '{0}:{1}:{2}' % (
                ie.Node.LexicalInfo.FileName,
                ie.Node.LexicalInfo.Line,
                ie.Node.LexicalInfo.Column)

        ee = entity as IExternalEntity
        if not ee:
            return null

        # Get the metadata token from the entity
        token = MetadataToken(ee.MemberInfo.MetadataToken)

        # Lookup the token in each module
        for asmdef in _assemblies:
            for mod in asmdef.Modules:
                match definition=mod.LookupToken(token):
                    case null:
                        continue
                    case method=MethodDefinition():
                        continue unless method.Name == entity.Name
                        return find_seq(method)
                    case prop=PropertyDefinition():
                        continue unless prop.Name == entity.Name
                        return find_seq(prop.GetMethod)
                    # TODO: Support types and field
                    otherwise:
                        print '# DEF', definition

        return null

