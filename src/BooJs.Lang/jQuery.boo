namespace BooJs.Lang.jQuery

import BooJs.Lang.Dom2 as DOM


interface IjQuery(ICallable):
    context as DOM.Element:
        get
    length as uint:
        get
    selector as string:
        get

    # Callable interface
    def Call(expression as string, context as jQuery) as jQuery
    def Call(expr_or_html as string) as jQuery
    def Call(html as string, document as DOM.Document) as jQuery
    def Call(element as DOM.Element) as jQuery
    def Call(elements as (DOM.Element)) as jQuery
    def Call(callback as callable) as jQuery

    # Core - Accessors
    def index(subject as jQuery) as int
    def index(subject as DOM.Element) as int

    def each(callback as callable) as jQuery

    def size() as uint

    def get() as (DOM.Element)
    def get(index as int) as DOM.Element

    def eq(position as int) as jQuery

    # Core - Data
    def queue(name as string, callback as callable) as jQuery
    def queue(callback as callable) as jQuery
    def queue(name as string) as (callable)
    def queue(name as string, queue as (callable)) as jQuery
    def dequeue(name as string) as jQuery
    def dequeue() as jQuery

    def data(name as string) as object
    def data(name as string, value as object) as jQuery
    def removeData(name as string) as jQuery

    # Core - Plugins
    def extend(obj as object) as jQuery
    # TODO: $.fn.extend ??

    # Core - Interoperability
    def noConflict() as jQuery
    def noConflict(extreme as bool) as jQuery


    # Attributes
    def attr(name as string) as string
    def attr(props as Hash) as jQuery
    def attr(key as string, value as string) as jQuery
    def attr(key as string, resolver as callable) as jQuery
    def removeAttr(name as string) as jQuery

    def toggleClass(cls as string, switch as bool) as jQuery
    def toggleClass(cls as string) as jQuery
    def addClass(cls as string) as jQuery
    def hasClass(cls as string) as bool
    def removeClass(cls as string) as jQuery

    def html() as string
    def html(val as string) as jQuery

    def text() as string
    def text(val as string) as jQuery

    def val() as string # or (string)
    def val(val as string) as jQuery
    def val(vals as (string)) as jQuery

    # Traversing - Filtering
    #def is(expression as string) as bool
    def filter(expr as string) as jQuery
    def filter(resolver as callable) as jQuery
    #def not(expr as string) as jQuery
    def slice(start as int) as jQuery
    def slice(start as int, stop as int) as jQuery
    def map(callback as callable) as jQuery

    # Traversing - Finding
    def parent(expr as string) as jQuery
    def parent() as jQuery

    def parents(expr as string) as jQuery
    def parents() as jQuery

    def find(expr as string) as jQuery

    def prev(expr as string) as jQuery
    def prev() as jQuery
    def prevAll(expr as string) as jQuery
    def prevAll() as jQuery

    def next(expr as string) as jQuery
    def next() as jQuery
    def nextAll(expr as string) as jQuery
    def nextAll() as jQuery

    def siblings(expr as string) as jQuery
    def siblings() as jQuery

    def add(expr as string) as jQuery
    def add(expr as DOM.Element) as jQuery
    def add(expr as (DOM.Element)) as jQuery

    def children(expr as string) as jQuery
    def children() as jQuery

    def closests(expr as string) as jQuery

    def contents() as jQuery

    def offsetParent() as jQuery

    # Traversing - chaining
    def andSelf() as jQuery
    def end() as jQuery


    # Manipulation
    def append(content as string) as jQuery
    def append(content as DOM.Element) as jQuery
    def append(content as jQuery) as jQuery
    def appendTo(selector as string) as jQuery

    def prepend(content as string) as jQuery
    def prepend(content as DOM.Element) as jQuery
    def prepend(content as jQuery) as jQuery
    def prependTo(selector as string) as jQuery

    # .......



class jQuery(IjQuery):
    # Utilities (static)
    static def map(arr as (object), callback as callable) as (object):
        pass
    static def each(obj as Hash, callback as callable) as Hash:
        pass
    static def merge(arr1 as (object), arr2 as (object)) as (object):
        pass
    static def unique(arr as (object)) as (object):
        pass
    static def inArray(hay as object, haystack as (object)) as bool:
        pass
    static def makeArray(obj as object) as (object):
        pass
    static def grep(arr as (object), callback as callable, invert as bool) as (object):
        pass
    static def grep(arr as (object), callback as callable) as (object):
        pass

    static def extend(deep as bool, target as object, obj1 as object) as object:
        pass
    static def extend(target as object, obj1 as object) as object:
        pass
    # Conflicts with instance method
    #static def extend(obj1 as object) as object:
    #    pass
    static def extend(target as object, obj1 as object, obj2 as object) as object:
        pass
    # ...

    static def isArray(val as object) as bool:
        pass
    static def isFunction(val as object) as bool:
        pass

    static def trim(val as string) as string:
        pass

    static def param(elems as (DOM.Element)) as string:
        pass
    static def param(jq as jQuery) as string:
        pass
    static def param(obj as object) as string:
        pass










