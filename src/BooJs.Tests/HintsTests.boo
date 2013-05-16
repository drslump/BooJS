namespace boojs.Tests.Hints

import NUnit.Framework
import boojs.Hints
import boojs.Hints.Messages(Query)
import Boo.Lang.Interpreter.Builtins(repr)


def code(code as string):
	lines = code.Replace('\t', '    ').Split(char('\n'))
	lines = lines[1:-1]
	indent = 1000
	for line in lines:
		if len(line.Trim()):
			indent = System.Math.Min(indent, len(/^\s*/.Match(line).Value))
	code = join([line[indent:] for line in lines], '\n')
	return code


[TestFixture]
class LocalsTests:

	index as ProjectIndex
	commands as Commands

	[SetUp]
	def setUp():
		index = ProjectIndex.Boo()
		commands = Commands(index)

	[Test]
	def LocalsForEmptyMethod():
		q = Query(fname:'test.boo', line:2, code:'namespace foo\ndef foo():\n\t\n\treturn false\n')
		resp = commands.locals(q)
		Assert.AreEqual(resp.scope, '')
		Assert.IsEmpty(resp.hints)

	[Test]
	def LocalsForMethod():
		q = Query(fname:'test.boo', line:2, code:'namespace foo\ndef foo():\n\tx = 10\n\ty = 20\n\tz = 30\n\treturn false\n')
		resp = commands.locals(q)
		Assert.AreEqual('', resp.scope)
		Assert.IsEmpty(resp.hints)

		q.line = 3
		resp = commands.locals(q)
		assert len(resp.hints) == 1
		assert resp.hints[-1].name == 'x'

		q.line = 4
		resp = commands.locals(q)
		assert len(resp.hints) == 2
		assert resp.hints[-1].name == 'y'

		q.line = 5
		resp = commands.locals(q)
		assert len(resp.hints) == 3
		assert resp.hints[-1].name == 'z'

	[Test]
	def LocalsForMethodParams():
		q = Query(fname:'test.boo', line:3, code:'namespace foo\ndef foo(x, y):\n\tx = 10\n\tz = 20\n')

		resp = commands.locals(q)
		assert len(resp.hints) == 2
		assert resp.hints[0].name == 'x'
		assert resp.hints[1].name == 'y'

		q.line = 4
		resp = commands.locals(q)
		assert len(resp.hints) == 3
		assert resp.hints[-1].name == 'z'

	[Test]
	def LocalsForClosure():
		q = Query(fname:'test.boo', code:'a = 10\ndef foo(x, y):\n\tz=20\n\treturn z')

		q.line = 1
		resp = commands.locals(q)
		assert len(resp.hints) == 2
		assert resp.hints[0].name == 'argv'
		assert resp.hints[1].name == 'a'

		q.line = 4
		resp = commands.locals(q)
		assert len(resp.hints) == 6
		assert resp.hints[2].name == 'foo'
		assert resp.hints[3].name == 'x'
		assert resp.hints[4].name == 'y'
		assert resp.hints[5].name == 'z'

	[Test]
	def LocalsForBlock():
		q = Query(fname:'test.boo', code:'def foo(x, y):\n\tbar() do (z):\n\t\treturn z\n\treturn true\n')

		q.line = 1
		resp = commands.locals(q)
		assert len(resp.hints) == 2
		assert resp.hints[-1].name == 'y'

		q.line = 2
		resp = commands.locals(q)
		assert len(resp.hints) == 3
		assert resp.hints[-1].name == 'z'


[TestFixture]
class ParseTests:

	index as ProjectIndex
	commands as Commands

	[SetUp]
	def setUp():
		index = ProjectIndex.Boo()
		commands = Commands(index)

	[Test]
	def ParseEmpty():
		q = Query(fname:'parse.boo', code:'')
		resp = commands.parse(q)
		assert len(resp.errors) == 0
		assert len(resp.warnings) == 0

	[Test]
	def ParseSyntaxError():
		q = Query(fname:'parse.boo', code:code("""
			namespace Foo.Bar

			print!
		"""))
		resp = commands.parse(q)
		assert len(resp.errors) == 1
		err = resp.errors[0]
		assert err.code == 'BCE0044'
		assert err.line == 3
		assert err.column == 6

	[Test]
	def ParseWarning():
		q = Query(fname:'parse.boo', extra:true, code:code("""
			if a=10:
				pass
		"""))
		resp = commands.parse(q)
		assert len(resp.warnings) == 1
		warn = resp.warnings[0]
		assert warn.code == 'BCW0007'
		assert warn.line == 1
		assert warn.column == 5


