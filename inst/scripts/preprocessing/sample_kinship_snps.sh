#!/usr/bin/tcsh
conda activate /usr/local/usrapps/maize/sorghum/conda/envs/r_env

echo "Usage: $0 -n snp_sample_size"

# I installed  powershuf.py to the $PATH location:
# /usr/local/usrapps/maize/sorghum/conda/envs/r_env/bin
# I need to set the random number seed in the powershuf.py script
# for reproducible results.
# Branch from gitlabs?
# https://gitlab.com/aapjeisbaas/shuf

set geno_dir="/rsstu/users/r/rrellan/sara/SorghumGEA/data/Lasky2015/filtered"


# merge all chromosomes
echo "Merrging genotype files"
tail -n +2 $geno_dir/*.hmp.txt > tmp/sorghum/markers.txt

# Take the random sample, sort by chromosome and position
echo "sampling $1 random SNPs with powershuf.py."
echo "from: $geno_dir"

powershuf.py  -n $1 --file tmp/sorghum/markers.txt > tmp/kinship_sample.txt

# Add hapmap header
head -n 1 $geno_dir/Lasky2015_c01_001.hmp.txt > tmp/kinship_sample_sorted.txt

echo "Sorting sample..."
sort -k3,3n -k4,4n tmp/kinship_sample.txt >> tmp/kinship_sample_sorted.txt


# The TASSEL java library of rTASSEL has some kind of bug
# that des not allow it to read this random sample file
# so I had to use command line TASSEL5 to make it readable
# Because I sorted the file I think it might be the line breaks \n\r?

set TASSEL5=/usr/local/usrapps/maize/tassel-5-standalone/run_pipeline.pl


$TASSEL5 -h tmp/kinship_sample_sorted.txt\
    -export all_chr_10K \
    -exportType HapmapDiploid

# Make histogram
# there is something odd with the output.
# I have two repeated lines for chromosome 1
# The first one without count (second column).
# Excluded that line from the histogram.

echo "Marker frequency per chromosome"
cut -f 3 all_chr_10K.hmp.txt \
  | sort -n -k1,1 \
  | tail -n +2 \
  | uniq -c \
  | perl -pe "s/^ +//; s/ +/\t/" \
  | awk ' { t = $1; $1 = $2; $2 = t; print; } ' \
  | perl -lane 'print $F[0], "\t", $F[1], "\t", "=" x ($F[1] / 25)'


#TODO:(frz) set the random number seed in the powershuf.py script #
#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #

# set kinship_dir=/rsstu/users/r/rrellan/sara/SorghumGEA/data/Lasky2015/kinship_sample
#
# echo "Copying to a more permanent location: "
# echo $kinship_dir
#
# cp all_chr_10K.hmp.txt  $kinship_dir
#
# head $kinship_dir/all_chr_10K.hmp.txt | cut -f1-15

