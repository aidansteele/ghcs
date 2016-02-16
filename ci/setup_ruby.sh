#!/bin/bash

mkdir -p ~/.rubies/
wget -P ~/.rubies/ https://s3.amazonaws.com/travis-rubies/binaries/ubuntu/14.04/x86_64/ruby-2.3.0.tar.bz2
tar -jxf ruby-2.3.0.tar.bz2 -C ~/.rubies/
export PATH=~/.rubies/ruby-2.3.0/bin:$PATH

gem install bundler --no-ri --no-rdoc
