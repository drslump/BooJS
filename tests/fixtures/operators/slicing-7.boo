#IGNORE: property overloading not supported yet
"""
Guido
Matz
"""
from BooJs.Tests.Support import CharacterCollection, Character

people = CharacterCollection()
people.Add(Character("Homer", Age: 20))
people.Add(Character("Eric", Age: 30))

people[0] = Character("Guido")
people["Eric"] = Character("Matz")

print(people[0].Name)
print(people[1].Name)
