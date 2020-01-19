#!/bin/bash

SRC=$PWD
PREFIX=$HOME
if [ $# -gt 0 ]; then
	$PREFIX=$1
fi

BIN=$PREFIX/bin
LIB=$PREFIX/lib/vex

if [[ ! -d $BIN ]]
then
    mkdir -p $BIN
fi

if [[ ! -d $LIB ]]
then
	mkdir -p $LIB
fi

cp $SRC/vex $BIN/vex
sed -i "/^\s*VEXLIB=/ s%=.*$%=$LIB%" $BIN/vex

cp $SRC/wson-encode.vim $BIN
cp -r $SRC/autoload $LIB
