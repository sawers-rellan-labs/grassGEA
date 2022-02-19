#!/usr/bin/env bash

# usage: test_loop.sh file_path output_dir

name=$(basename $1)

# Check for match with 'sb_snpsDryad_sept2013' string
# if match extract chromosome number in the name

if [[ "$name" =~ 'sb_snpsDryad_sept2013' ]]; then
    chr=`echo ${name} | perl -pe '$_=~ s/.*filter\.c|\.imp\.hmp\.txt//g'`
    echo "Chromosome in $1 is $chr" > $2/$1
else
    echo "$name does no match the string: 'sb_snpsDryad_sept2013'" > $2/$1
fi






