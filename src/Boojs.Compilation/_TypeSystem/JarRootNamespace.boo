namespace Boojay.Compilation.TypeSystem

import java.util.jar

class JarRootNamespace(JarNamespaceCommon):
			
	def constructor(jar as string):
		_jar = JarFile(jar)
