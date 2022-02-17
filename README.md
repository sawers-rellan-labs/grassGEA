# Sorghum and Maize Genome Environment Association

We'll start using rTassel for GEA, or eenvironmental (eGWAS)

## For use in the HPC environment

### R config

We need to install the rTASSEL library and add the following line to
`~/.Renviron`

```bash
R_LIBS=/usr/local/usrapps/maize/libs/R
```
Bad idea. This installation used the system gcc (4.85). Could not compile  RcppTOML,a dependency for `optparse`.
Failed miserably!

I deleted this line from `~/.Renviron` proceeded to run r from a conda environment.
Installation was not smooth but at the end it worked.
Details on `INSTALL.md`.

### `r_env` activation

Before using the scripts we must first activate the conda `r_env` environment.

```
conda activate /usr/local/usrapps/maize/sorghum/conda/envs/r_env
```

### We well use a script confuguration file.

A configuration file can be passed to each script via thee `--config` option.
A sample config file is in the extdata folder in the grassGEA installation `config.yaml` 

```{bash}
#in tcsh
set R_ENV_DIR="/usr/local/usrapps/maize/sorghum/conda/envs/r_env"
set GEAR_EXT_DATA = "$R_ENV_DIR/lib/R/library/grassGEA/extdata"
cp "$GEAR_EXT_DATA/config.yaml"  ./
```

### Parallelizing Scripts on Chromosomes

We need to setup the memory requirement for each chromosome task
and add those requirements to the batch processing scripts

each  job script needs to call on an R script that runs from the command line

```bash
#!/bin/tcsh
#BSUB -n 1
#BSUB -W 120
#BSUB -J mycode
#BSUB -o stdout.%J
#BSUB -e stderr.%J
run_GML -genotype chr_genotype_file -phenotype phenotpe_file
run_MM -genotype chr_genotype_file -phenotype phenotpe_file -kinship kinship_file
```

## License
[MIT](https://choosealicense.com/licenses/mit/)
