#!/usr/bin/env bash
# this way of making these matrices is very simple
# another way might be using TASSEL

mkdir kinship

for c in {1..10}
do
# chr=$(printf "%02d" $c)
 grep -v "^S${c}_" kinship_sample_10K.hmp.txt > kinship/loco_chr_${c}.hmp.txt
done
mv all_chr_10K.hmp.txt kinship_sample



