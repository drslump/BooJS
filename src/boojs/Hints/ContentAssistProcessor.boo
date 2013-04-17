namespace boojs.Hints

import Boo.Lang.Compiler.Ast
import Boo.Lang.Compiler.TypeSystem
import Boo.Lang.Compiler.TypeSystem.Services


/*
class ContentAssistProcessor(DepthFirstVisitor):

    static final MemberAnchor = '__codecomplete__'

    static def WithProposalsFor(source as string, continuation as callable(IEntity*)):
        resolution = ExpressionResolution.ForCodeString(source)
        processor = ContentAssistProcessor(resolution.NodeInformationProvider)
        resolution.RunInResolvedCompilerContext:
            processor.VisitAllowingCancellation(resolution.OriginalCompileUnit)
            continuation(processor.Members)

    Members as (IEntity):
        get:
            _members.Sort(_members, {left, right | left.ToString().CompareTo(right.ToString())})
            return _members

    _members = array(IEntity, 0)
    _nodeInformationProvider as NodeInformationProvider
    _currentType as IType

    def constructor(nif as NodeInformationProvider):
        _nodeInformationProvider = nif

    override def OnClassDefinition(node as ClassDefinition):
        OnTypeDefinition(node)

    override def OnInterfaceDefinition(node as InterfaceDefinition):
        OnTypeDefinition(node)

    override def OnStructDefinition(node as StructDefinition):
        OnTypeDefinition(node)

    def OnTypeDefinition(node as TypeDefinition):
        oldType = _currentType
        _currentType = _nodeInformationProvider.EntityFor(node)
        Visit(node.Members)
        Visit(node.Attributes)
        _currentType = oldType

    override def LeaveMemberReferenceExpression(node as MemberReferenceExpression):
        if node.Name != MemberAnchor:
            return

        _members = FilterSuggestions(getCompletionNamespace(node))
        Cancel()

    def FilterSuggestions(entity as IEntity):
        ns = entity as INamespace
        return array(IEntity, 0) if ns is null
        return FilteredMembers(MemberCollector.CollectAllMembers(ns))

    def FilteredMembers(members as (IEntity)):
        return array(
                item
                for item in members
                unless IsSpecial(item) or not IsAccessible(item))

    def IsSpecial(entity as IEntity):
        for prefix in ".", "___", "add_", "remove_", "raise_", "get_", "set_":
            return true if entity.Name.StartsWith(prefix)

    def IsAccessible(entity as IEntity):
        member = entity as IAccessibleMember
        return true if member is null or member.IsPublic

        declaringType = member.DeclaringType
        return true if declaringType is _currentType
        return true if member.IsInternal and member isa IInternalEntity
        return true if member.IsProtected and _currentType is not null and _currentType.IsSubclassOf(declaringType)
        return false

    protected def getCompletionNamespace(expression as MemberReferenceExpression) as INamespace:
        return _nodeInformationProvider.NamespaceAt(expression.Target)
*/