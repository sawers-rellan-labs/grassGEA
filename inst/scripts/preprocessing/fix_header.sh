#!/usr/bin/bash

# usage: fix_hader.sh file1 file2 ...

# fixing hapmap header
# Dryad downloads have the headers "rs." and "assembly."
# Tassel Manual shows  "rs#" and "assembly#" instead
# Should wee get rid of the quotes by the way?

for hmp in "$@"
do
    perl -e "s/rs\\./rs\\#/; s/assembly\\./assembly\\#/" -i $tmp
done
