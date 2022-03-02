#!/usr/bin/env bash

# Activating conda r_env for config reading
module load conda
conda activate /usr/local/usrapps/maize/sorghum/conda/envs/r_env

# setting up options from config
# Using bash I can set up a read_config function inside the script
# In tcsh I have to make another executable script
# and get it into $PATH, so meh...

script="run_MLM"

get_config ( ) {
  opt=$1

  value=$(script=$script yq '.shared, .[env(script)]' $GEA_CONFIG | opt=$opt yq '.[env(opt)]')

  echo "$value"
}

pheno_file=$(get_config pheno_file)

pheno_name=$(basename $pheno_file |rev | cut -f2 -d'.'| rev)

geno_dir=$(get_config geno_dir)

km_dir=$(get_config km_dir)

output_dir=$(get_config output_dir)


if [ ! -d "$output_dir" ]
then
    mkdir "$output_dir"
else
    echo "$output_dir already exists."
fi

# I could move this to the configuration file

hm_prefix="Lasky2015_c"
hm_suffix="_001.hmp.txt"


km_prefix="km_loco_"
km_suffix=".RDS"


# I'll wait for each process 12 hours 4GB of memory
q_opts="-n 1 -R 'rusage[mem=4GB]' -W 12:00 -o stdout.%J -e stderr.%J"


# Looping over chromosomes starting with just 10

for c in {10..10}
do

  chr=$(printf "%02d\n" $c)

  geno_file="$geno_dir/${hm_prefix}${chr}${hm_suffix}"
  kinship_matrix="$km_dir/${km_prefix}${chr}${km_suffix}"
  mlm_prefix=$(get_config mlm_prefix)
  mlm_prefix=${mlm_prefix}_${pheno_name}_${chr}

# Submitting the job

echo bsub $q_opts ./run_chr_MLM.sh \
               "$geno_file" \
               "$pheno_file" \
               "$kinship_matrix" \
               "$mlm_prefix"

done

