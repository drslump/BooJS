// BooJs Runtime
// MIT license
// Copyright 2012-2013 Iván -DrSlump- Montes <drslump@pollinimini.net>

/*jshint indent:4, lastsemic:false, curly:false */
/*global StopIteration: false */

(function (exports, undefined) {
    // Short alias for hasOwnProperty
    function hop(obj, prop) {
        return Object.prototype.hasOwnProperty.call(obj, prop);
    }

    // Map of typeof and Object.toString values
    var type_lookup = {
        'undefined': 'Null',
        'boolean': 'Boolean',
        'number': 'Number',
        'string': 'String',
        'function': 'Function',
        '[object Null]': 'Null',
        '[object Boolean]': 'Boolean',
        '[object String]': 'String',
        '[object Number]': 'Number',
        '[object Array]': 'Array',
        '[object Function]': 'Function',
        '[object RegExp]': 'RegExp',
        '[object Date]': 'Date'
    };

    // Tells the type of a variable according to the following rules:
    //  - Undefineds and Nulls are coerced to null
    //  - Non primitive objects are reported as Object (except for Array, Date and RegExp)
    function typeOf(v) {
        var t = typeof(v);
        if (t in type_lookup) return type_lookup[t];
        // Jurassic engine doesn't support toString on nulls
        if (v === null) return 'Null';
        // Check using Object.toString
        t = Object.prototype.toString.call(v);
        return type_lookup[t] || 'Object';
    }

    // Checks if the type of a value is the one given (multiple expected types supported)
    function typeIs(v, expected /* or_expected ... */) {
        var i, t = typeOf(v);
        for (i = 1; i < arguments.length; i++) {
            if (t === arguments[i]) return true;
        }
        return false;
    }

    // Main namespace
    var Boo = {
        BOO_RUNTIME_VERSION: '0.0.1',
        UNDEF: undefined,
        // Used in loops to flag branching
        LOOP_OR: 1,
        LOOP_THEN: 2,
        // Used as an unique identifier when we want to stop iterating a generator
        STOP: typeof StopIteration !== 'undefined' ? StopIteration : {name: 'StopIteration'}
    };

    // Assertion error
    function AssertionError(message) {
        this.name = 'AssertionError';
        this.message = message;
    }
    AssertionError.prototype = new Error();
    AssertionError.prototype.constructor = AssertionError;
    Boo.AssertionError = AssertionError;

    // Cast error
    function CastError(from, to) {
        this.name = 'CastError';
        this.message = "Cannot cast '" + from + "' to '" + to + "'";
    }
    CastError.prototype = new Error();
    CastError.prototype.constructor = CastError;
    Boo.CastError = CastError;

    // State for the module loader
    var mod_waiting = {},
        mod_defined = { 'Boo': Boo };

    // AMD style module loader. All Boo modules (files) wrap their
    // contents in a call to this function. This implementation is
    // intentionally very naive, expecting all dependencies to be
    // already loaded in the correct order. It could be overridden
    // to support on demand loading using RequireJs or CommonJs.
    Boo.define = function (name, deps, factory) {
        var i, dep, args, member, module,
            refs = [];

        // Check if we were called without dependencies
        if (!typeIs(deps, 'Array')) {
            factory = deps;
            deps = [];
        }

        // The first time we know about the module add it to the waiting list
        if (!hop(mod_defined, name)) {
            mod_waiting[name] = [name, deps, factory];
        }

        // Evaluate dependencies
        for (i = 0; i < deps.length; i++) {
            dep = deps[i];

            // Handle exports in a special way
            if (dep === 'exports') {
                refs[i] = mod_defined[name] = mod_defined[name] || {};
                continue;
            }

            // Ignore assembly filenames
            if (dep.indexOf(':') !== -1) {
                dep = dep.substring(0, dep.indexOf(':'));
            }

            // If the dependency is waiting to be resolved, do it now
            if (hop(mod_waiting, dep)) {
                args = mod_waiting[dep];
                delete mod_waiting[dep];
                mod_defined[dep] = mod_defined[dep] || null;
                Boo.define.apply(this, args);
            }

            // The module should now be available
            if (!hop(mod_defined, dep)) {
                delete mod_waiting[dep];
                throw new Error('Unable to load module ' + dep);
            }

            // Set the dependency as a reference
            refs[i] = mod_defined[dep];
        }

        // Execute the module and pass references to its dependencies
        factory.apply(undefined, refs);
        delete mod_waiting[name];

        // Register nested namespaces
        // TODO: Handle nested levels
        module = mod_defined[name];
        for (member in module) {
            if (hop(module, member) && typeIs(module[member], 'Object')) {
                mod_defined[name + '.' + member] = module[member];
            }
        }
    };

    // AMD style dependency retriever. It should be used to access Boo generated
    // types from Javascript code. Boo does not generate global variables for the
    // defined types so you need to obtain a reference to them with this function.
    Boo.require = function (deps, callback) {
        // Single argument just obtains a previously defined module
        if (arguments.length === 1) {
            if (hop(mod_defined, deps))
                return mod_defined[deps];
            throw new Error('Module ' + deps + ' not found');
        }

        // Collect all dependencies
        var i, args = [];
        for (i = 0; i < deps.length; i++) {
            if (!hop(mod_defined, deps[i]))
                throw new Error('Module ' + deps[i] + ' not found');
            args[i] = mod_defined[deps[i]];
        }

        callback.apply(undefined, args);
    };

    // Registers a source map. Does nothing by default, it's overridden for debug.
    Boo.sourcemap = function (srcmap) {
    };

    // Note: We don't use the native forEach method since this is custom tailored
    //       to the generated code. It handles unpacking and iteration stoppage.
    function boo_each(obj, iterator, context) {
        if (obj === null || typeof obj === 'undefined') return;
        if (typeof obj === 'string') obj = obj.split('');

        var i;
        if (obj.length === +obj.length) {
            // Mode is computed based on the following rules:
            //   - If the callback only has one argument the value is passed as is
            //   - If it has more than one the argument it gets unpacked (apply style invocation)
            var l = obj.length, mode = iterator.length === 1 ? 'call' : 'apply';
            for (i = 0; i < l; i++) {
                if (i in obj && iterator[mode](context, obj[i]) === Boo.STOP) return;
            }
        } else if (typeof obj.next === 'function') {
            i = 0;
            try {
                while (iterator.call(context, obj.next(), i) !== Boo.STOP) { i++; }
            } catch (e) {
                if (e !== Boo.STOP) throw e;
            } finally {
                obj.close();
            }
        } else {
            // For dictionaries we always pass the key and the value
            for (i in obj) {
                if (hop(obj, i)) {
                    if (iterator.call(context, i, obj[i]) === Boo.STOP) return;
                }
            }
        }
    }
    Boo.each = boo_each;

    // Generator factory
    Boo.generator = function (closure) {
        // Convert array/object to a generator
        if (typeof closure === 'function') {
            // Forward generators
            if (hop(closure, 'next') && hop(closure, 'close') &&
                typeof closure.next === 'function' && typeof closure.close === 'function') {
                return closure;
            }

            var idx = 0, data = closure;

            if (!typeIs(data, 'Array'))
                data = Boo.Hash.values(data);

            closure = function (v, e) {
                if (typeof e !== 'undefined') throw e;
                if (idx >= data.length) throw Boo.STOP;
                return data[idx++];
            };
        }

        return {
            next: closure,  // next()
            send: closure,  // send(value)
            'throw': function (error) {
                closure(undefined, error);
            },
            close: function () {
                try {
                    closure(undefined, Boo.STOP);
                } catch (e) {
                    if (e !== Boo.STOP) throw e;
                }
            }
        };
    };

    // Similar to Python's range function this will return an array of integers
    // based on the given parameters.
    function boo_range(start, stop, step) {
        if (arguments.length === 2) {
            step = start < stop ? 1 : -1;
        } else if (arguments.length === 1) {
            stop = start;
            start = 0;
            step = 1;
        }

        var values = [];
        if (step > 0 && start >= stop || step < 0 && start <= stop) {
            return values;
        }

        while (step > 0 ? start < stop : start > stop) {
            values.push(start);
            start += step;
        }

        return values;
    }
    Boo.range = boo_range;

    // Generate a list of key,value pairs
    function boo_enumerate(enumerable) {
        // Strings/Arrays can be solved using zip+range
        if (enumerable.length === +enumerable.length)
            return boo_zip([boo_range(enumerable.length), enumerable]);

        var result = [];
        boo_each(enumerable, function (k, v) {
            result.push([k, v]);
        });
        return result;
    }
    Boo.enumerate = boo_enumerate;

    // Debug method to output information
    Boo.print = function (args) {
        if (typeof console !== undefined && console.log) {
            console.log.apply(console, args);
        }
    };

    // Concatenates the elements of the arrays given as argument
    Boo.cat = function (args) {
        var values = [], fn = function (v) { values.push(v); };

        args = Boo.enumerable(args);
        for (var i = 0, l = args.length; i < l; i++) {
            boo_each(args[i], fn);
        }

        return values;
    };

    // Generates a string concatenating the elements in the array
    Boo.join = function (list, sep) {
        list = Boo.enumerable(list);
        return list.join(arguments.length > 1 ? sep : ' ');
    };

    // Obtain a reversed version of the given array
    Boo.reversed = function (list) {
        var result = Boo.enumerable(list);
        result.reverse();
        return result;
    };

    // Calls a function for each element in the array
    function boo_map(list, callback) {
        var result = [];
        boo_each(list, function (v) {
            result.push(callback(v));
        });
        return result;
    }
    Boo.map = boo_map;

    // Filters out elements from the list for which the callback returns false
    Boo.filter = function (list, callback) {
        var result = [];
        boo_each(list, function (v) {
            if (callback(v)) result.push(v);
        });
        return result;
    };

    // Reduces a list of items to a single one by using a callback receiving an accumulator and the next item
    function boo_reduce(list, callback, value) {
        if (list === null || list === undefined) throw new TypeError("Object is null or undefined");

        // Make sure we always work with an array
        list = Boo.enumerable(list);

        var i = 0, l = +list.length;

        if (arguments.length < 3) {
            if (l === 0) throw new TypeError("Array length is 0 and no third argument");
            value = list[0];
            i = 1;
        } else if (typeof callback !== 'function') {
            var tmp = callback;
            callback = value;
            value = tmp;
        }

        while (i < l) {
            if (i in list) value = callback.call(undefined, value, list[i], i, list);
            ++i;
        }

        return value;
    }
    Boo.reduce = boo_reduce;

    // Builds a list of lists using one item from each given array (zip shortest)
    function boo_zip(args) {
        var i, fn, result = [],
            all_arrays = boo_reduce(args, true, function (a, b) { return a && typeIs(b, 'Array'); });

        if (all_arrays) {
            var shortest = boo_reduce(args, function (a, b) {
                return a.length < b.length ? a : b;
            });

            fn = function (arg) { return arg[i]; };
            for (i = 0; i < shortest.length; i++) {
                result[i] = boo_map(args, fn);
            }
        } else {
            // If there is a generator among them
            fn = function (arg) { return arg[i]; };
            args = boo_map(args, Boo.generator);
            // Initialize
            for (i = 0; i < args.length; i++) args[i] = args[i]();
            // Consume
            while (true) {
                try {
                    result[i] = boo_map(args, fn);
                } catch (e) {
                    if (e !== Boo.STOP) throw e;
                    break;
                }
            }
            // Terminate
            for (i = 0; i < args.length; i++) args[i].close();
        }
        return result;
    }
    Boo.zip = boo_zip;

    // Converts any enumerable into an array, casting its values to a given type.
    // If no type is given just convert it into an array.
    // If the enumerable is a number an array with that many elements is created.
    Boo.array = function (type, enumerable) {
        if (arguments.length === 1) {
            enumerable = type;
            type = null;
        }

        var result, value;
        if (typeIs(enumerable, 'Number')) {
            result = new Array(enumerable);
            value = type === 'int' || type === 'uint' || type === 'double' ? 0 : type === 'bool' ? false : null;
            for (var i = 0, l = enumerable.length; i < l; i++) {
                result[i] = value;
            }
        } else {
            result = [];
            boo_each(enumerable, function (v) {
                result.push(type ? boo_cast(v, type) : v);
            });
        }

        return result;
    };

    // Makes sure a value is enumerable
    Boo.enumerable = function (value) {
        if (typeIs(value, 'String')) value = value.split('');
        if (value && typeof(value.next) === 'function') value = Boo.array(value);
        return (value && value.length) ? value : [];
    };

    // Runtime support for slicing on arrays
    Boo.slice = function (value, begin, end, step) {
        begin = begin || 0;
        if (begin < 0) begin += value.length;

        // Index access
        if (arguments.length === 2) {
            return value.slice(begin, begin + 1)[0];
        }

        end = end || value.length;
        if (end < 0) end += value.length;
        step = step || (begin <= end ? 1 : -1);
        if (begin < end && step === 1) {
            return value.slice(begin, end);
        }

        var result = [];
        if ((begin < end && step > 0) || (begin > end && step < 0)) {
            for (var i = begin; (begin <= end && i < end) || (begin > end && i > end); i += step) {
                result.push(value[i]);
            }
        }
        return (typeof value === 'string') ? result.join('') : result;
    };

    Boo.sliceSet = function (target, begin, end, value) {
        var args;

        begin = begin || 0;
        if (begin < 0) begin += target.length;
        end = end || target.length;
        if (end < 0) end += target.length;

        args = [begin, end - begin].concat(value);
        target.splice.apply(target, args);
    };

    // Check if a value is null (or undefined)
    Boo.isNull = function (value) {
        //return typeOf(value) === 'Null';
        return value === null || value === undefined || typeof value === 'undefined';
    };

    // Check the type of a value
    function boo_isa(value, type) {
        // Handle literal primitives
        if (typeof type === 'string') {
            switch (typeOf(value)) {
            case 'String':
                return type === 'string';
            case 'Function':
                return type === 'callable';
            case 'Boolean':
                return type === 'bool';
            case 'Number':
                if (type === 'int' && value === parseInt(value, 10))
                    return true;
                if (type === 'uint' && value === parseInt(value, 10) && value >= 0)
                    return true;
                return type === 'double';
            default:
                return type === 'object';
            }
        }

        // Special handling for arrays (just in case we run into cross-frame issues)
        if (type === Array) {
            return typeOf(value) === 'Array';
        // Special handling for hash (any object except arrays/dates/regexps can be casted to a hash)
        } else if (type === Boo.Hash) {
            return typeIs(value, 'Object');
        }

        // Check the prototype (basic inheritance)
        if (value instanceof type)
            return true;

        // Check interfaces
        return hop(value, '$boo$interfaces') && -1 !== Boo.indexOf(value.$boo$interfaces, type);
    }
    Boo.isa = boo_isa;

    // Casts a value to the given type, raising an error if it's not possible
    function boo_cast(value, type) {
        // Use isa to detect impossible casts
        if (!boo_isa(value, type))
            throw new Boo.CastError(typeOf(value), type);

        return value;
    }
    Boo.cast = boo_cast;

    // Casts a value to the given type, resulting in a null if it's not possible
    function boo_trycast(value, type) {
        try {
            return boo_cast(value, type);
        } catch (e) {
            return null;
        }
    }
    Boo.trycast = boo_trycast;

    // Obtains the length of a value
    function boo_len(value) {
        var tof = typeof(value);
        if (value !== null && tof !== 'undefined') {
            if (value.length === +value.length) {
                return value.length;
            } else if (typeof value.length === 'function') {
                return value.length();
            }

            if (tof === 'object') {
                var k, length = 0;
                for (k in value)
                    if (hop(value, k)) length++;
                return length;
            }
        }

        throw new Error('Unable to obtain length for value');
    }
    Boo.len = boo_len;


    ////////// Operators /////////////////////////////////////////////////

    // Runtime support for String type
    Boo.String = {
        op_Modulus: function (lhs, rhs) {
            var escapes = { '{{': '{', '}}': '}' };
            return lhs.replace(/\{\{|\}\}|\{(\d+)\}/g, function (m, digit) {
                return m in escapes ? escapes[m] : rhs[digit];
            });
        },
        op_Multiply: function (lhs, rhs) {
            var result = new Array(rhs);
            while (rhs--) result[rhs] = lhs;
            return result.join('');
        }
    };

    // Runtime support for Array type
    Boo.Array = {
        // Checks for equality between two arrays, comparing nested arrays but not objects
        op_Equality: function op_Equality(lhs, rhs) {
            if (lhs.length !== +rhs.length) return false;
            for (var i = 0; i < lhs.length; i++) {
                if (lhs[i] === rhs[i]) continue;
                // Check nested arrays
                if (typeIs(lhs[i], 'Array') && typeIs(rhs[i], 'Array') && op_Equality(lhs[i], rhs[i]))
                    continue;

                return false;
            }
            return true;
        },
        // Checks if an item exists inside an array
        op_Member: function (itm, lst) {
            return Boo.indexOf(lst, itm) !== -1;
        },
        // Checks if an item does not exists inside an array
        op_NotMember: function (itm, lst) {
            return Boo.indexOf(lst, itm) === -1;
        },
        // Perform addition between two arrays
        op_Addition: function (lhs, rhs) {
            return lhs.concat(rhs);
        },
        // Perform multiply on an array
        op_Multiply: function (lhs, rhs) {
            var i, result = [];
            for (i = 0; i < rhs; i++) {
                result = result.concat(lhs);
            }
            return result;
        }
    };

    Boo.Duck = {
        invoke: function (target, method, args) {
            if (!target || typeof target[method] !== 'function')
                throw new Error('Method ' + method + ' not found in target ' + target.toString());
            return target[method].apply(target, args);
        },
        set: function (target, property, value) {
            if (!target)
                throw new Error('Target not found when setting property ' + property);
            target[property] = value;
        },
        get: function (target, property) {
            if (!target)
                throw new Error('Target not found when getting property ' + property);
            var value = target[property];
            return typeof value === 'undefined' ? null : value;
        },
        binary: function (op, lhs, rhs) {
            var lhs_t, rhs_t;

            lhs_t = typeOf(lhs);
            if (Boo[lhs_t] && Boo[lhs_t][op])
                return Boo[lhs_t][op](lhs, rhs);

            rhs_t = typeOf(rhs);
            if (Boo[rhs_t] && Boo[rhs_t][op])
                return Boo[rhs_t][op](rhs, lhs);

            throw new TypeError('Unsupported binary operator (' + op + ') for operands of types ' + lhs_t + ' and ' + rhs_t);
        }
    };

    // Constructor for hashes
    Boo.Hash = function (items) {
        var obj = {};
        if (items) {
            for (var i = 0; i < items.length; i++) {
                obj[items[i][0]] = items[i][1];
            }
        }

        return obj;
    };

    // Obtains the keys of an object
    Boo.Hash.keys = function (hash) {
        var result = [], enumerated = boo_enumerate(hash);
        for (var i = 0, l = enumerated.length; i < l; i++) {
            result.push(enumerated[i][0]);
        }
        return result;
    };

    // Obtains the values of an object
    Boo.Hash.values = function (hash) {
        var result = [], enumerated = boo_enumerate(hash);
        for (var i = 0, l = enumerated.length; i < l; i++) {
            result.push(enumerated[i][1]);
        }
        return result;
    };


    ////////// Events support /////////////////////////////////////////////////

    Boo.Event = function () {
        var handlers = [];

        function fire() {
            var i, args = arguments;
            for (i = 0; i < handlers.length; i++) {
                handlers[i].apply(fire, args);
            }
        }

        fire.add = function (hdlr) {
            handlers.push(hdlr);
            return hdlr;
        };

        fire.remove = function (hdlr) {
            var idx = Boo.indexOf(handlers, hdlr);
            if (idx >= 0) {
                handlers.splice(idx);
            }
            return idx >= 0;
        };

        return fire;
    };

    // function foo() {
    //     return Boo.overload(
    //         arguments,
    //         [
    //             [],
    //             [String, Boo.Hash]
    //         ],
    //         [foo$0, foo$1]
    //     );
    // }
    // function foo$0() {}
    // function foo$1(str, dict) {}
    Boo.overload = function (args, specs, funcs) {
        // Pre-filter based on the number of args
        var matching = [];
        for (var i = 0; i < specs.length; i++) {
            if (args.length === specs[i].length) {
                matching.push(i);
            }
        }

        if (0 === matching.length) {
            throw new Error('No valid overload found for the number of arguments');
        }

        // If there only a match just execute it
        if (matching.length === 1) {
            return funcs[matching[0]].apply(this, args);
        }

        // Filter based on types
        throw new Error('Overloads based on parameter types are not supported yet');
    };


    ///////// Shims ////////////////////////////////////////////////////////

    Boo.create = Object.create || function (o) {
        function F() {}
        F.prototype = o;
        return new F();
    };

    // TODO: Perhaps we should require an Ecma 5th edition environment as base
    Boo.indexOf = function (arr, find, i) {
        i = i || 0;
        if (i < 0) i = 0;
        for (var n = arr.length; i < n; i++) {
            if (i in arr && arr[i] === find) {
                return i;
            }
        }
        return -1;
    };


    exports.Boo = Boo;
})(this);
