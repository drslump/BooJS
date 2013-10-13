namespace BooJs.Tests

import BooJs.Tests.Support

import NUnit.Framework

import BooJs.Compiler.SourceMap

[TestFixture]
class SourceMapTest:

    [Test]
    def base64_encoding():
        assert Base64VLQ.encode(0) == 'B'

        assert Base64VLQ.encode(1) == 'C'
        assert Base64VLQ.encode(10) == 'U'
        assert Base64VLQ.encode(100) == 'oG'
        assert Base64VLQ.encode(1000) == 'w+B'
        assert Base64VLQ.encode(10000) == 'gxT'
        assert Base64VLQ.encode(100000) == 'gqjG'
        assert Base64VLQ.encode(1000000) == 'gkh9B'
        assert Base64VLQ.encode(10000000) == 'goriT'
        assert Base64VLQ.encode(100000000) == 'gww3+F'
        assert Base64VLQ.encode(1000000000) == 'gglrz7B'

        assert Base64VLQ.encode(-1) == 'D'
        assert Base64VLQ.encode(-10) == 'V'
        assert Base64VLQ.encode(-100) == 'pG'
        assert Base64VLQ.encode(-1000) == 'x+B'
        assert Base64VLQ.encode(-10000) == 'hxT'

    [Test]
    def ToHash():
        builder = MapBuilder()
        builder.SourceRoot = 'http://root/'
        builder.File = 'assembly.js'
        builder.Map('foo.boo', 1, 1, 2, 2, 'foo')
        builder.Map('foo.boo', 2, 2, 3, 3, 'bar')
        builder.Map('bar.boo', 1, 1, 2, 2, 'foo')

        h = builder.ToDict()
        assert h['sourceRoot'] == 'http://root/'
        assert h['file'] == 'assembly.js'
        assert len(h['sources']) == 2
        assert array(h['sources']) == ('foo.boo', 'bar.boo')
        assert len(h['names']) == 2
        assert array(h['names']) == ('foo', 'bar')

    [Test]
    def ToJSON():
        builder = MapBuilder()
        builder.File = 'assembly.js'
        builder.Map('foo.boo', 1, 1, 2, 2, 'foo')

        json = builder.ToJSON()
        assert json =~ @/"version":3/
        assert json =~ @/"file":"assembly.js"/
        assert json =~ @/"names":\["foo"\]/