[TestFixture]
class NamespaceTests:

	index as ProjectIndex
	commands as Commands

	[SetUp]
	def setUp():
		index = ProjectIndex.Boo()
		commands = Commands(index)

	[Test]
	def CompleteRootNamespace():
		src = code("""
			import |
		""")
		q = Query(fname:'ns.boo', code:src, offset:src.IndexOf('|'))
		resp = commands.complete(q)
		assert len(resp.hints) > 0
		assert resp.scope == 'import'
		assert resp.hints.Contains({ h as duck | h.name == 'System' })

	[Test]
	def CompleteNamespace():
		src = code("""
			import System.|
		""")
		q = Query(fname:'ns.boo', code:src, offset:src.IndexOf('|'))
		resp = commands.complete(q)
		assert len(resp.hints) > 0
		assert resp.scope == 'import'
		assert resp.hints.Contains({ h as duck | h.name == 'IO' })
		assert resp.hints.Contains({ h as duck | h.name == 'Math' })
		assert resp.hints.Contains({ h as duck | h.name == 'Reflection' })

	[Test]
	def CompleteTypes():
		src = code("""
			import System.IO.|
		""")
		q = Query(fname:'ns.boo', code:src, offset:src.IndexOf('|'))
		resp = commands.complete(q)
		assert len(resp.hints) > 0
		assert resp.scope == 'import'
		assert resp.hints.Contains({ h as duck | h.name == 'File' })


[TestFixture]
class InternalEntityTests:

	index as ProjectIndex
	commands as Commands

	[SetUp]
	def setUp():
		index = ProjectIndex.Boo()
		commands = Commands(index)

	[Test]
	def CompleteProperty():
		src = code("""
			class Foo:
				property field as int
				def bar():
					|
		""")
		q = Query(fname:'ientity.boo', code:src, offset:src.IndexOf('|'))
		resp = commands.complete(q)
		assert len(resp.hints) > 0
		assert resp.hints.Contains({ h as duck | h.name == 'field' })
		assert resp.hints.Contains({ h as duck | h.name == 'bar' })

	[Test]
	def CompleteMethod():
		src = code("""
			class Foo:
				def foo():
					pass
				def bar():
					|
		""")
		q = Query(fname:'ientity.boo', code:src, offset:src.IndexOf('|'))
		resp = commands.complete(q)
		assert len(resp.hints) > 0
		assert resp.hints.Contains({ h as duck | h.name == 'foo' })
		assert resp.hints.Contains({ h as duck | h.name == 'bar' })

	[Test]
	def CompletePrivateField():
		src = code("""
			class Foo:
				private _field as int
				def foo():
					|
		""")
		q = Query(fname:'ientity.boo', code:src, offset:src.IndexOf('|'))
		resp = commands.complete(q)
		assert len(resp.hints) > 0
		assert resp.hints.Contains({ h as duck | h.name == '_field' })
		assert resp.hints.Contains({ h as duck | h.name == 'foo' })

	[Test]
	def CompleteInheritedProtected():
		src = code("""
			class Foo:
				protected def foo():
					pass

			class Bar(Foo):
				def bar():
					|
		""")
		q = Query(fname:'ientity.boo', code:src, offset:src.IndexOf('|'))
		resp = commands.complete(q)
		assert len(resp.hints) > 0
		assert resp.hints.Contains({ h as duck | h.name == 'foo' })
		assert resp.hints.Contains({ h as duck | h.name == 'bar' })

	[Test]
	def CompleteInstance():
		src = code("""
			class Foo:
				property prop as int
				def foo():
					pass

			foo = Foo()
			foo.|
		""")
		q = Query(fname:'ientity.boo', code:src, offset:src.IndexOf('|'))
		resp = commands.complete(q)
		assert len(resp.hints) > 0
		assert resp.hints.Contains({ h as duck | h.name == 'prop' })
		assert resp.hints.Contains({ h as duck | h.name == 'foo' })

	[Test]
	def CompleteSelf():
		src = code("""
			class Foo:
				field as int
				def foo():
					self.|
		""")
		q = Query(fname:'ientity.boo', code:src, offset:src.IndexOf('|'))
		resp = commands.complete(q)
		assert len(resp.hints) > 0
		assert resp.hints.Contains({ h as duck | h.name == 'field' })
		assert resp.hints.Contains({ h as duck | h.name == 'foo' })

	[Test]
	def CompleteType():
		src = code("""
			class Foo:
				pass

			|
		""")
		q = Query(fname:'ientity.boo', code:src, offset:src.IndexOf('|'))
		resp = commands.complete(q)
		assert len(resp.hints) > 0
		assert resp.hints.Contains({ h as duck | h.name == 'Foo' })

	[Test]
	def CompleteTypeNoGlobals():
		src = code("""
			class Foo:
				pass

			|
		""")
		q = Query(fname:'ientity.boo', code:src, offset:src.IndexOf('|'), params:(of object: true,))
		resp = commands.complete(q)
		assert not resp.hints.Contains({ h as duck | h.name == 'Foo' })

	[Test]
	def CompleteStatic():
		src = code("""
			class Foo:
				static def foo():
					pass

			Foo.|
		""")
		q = Query(fname:'ientity.boo', code:src, offset:src.IndexOf('|'))
		resp = commands.complete(q)
		assert len(resp.hints) > 0
		assert resp.hints.Contains({ h as duck | h.name == 'foo' })



