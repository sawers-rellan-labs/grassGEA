#!/usr/bin/tcsh

# Activating conda r_env for reading config
conda activate /usr/local/usrapps/maize/sorghum/conda/envs/r_env

# so everything that needs to be read from the conda environment
# must be dealt with in the wrapper script.

set pheno_file =$1
set geno_dir =$2
set out_dir= $3

# I'll wait for each process 60 min
set q_args="-n 1 -W 60 -o stdout.%J -e stderr.%J"

mkdir $out_dir

foreach $geno_file (`ls $gt_dir/*.`)
  q_args="$q_args source ./run_chr_GLM.sh $pheno_file $geno_phile"
  bsub $q_args
end