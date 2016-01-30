#!/bin/bash

export PATH=$HOME/Nim/bin:$HOME/.nimble/bin:$PATH

if hash nimble 2>/dev/null; then
    echo "nim and nimble already installed"
else
    git clone https://github.com/nim-lang/Nim.git $HOME/Nim
    cd $HOME/Nim
    sh bootstrap.sh
    cd -

    git clone https://github.com/nim-lang/nimble.git $HOME/nimble
    cd $HOME/nimble
    git clone -b v0.13.0 --depth 1 https://github.com/nim-lang/nim vendor/nim
    nim c -r src/nimble install
    cd -
fi
