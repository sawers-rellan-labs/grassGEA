#!/usr/bin/env bash
# this way of making these genotype files is very simple
# another way might be using TASSEL

out_dir=kinship_sample

mkdir $out_dir

for c in {1..10}
do
# chr=$(printf "%02d" $c)
 grep -v "^S${c}_" all_chr_10K.hmp.txt > $out_dir/loco_chr_${c}.hmp.txt
done
mv all_chr_10K.hmp.txt $out_dir
