namespace Boojay.Compilation.TypeSystem

import System

class JarTypeSystemProvider:
	
	def ForJar(jar as string):
		return JarCompileUnit(jar)
