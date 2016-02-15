
function moo(fn) {
    var str = "hello " + fn() + " world!";
    return str;
}

//print(Ghcs);
var Ghcs = require('ghcs');
print(moo(function() { return Ghcs.meth(); }));
//print(moo(() =>  "hey"));
