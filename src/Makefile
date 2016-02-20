TOP_DIR = $(shell pwd)
PCRE_PREFIX = $(TOP_DIR)/vendor/libpcre
PCRE = $(PCRE_PREFIX)/lib/libpcre.a

$(PCRE):
	wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.38.tar.bz2
	tar -jxf pcre-8.38.tar.bz2
	cd pcre-8.38; ./configure --prefix=$(PCRE_PREFIX); make; make install

vendor/babel/babel.js: vendor/babel/babel.orig.js vendor/babel/babel.patch
	patch vendor/babel/babel.orig.js -o vendor/babel/babel.js < vendor/babel/babel.patch

ghcs: *.nim js/*.js vendor/babel/babel.js $(PCRE)
	nim c -d:release --passC:-flto ghcs.nim
	strip ghcs

test: ghcs
	nim c -r tests/tester.nim

default: ghcs
