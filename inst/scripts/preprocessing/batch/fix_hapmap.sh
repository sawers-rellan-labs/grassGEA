#!/usr/bin/bash

# usage: fix_hader.sh hapmap_file

# fixing hapmap header
# Dryad downloads have the headers "rs.", "assembly.", "panelLSID"
# Tassel Manual shows  "rs#", "assembly#","panel" instead
# Getting rid of quotes. The quotes were the cause of TASSEL
# dying with an error referring to the number of alleles.

name=$(basename $1)

# echo $in > "fixed/$name"
# echo $name > "fixed/$name"
perl -pe 's/rs\./rs#/; s/assembly\./assembly#/;  s/panelLSID/panel/; s/"//g' $1 > "fixed/$name"

