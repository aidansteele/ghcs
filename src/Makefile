TOP_DIR = $(shell pwd)
PCRE_PREFIX = $(TOP_DIR)/vendor/libpcre
PCRE = $(PCRE_PREFIX)/lib/libpcre.a

BABEL = vendor/babel/babel.js

$(PCRE):
	wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.38.tar.bz2
	tar -jxf pcre-8.38.tar.bz2
	cd pcre-8.38; ./configure --prefix=$(PCRE_PREFIX); make; make install

$(BABEL): vendor/babel/babel.orig.js vendor/babel/babel.patch
	patch vendor/babel/babel.orig.js -o vendor/babel/babel.js < vendor/babel/babel.patch

ghcs: *.nim js/*.js $(BABEL) $(PCRE) ## Build ghcs itself
	nim c -d:release --passC:-flto ghcs.nim
	strip ghcs

test: ghcs ## Run unit tests
	nim c -r tests/tester.nim

.PHONY: help
.DEFAULT_GOAL := help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
