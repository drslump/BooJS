namespace BooJs.Compiler.Steps

from Boo.Lang.Compiler.TypeSystem import IEntity
from Boo.Lang.Compiler.Steps import AbstractCompilerStep


class InitializeEntityNameMatcher(AbstractCompilerStep):
""" Configures the name matching logic to use. 
"""
    override def Run():
        NameResolutionService.EntityNameMatcher = NameMatcher
    
    def NameMatcher(entity as IEntity, name as string):
        return entity.Name == name
