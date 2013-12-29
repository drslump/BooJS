"""
-Hello!
"""
def main():
	print("Hello!")
	
def print(message): # builtin redefinition
	js `console.log('-' + message)`
	
main()
