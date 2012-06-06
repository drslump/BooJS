// Boo.Js Runtime
var Boo = {};

// Used as a unique indentifier when we want to stop iterating a generator
var STOP = Boo.STOP = {};

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






var BooJs = {};
BooJs.Lang = {};

BooJs.Lang.Array = {
    op_Equality: function(x, y){
        throw new Error('Implement equality function. Check assert libraries for proven implementations (ie: qunit)');
    },
    op_Member: function(itm, lst){
        return lst.indexOf(itm) !== -1;
    },
    op_NotMember: function(itm, lst){
        return lst.indexOf(itm) === -1;
    }
};
