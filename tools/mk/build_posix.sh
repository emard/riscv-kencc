#!/bin/sh

echo "Building 'mk' from scratch"
echo ""
echo "Compiling selected library files..."
cc -c -Ih -Os lib/*.c
echo "Compiling 'mk' itself"
cc -c -Ih -Os *.c
echo "Linking output file"
cc -o mk *.o
strip mk
echo "Cleaning build files"
rm *.o
echo "Done."

