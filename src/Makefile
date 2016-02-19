vendor/babel/babel.js: vendor/babel/babel.orig.js vendor/babel/babel.patch
	patch vendor/babel/babel.orig.js -o vendor/babel/babel.js < vendor/babel/babel.patch

ghcs: *.nim js/*.js vendor/babel/babel.js
	nim c -d:release --passC:-flto ghcs.nim
	strip ghcs

test: ghcs
	nim c tests/tester.nim
	strace tests/tester

default: ghcs
