#/usr/bin/env bash

# I need to set the random number seed in the  powershuf.py script
# for reproducible results.
# Branch from gitlabs?
# https://gitlab.com/aapjeisbaas/shuf
# I installed  powershuf.py  to
# /usr/local/usrapps/maize/sorghum/conda/envs/r_env/bin

powershuf.py --file tmp/sorghum/markers.txt -n 10000 \
| sort -k3,3 -k 4,4 > tmp/kinship_sample.txt;

# histogram
cut -f 3 kinship_sample.txt \
  | sort -n -k1,1 \
  | tail -n +2 \
  | uniq -c \
  | perl -pe "s/^ +//; s/ +/\t/" \
  | awk ' { t = $1; $1 = $2; $2 = t; print; } ' \
  | perl -lane 'print $F[0], "\t", "=" x ($F[1] / 20)'

# there is something odd with the output.
# I have repeated two lines forr chromosome 1


head -n 1 tmp/sorghum/markers.txt > tmp/hapmap_header

cp kinship_sample_10K.hapmap.txt /rsstu/users/r/rrellan/sara/SorghumGEA/results/TASSEL_kinship/


