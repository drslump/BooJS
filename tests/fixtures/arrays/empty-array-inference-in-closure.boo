#IGNORE: Type sytem not fully supported
#category FailsOnMono
"""
System.String
"""
def returnArrayFromClosure():
	def closure() as (string):
		return (,)
	return closure()
	
print returnArrayFromClosure().GetType().GetElementType()
