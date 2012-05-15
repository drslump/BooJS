namespace Boojay.Compilation.TypeSystem

import java.util.jar

class JarNamespace(JarNamespaceCommon):
	_entry as JarEntry
	_parentName as string
	
	[getter(Name)]
	_name as string
	
	override FullName as string:
		get:
			return _name if string.IsNullOrEmpty(_parentName) 
			return "${_parentName}/${_name}"
	
	def constructor(parentName as string, jar as JarFile, name as string):
		_jar = jar
		_name = name
		_parentName = parentName

	override def ShouldProcess(entry as JarEntry):
		return entry.getName().StartsWith("${FullName}/")

	override def GetRelativeEntryName(entry as JarEntry):
		return entry.getName().RemoveStart("${FullName}/")
