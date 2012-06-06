"""
1
"""
# Boo handles enums differently
#"""
#BooCompiler.Tests.SupportingClasses.TestEnum
#Foo, Bar
#"""
enum TestEnum:
  Foo
  Bar

a = TestEnum.Foo|TestEnum.Bar
#print a.GetType()
print a
