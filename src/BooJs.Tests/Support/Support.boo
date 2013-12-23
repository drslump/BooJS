namespace BooJs.Tests.Support


enum Gender:
    Male
    Female

enum Card:
    clubs
    diamonds
    hearts
    spades

enum TestEnum:
    Foo = 1
    Bar = 2
    Baz = 4
    Gazong = -2

class Constants:
    static public final StringConstant = 'Foo'
    static public final IntegerConstant = 14

class Character:
    property Name as string
    property Age as uint
    def constructor(name as string):
        Name = name

class CharacterCollection:
    _list = List[of Character]()

    self[i as int] as Character:
        get: return _list[i]

    self[k as string] as Character:
        get:
            for itm in _list:
                return itm if itm.Name == k
            return null

    def Add(item as Character):
        _list.Add(item)

class Clickable:
    event Click as callable(Clickable)

    def RaiseClick():
        Click(self) if Click

class ImplicitConversionToDouble:
    public Value as double

    def constructor(value as double):
        self.Value = value

    static def op_Implicit(o as ImplicitConversionToDouble) as double:
        return o.Value

class OverrideEqualityOperators:
    static def op_Equality(lhs as OverrideEqualityOperators, rhs as OverrideEqualityOperators) as bool:
        if lhs is null:
            print 'lhs is null'
        if rhs is null:
            print 'rhs is null'
        return true
        
    static def op_Inequality(lhs as OverrideEqualityOperators, rhs as OverrideEqualityOperators) as bool:
        if lhs is null:
            print 'lhs is null'
        if rhs is null:
            print 'rhs is null'
        return false

class VarArgs:
    def Method():
        print "VarArgs.Method"
        
    def Method(*args as (object)):
        print "VarArgs.Method(" + join(args, ', ') + ")"

abstract class AbstractClass:
    pass

abstract class AnotherAbstractClass:
    abstract protected def Foo() as string:
        pass

    virtual def Bar() as string:
        return "Bar";

class AmbiguousBase:
    def Path(empty as string) as string:
        return "Base"

class AmbiguousSub1(AmbiguousBase):
    Path as string:
        get: return "Sub1"

class AmbiguousSub2(AmbiguousSub1):
    pass

class BaseClass:
    def constructor():
        pass
        
    protected def constructor(message as string):
        print "BaseClass.constructor('{0}')" % (message,)
         
    virtual def Method0():
        print "BaseClass.Method0"
        
    virtual def Method0(text as string):
        print "BaseClass.Method0('{0}')" % (text,)
        
    virtual def Method1():
        print "BaseClass.Method1"
        
    //for BOO-632 regression test
    protected _protectedfield as int = 0
    protected ProtectedProperty as int:
        get: return _protectedfield
        set: _protectedfield = value

class DerivedClass(BaseClass):
    def constructor():
        pass
        
    def Method2():
        Method0()
        Method1()

class ClassWithNewMethod(DerivedClass):
    new def Method2():
        print "ClassWithNewMethod.Method2"
        


def method(x):
    return x

def square(x as int):
    return x * x



