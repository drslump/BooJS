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
        try {
            _define.apply(Boo, arguments);
        } catch (e) {
            // TODO: Normalize error and stack trace using source maps
            console.log(e.trace);
        }
    };

})(this);
