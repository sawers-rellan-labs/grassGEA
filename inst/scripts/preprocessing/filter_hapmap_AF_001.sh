#!/usr/bin/env bash
# I'll use the same filter I used in corn 1% minor allelele frequency
TASSEL5=/usr/local/usrapps/maize/tassel-5-standalone/run_pipeline.pl

data_dir="/rsstu/users/r/rrellan/sara/SorghumGEA/data/Lasky2015/snpsLaskySciAdv_dryad"

mkdir filtered

for c in $(seq 1 10);
do
  chr=$(printf "%02d" $c)
  echo $chr
  $TASSEL5  -h $data_dir/sb_snpsDryad_sept2013_filter.c${c}.imp.hmp.txt  \
  	-FilterSiteBuilderPlugin -siteMinAlleleFreq 0.01 -endPlugin \
  	-export filtered/Lasky2015_c${chr}_001_ \
    -exportType HapmapDiploid
done


