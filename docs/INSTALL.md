# Installing

## Debian / Ubuntu

TODO: Add instructions on getting GPG key once I have once.

    $ sudo sh -c 'echo deb http://ghcs-apt.s3-website-us-east-1.amazonaws.com/ unstable main >> /etc/apt/sources.list.d/ghcs.list'
    
## From source

First, install UPX - `brew install upx` or `apt-get install upx-ucl`. If 
you want to build a `.deb` package, you will also need `gem install fpm`.
To build docs, you will need `pandoc`.

    $ git clone git@github.com:aidansteele/ghcs.git
    $ cd ghcs
    $ make ghcs    
