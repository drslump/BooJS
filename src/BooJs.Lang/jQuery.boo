import BooJs.Lang.Globals(Object)
import BooJs.Lang.Builtins(ICallable)
import BooJs.Lang.Extensions
import Browser.Dom2 as DOM
import Async(IPromise)

[Extern(Factory:true)]
class jQuery(ICallable):

    interface Promise(IPromise):
        def @then(ok as callable, error as callable, progress as callable) as Promise
        def done(cb as callable) as Promise
        def fail(cb as callable) as Promise
        def always(cb as callable) as Promise
        def pipe(okfilter as callable, failfilter as callable, progressfilter as callable) as Promise
        def isResolved() as bool
        def isRejected() as bool

    interface jqXHR(Promise):
        def success(cb as callable) as Promise
        def error(cb as callable) as Promise
        def complete(cb as callable) as Promise




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


    static def get(url as string) as jqXHR:
        pass

    static def post(url as string) as jqXHR:
        pass
    static def post(url as string, data as Hash) as jqXHR:
        pass

    static def ajax(url as string) as jqXHR:
        pass
    static def ajax(url as string, settings as Hash) as jqXHR:
        pass
    static def ajax(settings as Hash) as jqXHR:
        pass


    # Instance members

    context as DOM.Element:
        get: pass
    length as uint:
        get: pass
    selector as string:
        get: pass


    # TODO: Use Transform to convert the instance creation into a simple call
    # TODO: Perhaps we should have a specialized attribute to signal constructors/factories that don't use `new` in JS
    def constructor():
        pass
    def constructor(expr_or_html as string):
        pass
    def constructor(expression as string, context as jQuery):
        pass
    def constructor(html as string, document as DOM.Document):
        pass
    def constructor(element as DOM.Element):
        pass
    def constructor(elements as (DOM.Element)):
        pass
    def constructor(callback as callable):
        pass


    # Callable interface
    def Call(args as (Object)) as Object:
        pass
    # callable methods for BooJs
    def Call(expr_or_html as string) as jQuery:
        pass
    def Call(expression as string, context as jQuery) as jQuery:
        pass
    def Call(html as string, document as DOM.Document) as jQuery:
        pass
    def Call(element as DOM.Element) as jQuery:
        pass
    def Call(elements as (DOM.Element)) as jQuery:
        pass
    def Call(callback as callable) as jQuery:
        pass

    # Core - Accessors
    def index(subject as jQuery) as int:
        pass
    def index(subject as DOM.Element) as int: 
        pass

    #def each(callback as callable(object)) as jQuery:
    #    pass
    def each(callback as callable) as jQuery:
        pass


    def size() as uint: 
        pass

    def get() as (DOM.Element): 
        pass
    def get(index as int) as DOM.Element: 
        pass

    def eq(position as int) as jQuery:
        pass

    # Core - Data
    def queue(name as string, callback as callable) as jQuery:
        pass
    def queue(callback as callable) as jQuery:
        pass
    def queue(name as string) as (callable): 
        pass
    def queue(name as string, queue as (callable)) as jQuery:
        pass
    def dequeue(name as string) as jQuery:
        pass
    def dequeue() as jQuery:
        pass

    def data(name as string) as object: 
        pass
    def data(name as string, value as object) as jQuery:
        pass
    def removeData(name as string) as jQuery:
        pass

    # Core - Plugins
    def extend(obj as object) as jQuery:
        pass
    # TODO: $.fn.extend ??

    # Core - Interoperability
    def noConflict() as jQuery:
        pass
    def noConflict(extreme as bool) as jQuery:
        pass

    # Attributes
    def attr(name as string) as string: 
        pass
    def attr(props as Hash) as jQuery:
        pass
    def attr(key as string, value as string) as jQuery:
        pass
    def attr(key as string, resolver as callable) as jQuery:
        pass
    def removeAttr(name as string) as jQuery:
        pass

    def toggleClass(cls as string, switch as bool) as jQuery:
        pass
    def toggleClass(cls as string) as jQuery:
        pass
    def addClass(cls as string) as jQuery:
        pass
    def hasClass(cls as string) as bool: 
        pass
    def removeClass(cls as string) as jQuery:
        pass

    def html() as string: 
        pass
    def html(val as string) as jQuery:
        pass

    def text() as string: 
        pass
    def text(val as string) as jQuery:
        pass

    def val() as string: # or (string)
        pass
    def val(val as string) as jQuery:
        pass
    def val(vals as (string)) as jQuery:
        pass

    # Traversing - Filtering
    #def is(expression as string) as bool
    def filter(expr as string) as jQuery:
        pass
    def filter(resolver as callable) as jQuery:
        pass
    #def not(expr as string) as jQuery
    def slice(start as int) as jQuery:
        pass
    def slice(start as int, stop as int) as jQuery:
        pass
    def map(callback as callable) as jQuery:
        pass

    # Traversing - Finding
    def parent(expr as string) as jQuery:
        pass
    def parent() as jQuery:
        pass

    def parents(expr as string) as jQuery:
        pass
    def parents() as jQuery:
        pass

    def find(expr as string) as jQuery:
        pass

    def prev(expr as string) as jQuery:
        pass
    def prev() as jQuery:
        pass
    def prevAll(expr as string) as jQuery:
        pass
    def prevAll() as jQuery:
        pass

    def next(expr as string) as jQuery:
        pass
    def next() as jQuery:
        pass
    def nextAll(expr as string) as jQuery:
        pass
    def nextAll() as jQuery:
        pass

    def siblings(expr as string) as jQuery:
        pass
    def siblings() as jQuery:
        pass

    def add(expr as string) as jQuery:
        pass
    def add(expr as DOM.Element) as jQuery:
        pass
    def add(expr as (DOM.Element)) as jQuery:
        pass

    def children(expr as string) as jQuery:
        pass
    def children() as jQuery:
        pass

    def closests(expr as string) as jQuery:
        pass

    def contents() as jQuery:
        pass

    def offsetParent() as jQuery:
        pass

    # Traversing - chaining
    def andSelf() as jQuery:
        pass
    def end() as jQuery:
        pass

    # Manipulation
    def append(content as string) as jQuery:
        pass
    def append(content as DOM.Element) as jQuery:
        pass
    def append(content as jQuery) as jQuery:
        pass
    def appendTo(selector as string) as jQuery:
        pass

    def prepend(content as string) as jQuery:
        pass
    def prepend(content as DOM.Element) as jQuery:
        pass
    def prepend(content as jQuery) as jQuery:
        pass
    def prependTo(selector as string) as jQuery:
        pass

    # .......

    def fadeIn() as jQuery:
        pass
    def fadeIn(duration as int) as jQuery:
        pass
    def fadeIn(duration as int, callback as callable) as jQuery:
        pass
    def fadeIn(duration as int, easing as string) as jQuery:
        pass
    def fadeIn(duration as int, easing as string, callback as callable) as jQuery:
        pass

    def fadeOut() as jQuery:
        pass
    def fadeOut(duration as int) as jQuery:
        pass
    def fadeOut(duration as int, callback as callable) as jQuery:
        pass
    def fadeOut(duration as int, easing as string) as jQuery:
        pass
    def fadeOut(duration as int, easing as string, callback as callable) as jQuery:
        pass

    def promise() as Promise:
        pass
    def promise(type as string) as Promise:
        pass
    def promise(type as string, target as object) as Promise:
        pass
