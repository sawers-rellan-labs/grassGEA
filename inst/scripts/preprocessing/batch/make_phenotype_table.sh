#!/usr/bin/env bash

# SCRIPT="$GEA_SCRIPTS"/preprocessing/make_phenotype_table.R --help

# Had to quote the path at declaration 
SCRIPT="$GEA_SCRIPTS"/preprocessing/make_phenotype_table.R

# and quote  when invoking for execution
# beacuse of the space  "/Volumes/GoogleDrive/My "
"$SCRIPT" --config="/Volumes/GoogleDrive/My Drive/repos/grassGEA/inst/extdata/hayu_config.yaml" \
        --hapmap_geo_loc=/Users/fvrodriguez/Desktop/sorghum/hapmap_geo_loc.tassel \
        --tif=/Users/fvrodriguez/Desktop/sorghum/soilP_raster/sol_VL.tif \
        --output_dir=/Users/fvrodriguez/Desktop/sorghum/GEA_ouput




