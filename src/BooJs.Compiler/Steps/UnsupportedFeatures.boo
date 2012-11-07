namespace BooJs.Compiler.Steps

import Boo.Lang.Compiler
import Boo.Lang.Compiler.Ast
import Boo.Lang.Compiler.Steps

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

    def _OnYieldStatement(node as YieldStatement):
    """ Porting yield/generators to standard Javascript is very difficult and it's not
        clear that it could work in all cases. Only Firefox supports them natively thus
        one option could be to add a compiler flag to allow them.
    """
        NotImplemented node, 'Yield is not implemented in Boojs'

    def OnEvent(node as Event):
    """ Boo Event's are a way to easily setup delegates in classes, implementing the 
        observer pattern. Basically they allow registering a callback on them from outside
        the class but only firing them from inside the class.
        There is no clear translation of them to Javascript, we could perhaps just implement
        them using a runtime.
    """
        NotImplemented node, 'Event is not implemented in Boojs'
