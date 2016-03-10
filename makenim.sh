#!/bin/bash

if hash nim 2>/dev/null; then
    echo "nim already installed"
else
    git clone --depth 1 https://github.com/nim-lang/Nim.git vendor/Nim
    cd vendor/Nim
    sh bootstrap.sh
fi
