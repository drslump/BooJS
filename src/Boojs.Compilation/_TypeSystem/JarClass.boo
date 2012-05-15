namespace Boojay.Compilation.TypeSystem

import System
import System.Collections.Generic
import System.IO

import Boo.Lang.Compiler.TypeSystem
import Boo.Lang.Compiler.TypeSystem.Core
import Boo.Lang.Compiler.TypeSystem.Services

import Boo.Lang.Environments
import Boo.Lang.Useful.Attributes

import org.objectweb.asm

import java.util.jar

class JarClass(AbstractType):
	
	_jar as JarFile
	_entry as JarEntry
	
	def constructor(jar as JarFile, entry as JarEntry):
		_jar = jar
		_entry = entry
		
	override Name:
		[once] get: return Path.GetFileNameWithoutExtension(_entry.getName())
		
	override FullName:
		[once] get: return _entry.getName().Replace("/", ".").RemoveEnd(".class")
		
	override EntityType:
		get: return EntityType.Type
		
	override IsClass:
		get: return true

	override IsFinal:
		get: return ClassFile().IsFinal
		
	override def IsAssignableFrom(other as IType):
		return other is self
		
	[once]
	override def GetMembers():
		return array(ClassFile().Members)
		
	def Resolve(result as ICollection[of IEntity], name as string, typesToConsider as EntityType):
		return my(NameResolutionService).Resolve(name, GetMembers(), typesToConsider, result)
		
	[once]
	private def ClassFile():
		reader = ClassReader(_jar.getInputStream(_entry))
		parser = ClassFileParser(self)
		flags = ClassReader.SKIP_CODE | ClassReader.SKIP_DEBUG | ClassReader.SKIP_FRAMES
		reader.accept(parser, flags)
		return parser

