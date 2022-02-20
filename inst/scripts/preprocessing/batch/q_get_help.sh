#!/bin/tcsh
#BSUB -W 10
#BSUB -n 1
#BSUB -o stdout.%J
#BSUB -e stderr.%J
module load conda
conda activate /usr/local/usrapps/maize/sorghum/conda/envs/r_env

# Quotes are to make it also compatible  with the blank space
# in the Google Drive "My Drive" folder mounted in my mac
# Quotes in declaration, quotes on invocation

set RCMD="$GEA_SCRIPTS"/preprocessing/make_hapmap_geo_loc.R
Rscript --verbose "$RCMD" --help
