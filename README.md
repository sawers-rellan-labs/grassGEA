# Sorghum and Maize Genom Environment Association

We'll start using rTassel for GEA, or eenvironmental (eGWAS)

## For use in thee HPC environment

### R config

We need to install the rTASSEL library and add the following line to
`~/.Renviron`

```bash
R_LIBS=/usr/local/usrapps/maize/libs/R
```


### Other libraries


### Parallelizing Scripts on Chromosomes

We need to setup the memory requireement for each chromosome task
and add those requirements to the batch processing scripts

```bash
#!/bin/tcsh
#BSUB -n 1
#BSUB -W 120
#BSUB -J mycode
#BSUB -o stdout.%J
#BSUB -e stderr.%J
conda activate /usr/local/usrapps/mygroup/env_mycode
mycode
conda deactivate
```

## License
[MIT](https://choosealicense.com/licenses/mit/)