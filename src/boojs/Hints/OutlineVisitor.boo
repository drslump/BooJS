namespace boojs.Hints

import Boo.Lang.Compiler.Ast
import Boo.Lang.PatternMatching


class OutlineVisitor(DepthFirstVisitor):

    _node as NodeMessage

    def constructor(root as NodeMessage):
        _node = root

    override def OnModule(node as Module):
        # Populate the root node
        _node.type = node.NodeType.ToString()
        _node.name = node.Name

        VisitCollection(node.Imports)
        VisitCollection(node.Members)
        Visit(node.Globals)

    override def OnNamespaceDeclaration(node as NamespaceDeclaration):
        AddNode(DescribeNode(node))

    override def OnImport(node as Import):
        AddNode(DescribeNode(node))

    override def OnMacroStatement(node as MacroStatement):
        prev = _node
        _node = current = DescribeNode(node)
        Visit(node.Body)
        _node = prev
        AddNode(current)

    override def OnClassDefinition(node as ClassDefinition):
        TypeNode(node)

    override def OnInterfaceDefinition(node as InterfaceDefinition):
        TypeNode(node)

    override def OnStructDefinition(node as StructDefinition):
        TypeNode(node)

    override def OnEnumDefinition(node as EnumDefinition):
        TypeNode(node)

    override def OnCallableDefinition(node as CallableDefinition):
        MemberNode(node)

    override def OnMethod(node as Method):
        MemberNode(node)

    override def OnField(node as Field):
        MemberNode(node)

    override def OnConstructor(node as Constructor):
        MemberNode(node)

    override def OnDestructor(node as Destructor):
        MemberNode(node)

    override def OnProperty(node as Property):
        prev = _node
        _node = current = DescribeNode(node)
        Visit(node.Getter)
        Visit(node.Setter)
        _node = prev
        AddNode(current)

    override def OnEvent(node as Event):
        MemberNode(node)

    protected def NodeName(node as Node):
        match node:
            case field = Field():
                return field.Name
            case method = Method():
                return method.Name
            case prop = Property():
                return prop.Name
            case member = TypeMember():
                return member.Name
            case macro = MacroStatement(Name: macroName):
                return macroName
            otherwise:
                return null

    protected def NodeDesc(node as Node):
        match node:
            case field = Field():
                return field.Name + describeReturnType(field.Type)
            case method = Method():
                return '{0}({1}){2}' % (
                    method.Name,
                    describeParams(method.Parameters),
                    describeReturnType(method.ReturnType)
                )
            case prop = Property():
                return '{0}({1}){2}' % (
                    prop.Name,
                    describeParams(prop.Parameters),
                    describeReturnType(prop.Type)
                )
            case member = TypeMember():
                return member.FullName
            case macro = MacroStatement(Name: macroName, Arguments: args):
                if len(args) > 0:
                    return "${macroName} ${args[0]}"
                return macroName
            otherwise:
                return node.ToString()

    protected def DescribeNode(node as Node):
        msg = NodeMessage()
        msg.type = node.NodeType.ToString()
        msg.name = NodeName(node)
        msg.desc = NodeDesc(node)
        msg.line = node.LexicalInfo.Line
        if node.EndSourceLocation.Line > 0:
            msg.length = node.EndSourceLocation.Line - node.LexicalInfo.Line + 1
        else:
            msg.length = 0
        return msg

    protected def DescribeNode(node as Node, visibility as string):
        msg = DescribeNode(node)
        msg.visibility = visibility
        return msg

    protected def AddNode(node as NodeMessage):
        _node.members.Add(node)

    protected def MemberNode(node as TypeMember):
        current = DescribeNode(node, GetVisibility(node))
        AddNode(current)

    protected def TypeNode(node as TypeDefinition):
        prev = _node
        _node = current = DescribeNode(node)
        VisitCollection(node.Members)
        _node = prev
        AddNode(current)

    protected def GetVisibility(node as TypeMember):
        if node.IsVisibilitySet:
            return "Internal" if node.IsInternal
            return "Protected" if node.IsProtected
            return "Private" if node.IsPrivate
            return "Public" if node.IsPublic

        return "Internal"
