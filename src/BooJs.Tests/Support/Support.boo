namespace BooJs.Tests.Support

enum Gender:
    Male
    Female

enum Card:
    clubs
    diamonds
    hearts
    spades

class Character:
    property Name as string
    def constructor(name as string):
        Name = name

class Clickable:
    event Click as callable()

    def RaiseClick():
        Click() if Click


def method(x):
    return x

def square(x as int):
    return x * x



