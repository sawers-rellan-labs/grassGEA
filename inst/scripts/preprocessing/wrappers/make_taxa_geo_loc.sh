#!/usr/bin/env bash

# SCRIPT=$GEA_SCRIPTS/preprocessing/make_taxa_geo_loc.R --help

SCRIPT="$GEA_SCRIPTS"/preprocessing/make_taxa_geo_loc.R

"$SCRIPT" --config="/Volumes/GoogleDrive/My Drive/repos/grassGEA/inst/extdata/hayu_config.yaml" \
        --geo_loc=/Users/fvrodriguez/Desktop/sorghum/georef.csv \
        --id_map=/Users/fvrodriguez/Desktop/sorghum/genotype_ids.txt \
        --hapmap_geo_loc=/Users/fvrodriguez/Desktop/sorghum/hapmap_geo_loc.tassel





