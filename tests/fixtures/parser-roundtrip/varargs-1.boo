"""
foo -> bar
foo -> bar
"""
class Console:
	def WriteLine(format as string, *args):
		print(format % args)
		
	def WriteLn(format as string, *args as (object)):
		print(format % args)


c = Console()
c.WriteLine('{0} -> {1}', 'foo', 'bar')
c.WriteLn('{0} -> {1}', 'foo', 'bar')
