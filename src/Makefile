duktape.o: vendor/duktape/duktape.c
	cc -g -std=c99 -c vendor/duktape/duktape.c

vendor/babel/babel.js: vendor/babel/babel.orig.js vendor/babel/babel.patch
	patch vendor/babel/babel.orig.js -o vendor/babel/babel.js < vendor/babel/babel.patch

ghcs: duktape.o *.nim vendor/babel/babel.js
	nim c -d:release --passC:-flto ghcs.nim
	strip ghcs

test: ghcs
	nim c -r tests/tester.nim

default: ghcs
