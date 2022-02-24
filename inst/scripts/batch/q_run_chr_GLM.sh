#!/usr/bin/tcsh

# Activating conda r_env for config reading 
module load conda
conda activate /usr/local/usrapps/maize/sorghum/conda/envs/r_env

# setting up options from config
# If I use bash I could set up a read_config function inside the script
# In tcsh I have to make another executable script
# and get it into $PATH, so meh...

set RCMD="$GEA_SCRIPTS"/run_GLM.R

set $get_gonfig="yq '.shared, .run_GLM' $GEA_CONFIG | yq "


set pheno_file=`$get_gonfig '.pheno_file  | envsubst'`

set pheno_name=`basename $pheno_file |rev | cut -f2 -d'.'| rev`

set geno_dir=`$get_gonfig '.geno_dir | envsubst'`

set output_dir=`$get_gonfig '.output_dir | envsubst'`

set out_prefix=`$get_gonfig '.glm_prefix | envsubst'`

# I'll wait for each process 60 min
set q_opts="-n 1 -W 60 -o stdout.%J -e stderr.%J"

# I'll start like this but probably we should store markers after filtering
# in a hapmap file with a simpler name

set hm_prefix="sb_snpsDryad_sept2013_filter.c"
set hm_suffix=".imp.hmp.txt"

if (! -d $output_dir) then 
    mkdir $output_dir
else
    echo "$output_dir already exists."
endif

# A more elegant way of doing this loop  is with
# bash brace substitution {1..2}
# also I could save on all those 'set'
# AND DEFINE FUNCTIONS!!!!!!!!
# I'd be very glad to change to bash but
# I'll stick with tcsh because it's been working.

foreach c (`seq 1 10`)

set chr=`printf "%02d\n" $c`
set geno_file=${hm_prefix}${c}${hm_suffix}
set glm_prefix=${out_prefix}_${pheno_name}_${chr}

# It will run if I just give it the --config file
# but here I am showing how to pass the command line arguments to
# the $RCMD script
  # bsub $q_opts Rscript --verbose "$RCMD" \
  #       --pheno_file=$pheno_file \
  #       --geno_file=$geno_dir/$geno_file \
  #       --output_dir=$output_dir \
  #       --glm_prefix=$glm_prefix

bsub $q_opts ./run_chr_GLM.sh $geno_dir/$geno_file $glm_prefix

end


