namespace BooJs.Compiler.Steps

from Boo.Lang.Compiler.Ast import *
from Boo.Lang.Compiler.Steps import AbstractTransformerCompilerStep
from Boo.Lang.Compiler.TypeSystem import EntityType, IExternalEntity, ExternalConstructor, IMethod
from Boo.Lang.Compiler.TypeSystem.Reflection import ExternalType

from BooJs.Lang.Extensions import ExternAttribute

from BooJs.Compiler.Utils import *


class ProcessImports(AbstractTransformerCompilerStep):
"""
    Process imports

    Wraps the module in an AMD style loader, placing any referenced namespaces as imports
"""
    _mappings = {}
    _asmrefs = {}

    protected def FindNamespace(fqn as string) as string:
    """ Given a fully qualified name it will check backwards until it 
        finds the containing namespace
    """
        parts = fqn.Split(char('.'))
        while len(parts):
            type = NameResolutionService.ResolveQualifiedName(join(parts, '.'))
            if type.EntityType in (EntityType.Namespace,):
                return type.FullName
            parts = parts[:-1]
        return null

    protected def MapNamespace(ns as string, alias as string, asmref as ReferenceExpression):
        actualns = FindNamespace(ns)
        if actualns != ns:
            alias = null

        # Namespace already mapped, nothing to do
        if actualns in _mappings:
            return

        # Generate an alias name if none given
        if not alias:
            alias = Context.GetUniqueName('NS')

        # Map the namespace
        _mappings[actualns] = alias
        if asmref:
            _asmrefs[actualns] = asmref.Name

    def OnModule(node as Module):
        # Map module namespace to the exports special symbol
        ns = (node.Namespace.Name if node.Namespace else '')
        _mappings[ns] = 'exports'

        # Makes sure we visit the imports first
        Visit node.Imports
        Visit node.Members
        Visit node.Globals

        # Annotate the module with the reported namespace mappings
        # TODO: Avoid the annotations by converting this step into a simple visitor
        #       used from the printer
        node.Annotate('nsmapping', _mappings.Clone())
        node.Annotate('nsasmrefs', _asmrefs.Clone())

        # Reset for next module
        _mappings.Clear()
        _asmrefs.Clear()

    def OnImport(node as Import):
        # Detect imports of the own module namespace
        module = node.GetAncestor[of Module]()
        if module and module.Namespace and module.Namespace.Name == node.Namespace:
            return

        if mie = node.Expression as MethodInvocationExpression:
            for arg as ReferenceExpression in mie.Arguments:
                fqn = node.Namespace + '.' + arg.Name
                continue if isExtern(fqn)

                if node.Alias:
                    MapNamespace(node.Namespace + '.' + arg.Name, null, node.AssemblyReference)
                elif arg.ContainsAnnotation('alias'):
                    MapNamespace(node.Namespace + '.' + arg.Name, arg['alias'], node.AssemblyReference)
                else:
                    MapNamespace(node.Namespace + '.' + arg.Name, arg.Name, node.AssemblyReference)


        elif not isExtern(node.Namespace):
            if node.Alias:
                MapNamespace(node.Namespace, node.Alias.Name, node.AssemblyReference)
            else:
                MapNamespace(node.Namespace, null, node.AssemblyReference)

    def OnMemberReferenceExpression(node as MemberReferenceExpression):
        # Ignore special method names
        if im = node.Entity as IMethod and im.IsSpecialName:
            super(node)
            return

        # Make sure we use the entity name for external references (they may have been aliased)
        if extent = node.Entity as IExternalEntity:
            node.Name = extent.Name

        super(node)

    protected def GetExternName(ent as IExternalEntity) as string:
        attr as ExternAttribute
        if ec = ent as ExternalConstructor:
            attr = System.Attribute.GetCustomAttribute(ec.ConstructorInfo.DeclaringType, typeof(ExternAttribute), false)
        elif et = ent as ExternalType:
            attr = System.Attribute.GetCustomAttribute(et.ActualType, typeof(ExternAttribute), false)

        return (attr.Name if attr else null)

    def OnReferenceExpression(node as ReferenceExpression):
        # Get name from extern definition
        if node.Entity and node.Entity isa IExternalEntity:
            name = GetExternName(node.Entity)
            if name:
                node.Name = name
                return

        # External constructors
        if extent = node.Entity as IExternalEntity:
            if extent.EntityType == EntityType.Constructor:
                name = (extent as ExternalConstructor).DeclaringType.FullName
            else:
                name = extent.FullName

        # External types
        elif exttype = node.Entity as ExternalType:
            
            name = exttype.FullName

        # Handle aliases with multiple references: import Foo(Bar, Baz) as MyFoo
        elif esimple = node.Entity as Boo.Lang.Compiler.TypeSystem.Core.SimpleNamespace:
            if esimple.FullName:
                name = esimple.FullName
            else:
                for member in esimple.GetMembers():
                    if member isa ExternalType:
                        name = (member as ExternalType).ActualType.Namespace
                        break;

        return unless name

        # Find a mapping containing the full name of the entity
        parts = name.Split(char('.'))
        rhs = []
        while len(parts):
            name = join(parts, '.')
            if name in _mappings:
                rhs.Insert(0, _mappings[name])
                node.Name = join(rhs, '.')
                break

            # Skip module classes
            if not IsModule(name):
                rhs.Add(parts[-1])

            parts = parts[:-1]


    protected def IsModule(fqn as string) as bool:
    """ Checks if the given fully qualified name actually resolves into a module
    """
        try:
            type = NameResolutionService.ResolveQualifiedName(fqn) as ExternalType
            return type and type.IsClass and type.IsFinal and type.Name.EndsWith('Module')
        except:
            return false
