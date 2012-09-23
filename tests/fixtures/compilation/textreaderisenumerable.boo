#IGNORE: Classes not supported yet
"""
foo
bar
baz
"""
import System.IO

reader as TextReader = StringReader("foo\nbar\nbaz")

for line in reader:
	print(line)
