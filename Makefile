TOP_DIR = $(shell pwd)
PCRE_PREFIX = $(TOP_DIR)/vendor/libpcre
PCRE = $(PCRE_PREFIX)/lib/libpcre.a
NIM = nim #$(TOP_DIR)/vendor/Nim/bin/nim
BABEL = vendor/babel/babel.js
DEBFILE = ghcs_1.0_amd64.deb
DOCS = ghcs.1

$(NIM): ## Build nim itself from master
	./makenim.sh

$(PCRE):
	wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.38.tar.bz2
	tar -jxf pcre-8.38.tar.bz2
	cd pcre-8.38; ./configure --prefix=$(PCRE_PREFIX); make; make install

$(BABEL): vendor/babel/babel.orig.js vendor/babel/babel.patch
	patch vendor/babel/babel.orig.js -o vendor/babel/babel.js < vendor/babel/babel.patch

release: nim/*.nim js/*.js $(BABEL) $(PCRE) $(NIM) ## Build ghcs itself
	$(NIM) c -d:release --passC:-flto nim/ghcs.nim
	mv nim/ghcs .
	strip ghcs
	upx ghcs

$(DOCS): docs/MAN.md
	pandoc docs/MAN.md -s -o ghcs.1

test: ## Run unit tests
	$(NIM) c -d:testing -r nim/ghcs.nim
	$(NIM) c nim/ghcs.nim
	$(NIM) c -r tests/tester.nim

$(DEBFILE):
	./makedeb.sh

deb: test $(DOCS) $(DEBFILE) ## Make deb file

.PHONY: help
.DEFAULT_GOAL := help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
