"""
Interfaces for DOM Level 2

Ref: http://www.w3.org/TR/DOM-Level-2-Core/idl-definitions.html
"""
namespace BooJs.Lang.Dom2

interface Node:
    /*
    static final ELEMENT_NODE as ushort                = 1
    static final ATTRIBUTE_NODE as ushort              = 2
    static final TEXT_NODE as ushort                   = 3
    static final CDATA_SECTION_NODE as ushort          = 4
    static final ENTITY_REFERENCE_NODE as ushort       = 5
    static final ENTITY_NODE as ushort                 = 6
    static final PROCESSING_INSTRUCTION_NODE as ushort = 7
    static final COMMENT_NODE as ushort                = 8
    static final DOCUMENT_NODE as ushort               = 9
    static final DOCUMENT_TYPE_NODE as ushort          = 10
    static final DOCUMENT_FRAGMENT_NODE as ushort      = 11
    static final NOTATION_NODE as ushort               = 12
    */

    nodeName as string:
        get
    nodevalue as string:
        get
        set
    nodeType as ushort:
        get
    parentNode as Node:
        get
    childNodes as NodeList:
        get
    firstChild as Node:
        get
    lastChild as Node:
        get
    previousSibling as Node:
        get
    nextSibling as Node:
        get
    attributes as NamedNodeMap:
        get
    ownerDocument as Document:
        get
    namespaceURI as string:
        get
    prefix as string:
        get
        set
    localName as string:
        get

    def insertBefore(newChild as Node, refChild as Node) as Node
    def replaceChild(newChild as Node, oldChild as Node) as Node
    def removeChild(oldChild as Node) as Node
    def appendChild(newChild as Node) as Node
    def hasChildNodes() as bool
    def cloneNode(deep as bool) as Node
    def normalize() as void
    def isSupported(feature as string, version as string) as bool
    def hasAttributes() as bool



interface NodeList:
    //readonly attribute unsigned long    length;
    length as ulong:
        get

    def item(index as ulong) as Node


interface NamedNodeMap:
    //readonly attribute unsigned long    length;
    length as ulong:
        get

    def getNamedItem(name as string) as Node
    def setNamedItem(arg as Node) as Node
    def removeNamedItem(name as string) as Node
    def item(index as ulong) as Node
    def getNamedItemNS(namespaceURI as string, localName as string) as Node
    def setNamedItemNS(arg as Node) as Node
    def removeNamedItemNS(namespaceURI as string, localName as string) as Node

interface DocumentType(Node):
    name as string:
        get
    entities as NamedNodeMap:
        get
    notations as NamedNodeMap:
        get
    publicId as string:
        get
    systemId as string:
        get
    internalSubset as string:
        get


interface DOMImplementation:
    def hasFeature(feature as string, version as string) as bool
    def createDocumentType(qualifiedName as string, publicId as string, systemId as string) as DocumentType
    def createDocument(namespaceURI as string, qualifiedName as string, doctype as DocumentType) as Document


interface Element(Node):
    tagName as string:
        get

    def getAttribute(name as string) as string
    def setAttribute(name as string, value as string) as void
    def removeAttribute(name as string) as void
    /*
    Attr               getAttributeNode(in DOMString name);
    Attr               setAttributeNode(in Attr newAttr)
    Attr               removeAttributeNode(in Attr oldAttr)
    NodeList           getElementsByTagName(in DOMString name);
    DOMString          getAttributeNS(in DOMString namespaceURI,
                                    in DOMString localName);
    void               setAttributeNS(in DOMString namespaceURI,
                                    in DOMString qualifiedName,
                                    in DOMString value)
    void               removeAttributeNS(in DOMString namespaceURI,
                                       in DOMString localName)
                                        raises(DOMException);
    Attr               getAttributeNodeNS(in DOMString namespaceURI,
                                        in DOMString localName);
    Attr               setAttributeNodeNS(in Attr newAttr)
                                        raises(DOMException);
    NodeList           getElementsByTagNameNS(in DOMString namespaceURI,
                                            in DOMString localName);
    */
    def hasAttribute(name as string) as bool
    def hasAttributeNS(namespaceURI as string, localName as string) as bool


interface Attr(Node):
    name as string:
        get
    specified as bool:
        get
    value as string:
        get
        set
    ownerElement as Element:
        get


interface DocumentFragment(Node):
    pass


interface CharacterData(Node):
    data as string:
        get
        set

    length as ulong:
        get

    def substringData(offset as ulong, count as ulong) as string
    def appendData(arg as string) as void
    def insertData(offset as ulong, data as string) as void
    def deleteData(offset as ulong, count as ulong) as void
    def replaceData(offset as ulong, count as ulong, arg as string) as void

interface Text(CharacterData):
    def splitText(offset as ulong) as Text

interface Comment(CharacterData):
    pass

interface CDATASection(Text):
    pass

interface EntityReference(Node):
    pass

interface ProcessingInstruction(Node):
    target as string:
        get

    data as string:
        get
        set

interface Notation(Node):
    publicId as string:
        get
    systemId as string:
        get

interface Entity(Node):
    publicId as string:
        get
    systemId as string:
        get
    notationName as string:
        get

interface Document(Node):
    //readonly attribute DocumentType     doctype;
    doctype as DocumentType:
        get
    //readonly attribute DOMImplementation  implementation;
    implementation as DOMImplementation:
        get
    //readonly attribute Element          documentElement;
    documentElement as Element:
        get

    def createElement(tagName as string) as Element
    def createDocumentFragment() as DocumentFragment
    def createTextNode(data as string) as Text
    def createComment(data as string) as Comment
    def createCDATASection(data as string) as CDATASection
    def createProcessingInstruction(target as string, data as string) as ProcessingInstruction
    def createAttribute(name as string) as Attr
    def createEntityReference(name as string) as EntityReference
    def getElementsByTagName(tagname as string) as NodeList
    def importNode(importedNode as Node, deep as bool) as Node
    def createElementNS(namespaceURI as string, qualifiedName as string) as Element
    def createAttributeNS(namespaceURI as string, qualifiedNamed as string) as Attr
    def getElementsByTagNameNS(namespaceURI as string, localName as string) as NodeList
    def getElementById(elementId as string) as Element

