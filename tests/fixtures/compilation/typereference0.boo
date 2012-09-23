#IGNORE: Type system not fully supported
"""
System.String[]
System.String[]
"""
print(["foo"].ToArray(string).GetType().ToString())
print(["bar"].ToArray(System.String).GetType().ToString())
