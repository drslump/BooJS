namespace Boojay.Compilation.TypeSystem

import Boo.Lang.Environments

import Boo.Lang.Compiler.TypeSystem

class JarConstructor(IConstructor, JarMethod):
	
	def constructor(declaringType as IType, descriptor as string, access as int):
		super(declaringType, "constructor", descriptor, access)

	EntityType:
		get: return EntityType.Constructor

	ReturnType:
		get: return my(TypeSystemServices).VoidType
