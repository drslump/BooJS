// Boo.Js Runtime Debugging extensions
// MIT license
// Copyright 2012 Iván -DrSlump- Montes <drslump@pollinimini.net>

/*jshint indent:4 lastsemic:false curly:false */
/*global Boo:true */

(function (exports, undefined) {
    var sourcemaps = [];

    // Override the sourcemap registry implementation
    Boo.sourcemap = function (srcmap) {
        sourcemaps.push(srcmap);
    };

    var _define = Boo.define;
    Boo.define = function () {
        var args = arguments;

        // HACK: Delay triggering to allow the sourcemap to be registered
        setTimeout(function () {
            try {
                _define.apply(Boo, args);
            } catch (e) {
                var trace = [e.message], frames = e.stack.split(/\n/);
                
                for (var i = 0; i < frames.length; i++) {
                    var ident, file, line, column, m, frame = frames[i];

                    // Chrome
                    if (m = frame.match(/^\s+at\s+([^\s]+)\s+\((.+?):(\d+):(\d+)\)$/)) {
                        ident = m[1].replace('Object.<anonymous>', '{anonymous}').replace('Object.', '');
                        file = m[2];
                        line = parseInt(m[3], 10) - 1;
                        column = parseInt(m[4], 10) - 1;
                    // Generic (ie: Firefox, Opera)
                    } else if (m = frame.match(/[\s@]?(.+?):(\d+)([:,](\d+))?$/)) {
                        ident = '{anonymous}';
                        file = m[1];
                        line = parseInt(m[2], 10) - 1;
                        column = m[2] ? parseInt(m[3], 10) - 1 : -1;
                    // Unrecognized but seems important
                    } else if (/:\d+/.test(frame) || /\w+:\/\//.test(frame)) {
                        trace.push(frame.replace(/^\s+/, ''));
                        continue;
                    // Unrecognized, just ignore it
                    } else {
                        continue;
                    }

                    // Ignore runtime
                    if (/\/Boo(\.\w+)?\.js$/.test(file)) {
                        continue;
                    }

                    var srcmap;
                    for (var j = 0; j < sourcemaps.length; j++) {
                        // TODO: Make the matching a bit fuzzy (backslashes, spaces, ...)
                        if (-1 !== file.indexOf(sourcemaps[j].file)) {
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
                        trace.push('at ' + ident + ' @ ' + found.source + ':' + (found.line + 1) + ':' + (found.column + 1));
                    } else {
                        trace.push('at ' + ident + ' @ ' + file + ':' + (line + 1) + ':' + (column + 1));
                    }
                }

                trace = trace.join('\n    ');
                if ('warn' in console) {
                    console.warn(trace);
                } else if ('log' in console) {
                    console.log(trace);
                } else {
                    e.message = trace;
                }

                throw e;
            }
        }, 0);
    };


    function SrcMap(srcmap) {

        // Consumes a VLQ encoded segment. It must be called sequentially from the first
        // segment in the map.
        // TODO: Handle the case where a segment has undefined properties
        function consume(segment, prev) {
            var values = [],
                pair = [null, segment];
            
            do {
                pair = vlq(pair[1]);
                values.push(pair[0]);
            } while (pair[1].length);

            return {
                offset: (prev.offset || 0) + values[0],
                source: (prev.source || 0) + (values.length > 1 ? values[1] : 0),
                line: (prev.line || 0) + (values.length > 2 ? values[2] : 0),
                column: (prev.column || 0) + (values.length > 3 ? values[3] : 0),
                name: (prev.name || 0) + (values.length > 4 ? values[4] : 0)
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
                if (i >= len) {
                    throw new Error("Expected more digits in base 64 VLQ value.");
                }
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


        var mappings = srcmap.mappings.split(';');

        return {
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
