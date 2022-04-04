#!/usr/bin/env bash

# Activating conda r_env for config reading
module load conda
conda activate /usr/local/usrapps/maize/sorghum/conda/envs/r_env

# setting up options from config
# Using bash I can set up a read_config function inside the script
# In tcsh I have to make another executable script
# and get it into $PATH, so meh...

script="run_GLM"

get_config ( ) {
  opt=$1

  value=$(script=$script yq '.shared, .[env(script)]' $GEA_CONFIG | opt=$1 yq '.[env(opt)]')

  echo "$value"
}

pheno_file=$(get_config pheno_file)

pheno_name=$(basename $pheno_file |rev | cut -f2 -d'.'| rev)

geno_dir=$(get_config geno_dir)

output_dir=$(get_config output_dir)

out_prefix=$(get_config glm_prefix)

# I'll wait for each process 60 min
q_opts="-n 1 -W 60 -o stdout.%J -e stderr.%J"

# I'll start like this but probably we should store markers after filtering
# in a hapmap file with a simpler name

hm_prefix="sb_snpsDryad_sept2013_filter.c"
hm_suffix=".imp.hmp.txt"

if [[! -d "$output_dir" ]]
then
    mkdir "$output_dir"
else
    echo "$output_dir already exists."
fi

# Looping over chromosomes

for c in {1..10}
do

  chr=$(printf "%02d\n" $c)
  geno_file=${hm_prefix}${c}${hm_suffix}
  glm_prefix=${out_prefix}_${pheno_name}_${chr}

# Submitting the job

  bsub $q_opts ./run_chr_GLM.sh "$geno_dir"/"$geno_file" $glm_prefix

done

