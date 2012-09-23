// Boo.Js Runtime
// MIT license
// Copyright 2012 Iván -DrSlump- Montes <drslump@pollinimini.net>

/*jshint indent:4 lastsemic:false curly:false */

var Boo = {};

// Used as a unique indentifier when we want to stop iterating a generator
Boo.STOP = {};

// Standard types
Boo.Types = {
    'void': 'void',
    'bool': 'bool',
    'duck': 'duck',
    'string': 'string',
    'String': 'string',
    'object': 'object',
    'int': 'int',
    'uint': 'uint',
    'double': 'double',
    'callable': 'callable'
};

// Note: We don't use the native forEach method since it doesn't offer a clean way
//       to stop/break the iteration.
Boo.each = function (obj, iterator, context) {
    if (obj === null || typeof obj === 'undefined') return;
    if (typeof obj === 'string') obj = obj.split('');
    if (obj.length === +obj.length) {
        for (var i = 0, l = obj.length; i < l; i++) {
            if (i in obj && iterator.call(context, obj[i], i, obj) === Boo.STOP) return;
        }
    } else {
        for (var key in obj) {
            if (obj.hasOwnProperty(key)) {
                if (iterator.call(context, obj[key], key, obj) === Boo.STOP) return;
            }
        }
    }
};

// Generator factory
Boo.generator = function (closure) {
    return {next: closure};
};

// Similar to Python's range function this will return an array of integers
// based on the given parameters.
Boo.range = function (start, stop, step) {
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

// Debug method to output information
Boo.print = function (args) {
    if (typeof console !== undefined && console.log) {
        console.log.apply(console, args);
    }
};

// Concatenates the elements of the arrays given as argument
Boo.cat = function (args) {
    var values = [],
        add = function (v) { values.push(v); };

    for (var i = 0, l = args.length; i < l; i++) {
        Boo.each(args[i], add);
    }

    return values;
};

// Generates a string concatenating the elements in the array
Boo.join = function (list, sep) {
    var result = Boo.cat([list]);
    return result.join(sep || ' ');
};

// Calls a function for each element in the array
Boo.map = function (list, callback) {
    var result = [];
    Boo.each(list, function (v) {
        result.push(callback(v));
    });
    return result;
};

// Obtain a reversed version of the given array
Boo.reversed = function (list) {
    var result = Boo.cat([list]);
    result.reverse();
    return result;
};

// Casts a value to the given type, raising an error if it's not possible
Boo.cast = function (value, type) {
    // TODO: This is an absolute hack!!!
    var t = type, tof = typeof(value);
    if (t === Boo.Types.int || t === Boo.Types.uint || t === Boo.Types.double) t = 'number';

    if (tof === t)
        return value;
    else if (tof !== 'undefined' && t === 'object')
        return value;
    else if ((tof === 'undefined' || value === null) && t === 'number')
        return 0;
    else if ((tof === 'undefined' || value === null) && t === 'string')
        return '';
    else
        throw new Error('Unable to cast from ' + tof + ' to ' + type);
};

// Casts a value to the given type, resulting in a null if it's not possible
Boo.trycast = function (value, type) {
    try {
        return Boo.cast(value, type);
    } catch (e) {
        return null;
    }
};

// Converts any enumerable into an array, casting to a given type
// If the enumerable is a number an array with that many elements is created
Boo.array = function (type, enumerable) {
    var result = [];
    if (typeof enumerable === 'number') {
        enumerable = new Array(enumerable);
        for (var i = 0, l = enumerable.length; i < l; i++) {
            enumerable[i] = null;
        }
    }

    Boo.each(enumerable, function (v) {
        result.push(Boo.cast(v, type));
    });
    return result;
};

// Perform the modulus operation on two operands
Boo.op_Modulus = function (lhs, rhs) {
    // Check if we should format a string
    if (typeof lhs === 'string' && typeof rhs === 'object') {
        return lhs.replace(/\{(\d+)\}/g, function (m, capt) {
            return rhs[capt];
        });
    } else {
        return lhs % rhs;
    }
};

// Perform an addition operation on two operands
Boo.op_Addition = function (lhs, rhs) {
    return lhs + rhs;
};

// Perform a multiply operations on two operands
Boo.op_Multiply = function (lhs, rhs) {
    // Handle string duplication
    if (typeof lhs === 'number' && typeof rhs === 'string') {
        var _ = lhs;
        lhs = rhs;
        rhs = _;
    }
    if (typeof lhs === 'string' && typeof rhs === 'number') {
        var result = '';
        while (rhs--) result += lhs;
        return result;
    }

    return lhs * rhs;
};


var BooJs = {};
BooJs.Lang = {};

BooJs.Lang.Array = {
    // Checks for equality between two arrays, comparing nested arrays but not objects
    op_Equality: function (a, b) {
        if (a.length !== b.length) return false;
        for (var i = 0; i < a.length; i++) {
            if (a[i] === b[i]) continue;

            // Check nested arrays
            if (typeof a[i] === 'object' && typeof b[i] === 'object' && a[i].length === +a[1].length) {
                if (Boo.Lang.Array.op_Equality(a[i], b[i])) continue;
            }

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
    }
};
