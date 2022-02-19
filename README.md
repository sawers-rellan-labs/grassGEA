# Sorghum and Maize Genome Environment Association (GEA)
==============

We'll start using rTassel for GEA, or environmental (eGWAS)

## For use in the HPC environment 

### R config 
We need to install the `rTASSEL`, `rJava`  and `configr` libraries.
Details on `INSTALL.md`.

### Use in HPC cluster 

Before using the scripts we must first activate the conda `r_env` environment.

```{bash}
#in tcsh
conda activate /usr/local/usrapps/maize/sorghum/conda/envs/r_env
```

### We will use a `yaml` configuration file for scripts 

A sample config file is in the extdata folder in the `grassGEA` installation `config.yaml` 

```{bash}
#in tcsh
cp $GEA_CONFIG  ./
```

## Parallelizing Scripts on Chromosomes 

***Just showing the design it is not currenttly working!***

***For a working example go to next section***

We need to setup the memory requirement and time for each chromosome task
and add those requirements to the batch processing scripts.

For submitting chromosome jobs I've decided to use a loop
as discussed in the [HPC batch sripts](https://projects.ncsu.edu/hpc/Documents/lsf_scripts.php) submission page.

Each job will be sent as call to a wrapper for aR script that runs from the command line.

The queue script will have a `q_` preffix

`q_run_chr_GLM.sh`

```{bash}
#!/usr/bin/tcsh

set out_dir="GLM_output"

mkdir $out_dir

# Comment for local tests
conda activate /usr/local/usrapps/maize/sorghum/conda/envs/r_env

# The yq command will only run if the conda r_env environment is active
# you could personlize $GEA_CONFIG for local tests
# set ENV $GEA_CONFIG=/my/local/path/to/config.yaml

set gt_dir=(yq .genotype_dir $GEA_CONFIG)
set pht_file=(yq .phenonotype_file$GEA_CONFIG)

set q_args="-n 1 -W 15 -o stdout.%J -e stderr.%J"


foreach hapmap (`ls $gt_dir`)
  q_args="$q_args source ./run_chr_GLM.sh $gt_dir/$hapmap $pht_file $out_dir"
  bsub $q_args
end
```
***The R wrapper script***
`run_chr_GLM.sh`

```{bash}
#!/usr/bin/env bash

# usage: run_chr_GLM.R hapmap_file phenotytpe_file output_dir

Rcript run_GLM.R --genotype $1   --phenotytpe $2 --output_dir $3

```


Put `q_run_chr_GLM.sh` and `run_chr_GLM.sh` in the scratch folder `/share/$GROUP/$USER`

```{bash}
# assuming the working directory is $HOME and you are editing the scripts there
cp q_run_chr_GLM.sh run_chr_GLM.sh /share/$GROUP/$USER/
```

go to scratch and run

```{bash}
cd /share/$GROUP/$USER/

chmod u+x  q_run_chr_GLM.sh run_chr_GLM.sh

./q_run_chr_GLM.sh
```

## Multiple job submission test

For a test that actually works you can copy the examples from `$GEA_SCRIPTS`

```{bash}

# copy the scripts
cp $GEA_SCRIPTS/preprocessing/batch/*test_loop.sh  /share/$GROUP/$USER/

# go to scratch
cd /share/$GROUP/$USER/

# add permission to execute
chmod u+x *test_loop.sh 

# run
./q_test_loop.sh
```

## License
[MIT](https://choosealicense.com/licenses/mit/)
