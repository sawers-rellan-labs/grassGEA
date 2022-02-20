# Pipeline on HPC


### `Rscript` submission example

`q_get_help.sh` in `$GEA_SCRIPTS/batch`will invoke an R script
just to print help.

```{R}
#!/bin/tcsh
#BSUB -W 10
#BSUB -n 1
#BSUB -o stdout.%J
#BSUB -e stderr.%J
module load conda
conda activate /usr/local/usrapps/maize/sorghum/conda/envs/r_env

set RCMD="$GEA_SCRIPTS"/preprocessing/make_hapmap_geo_loc.R

# I could no make the Rscript shebang #!usr/bin/Rscript --verbose
# or #!usr/bin/env Rscript --verbose
# to work so I will invoke Rscript directly

Rscript --verbose $RCMD --help
```

```{bash}
#on tsch
# activate conda r_env environment
conda activate /usr/local/usrapps/maize/sorghum/conda/envs/r_env

# copy the script
cp $GEA_SCRIPTS/q_get_help.sh  /share/$GROUP/$USER/q_get_help.sh

# go to scratch
cd /share/$GROUP/$USER/

# add permission to execute
chmod u+x q_get_help.sh

# Submit
bsub < q_get_help.sh

# wait 30 seconds
sleep 30
```


# Pipeline on HPC


### `Rscript` submission example

`q_get_help.sh` in `$GEA_SCRIPTS/batch`will invoke an R script
just to print help.

```{R}
#!/bin/tcsh
#BSUB -W 10
#BSUB -n 1
#BSUB -o stdout.%J
#BSUB -e stderr.%J
module load conda
conda activate /usr/local/usrapps/maize/sorghum/conda/envs/r_env

set RCMD="$GEA_SCRIPTS"/preprocessing/make_hapmap_geo_loc.R

# I could no make the Rscript shebang #!usr/bin/Rscript --verbose
# or #!usr/bin/env Rscript --verbose
# to work so I will invoke Rscript directly

Rscript --verbose $RCMD --help
```

```{bash}
#on tsch
# activate conda r_env environment
conda activate /usr/local/usrapps/maize/sorghum/conda/envs/r_env

# copy the script
cp $GEA_SCRIPTS/q_get_help.sh  /share/$GROUP/$USER/q_get_help.sh

# go to scratch
cd /share/$GROUP/$USER/

# add permission to execute
chmod u+x q_get_help.sh

# Submit
bsub < q_get_help.sh

# wait 30 seconds
sleep 30
```
