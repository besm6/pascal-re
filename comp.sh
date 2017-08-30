#!/bin/sh
sed 's/{/_(/g;s/}/_)/g' < pascompl.b6 > pascompl$$
dispak -s pascompl$$
rm -f pascompl$$
