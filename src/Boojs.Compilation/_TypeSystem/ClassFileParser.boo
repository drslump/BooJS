namespace Boojay.Compilation.TypeSystem

import System
import Boo.Lang.Compiler.TypeSystem
import org.objectweb.asm
import org.objectweb.asm.commons

class ClassFileParser(EmptyVisitor):
	
	_declaringType as IType
	_access as int
	
	[getter(Members)] _members = List[of IEntity]()
	
	IsPublic as bool:
		get: return (_access & Opcodes.ACC_PUBLIC) != 0

	IsPrivate as bool:
		get: return (_access & Opcodes.ACC_PRIVATE) != 0

	IsStatic as bool:
		get: return (_access & Opcodes.ACC_STATIC) != 0

	IsFinal as bool:
		get: return (_access & Opcodes.ACC_FINAL) != 0
	
	def constructor(declaringType as IType):
		_declaringType = declaringType
		
	override def visit(version as int, access as int, name as string,
			signature as string, superName as string, 
			interfaces as (string)):
		_access = access

	override def visitMethod(access as int, name as string,
					descriptor as string, signature as string, exceptions as (string)):
		if isConstructor(name):
			_members.Add(JarConstructor(_declaringType, descriptor, access))
		else:
			_members.Add(JarMethod(_declaringType, name, descriptor, access))
		return super(access, name, descriptor, signature, exceptions)
		
	private def isConstructor(methodName as string):
		return methodName.Equals("<init>")
