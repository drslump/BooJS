namespace BooJs.Compiler.Steps

import Boo.Lang.Compiler.Steps
import Boo.Lang.Compiler.TypeSystem


class InitializeEntityNameMatcher(AbstractCompilerStep):
""" Configures the name matching logic to use. 
"""
    override def Run():
        NameResolutionService.EntityNameMatcher = NameMatcher
    
    def NameMatcher(entity as IEntity, name as string):
        return entity.Name == name
