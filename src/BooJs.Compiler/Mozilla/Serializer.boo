namespace BooJs.Compiler.Mozilla

import System
import System.Collections.Generic(IDictionary, Dictionary)
import System.Web.Script.Serialization(JavaScriptConverter, JavaScriptSerializer) from 'System.Web.Extensions'


class Serializer():

    static _serializer as JavaScriptSerializer

    static def constructor():
        _serializer = JavaScriptSerializer()
        _serializer.RegisterConverters((
            MozillaJavaScriptConverter(),
        ))

    static def Serialize(node as Node) as string:
        return _serializer.Serialize(node)

    static def Deserialize(json as string) as Node:
        return _serializer.Deserialize[of Node](json)


class MozillaJavaScriptConverter(JavaScriptConverter):
""" Custom serialization converter for the Mozilla AST
"""
    NodeType = typeof(Node)
    SourceLocationType = typeof(SourceLocation)

    SupportedTypes:
        get: return (NodeType, SourceLocationType)

    public FieldMap = {
        '_constructor': 'constructor',
        'xreplace': 'x-replace',
    }

    def Deserialize(dict as IDictionary[of string,object], type as Type, serializer as JavaScriptSerializer) as object:

        if type is SourceLocationType:
            loc = SourceLocation()
            loc.source = dict['source'] if dict.ContainsKey('source')
            if dict.ContainsKey('start') and dict['start']:
                h = dict['start'] as IDictionary[of string,object]
                loc.start = Position(line: h['line'], column: h['column'])
            if dict.ContainsKey('end') and dict['end']:
                h = dict['end'] as IDictionary[of string,object]
                loc.end = Position(line: h['line'], column: h['column'])

            return loc

        elif type is NodeType:
            cls = NodeType.Module.GetType(NodeType.Namespace + '.' + dict['type'])
            obj = cls()

            for k in dict.Keys:
                field = cls.GetField(k)
                if field and field.IsPublic:
                    k = FieldMap[k] if FieldMap.ContainsKey(k)
                    list as duck
                    val = dict[k]
                    if typeof(INode).IsAssignableFrom(field.FieldType):
                        val = serializer.ConvertToType[of Node](val)
                    if SourceLocationType.IsAssignableFrom(field.FieldType):
                        val = serializer.ConvertToType[of SourceLocation](val)
                    elif typeof(List[of IPattern]).IsAssignableFrom(field.FieldType):
                        list = List[of IPattern]()
                        for itm in val:
                            list.Add( serializer.ConvertToType[of Node](itm) )
                        val = list
                    elif typeof(List[of IExpression]).IsAssignableFrom(field.FieldType):
                        list = List[of IExpression]()
                        for itm in val:
                            list.Add( serializer.ConvertToType[of Node](itm) )
                        val = list
                    elif typeof(List[of IStatement]).IsAssignableFrom(field.FieldType):
                        list = List[of IStatement]()
                        for itm in val:
                            list.Add( serializer.ConvertToType[of Node](itm) )
                        val = list
                    elif typeof(List[of VariableDeclarator]).IsAssignableFrom(field.FieldType):
                        list = List[of VariableDeclarator]()
                        for itm in val:
                            list.Add( serializer.ConvertToType[of Node](itm) )
                        val = list

                    field.SetValue(obj, val)

            return obj

        return null

    def Serialize(obj as object, serializer as JavaScriptSerializer) as IDictionary[of string,object]:
        type = obj.GetType()

        result = Dictionary[of string,object]()

        node = obj as Node
        if node:
            result['type'] = type.Name

        for field in type.GetFields():
            if field.IsPublic:
                name = field.Name
                name = FieldMap[name] if FieldMap.ContainsKey(name)
                val = field.GetValue(obj)
                result[name] = val if val is not null

        if node and node.loc:
            result['loc'] = node.loc

        return result

