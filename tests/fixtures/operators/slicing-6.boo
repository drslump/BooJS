#IGNORE: property overloading not supported yet
"""
Homer
Idle
Simpson
"""
from BooJs.Tests.Support import CharacterCollection, Character

people = CharacterCollection()
people.Add(Character("Homer", Age: 20))
people.Add(Character("Eric", Age: 30))

print(people[0].Name)
print(people[1].Age)
print(people["Homer"].Age)
