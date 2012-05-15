namespace Boojay.Compilation.TypeSystem

[extension]
def RemoveStart(value as string, start as string):
	return value unless value.StartsWith(start)
	return value[start.Length:]
		
[extension]
def RemoveEnd(value as string, end as string):
	return value unless value.EndsWith(end)
	return value[:-end.Length]
