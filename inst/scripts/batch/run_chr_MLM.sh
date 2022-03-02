#!/usr/bin/tcsh

# When running a test with an interactive terminal:
# open the terminal with
## bsub -Is -n 4 -R "span[hosts=1]" -W 10 tcsh
# then  activate conda r_env for reading config
module load conda
conda activate /usr/local/usrapps/maize/sorghum/conda/envs/r_env

set RCMD="$GEA_SCRIPTS"/run_MLM.R

# get help
#  Rscript --verbose "$RCMD" --help

set geno_file=$1
set pheno_file=$2
set kinship_matrix=$3
set mlm_prefix=$4
set output_dir=`yq '.shared.output_dir | envsubst' $GEA_CONFIG`


if (! -d $output_dir) then
    mkdir $output_dir
else
    echo "$output_dir already exists."
endif


# all other options will be set by the default config file
Rscript --verbose "$RCMD" \
        --geno_file=$geno_file\
        --pheno_file=$pheno_file\
        --kinship_matrix=$kinship_matrix\
        --mlm_prefix=$mlm_prefix
