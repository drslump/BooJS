// Boo.Js Runtime
// MIT license
// Copyright 2012 Iván -DrSlump- Montes <drslump@pollinimini.net>

/*jshint indent:4 lastsemic:false curly:false */
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
        '[object RegExp]': 'RegExp'
    };
    // Tells the type of a variable according to the following rules:
    //  - Undefineds and Nulls are reported as null
    //  - Objects without primitives are reported as Object (except for Array and RegExp)
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
    function typeIs(v, expected) {
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
        // Used as a unique indentifier when we want to stop iterating a generator
        STOP: typeof StopIteration !== 'undefined' ? StopIteration : {}
    };

    // Assertion error
    Boo.AssertionError = function AssertionError(message) {
        this.name = 'AssertionError';
        this.message = message;
    };
    Boo.AssertionError.prototype = new Error();
    Boo.AssertionError.prototype.constructor = Boo.AssertionError;

    // Cast error
    Boo.CastError = function CastError(from, to) {
        this.name = 'CastError';
        this.message = "Cannot cast '" + from + "' to '" + to + "'";
    };
    Boo.CastError.prototype = new Error();
    Boo.CastError.prototype.constructor = Boo.CastError;

    // State for the module loader
    var mod_waiting = {},
        mod_defined = { 'Boo': Boo };

    // AMD style module loader. All Boo modules (files) wrap their
    // contents in a call to this function. This implementation is
    // intentionally very naive, expecting all dependencies to be
    // already loaded in the correct order. It can be overriden
    // to support on demand loading using RequireJs or CommonJs.
    Boo.define = function (name, deps, factory) {
        var i, dep, args, member, module,
            refs = [];

        // Support function signature without dependencies
        if (!typeIs(deps, 'Array')) {
            factory = deps;
            deps = [];
        }

        // The first time we know about the module add it to the waiting list
        if (!hop(mod_defined, name)) {
            mod_waiting[name] = [name, deps, factory];
        }

        // Evaluate dependencies (the fist element is always 'exports')
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
    // defined types so you need to obtain a reference to them thru this function.
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

    // Registers a source map. Does nothing by default.
    Boo.sourcemap = function (srcmap) {
    };

    // Note: We don't use the native forEach method since this is custom tailored
    //       to the generated code. It handles unpacking and iteration stopage.
    var each = Boo.each = function (obj, iterator, context) {
        if (obj === null || typeof obj === 'undefined') return;
        if (typeof obj === 'string') obj = obj.split('');

        var i;
        if (obj.length === +obj.length) {
            // Mode is computed based on the following rules:
            //   - If the callback only has one argument the value is passed as is
            //   - If it has more than one the argument is unpacked (apply style invocation)
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
    };

    // Generator factory
    Boo.generator = function (closure) {
        // Convert array/object to a generator
        if (!typeIs(closure, 'Function')) {
            // Forward generators
            if (closure && hop(closure, 'next') && hop(closure, 'close') &&
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
    var range = Boo.range = function (start, stop, step) {
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
    };

    // Generate a list of pairs of key, value
    var enumerate = Boo.enumerate = function (enumerable) {
        // Strings/Arrays can be solved using zip/range
        if (enumerable.length === +enumerable.length)
            return zip([range(enumerable.length), enumerable]);

        var result = [];
        each(enumerable, function (k, v) {
            result.push([k, v]);
        });
        return result;
    };

    // Debug method to output information
    Boo.print = function (args) {
        if (typeof console !== undefined && console.log) {
            console.log.apply(console, args);
        }
    };

    // Concatenates the elements of the arrays given as argument
    var cat = Boo.cat = function (args) {
        var values = [], fn = function (v) { values.push(v); };

        args = Boo.enumerable(args);
        for (var i = 0, l = args.length; i < l; i++) {
            each(args[i], fn);
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
        var result = cat([list]);
        result.reverse();
        return result;
    };

    // Calls a function for each element in the array
    var map = Boo.map = function (list, callback) {
        var result = [];
        each(list, function (v) {
            result.push(callback(v));
        });
        return result;
    };

    // Calls a function for each element in the array
    Boo.filter = function (list, callback) {
        var result = [];
        each(list, function (v) {
            if (callback(v)) result.push(v);
        });
        return result;
    };

    // Reduces a list of items using a callback to a single one
    var reduce = Boo.reduce = function (list, callback, value) {
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
    };

    // Builds a list of lists using one item from each given array (zip shortest)
    var zip = Boo.zip = function (args) {
        var i, fn, result = [],
            all_arrays = reduce(args, true, function (a, b) { return a && typeIs(b, 'Array'); });

        if (all_arrays) {
            var shortest = reduce(args, function (a, b) {
                return a.length < b.length ? a : b;
            });

            fn = function (arg) { return arg[i]; };
            for (i = 0; i < shortest.length; i++) {
                result[i] = map(args, fn);
            }
            return result;
        } else {
            // If there is a generator among them
            fn = function (arg) { return arg[i]; };
            args = map(args, Boo.generator);
            // Initialize
            for (i = 0; i < args.length; i++) args[i] = args[i]();
            // Consume
            while (true) {
                try {
                    result[i] = map(args, fn);
                } catch (e) {
                    if (e !== Boo.STOP) throw e;
                    break;
                }
            }
            // Terminate
            for (i = 0; i < args.length; i++) args[i].close();

            return result;
        }
    };

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
            each(enumerable, function (v) {
                result.push(type ? cast(v, type) : v);
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
        return typeOf(value) === 'Null';
    };

    // Check the type of a value
    var isa = Boo.isa = function (value, type) {
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
        // Special handling for hash (any object except arrays/regexps can be casted to a hash)
        } else if (type === Boo.Hash) {
            return typeIs(value, 'Object');
        }

        // Check the prototype (basic inheritance)
        if (value instanceof type)
            return true;

        // Check interfaces
        return hop(value, '$boo$interfaces') && -1 !== value.$boo$interfaces.indexOf(type);
    };

    // Casts a value to the given type, raising an error if it's not possible
    var cast = Boo.cast = function (value, type) {
        // Use isa to detect imposible casts
        if (!isa(value, type))
            throw new Boo.CastError(typeOf(value), type);

        return value;
    };

    // Casts a value to the given type, resulting in a null if it's not possible
    Boo.trycast = function (value, type) {
        try {
            return cast(value, type);
        } catch (e) {
            return null;
        }
    };

    // Obtains the length of a value
    Boo.len = function (value) {
        if (value !== null && typeof value === 'object') {
            if (value.length === +value.length) {
                return value.length;
            } else if (typeof value.length === 'function') {
                return value.length();
            }

            var k, length = 0;
            for (k in value) {
                if (hop(value, k)) {
                    length++;
                }
            }
            return length;
        }

        throw new Error('Unable to obtain length for value');
    };


    ////////// Operators /////////////////////////////////////////////////

    // Runtime support for String type
    Boo.String = {
        op_Modulus: function (lhs, rhs) {
            return lhs.replace(/\{(\d+)\}/g, function (m, capt) {
                return rhs[capt];
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
        op_Equality: function (lhs, rhs) {
            if (lhs.length !== rhs.length) return false;
            for (var i = 0; i < lhs.length; i++) {
                if (lhs[i] == rhs[i]) continue;
                // Check nested arrays
                if (typeIs(lhs[i], 'Array') && typeIs(rhs[i], 'Array') && Boo.Array.op_Equality(lhs[i], rhs[i]))
                    continue;

                return false;
            }
            return true;
        },
        // Checks if an item exists inside an array
        op_Member: function (itm, lst) {
            return lst.indexOf(itm) !== -1;
        },
        // Checks if an item does not exists inside an array
        op_NotMember: function (itm, lst) {
            return lst.indexOf(itm) === -1;
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
        var result = [], enumerated = enumerate(hash);
        for (var i = 0, l = enumerated.length; i < l; i++) {
            result.push(enumerated[i][0]);
        }
        return result;
    };

    // Obtains the values of an object
    Boo.Hash.values = function (hash) {
        var result = [], enumerated = enumerate(hash);
        for (var i = 0, l = enumerated.length; i < l; i++) {
            result.push(enumerated[i][1]);
        }
        return result;
    };


    ////////// Class //////////////////////////////////////////////////////

    // Class factory. Inherits from the first item in the `extend` array,
    // registering additional items as interfaces.
    Boo.Class = function (extend, constructor, statics, instance) {
        var prop, base, cls = constructor;

        cls.prototype.constructor = cls;
        if (extend.length) {
            base = extend.shift();
            cls.prototype = new base;
            cls.$boo$interfaces = extend;
        }

        for (prop in statics) if (hop(statics, prop))
            cls[prop] = statics[prop];
        for (prop in instance) if (hop(instance, prop))
            cls.prototype[prop] = instance[prop];

        return cls;
    };

    /*
    Person = Boo.Class([Base, IEnumerable], function (){

    }, {
        Flag: 'flag',
        foo: function Person$foo() {}
    }, {
        bar: 'field',
        baz: function Person$baz() {}
    });

    Person = function () {};
    // Basic inheritance
    Person.prototype = new Base();
    Person.prototype.constructor = Person;
    // Interface metadata (used by isa testing)
    Person.$boo$interfaces = [IEnumerable];
    // Static members
    Person.Flag = 'flag';
    Person.foo = function Person$bar() {};   // Name functions to help debugging
    // Instance members
    Person.prototype.bar = 'field';
    Person.prototype.baz = function Person$baz() {};
    */


    exports.Boo = Boo;
})(this);
