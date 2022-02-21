#!/bin/tcsh
#BSUB -W 10
#BSUB -n 1
#BSUB -o stdout.%J
#BSUB -e stderr.%J
module load conda
conda activate /usr/local/usrapps/maize/sorghum/conda/envs/r_env

# Quotes are to make it also compatible  with the blank space
# in the Google Drive "My Drive" folder mounted in my mac.
# Quotes in declaration, quotes on invocation
set RCMD="$GEA_SCRIPTS"/preprocessing/make_hapmap_geo_loc.R

set hapmap_geo_loc=`yq '.hapmap_geo_loc | envsubst' $GEA_CONFIG`

set tif=`yq '.tif | envsubst' $GEA_CONFIG`

set output_dir=`yq '.tif | envsubst' $GEA_CONFIG`


# Probably it will also run if I just give it the --config file
# but here I am showing how to pass the the command line arguments to
# the $RCMD script  
Rscript --verbose "$RCMD" \
        --config=$GEA_CONFIG \
        --hapmap_geo_loc=$hapmap_geo_loc \
        --tif=$tif \
        --output_dir=$output_dir


# if the shebang worked it would be like this:

# "$RCMD" --config=$GEA_CONFIG \
#         --geo_loc=$geo_loc \
#         --id_map=$id_map \
#         --hapmap_geo_loc=$hapmap_geo_loc

