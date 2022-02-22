#!/usr/bin/tcsh

# When running a test with an interactive terminal:
# open the terminal with 
## bsub -Is -n 4 -R "span[hosts=1]" -W 10 tcsh
# then run
# Activating conda r_env for reading config
module load conda
conda activate /usr/local/usrapps/maize/sorghum/conda/envs/r_env

set RCMD="$GEA_SCRIPTS"/run_GLM.R

# get help
#  Rscript --verbose "$RCMD" --help

set output_dir=`yq '.output_dir | envsubst' $GEA_CONFIG`
set geno_dir=`yq '.geno_dir | envsubst' $GEA_CONFIG`
set geno_file=`basename $1`

mkdir $output_dir
Rscript --verbose "$RCMD" \
        --geno_file=$geno_dir/$geno_file
ls 