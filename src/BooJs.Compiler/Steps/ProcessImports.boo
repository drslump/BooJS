namespace BooJs.Compiler.Steps

import Boo.Lang.Compiler.Ast
import Boo.Lang.Compiler.Steps
import Boo.Lang.Compiler.TypeSystem(EntityType)
import Boo.Lang.Compiler.TypeSystem.Reflection(ExternalType)

import BooJs.Compiler.Utils

class ProcessImports(AbstractTransformerCompilerStep):
"""
    Process imports

    Wraps the module in an AMD style loader, placing any referenced namespaces as imports
"""
    _mappings = {}
    _asmrefs = {}
    _nsidx = 0


    protected def FindNamespace(fqn as string) as string:
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
            alias = 'NS' + _nsidx++

        # Map the namespace
        _mappings[actualns] = alias
        if asmref:
            _asmrefs[actualns] = asmref.Name

    def OnModule(node as Module):
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
        _nsidx = 0

    def OnImport(node as Import):
        if mie = node.Expression as MethodInvocationExpression:
            for arg as ReferenceExpression in mie.Arguments:
                fqn = node.Namespace + '.' + arg.Name
                continue if isExtern(fqn)

                if node.Alias:
                    MapNamespace(node.Namespace + '.' + arg.Name, null, node.AssemblyReference)
                else:
                    MapNamespace(node.Namespace + '.' + arg.Name, arg.Name, node.AssemblyReference)

        elif not isExtern(node.Namespace):
            if node.Alias:
                MapNamespace(node.Namespace, node.Alias.Name, node.AssemblyReference)
            else:
                MapNamespace(node.Namespace, null, node.AssemblyReference)

    def OnReferenceExpression(node as ReferenceExpression):
        # Only process external types
        if etype = node.ExpressionType as ExternalType:
            name = etype.FullName
        # Handle aliases with multiple references: import Foo(Bar, Baz) as MyFoo
        elif entity = node.Entity as Boo.Lang.Compiler.TypeSystem.Core.SimpleNamespace:
            if entity.FullName:
                name = entity.FullName
            else:
                for member in entity.GetMembers():
                    if member isa ExternalType:
                        name = (member as ExternalType).ActualType.Namespace
                        break;

        if not name:
            return

        parts = name.Split(char('.'))
        rhs = []
        while len(parts):
            name = join(parts, '.')
            if name in _mappings:
                rhs.Insert(0, _mappings[name])
                node.Name = join(rhs, '.')
                break

            # Detect module classes to skip them
            if not IsModule(name):
                rhs.Add(parts[-1])

            parts = parts[:-1]


    protected def IsModule(fqn as string) as bool:
        try:
            type = NameResolutionService.ResolveQualifiedName(fqn) as ExternalType
            return type and type.IsClass and type.IsFinal and type.Name =~ /^\w+Module$/
        except:
            return false
