# Sorghum and Maize Genome Environment Association

We'll start using rTassel for GEA, or eenvironmental (eGWAS)

## For use in the HPC environment

### R config

We need to install the rTASSEL library and add the following line to
`~/.Renviron`

```bash
R_LIBS=/usr/local/usrapps/maize/libs/R
```


### Other libraries


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
