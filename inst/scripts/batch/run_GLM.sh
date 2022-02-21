#!/bin/tcsh

# I'll activate the conda r_env here to guarantee
# that it load R and read the envuronment variables
conda activate /usr/local/usrapps/maize/sorghum/conda/envs/r_env

# Quotes are to make it also compatible  with the blank space
# in the Google Drive "My Drive" folder mounted in my mac
# Quotes in declaration, quotes on invocation
set RCMD="$GEA_SCRIPTS"/run_GML.R

set glm_preffix=`yq '.glm_preffix| envsubst' $GEA_CONFIG`

# Probably it will also run if I just give it the --config file
# but here I am showing how to pass the command line arguments to
# the $RCMD script


Rscript --verbose "$RCMD" \
        --pheno_file=$1 \
        --geno_file=$2 \
        --output_dir=$3 \
        --glm_preffix=$glm_preffix

