namespace BooJs.Compiler.Steps

from Boo.Lang.Compiler import CompilerErrorFactory
from Boo.Lang.Compiler.Ast import *
from Boo.Lang.Compiler.Steps import AbstractVisitorCompilerStep


class UnsupportedFeatures(AbstractVisitorCompilerStep):
"""
    Detect those features not yet supported by Boojs and raise errors for them

    Note: This step should be placed just after parsing and just after expanding macros
"""
    override def Run():
        if len(Errors) > 0:
            return
        Visit CompileUnit

    def NotImplemented(node, msg):
        Error( CompilerErrorFactory.NotImplemented(node, msg) )

    def OnStructDefinition(node as StructDefinition):
    """ Boo's struct is a value type like integers that works as a class. It means
        that when declaring it an instance is created and when passing it to a function a 
        copy is made instead of passing a reference.
        Javascript doesn't have any similar type so the conversion is not trivial. Perhaps
        we can have a 'clone' method in the runtime which gets used when we detect a struct 
        type.
    """
        NotImplemented node, 'Struct is not implemented in Boojs'

    def OnEvent(node as Event):
    """ Boo Event's are a way to easily setup delegates in classes, implementing the 
        observer pattern. Basically they allow registering a callback on them from outside
        the class but only firing them from inside the class.
        There is no clear translation of them to Javascript, we could perhaps just implement
        them using a runtime.
    """
        NotImplemented node, 'Event is not implemented in Boojs'
