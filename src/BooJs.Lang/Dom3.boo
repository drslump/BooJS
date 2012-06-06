"""
Interfaces for DOM Level 3

Ref: http://www.w3.org/TR/DOM-Level-3-Core/idl-definitions.html
"""
namespace BooJs.Lang.Dom3

import BooJs.Lang.Dom2 as Dom2


interface Node(Dom2.Node):
    baseURI as string:
        get

    textContent as string:
        get
        set

    def compareDocumentPosition(other as Node) as ushort
    def isSameNode(other as Node) as bool
    def lookupPrefix(namespaceURI as string) as string
    def isDefaultNamespace(namespaceURI as string) as bool
    def lookupNamespaceURI(prefix as string) as string
    def isEqualNode(arg as Node) as bool
    def getFeature(feature as string, version as string) as object # DOMObject
    def setUserData(key as string, data as object /*DOMUserData*/, handler as UserDataHandler) as object /*DOMUserData*/
    def getUserData(key as string) as object /*DOMUserData*/


interface NodeList(Dom2.NodeList):
    pass


interface NamedNodeMap(Dom2.NamedNodeMap):
    pass


interface DocumentType(Dom2.DocumentType):
    pass


interface DOMImplementation(Dom2.DOMImplementation):
    def getFeature(feature as string, version as string) as object #DOMObject


interface Element(Dom2.Element):
    schemaTypeInfo as TypeInfo:
        get

    def setIdAttribute(name as string, isId as bool) as void
    def setIdAttributeNS(namespaceURI as string, localName as string, isId as bool) as void
    def setIdAttributeNode(idAttr as Attr, isId as bool) as void

interface Attr(Dom2.Attr):
    schemaTypeInfo as TypeInfo:
        get
    isId as bool:
        get


interface DocumentFragment(Dom2.DocumentFragment):
    pass


interface CharacterData(Dom2.CharacterData):
    pass

interface Text(Dom2.Text):
    isElementContentWhitespace as bool:
        get
    wholeText as string:
        get

    def replaceWholeText(content as string) as Text


interface Comment(Dom2.Comment):
    pass

interface CDATASection(Dom2.CDATASection):
    pass

interface EntityReference(Dom2.EntityReference):
    pass

interface ProcessingInstruction(Dom2.ProcessingInstruction):
    target as string:
        get

    data as string:
        get
        set

interface Notation(Dom2.Notation):
    pass

interface Entity(Dom2.Entity):
    inputEncoding as string:
        get
    xmlEncoding as string:
        get
    xmlVersion as string:
        get


interface Document(Dom2.Document):
    inputEncoding as string:
        get
    xmlEncoding as string:
        get
    xmlStandalone as bool:
        get
        set
    xmlVersion as string:
        get
        set
    strictErrorChecking as bool:
        get
        set
    documentURI as string:
        get
        set
    domConfig as DOMConfiguration:
        get

    def adoptNode(source as Node) as Node
    def normalizeDocument() as void
    def renameNode(n as Node, namespaceURI as string, qualifiedName as string) as Node



# New interfaces in Level 3

interface DOMStringList:
    length as ulong:
        get

    def item(index as ulong) as string
    def contains(str as string) as bool

interface NameList:
    length as ulong:
        get

    def getName(index as ulong) as string
    def getNamespaceURI(index as ulong) as string
    def contains(str as string) as bool
    def containsNS(namespaceURI as string, name as string) as bool

interface DOMImplementationList:
    length as ulong:
        get

    def item(index as ulong) as DOMImplementation

interface DOMImplementationSource:
    def getDOMImplementation(features as string) as DOMImplementation
    def getDOMImplementationList(features as string) as DOMImplementationList

interface TypeInfo:
    typeName as string:
        get
    typeNamespace as string:
        get

    // DerivationMethods
    //const unsigned long       DERIVATION_RESTRICTION         = 0x00000001;
    //const unsigned long       DERIVATION_EXTENSION           = 0x00000002;
    //const unsigned long       DERIVATION_UNION               = 0x00000004;
    //const unsigned long       DERIVATION_LIST                = 0x00000008;

    def isDerivedFrom(typeNamespaceArg as string, typeNameArg as string, derivationMethod as ulong) as bool

interface UserDataHandler:

    // OperationType
    //const unsigned short      NODE_CLONED                    = 1;
    //const unsigned short      NODE_IMPORTED                  = 2;
    //const unsigned short      NODE_DELETED                   = 3;
    //const unsigned short      NODE_RENAMED                   = 4;
    //const unsigned short      NODE_ADOPTED                   = 5;

    def handle(operation as ushort, key as string, data as object /*DOMUserData*/, src as Node, dst as Node) as void

interface DOMError:

    // ErrorSeverity
    //const unsigned short      SEVERITY_WARNING               = 1;
    //const unsigned short      SEVERITY_ERROR                 = 2;
    //const unsigned short      SEVERITY_FATAL_ERROR           = 3;

    severity as ushort:
        get
    message as string:
        get
    type as string:
        get
    relatedException as object: #DOMObject
        get
    relatedData as object: #DOMObject
        get
    location as DOMLocator:
        get

interface DOMErrorHandler:
    def handleError(error as DOMError) as bool

interface DOMLocator:
    lineNumber as long:
        get
    columnNumber as long:
        get
    byteOffset as long:
        get
    utf16Offset as long:
        get
    relatedNode as Node:
        get
    uri as string:
        get

interface DOMConfiguration:
    parameterNames as DOMStringList:
        get

    def setParameter(name as string, value as object /*DOMUserData*/) as void
    def getParameter(name as string) as object /*DOMUserData*/
    def canSetParameter(name as string, value as object /*DOMUserData*/) as bool
