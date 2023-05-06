Table of Contents
=================

* [Sorghum and Maize Genome Environment Association (GEA)](#sorghum-and-maize-genome-environment-association-gea)
   * [Dependencies](#dependencies)
   * [HPC cluster setup](#hpc-cluster-setup)
      * [Conda Environment](#conda-environment)
      * [Configuration file](#configuration-file)
      * [Parallelizing Scripts on Chromosomes](#parallelizing-scripts-on-chromosomes)
      * [Multiple job submission test](#multiple-job-submission-test)
   * [License](#license)

Sorghum and Maize Genome Environment Association (GEA) 
==============

We'll start using rTassel for GEA, or environmental (eGWAS)

## Dependencies

`R` libraries:

  - `rTASSEL`
  - `rJava` 
  - `configr`

Command line utilties:

  - `yq` 4.20.1 (for reading `yaml` configuration files from shell scripts)
  
Details on [`INSTALL.md`](https://github.com/sawers-rellan-labs/grassGEA/blob/master/INSTALL.md).

## HPC cluster setup

### Conda Environment

Before using the scripts we must first activate the conda `r_env` environment.

```{bash}
#in tcsh
conda activate /usr/local/usrapps/maize/sorghum/conda/envs/r_env
```

### Configuration file
We will use a `yaml` that can be read both, by `R` (using `configr`) and shell scripts (using `yq`).
There is a sample config file `config.yaml` in the extdata folder of the `grassGEA` installation.  

```{bash}
#in tcsh
cp $GEA_CONFIG  ./
```

### Parallelizing Scripts on Chromosomes 

***Now these scripts should work!***

***For a working short example go to next section***

We need to setup the memory requirement and time for each chromosome task
and add those requirements to the batch processing scripts.

For submitting chromosome jobs I've decided to use a loop
as discussed in the [HPC batch sripts](https://projects.ncsu.edu/hpc/Documents/lsf_scripts.php) submission page.

Each job will be sent as call to a wrapper for a `R` script that runs from the command line.

The script queuing the jobs, with `bsub`, will have a `q_` preffix

`q_run_chr_GLM.sh`

```{bash}
#!/usr/bin/env bash

# Activating conda r_env for config reading
module load conda
conda activate /usr/local/usrapps/maize/sorghum/conda/envs/r_env

# setting up options from config
# If I use bash I could set up a read_config function inside the script
# In tcsh I have to make another executable script
# and get it into $PATH, so...

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

# A more elegant way of doing this loop  is with
# bash brace substitution {1..2}
# also I could save on all those 'set'
# AND DEFINE FUNCTIONS!!!!!!!!
# I'd be very glad to change to bash but
# I'll stick with tcsh because it's been working.

for c in {1..10}
do

  chr=$(printf "%02d\n" $c)
  geno_file=${hm_prefix}${c}${hm_suffix}
  glm_prefix=${out_prefix}_${pheno_name}_${chr}

# It will run if I just give it the --config file
# but here I am showing how to pass the command line arguments to
# the $RCMD script
  # bsub $q_opts Rscript --verbose "$RCMD" \
  #       --pheno_file=$pheno_file \
  #       --geno_file=$geno_dir/$geno_file \
  #       --output_dir=$output_dir \
  #       --glm_prefix=$glm_prefix

  bsub $q_opts ./run_chr_GLM.sh "$geno_dir"/"$geno_file" $glm_prefix

done
```
***The R wrapper script***
`run_chr_GLM.sh`

```{bash}
#!/usr/bin/tcsh

# usage $0  geno_file output_file_prefix

# When running a test with an interactive terminal:
# open the terminal with
## bsub -Is -n 4 -R "span[hosts=1]" -W 10 tcsh
# then run
# Activating conda r_env for reading config
module load conda
conda activate /usr/local/usrapps/maize/sorghum/conda/envs/r_env

set RCMD="$GEA_SCRIPTS"/run_GLM.R

# get help
#  Rscript --verbose "$RCMD" --help

set geno_file=$1
set glm_prefix=$2
set output_dir=`yq '.shared.output_dir | envsubst' $GEA_CONFIG`


if (! -d $output_dir) then
    mkdir $output_dir
else
    echo "$output_dir already exists."
endif


# all other options will be set by the default config file
Rscript --verbose "$RCMD" \
        --geno_file=$geno_file\
        --glm_prefix=$glm_prefix

```

Put `q_run_chr_GLM.sh` and `run_chr_GLM.sh` in the scratch folder `/share/$GROUP/$USER`

```{bash}
# assuming the working directory is $HOME and you are editing the scripts there
cp q_run_chr_GLM.sh run_chr_GLM.sh /share/$GROUP/$USER/
```

go to scratch and run

```{bash}
#on tsch

# Activate conda r_env
conda activate /usr/local/usrapps/maize/sorghum/conda/envs/r_env

# copy the script
cp $GEA_SCRIPTS/batch/*chr*.sh /share/$GROUP/$USER/

# go to scratch
cd /share/$GROUP/$USER/

# add permission to execute
chmod u+x *chr*.sh

#make output dir
mkdirc

# Submit
./q_run_chr_GLM.sh

#check the output
ls geno_out/

# Ran successfully!
```

### Multiple job submission test

For a short test that actually works you can copy the examples from `$GEA_SCRIPTS`

```{bash}
# activate conda r_env environment
conda activate /usr/local/usrapps/maize/sorghum/conda/envs/r_env

# copy the scripts
cp $GEA_SCRIPTS/preprocessing/batch/*test_loop.sh  /share/$GROUP/$USER/

# go to scratch
cd /share/$GROUP/$USER/

# add permission to execute
chmod u+x *test_loop.sh 

# run
./q_test_loop.sh

# wait 30 seconds
sleep 30

#check the output
cat test_output/*

```

## License
[MIT](https://choosealicense.com/licenses/mit/)
