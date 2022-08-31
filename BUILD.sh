#!/bin/sh

export BIN=`pwd`/host/bin

# First make 'mk' as a standalone tool
cd tools/mk
./build_posix.sh
cp mk $BIN/mk
cd ../..

# Now make the required Plan9 std libraries
cd lib9
$BIN/mk install
cd ../libbio
$BIN/mk install
cd ../libmach
$BIN/mk install
cd ..

# Build our own version of yacc
cd tools/yacc
$BIN/mk install
cd ../..

## Build our own version of ar
cd tools/ar
$BIN/mk install
cd ../..

# Build the machine-independent part of CC as a library
cd cmd/cc
$BIN/mk install
cd ..

# Build the 386 compiler
cd 8c
$BIN/mk install
cd ../8l
$BIN/mk install
cd ../8a
$BIN/mk install
cd ..

# Build the 68020 compiler
cd 2c
$BIN/mk install
cd ../2l
$BIN/mk install
cd ../2a
$BIN/mk install
cd ..

# Build the RISCV32 and RISCV64 compilers
cd ic
$BIN/mk install
cd ../il
$BIN/mk install
cd ../ia
$BIN/mk install
cd ../..

echo "==== BUILD COMPLETE, SEE build/bin DIR ====="

