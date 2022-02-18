#!/usr/local/bin/bash

# usage: fix_hader.sh file1 file2 ...

# fixing hapmap header
# Dryad downloads have the headers "rs." and "assembly."
# Tassel Manual shows  "rs#" and "assembly#" instead
# Should wee get rid of the quotes by the way?
for file in $@
do
perl -pe 's/rs\./rs#/; s/assembly\./assembly#/' -i $file;
perl -pe 's/panelLSID/panel/; s/"//g' -i $file
done
