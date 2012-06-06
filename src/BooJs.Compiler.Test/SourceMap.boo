import NUnit.Framework

import BooJs.Compiler.SourceMap

[TestFixture]
class SourceMapTest:

    [Test]
    def base64_encoding():
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
