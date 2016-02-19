#!/bin/bash
set -x

if [ ! -d "$HOME/libpcre" ]; then
  cd $HOME
  wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.38.tar.bz2
  tar -jxf pcre-8.38.tar.bz2
  cd pcre-8.38
  ./configure --prefix=$HOME/libpcre
  make
  make install
fi
