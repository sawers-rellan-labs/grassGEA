#!/usr/bin/tcsh

# Activating conda r_env for reading config
module load conda
conda activate /usr/local/usrapps/maize/sorghum/conda/envs/r_env

# so everything that needs to be read from the conda environment
# must be dealt with in the wrapper script.

set RCMD="$GEA_SCRIPTS"/run_GLM.R

set pheno_file=`yq '.pheno_file | envsubst' $GEA_CONFIG`

# set geno_dir=`yq '.geno_dir | envsubst' $GEA_CONFIG`
set geno_dir="geno_dir"

set output_dir=`yq '.output_dir | envsubst' $GEA_CONFIG`

set glm_prefix=`yq '.glm_prefix| envsubst' $GEA_CONFIG`

# I'll wait for each process 60 min
set q_opts="-n 1 -W 60 -o stdout.%J -e stderr.%J"


mkdir $output_dir

foreach geno_file (`ls $geno_dir`)

# Probably it will also run if I just give it the --config file
# but here I am showing how to pass the command line arguments to
# the $RCMD script

  bsub $q_opts Rscript --verbose "$RCMD" \
        --pheno_file=$pheno_file \
        --geno_file=$geno_dir/$geno_file \
        --output_dir=$output_dir \
        --glm_prefix=$glm_prefix
end
