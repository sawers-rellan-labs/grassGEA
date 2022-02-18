#!/bin/tcsh

# you could personlize $GEA_CONFIG for local tests
# set ENV $GEA_CONFIG=/my/local/path/to/config.yaml

# Comment for local tests
conda activate /usr/local/usrapps/maize/sorghum/conda/envs/r_env

mkdir fixed
# this line will only run if the conda r_env environment is active
set data_dir=(yq .genotype_folder $GEA_CONFIG)

foreach hapmap (`ls $data_dir`)
    bsub -n 1 -W 15 -o stdout.%J -e stderr.%J "source ./fix_hapmap.sh $data_dir/$hapmap"
end

