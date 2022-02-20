#!/usr/bin/tcsh

# RCMD=$GEA_SCRIPTS/preprocessing/make_taxa_geo_loc.R --help

RCMD="$GEA_SCRIPTS"/preprocessing/make_taxa_geo_loc.R

set geo_loc=`yq '.geo_loc | envsubst' $GEA_CONFIG`

set id_map=`yq '.id_map | envsubst' $GEA_CONFIG`

set hapmap_geo_loc=`yq '.phapmap_geo_loc| envsubst' $GEA_CONFIG`


"$RCMD" --config=$GEA_CONFIG \
        --geo_loc=$geo_loc \
        --id_map=$id_map \
        --hapmap_geo_loc=$hapmap_geo_loc





