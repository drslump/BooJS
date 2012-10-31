Boo.define('BooJs.Tests.Support', [], function () {

    this.Gender = {
        Male: 0,
        Female: 1
    };

    this.Card = {
        clubs: 0,
        diamonds: 1,
        hearts: 2,
        spades: 3
    };

    return this;
});


// Emulate jQuery
var jQuery = function(){
    return jQuery;
};
jQuery.isArray = function(){ return true; };
jQuery.each = function(){ return jQuery; };
