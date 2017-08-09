#!/bin/sh
sed 's/{/_(/g;s/}/_)/g' < pascompl.b6 > pascompl$$
length=`dispak pascompl$$ | grep ЗОН | cut -d ' ' -f 5`
echo Length of library is $length
besmtool dump 1234 --start=2 --length=$length --to-file=re-pascompl.o
dtran -d re-pascompl.o > re-pascompl.asm
rm -f pascompl$$
