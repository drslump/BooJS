namespace Boojay.Compilation.TypeSystem

import Boo.Lang.Compiler.TypeSystem
import Boo.Lang.Useful.Attributes

import java.util.jar

abstract class JarNamespaceCommon(AbstractNamespace):

	[getter(Jar)]
	_jar as JarFile

	_children = {}
	
	virtual FullName as string:
		get: return ""
			
	[once]
	override def GetMembers():
		return array(LoadMembers())
		
	private def LoadMembers() as IEntity*:
		entries = _jar.entries()
		while entries.hasMoreElements():
			entry as JarEntry = entries.nextElement()
			continue unless ShouldProcess(entry)

			relativeName = GetRelativeEntryName(entry)
			
			if HasNamespace(relativeName):
				yield ProcessNamespace(relativeName)
			else:
				yield JarClass(_jar, entry)

	virtual protected def ShouldProcess(entry as JarEntry):
		return true
			
	virtual protected def GetRelativeEntryName(entry as JarEntry):
		return entry.getName()

	private def HasNamespace(name as string):
		return "/" in name

	private def ProcessNamespace(name as string) as INamespace:
		return GetNamespace(/\//.Split(name)[0])
		
	private def GetNamespace(name as string):
		_children[name] = JarNamespace(FullName, _jar, name) unless _children.Contains(name)
		return _children[name]
