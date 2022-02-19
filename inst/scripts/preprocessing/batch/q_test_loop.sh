#!/bin/tcsh
#usage q_test_loop.sh

# This script will create files in the test_output folder
# with their base names as content

# Comment for local tests
conda activate /usr/local/usrapps/maize/sorghum/conda/envs/r_env

# The yq command will only run if the conda r_env environment is active
# you could personlize $GEA_CONFIG for local tests
# set ENV $GEA_CONFIG=/my/local/path/to/config.yaml

set out_dir="test_output"

mkdir $out_dir

# the -r option for yq is critical for using the raw string output
# otherwise the default quoted string is useless
# -r works with version 2.13.0

set in_dir=`yq -r .genotype_folder $GEA_CONFIG`

foreach file (`ls $in_dir`)
  bsub -n 1 -W 15 -o stdout.%J -e stderr.%J "source ./test_loop.sh $file $out_dir"
end


