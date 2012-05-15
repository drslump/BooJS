namespace Boojay.Compilation.TypeSystem

import Boo.Lang.Environments

import Boo.Lang.Compiler.TypeSystem
import Boo.Lang.Compiler.TypeSystem.Services
import Boo.Lang.PatternMatching

static class AsmTypeResolver:
	def ResolveTypeName(asmType as org.objectweb.asm.Type):
		resolved = _ResolveTypeName(asmType)
		#print asmType, "=>", repr(resolved)
		return resolved
		
	private def _ResolveTypeName(asmType as org.objectweb.asm.Type):
		asmTypeName = asmType.ToString()
		match asmTypeName:
			case "b": return my(TypeSystemServices).ByteType
			case "V": return my(TypeSystemServices).VoidType
			case "I": return my(TypeSystemServices).IntType
			otherwise: return ResolveNonPrimitive(asmTypeName)
	
	private def ResolveNonPrimitive(typeName as string):
		if typeName[0:1] == "L":
			booTypeName = typeName[1:-1].Replace("/", ".")
			resolvedType = my(NameResolutionService).ResolveQualifiedName(booTypeName)
			raise "ResolveQualifiedName failed to resolve ${booTypeName}" unless resolvedType
			return resolvedType
		raise "Unknown NonPrimitive ${typeName}"
	
def repr(o):
	code = (0 if o is null else o.GetHashCode())
	return "${o} (${code})"
