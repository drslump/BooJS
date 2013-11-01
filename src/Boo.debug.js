// BooJs Runtime - Debugging extensions
// MIT license
// Copyright 2012-2013 Iván -DrSlump- Montes <drslump@pollinimini.net>

/*jshint indent:4, lastsemic:false, curly:false */
/*global Boo:true */

(function (exports, undefined) {
    var sourcemaps = [];

    // Allow to override the console with a mock
    Boo.console = console;

    // Override the sourcemap registry implementation
    Boo.sourcemap = function (srcmap) {
        sourcemaps.push(srcmap);
    };

    var _define = Boo.define;
    Boo.define = function () {
        // HACK: Delay triggering to allow the sourcemap to be registered
        var args = arguments;
        setTimeout(function () { run_and_process_exception(_define, args); }, 0);
    };

    var _require = Boo.require;
    Boo.require = function () {
        // HACK: Delay triggering to allow the sourcemap to be registered
        var args = arguments;
        setTimeout(function () { run_and_process_exception(_require, args); }, 0);
    };

    function norm(file) {
        return file.toLowerCase().replace('\\', '/');
    }

    function run_and_process_exception(fn, args) {
        try {
            fn.apply(Boo, args);
        } catch (e) {
            /*
            NOTE: Check for format examples: https://github.com/eriwen/javascript-stacktrace/blob/master/test/CapturedExceptions.js

            Opera 12:
                <anonymous function>([arguments not available])@http://localhost:63342/javascript-stacktrace/test/functional/ExceptionLab.js:4
                createException([arguments not available])@http://localhost:63342/javascript-stacktrace/test/functional/ExceptionLab.js:2

            Firefox 22:
                @file:///E:/javascript-stacktrace/test/functional/ExceptionLab.js:4
                createException@file:///E:/javascript-stacktrace/test/functional/ExceptionLab.js:8
        
            Safari 6:
                @file:///Users/eric/src/javascript-stacktrace/test/functional/ExceptionLab.html:48
                onclick@file:///Users/eric/src/javascript-stacktrace/test/functional/ExceptionLab.html:82
                [native code]

            Chrome 27:
                TypeError: Cannot call method 'undef' of null
                    at file:///E:/javascript-stacktrace/test/functional/ExceptionLab.js:4:9
                    at createException (file:///E:/javascript-stacktrace/test/functional/ExceptionLab.js:8:5)
                    at HTMLButtonElement.onclick (file:///E:/javascript-stacktrace/test/functional/ExceptionLab.html:83:126)

            Chrome 30:
                ReferenceError: value_ is not defined
                    at file://localhost/Users/drslump/www/boojs/hash-3.js:36:26
                    at Object.boo_each [as each] (file://localhost/Users/drslump/www/boojs/src/Boo.js:203:47)
                    at Object.Boo.require (file://localhost/Users/drslump/www/boojs/src/Boo.js:180:18)
                    at run_and_process_exception (file://localhost/Users/drslump/www/boojs/src/Boo.debug.js:32:16)

            Internet Explorer 10:
                TypeError: Unable to get property 'undef' of undefined or null reference
                   at Anonymous function (http://jenkins.eriwen.com/job/stacktrace.js/ws/test/functional/ExceptionLab.html:48:13)
                   at onclick (http://jenkins.eriwen.com/job/stacktrace.js/ws/test/functional/ExceptionLab.html:82:1)       
            */
            if (e.stack) {
                var stack = [], frames = e.stack.split(/\n/);
                
                for (var i = 0; i < frames.length; i++) {
                    var ident, file, line, column, m,
                        frame = frames[i];

                    // Ignore runtime files
                    if (/\/Boo(\.\w+)?\.js\b/.test(frame)) {
                        continue;
                    }

                    // Handle stuff like evals
                    // at eval (eval at <anonymous> (file:///generators.html:213:22), <anonymous>:17:11)
                    if (/\beval\b/.test(frame) && (m = frame.match(/:(\d+):(\d+)\)[^ ]*$/))) {
                        ident = '<anonymous>';
                        file = '<anonymous>';
                        line = parseInt(m[1], 10) - 1;
                        column = parseInt(m[2], 10) - 1;
                    // Chrome: 'at func (file:///path/to/file.js:4:9)'
                    } else if (m = frame.match(/^\s+at\s+([^\s]+)\s+\((.+?):(\d+):(\d+)\)$/)) {
                        ident = m[1].replace('Object.<anonymous>', '<anonymous>').replace('Object.', '');
                        file = m[2];
                        line = parseInt(m[3], 10) - 1;
                        column = parseInt(m[4], 10) - 1;
                    // Firefox, Opera, Safari: 'func@file:///path/to/file.js:4'
                    } else if (m = frame.match(/^\s+(\w+)?@(.+?):(\d+)([:,](\d+))?$/)) {
                        ident = m[1] || '<anonymous>';
                        file = m[2];
                        line = parseInt(m[3], 10) - 1;
                        column = m[4] ? parseInt(m[5], 10) - 1 : -1;
                    // Unrecognized
                    } else if (m = frame.match(/((?:\w+:\/\/)?[\w\d\.\/\\_=\+-]+):(\d+)([:,](\d+))?/)) {
                        ident = '<anonymous>';
                        file = m[1];
                        line = parseInt(m[2], 10) - 1;
                        column = m[3] ? parseInt(m[4], 10) - 1 : -1;

                    // Unfortunately nothing useful was found
                    } else {
                        // If it's indented it looks like a frame so perhaps we may be interested in it
                        if (/^\s+/.test(frame)) {
                            stack.push(frame.replace(/^\s+/, ''));
                        }
                        continue;
                    }

                    var srcmap;
                    for (var j = 0; j < sourcemaps.length; j++) {
                        if (-1 !== norm(file).indexOf(norm(sourcemaps[j].file))) {
                            srcmap = SrcMap(sourcemaps[j]);
                            break;
                        }
                    }

                    if (!srcmap) {
                        continue;
                    }

                    // TODO: don't output column if it's -1 in the Javascript stack
                    var found = srcmap.find(line, column);
                    if (found) {
                        file = found.source;
                        line = found.line;
                        column = column > -1 ? found.column : -1;
                    }
                    stack.push('at ' + (ident ? ident + ' ' : '') + '(' + file + ':' + (line + 1) + ':' + (column + 1) + ')');
                }

                var msg = e.name + ': ' + e.message + '\n   ' + stack.join('\n   ');
                if ('warn' in Boo.console) {
                    Boo.console.warn(msg);
                } else if ('log' in Boo.console) {
                    Boo.console.log(msg);
                } else {
                    // If the console is not available replace the exception message
                    e.message = msg;
                }
            }

            throw e;
        }
    }

    // Reduced implementation of a source map lookup method
    function SrcMap(srcmap) {

        // Consumes a VLQ encoded segment. It must be called sequentially from the first
        // segment in the map.
        function consume(segment, prev) {
            var values = [],
                pair = [null, segment];
            
            while (pair[1].length) {
                pair = vlq(pair[1]);
                values.push(pair[0]);
            }

            return {
                offset: (prev.offset | 0) + (values[0] | 0),
                source: (prev.source | 0) + (values[1] | 0),
                line: (prev.line | 0) + (values[2] | 0),
                column: (prev.column | 0) + (values[3] | 0),
                name: (prev.name | 0) + (values[4] | 0)
            };
        }

        // Decodes the next base 64 VLQ value from the given string and returns the
        // value and the rest of the string.
        function vlq(s) {
            var VLQ_BASE_SHIFT = 5,
                VLQ_BASE = 1 << VLQ_BASE_SHIFT,
                VLQ_BASE_MASK = VLQ_BASE - 1,
                VLQ_CONTINUATION_BIT = VLQ_BASE,
                B64CHARS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/',
                len = s.length,
                i, result, shift, continuation, digit;

            i = result = shift = 0;
            do {
                if (i >= len)
                    throw new Error("Expected more digits in base 64 VLQ value.");

                digit = B64CHARS.indexOf(s.charAt(i++));
                continuation = !!(digit & VLQ_CONTINUATION_BIT);
                digit &= VLQ_BASE_MASK;
                result += digit << shift;
                shift += VLQ_BASE_SHIFT;
            } while (continuation);

            // Convert to two-complement
            shift = result >> 1;
            result = (result & 1) === 1 ? -shift : shift;
            return [ result, s.slice(i) ];
        }

        // Convert mappings to an array (each item is a line in the generated code)
        var mappings = srcmap.mappings.split(';');

        return {
            // Simplified look up method based only of line-column
            find: function (line, column) {
                var ln, sgm, segments, found, values = {};

                column = column || 0;
                if (line < mappings.length) {
                    // Consume lines until the desired one to calculate original line/column
                    for (ln = 0; ln <= line; ln++) {
                        // Reset the offset on each new line
                        values.offset = 0;
                        segments = mappings[ln].split(',');
                        for (sgm = 0; sgm < segments.length; sgm++) {
                            values = consume(segments[sgm], values);
                            //console.log('%d:%d => %d:%d (%s)', ln, values.offset, values.line, values.column, values.name);
                            if (ln === line) {
                                if (found && Math.abs(found.offset - column) < Math.abs(values.offset - column)) {
                                    break;
                                }
                                found = values;
                            }
                        }
                    }
                }

                // Check if we probably were able to detect a specific symbol
                if (found && (column === -1 || Math.abs(found.offset - column) < 15)) {
                    found.source = srcmap.sources[found.source];
                    if (srcmap.sourceRoot)
                        found.source = srcmap.sourceRoot + found.source;
                    found.name = typeof found.name !== 'undefined' ? srcmap.names[found.name] : null;
                }

                return found || false;
            }
        };
    }

})(this);
