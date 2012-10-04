namespace BooJs.Lang.Globals


class String(Object):

    # Support formatting: '{0} {1}' % ('foo', 'bar')
    static def op_Modulus(s as string, a as (object)) as string:
        pass
        
    # Support addition between strings (TODO: this method should never be called)
    static def op_Addition(a as string, b as string) as string:
        pass
        
    # Support multiply operator: 'foo' * 2 --> 'foofoo'
    static def op_Multiply(s as string, a as int) as string:
        pass
        
       
    # Static methods

    static def fromCharCode(code as int) as string:
        pass


    # Instance members
    
    self[index as int] as string:
         get: pass

    public length as uint


    def charAt(idx as int) as string:
        pass
    def charCodeAt(idx as int) as int:
        pass
    def concat(str as string) as string:
        pass
    def indexOf(str as string) as int:
        pass
    def lastIndexOf(str as string) as int:
        pass

    def match(re as RegExp) as bool:
        pass
    def replace(re as RegExp, repl as string) as string:
        pass
    def replace(substr as string, repl as string) as string:
        pass
    def replace(re as RegExp, repl as callable) as string:
        pass
    def replace(substr as string, repl as callable) as string:
        pass

    def split(sep as string) as (string):
        pass

    def substr(start as uint, length as int) as string:
        pass
    def substring(start as uint, stop as int) as string:
        pass

    def toUpperCase() as string:
        pass

    def toLowerCase() as string:
        pass

    def trim() as string:
        pass

