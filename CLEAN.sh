#!/bin/sh

export BIN=`pwd`/host/bin

# Clean Plan9 std libraries
cd lib9
$BIN/mk nuke
cd ../libbio
$BIN/mk nuke
cd ../libmach
$BIN/mk nuke
cd ..

# Clean our own version of yacc
cd tools/yacc
$BIN/mk nuke
cd ../..

# Clean our own version of ar
cd tools/ar
$BIN/mk nuke
cd ../..

# Clean the machine-independent part of CC as a library
cd cmd/cc
$BIN/mk nuke
cd ..

# Clean the 386 compiler
cd 8c
$BIN/mk nuke
cd ../8l
$BIN/mk nuke
cd ../8a
$BIN/mk nuke
cd ..

# Clean the 68020 compiler
cd 2c
$BIN/mk nuke
cd ../2l
$BIN/mk nuke
cd ../2a
$BIN/mk nuke
cd ..

# Clean the RISCV32 and RISCV64 compilers
cd ic
$BIN/mk nuke
cd ../il
$BIN/mk nuke
cd ../ia
$BIN/mk nuke
cd ../..

rm $BIN/../lib/*

echo "==== CLEAN COMPLETE ====="

