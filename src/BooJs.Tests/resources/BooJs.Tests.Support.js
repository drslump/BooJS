Boo.define('BooJs.Tests.Support', ['Boo', 'exports'], function (Boo, exports) {
    exports.Gender = {
        Male: 0,
        Female: 1
    };

    exports.Card = {
        clubs: 0,
        diamonds: 1,
        hearts: 2,
        spades: 3
    };

    var Constants = (function (_super_) {
        function Constants(_init_) {
            if (_init_ != Boo.INIT)
                return Constants.constructor.apply(null, arguments);
        }
        Constants.constructor = function BooJs$Tests$Support$Constants$$constructor () {
            var self = this instanceof Constants ? this : new Constants(Boo.INIT);
            return self;
        }
        Constants.StringConstant = 'Foo';
        Constants.IntegerConstant = 14;

        Constants.prototype = Boo.create(_super_.prototype);
        Constants.prototype.constructor = Constants;
        Constants.prototype.$boo$interfaces = [];
        Constants.prototype.$boo$super = _super_;

        return Constants;
    })(Object);
    exports.Constants = Constants;

    var Character = (function (_super_) {
        function Character(_init_) {
            if (_init_ !== Boo.INIT)
                return Character.constructor.apply(null, arguments);
        }
        Character.constructor = function BooJs$Tests$Support$Character$$constructor (name) {
            var self = this instanceof Character ? this : new Character(Boo.INIT);
            self.Name = null;
            self.Age = 0;
            self.set_Name(name);
            return self;
        };
        Character.prototype = Boo.create(_super_.prototype);
        Character.prototype.constructor = Character;
        Character.prototype.$boo$interfaces = [];
        Character.prototype.$boo$super = _super_;
        Character.prototype.get_Name = function Character$get_Name() {
            return this.Name;
        };
        Character.prototype.set_Name = function Character$set_Name(value) {
            this.Name = value;
        };
        Character.prototype.get_Age = function Character$get_Age() {
            return this.Age;
        };
        Character.prototype.set_Age = function Character$set_Age(value) {
            this.Age = value;
        };

        return Character;
    })(Object);
    exports.Character = Character;


    var CharacterCollection = (function (_super_) {
        function CharacterCollection (_init_) {
            if (_init_ !== Boo.INIT)
                return CharacterCollection.constructor.apply(null, arguments);
        }
        CharacterCollection.constructor = function () {
            var self = this instanceof CharacterCollection ? this : new CharacterCollection(Boo.INIT);
            self._list = [];
            return self;
        };
        
        CharacterCollection.prototype = Boo.create(_super_.prototype);
        CharacterCollection.prototype.constructor = CharacterCollection;
        CharacterCollection.prototype.$boo$interfaces = [];
        CharacterCollection.prototype.$boo$super = _super_;

        CharacterCollection.prototype.get_Item$0 = function (i) {
            return this._list[i];
        };
        CharacterCollection.prototype.get_Item$1 = function (k) {
            for (var i=0; i<this._list.length; i++) 
                if (this._list[i].get_Name == k)
                    return this._list[i];
            return null;
        };
        CharacterCollection.prototype.Add = function(itm) {
            this._list.push(itm);
        };

        return CharacterCollection;
    })(Object);
    exports.CharacterCollection = CharacterCollection;


    var Clickable = (function (_super_) {
        function Clickable(_init_) {
            if (_init_ !== Boo.INIT)
                return Clickable.constructor.apply(null, arguments);

            this.Click = Boo.event();
        };
        Clickable.constructor = function () {
            var self = this instanceof Clickable ? this : new Clickable(Boo.INIT);
            return self;
        }
        
        Clickable.prototype = Boo.create(_super_.prototype);
        Clickable.prototype.constructor = Clickable;
        Clickable.prototype.$boo$interfaces = [];
        Clickable.prototype.$boo$super = _super_;
        Clickable.prototype.RaiseClick = function () {
            this.Click(this);
        };

        return Clickable;
    })(Object);
    exports.Clickable = Clickable;

    
    var ImplicitConversionToDouble = (function (_super_) {
        function ImplicitConversionToDouble (_init_) {
            if (_init_ !== Boo.INIT)
                return ImplicitConversionToDouble.constructor.apply(null, arguments);
        }
        ImplicitConversionToDouble.constructor = function BooJs$Tests$Support$ImplicitConversionToDouble$$constructor (value) {
            var self = this instanceof ImplicitConversionToDouble ? this : new ImplicitConversionToDouble(Boo.INIT);
            self.Value = value;
            return self;
        };
        ImplicitConversionToDouble.op_Implicit = function BooJs$Tests$Support$ImplicitConversionToDouble$$op_Implicit (o) {
            return o.Value;
        };

        ImplicitConversionToDouble.prototype = Boo.create(_super_.prototype);
        ImplicitConversionToDouble.prototype.constructor = ImplicitConversionToDouble;
        ImplicitConversionToDouble.prototype.$boo$interfaces = [];
        ImplicitConversionToDouble.prototype.$boo$super = _super_;

        return ImplicitConversionToDouble;
    })(Object);
    exports.ImplicitConversionToDouble = ImplicitConversionToDouble;


    var OverrideEqualityOperators = (function (_super_) {
        function OverrideEqualityOperators (_init_) {
            if (_init_ !== Boo.INIT)
                return OverrideEqualityOperators.constructor.apply(null, arguments);
        }
        OverrideEqualityOperators.op_Equality = function BooJs$Tests$Support$OverrideEqualityOperators$$op_Equality (lhs, rhs) {
            if (lhs === null) Boo.print('lhs is null');
            if (rhs === null) Boo.print('rhs is null');
            return true;
        };
        OverrideEqualityOperators.op_Inequality = function BooJs$Tests$Support$OverrideEqualityOperators$$op_Inequality (lhs, rhs) {
            if (lhs === null) Boo.print('lhs is null');
            if (rhs === null) Boo.print('rhs is null');
            return false;
        };

        OverrideEqualityOperators.prototype = Boo.create(_super_.prototype);
        OverrideEqualityOperators.prototype.constructor = OverrideEqualityOperators;
        OverrideEqualityOperators.prototype.$boo$interfaces = [];
        OverrideEqualityOperators.prototype.$boo$super = _super_;

        return OverrideEqualityOperators;
    })(Object);
    exports.OverrideEqualityOperators = OverrideEqualityOperators;


    var VarArgs = (function (_super_) {
        function VarArgs (_init_) {
            if (_init_ !== Boo.INIT)
                return VarArgs.constructor.apply(null, arguments);
        }
        VarArgs.constructor = function BooJs$Tests$Support$VarArgs$$constructor () {
            var self = this instanceof VarArgs ? this : new VarArgs(Boo.INIT);
            return self;
        };

        VarArgs.prototype = Boo.create(_super_.prototype);
        VarArgs.prototype.constructor = VarArgs;
        VarArgs.prototype.$boo$interfaces = [];
        VarArgs.prototype.$boo$super = _super_;

        VarArgs.prototype.Method = function BooJs$Tests$Support$VarArgs$Method () {
            return Boo.overload(arguments, [ [], [Array] ], [this.Method$0, this.Method$1]);
        };
        VarArgs.prototype.Method$0 = function BooJs$Tests$Support$VarArgs$Method$0 () {
            Boo.print("VarArgs.Method")
        };
        VarArgs.prototype.Method$1 = function BooJs$Tests$Support$VarArgs$Method$1 (args) {
            Boo.print("VarArgs.Method(" + Boo.join(args, ', ') + ")");
        };

        return VarArgs;
    })(Object);
    exports.VarArgs = VarArgs;


    function method(x) {
        return x;
    }
    exports.method = method;

    function square(x) {
        return x * x;
    }
    exports.square = square;
});


// Emulate jQuery
var jQuery = function(){
    return jQuery;
};
jQuery.isArray = function(){ return true; };
jQuery.each = function(){ return jQuery; };
jQuery.ajax = function(){ return jQuery; };
