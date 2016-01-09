
function moo(fn) {
    var str = "hello " + fn() + " world!";
    return str;
}

//print(Ghcs);
print(moo(function() { return Ghcs.meth(); }));
//print(moo(() =>  "hey"));
