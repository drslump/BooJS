Boo.define('BooJs.Tests.Support', ['exports'], function (exports) {
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

    exports.method = function (x) {
        return x;
    };

    exports.Character = function (name) {
        return {Name: name};
    };

    exports.Clickable = function () {
        this.Click = Boo.Event();
    };
    exports.Clickable.prototype.RaiseClick = function () {
        this.Click();
    };

    exports.square = function (x) {
        return x * x;
    };
});


// Emulate jQuery
var jQuery = function(){
    return jQuery;
};
jQuery.isArray = function(){ return true; };
jQuery.each = function(){ return jQuery; };
jQuery.ajax = function(){ return jQuery; };
