// Boo.Js Runtime
var Boo = {};

// Used as a unique indentifier when we want to stop iterating a generator
var STOP = Boo.STOP = {};

// Standard types
Boo.Types = {
    'void': 'void',
    'bool': 'bool',
    'duck': 'duck',
    'string': 'string',
    'object': 'object',
    'int': 'int',
    'uint': 'uint',
    'double': 'double',
    'callable': 'callable'
};

// Note: We don't use the native forEach method since it doesn't offer a clean way
//       to stop/break the iteration.
Boo.each = function (obj, iterator, context) {
    if (obj == null) return;
    if (typeof obj === 'string') obj = obj.split('');
    if (obj.length === +obj.length) {
        for (var i = 0, l = obj.length; i < l; i++) {
            if (i in obj && iterator.call(context, obj[i], i, obj) === STOP) return;
        }
    } else {
        for (var key in obj) {
            if (obj.hasOwnProperty(key)) {
                if (iterator.call(context, obj[key], key, obj) === STOP) return;
            }
        }
    }
};

// Generator factory
Boo.generator = function (closure) {
    return {next: closure};
};

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

Boo.print = function (args) {
    if (typeof console !== undefined && console.log) {
        console.log.apply(console, args);
    }
};

Boo.cat = function (args) {
    var values = [],
        add = function (v) { values.push(v); };

    for (var i = 0, l = args.length; i < l; i++) {
        Boo.each(args[i], add);
    }

    return values;
};

Boo.join = function (list, sep) {
    var result = Boo.cat([list]);
    return result.join(sep || ' ');
};

Boo.map = function (list, callback) {
    var result = [];
    Boo.each(list, function (v) {
        result.push(callback(v));
    });
    return result;
};

Boo.reversed = function (list) {
    var result = Boo.cat([list]);
    result.reverse();
    return result;
};


Boo.cast = function (value, type) {
    // TODO: This is an absolute hack!!!
    var t = type, tof = typeof(value);
    if (t === Boo.Types['int'] || t === Boo.Types['uint'] || t === Boo.Types['double']) t = 'number';

    if (tof === t)
        return value;
    else if (tof !== 'undefined' && t === 'object')
        return value 
    else if ((tof === 'undefined' || value === null) && t === 'number')
        return 0;
    else if ((tof === 'undefined' || value === null) && t === 'string')
        return '';
    else
        throw new Error('Unable to cast from ' + tof + ' to ' + type);
};

Boo.trycast = function (value, type) {
    try {
        return Boo.cast(value, type);
    } catch (e) {
        return null;
    }
};

// Converts any enumerable into an array, casting to a given type
Boo.array = function(type, enumerable) {
    var result = [];
    if (typeof enumerable === 'number') {
        enumerable = Array(enumerable);
        for (var i=0, l=enumerable.length; i<l; i++) {
            enumerable[i] = null;
        }
    }

    Boo.each(enumerable, function(v){
        result.push(Boo.cast(v, type));
    });
    return result;
};

Boo.op_Modulus = function(lhs, rhs) {
    // Check if we should format a string
    if (typeof lhs === 'string' && typeof rhs === 'object') {
        return lhs.replace(/{(\d+)}/g, function(m, capt){
            return rhs[capt];
        });
    } else {
        return lhs % rhs;
    }
};

Boo.op_Addition = function(lhs, rhs) {
    return lhs + rhs;
};






var BooJs = {};
BooJs.Lang = {};

BooJs.Lang.Array = {
    // Checks for equality between two arrays, comparing nested arrays but not objects
    op_Equality: function(a, b){
        if (a.length != b.length) return false;
        for (var i=0; i<a.length; i++) {
            if (a[i] === b[i]) continue;

            // Check nested arrays
            if (typeof a[i] === 'object' && typeof b[i] === 'object' && a[i].length && b[i].length) {
                if (Boo.Lang.Array.op_Equality(a[i], b[i])) continue;
            }

            return false;
        }
        return true;
    },
    op_Member: function(itm, lst){
        return lst.indexOf(itm) !== -1;
    },
    op_NotMember: function(itm, lst){
        return lst.indexOf(itm) === -1;
    }
};
