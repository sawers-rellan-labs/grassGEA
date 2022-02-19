#!/bin/tcsh

# you could personlize $GEA_CONFIG for local tests
# set ENV $GEA_CONFIG=/my/local/path/to/config.yaml

# Comment for local tests
conda activate /usr/local/usrapps/maize/sorghum/conda/envs/r_env

mkdir fixed
# this line will only run if the conda r_env environment is active
set gt_dir=(yq '.genotype_folder | envsubst' $GEA_CONFIG)

foreach hapmap (`ls $gt_dir/*.imp.hmp.txt`)
    bsub -n 1 -W 15 -o stdout.%J -e stderr.%J "source ./fix_hapmap.sh $gt_dir/$hapmap"
end

# there is a more elegant solution relying just on the chromosome index
# through a job array
# see https://projects.ncsu.edu/hpc/Documents/lsf_scripts.php

