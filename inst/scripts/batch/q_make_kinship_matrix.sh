#!/usr/bin/env bash

# Activating conda r_env for config reading
conda activate /usr/local/usrapps/maize/sorghum/conda/envs/r_env

# setting up options from config
# from bash I can set up a read_config function inside the script
# In tcsh I have to make another executable script
# and get it into $PATH, so meh...

script="make_kinship_matrix"

get_config ( ) {
  opt=$1

  value=$(script=$script yq '.shared, .[env(script)]' $GEA_CONFIG | opt=$opt yq '.[env(opt)]')

  echo "$value"
}

# rTASSEL calculates the kinship matrix from a GenoPheno Object so
# we need a phenotype file :/

pheno_file=$(get_config pheno_file)

# we are gonna read from the 10K LOCO genotype hapmap files
geno_dir=$(get_config geno_dir)

output_dir=$(get_config output_dir)


# I'll wait for each process 60 min
q_opts="-n 1 -W 60 -o stdout.%J -e stderr.%J"

# Working from the kinship sample

hm_prefix="loco_chr_"
hm_suffix=".hmp.txt"

if [ ! -d "$output_dir" ]
then
    mkdir "$output_dir"
else
    echo "$output_dir already exists."
fi

# Looping over chromosome number

for c in {1..10}
do
# change to padded left 0s
  chr=$(printf "%02d\n" $c)
  geno_file="$geno_dir"/${hm_prefix}${c}${hm_suffix}

  km_prefix=$(get_config km_prefix)
  mds_prefix=$(get_config mds_prefix)

  km_prefix=${km_prefix}_loco_${chr}
  mds_prefix=${mds_prefix}_loco_${chr}

#Submit the job
  bsub $q_opts ./make_kinship_matrix.sh \
                 $pheno_file \
                 $geno_file \
                 $km_prefix \
                 $mds_prefix
done
