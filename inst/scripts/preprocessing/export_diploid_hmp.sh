#!/usr/bin/env bash
# We had a problem with the Lansky 2015  hapmap ddata format
# importing and exporting  as diploid wiith the TASSEL5 GUI
# was useful to fix that
# Maybe using the TASSEL CLI will help too.
# sb_snpsDryad_sept2013_filter.c1.imp.hmp.txt
TASSEL5=/usr/local/usrapps/maize/tassel-5-standalone/run_pipeline.pl

data_dir="/rsstu/users/r/rrellan/sara/SorghumGEA/data/Lasky2015/snpsLaskySciAdv_dryad"

mkdir diplo

for c in {1..10}
do
$TASSEL5 -importGuess \
    $data_dir/sb_snpsDryad_sept2013_filter.c${c}.imp.hmp.txt \
    -export diplo/sb_snpsDryad_sept2013_filter.c${c}.imp.hmp.txt \
    -exportType HapmapDiploid
done

