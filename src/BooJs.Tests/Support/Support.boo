namespace BooJs.Tests.Support


enum Gender:
    Male
    Female

enum Card:
    clubs
    diamonds
    hearts
    spades

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


def method(x):
    return x

def square(x as int):
    return x * x



