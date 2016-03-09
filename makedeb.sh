#!/bin/bash
set -x

BASEDIR=$(dirname $0)
FPMDIR="$BASEDIR/fpm-temp"
BINDIR="$FPMDIR/usr/bin"
MANDIR="$FPMDIR/usr/share/man/man1"

mkdir -p $BINDIR
mkdir -p $MANDIR

cp "ghcs" "$BINDIR/"
cp "ghcs.1" "$MANDIR/"
# copy the man file too

rm "ghcs_1.0_amd64.deb"
fpm -s dir -t deb -n ghcs -C $FPMDIR -d "openssl" .
rm -rf $FPMDIR
