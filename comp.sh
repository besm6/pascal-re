#!/bin/sh
sed 's/{/_(/g;s/}/_)/g' < pascompl.b6 > pascompl$$
dispak pascompl$$
rm -f pascompl$$
