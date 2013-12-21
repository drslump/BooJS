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

    function Character(_init_) {
        if (_init_ !== Boo.INIT)
            return Character.constructor.apply(null, arguments);
    }
    Character.constructor = function BooJs$Tests$Support$Character$$constructor (name) {
        var self = this instanceof Character ? this : new Character(Boo.INIT);
        self.Name = null;
        self.set_Name(name);
        return self;
    };
    Character.prototype = Boo.create(Object.prototype);
    Character.prototype.constructor = Character;
    Character.prototype.$boo$interfaces = [];
    Character.prototype.get_Name = function Character$get_Name() {
        return this.Name;
    };
    Character.prototype.set_Name = function Character$set_Name(value) {
        this.Name = value;
    };
    exports.Character = Character;

    function Clickable() {
        this.Click = Boo.event();
    };
    Clickable.prototype = Boo.create(Object.prototype);
    Clickable.prototype.constructor = Clickable;
    Clickable.prototype.$boo$interfaces = [];
    Clickable.prototype.RaiseClick = function () {
        this.Click(this);
    };
    exports.Clickable = Clickable;

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
