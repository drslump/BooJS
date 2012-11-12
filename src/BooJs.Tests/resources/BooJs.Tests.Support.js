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
});


// Emulate jQuery
var jQuery = function(){
    return jQuery;
};
jQuery.isArray = function(){ return true; };
jQuery.each = function(){ return jQuery; };
jQuery.ajax = function(){ return jQuery; };
