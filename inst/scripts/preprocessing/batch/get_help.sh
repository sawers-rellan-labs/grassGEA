#!/bin/tcsh
#BSUB -W 10
#BSUB -n 1
#BSUB -o stdout.%J
#BSUB -e stderr.%J
module load conda
conda activate /usr/local/usrapps/maize/sorghum/conda/envs/r_env
set RCMD="$GEA_SCRIPTS"/preprocessing/make_hapmap_geo_loc.R
# I could no make the Rscript shebang #!usr/bin/Rscript --verbose
# or #!usr/bin/env Rscript --verbose
# to work so I will invoke Rscript directly
Rscript --verbose $RCMD --help
