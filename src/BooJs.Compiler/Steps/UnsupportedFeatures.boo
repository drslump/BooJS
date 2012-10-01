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
    """ Boo's struct a value type like strings or integers that works as a class. It means 
        that when declaring it an instance is created and when passing it to a function a 
        copy is made instead of passing a reference.
        Javascript doesn't have any similar type so the conversion is not trivial. Perhaps
        we can have a 'clone' method in the runtime which gets used when we detect a struct 
        type.
    """
        NotImplemented node, 'Struct is not implemented in Boojs'

    /*
    def OnSlicingExpression(node as SlicingExpression):
    """ Boo implements python style slicing, allowing to extract/replace ranges. JS does not have
        a direct syntax for it thus until we can work on converting the slices we flag this
        feature as unsupported
    """
        if len(node.Indices) != 1:
            NotImplemented node, 'Only one index is supported when slicing'

        slice = node.Indices[0]
        if not slice.Begin or slice.End or slice.Step:
            NotImplemented node, 'Range slicing is not supported'

        if slice.Begin isa UnaryExpression and \
           (slice.Begin as UnaryExpression).Operator == UnaryOperatorType.UnaryNegation:
            NotImplemented node, 'Slicing with a negative index is not supported'

        print slice.Begin, slice.Begin.NodeType
    */

    def OnTimeSpanLiteralExpression(node as TimeSpanLiteralExpression):
    """ Literal timespan values ( 1s, 4d, 3h ...)
    """
        NotImplemented node, 'Timespan expressions are not supported'

    def OnYieldStatement(node as YieldStatement):
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


