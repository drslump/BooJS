#IGNORE: Properties not supported yet
"""
Simpson, Homer
"""
import BooCompiler.Tests.SupportingClasses from BooCompiler.Tests

p = Person(LastName: "Simpson")
p.FirstName = "Homer"

print "${p.LastName}, ${p.FirstName}"
