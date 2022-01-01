#!/bin/sh

export ROOT=`pwd`
export CNF="mkfiles/mkconfig"

echo "" >$CNF
echo "# Configuration parameters" >>$CNF
echo "" >>$CNF
echo "ROOT="`pwd` >>$CNF

cat << EOF >>$CNF
OBJDIR= host
TARGMODEL= Posix
SHELLTYPE= sh
O= o

CC= cc -c -I$ROOT/include
CFLAGS= -Os
AS= cc -c 
LD= cc 
LDFLAGS=

AR= ar
ARFLAGS= ruvs

YACC= $ROOT/host/bin/iyacc
YFLAGS= -d

EOF
echo "Config file 'mkfiles/mkconfig' written"
