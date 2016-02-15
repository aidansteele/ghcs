DUKTAPE_C_O = duktape_c.o

duktape.o: vendor/duktape/duktape.c
	cc -std=c99 -c vendor/duktape/duktape.c

duktape_c.o: duktape_c.c
	cc -std=c99 -c duktape_c.c -iquote vendor/duktape

duktape_c.a: duktape_c.o duktape.o
	ar rcs $@ $^

vendor/babel/babel.js: vendor/babel/babel.orig.js vendor/babel/babel.patch
	patch vendor/babel/babel.orig.js -o vendor/babel/babel.js < vendor/babel/babel.patch

ghcs: duktape_c.a *.nim vendor/babel/babel.js
	nimble build

default: ghcs
