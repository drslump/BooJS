namespace Boojay.Compilation.TypeSystem

import Boo.Lang.Compiler.TypeSystem
import Boo.Lang.Compiler.TypeSystem.Reflection

class BeanAwareType(ExternalType):
	
	def constructor(provider as IReflectionTypeSystemProvider, type as System.Type):
		super(provider, type)
		
	override def CreateMembers():
		originalMembers = super()
		beanProperties = BeanPropertyFinder(originalMembers).findAll()
		return array(IEntity, cat(originalMembers, beanProperties))