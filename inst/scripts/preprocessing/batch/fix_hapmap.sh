#!/usr/bin/env bash

# usage: fix_hader.sh hapmap_file

# fixing hapmap header
# Dryad downloads have the headers "rs.", "assembly.", "panelLSID"
# Tassel Manual shows  "rs#", "assembly#","panel" instead
# Getting rid of quotes. The quotes were the cause of TASSEL
# dying with an error referring to the number of alleles.

name=$(basename $1)

# my perl habit won't die
perl -pe 's/rs\./rs#/; s/assembly\./assembly#/;  s/panelLSID/panel/; s/"//g' $1 > "fixed/$name"

#replace with sed?
