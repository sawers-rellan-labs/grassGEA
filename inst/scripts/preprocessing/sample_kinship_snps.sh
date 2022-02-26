#!/usr/bin/env bash

echo "Usage: $0 -n snp_sample_size"

# I installed  powershuf.py to the $PATH location:
# /usr/local/usrapps/maize/sorghum/conda/envs/r_env/bin
# I need to set the random number seed in the powershuf.py script
# for reproducible results.
# Branch from gitlabs?
# https://gitlab.com/aapjeisbaas/shuf

geno_dir="/rsstu/users/r/rrellan/sara/SorghumGEA/data/Lasky2015/snpsLaskySciAdv_dryad"

echo "sampling 10000 random SNPs with powershuf.py from :"
echo "from: $geno_dir"
# merge all chromosomes
tail -n +2 $geno_dir/*.imp.hmp.txt > tmp/sorghum/markers.txt

# Take the random sample, sort by chromosome and position
powershuf.py --file tmp/sorghum/markers.txt -n $1 \
  | sort -k3,3 -k 4,4 \
  > tmp/kinship_sample.txt

# Make histogram
echo "Marker frequency per chromosome"
cut -f 3 kinship_sample.txt \
  | sort -n -k1,1 \
  | tail -n +2 \
  | uniq -c \
  | perl -pe "s/^ +//; s/ +/\t/" \
  | awk ' { t = $1; $1 = $2; $2 = t; print; } ' \
  | perl -lane 'print $F[0], "\t", $F[1], "\t", "=" x ($F[1] / 25)'

# there is something odd with the output.
# I have two repeated lines for chromosome 1
# The first one without count (second column).
# Excluded that line from the histogram.

# Add hapmap header
head -n 1 $geno_dir/sb_snpsDryad_sept2013_filter.c10.imp.hmp.txt > tmp/hapmap_header
cat tmp/hapmap_header tmp/kinship_sample.txt > kinship_sample_10K.hapmap.txt

kinship_dir=/rsstu/users/r/rrellan/sara/SorghumGEA/results/TASSEL_kinship/

echo "Copying to a more permanent location: "
echo $kinship_dir

cp kinship_sample_10K.hapmap.txt  $kinship_dir

head $kinship_dir/kinship_sample_10K.hapmap.txt | cut -f1-15
