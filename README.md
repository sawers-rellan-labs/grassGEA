# Sorghum and Maize Genome Environment Association (GEA)

We'll start using rTassel for GEA, or environmental (eGWAS)

## For use in the HPC environment

### R config

<<<<<<< HEAD
We need to install the `rTASSEL`, `rJava`  and `configr` libraries 
=======
We need to install the rTASSEL library 
>>>>>>> 70a186652be06527b9787d2d809abc5996b2c12e

Details on `INSTALL.md`.

### Use in HPC cluster

Before using the scripts we must first activate the conda `r_env` environment.

```{bash}
#in tcsh
conda activate /usr/local/usrapps/maize/sorghum/conda/envs/r_env
```

<<<<<<< HEAD
### We will use a `yaml` configuration file for scripts.
=======
### We will use a script confuguration file.
>>>>>>> 70a186652be06527b9787d2d809abc5996b2c12e

A configuration file can be passed to each script via thee `--config` option.
A sample config file is in the extdata folder in the `grassGEA` installation `config.yaml` 

```{bash}
#in tcsh
cp $GEA_CONFIG  ./
```

### Parallelizing Scripts on Chromosomes

We need to setup the memory requirement and time for each chromosome task
and add those requirements to the batch processing scripts.

For submitting chromosome jobs I've decided to use a loop
as discussed in the [HPC batch sripts](https://projects.ncsu.edu/hpc/Documents/lsf_scripts.php) submission page.

Each job will be sent as call to a wrapper for an R script that runs from the command line.

The queue script will have a `q_` suffix

`q_run_chr_GLM.sh`

```{bash}
#!/usr/bin/tcsh

# you could personlize $GEA_CONFIG for local tests
# set ENV $GEA_CONFIG=/my/local/path/to/config.yaml

# Comment for local tests
conda activate /usr/local/usrapps/maize/sorghum/conda/envs/r_env

foreach hapmap (`ls $data_dir`)
    bsub -n 1 -W 15 -o stdout.%J -e stderr.%J "source ./run_chr_GLM.sh $data_dir/$hapmap"
end
```
***The R wrapper script***

```{bash}
#!/usr/bin/env bash

# usage: run_chr_GLM.R hapmap_file phenotytpe_file output_dir

Rcript run_GLM.R --genotype $1   --phenotytpe $2 --output_dir $3

```

## License
[MIT](https://choosealicense.com/licenses/mit/)
