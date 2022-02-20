# Pipeline on HPC


### `Rscript` submission example

I will submit a job to test that a `grassGEA` script is running through LSF.

The following is the script `q_get_help.sh` in `$GEA_SCRIPTS/batch`.

The job will just print script usage and help.

```{bash}
#!/bin/tcsh
#BSUB -W 10
#BSUB -n 1
#BSUB -o stdout.%J
#BSUB -e stderr.%J
module load conda
conda activate /usr/local/usrapps/maize/sorghum/conda/envs/r_env

set RCMD="$GEA_SCRIPTS"/preprocessing/make_hapmap_geo_loc.R

# I could not get the Rscript shebang to work. 
# Neither #!usr/bin/Rscript --verbose
# Nor     #!usr/bin/env Rscript --verbose
# So I will invoke Rscript directly

Rscript --verbose $RCMD --help
```

This time I will submit this job as a *redirection to `bsub`*.
Previously, in [the mutiple jobs test](https://github.com/sawers-rellan-labs/grassGEA#multiple-job-submission-test) of the `README.md`, I used a loop to build several `bsub` commands and send them in the background: `bsub $opts $CMD &`.
Now I'll redirect the code, `bsub < q_get_help.sh`, and `bsub` will take the options, like wall time `-W 10`, from the lines following the shebang.


```{bash}
#on tsch

# copy the script
cp $GEA_SCRIPTS/q_get_help.sh  /share/$GROUP/$USER/

# go to scratch
cd /share/$GROUP/$USER/

# add permission to execute
chmod u+x q_get_help.sh

# Submit
bsub < q_get_help.sh

# wait 30 seconds
sleep 30
```

## HPC `yaml` configuration file. 

I use the `yaml` format because I plan to add documentation on each file, like the sources and versions, as attributes in the `yaml` tree, [see this config file](https://github.com/sawers-rellan-labs/pglipid/blob/master/inst/config.yaml) for the lipid metabolic pathway analysis as an example. 
For now it's  just a commented `key: value` file similar to `json`.

```{json}
# Old config -------------------------------------------------
# genotype_folder:  /rsstu/users/r/rrellan/sara/SorghumGEA/data/Lasky2015/snpsLaskySciAdv_dryad
# batch_test_folder: $GEA_EXTDATA/batch_test

# General -------------------------------------------------
config: $GEA_EXTDATA/config_hpc.yaml
geno_dir: /rsstu/users/r/rrellan/sara/SorghumGEA/data/Lasky2015/snpsLaskySciAdv_dryad
pheno_dir: /rsstu/users/r/rrellan/sara/SorghumGEA/data/soilP
output_dir: GEA_ouput

# very low P solubility probabilty table TASSEL4 format
pheno_file: GEA_ouput/sol_VL.tassel
# Sorghum bicolor chromosome 10
geno_file:  /rsstu/users/r/rrellan/sara/SorghumGEA/data/Lasky2015/snpsLaskySciAdv_dryad/sb_snpsDryad_sept2013_filter.c10.imp.hmp.txt

# make_hapmap_geo_loc.R -----------------------------------
id_map: /rsstu/users/r/rrellan/sara/SorghumGEA/data/Lasky2015/hapmap_ids.txt
geo_loc: /rsstu/users/r/rrellan/sara/SorghumGEA/data/Lasky2015/geo_loc.csv
hapmap_geo_loc: GEA_ouput/hapmap_geo_loc.tassel # a copy was made to

# make_phenotype_table.R -----------------------------------
# very low P solubility probabilty raster
tif: /rsstu/users/r/rrellan/sara/SorghumGEA/data/soilP/sol_VL.tif

# run_GLM.R ------------------------------------------------
glm_prefix: glm

# run_MM.R -------------------------------------------------
mm_prefix: mm
```


## Matching passport data, i.e. germplasm geolocations,  to genotypes in hapmap files. 

There are a series of steps I took to obtain `id_map: hapmap_ids.txt` from
the Lasky2015 suplementary materials. Those shell scripts are in the folder
`preprocessing` and need documentation. The end product is the `hapmap_ids.txt`.
Then we matched them to the passport data in other table Lasky2015 suplementary materials that we store as `geo_loc: geo_loc.csv`.

### Making `hapmpap_geo_loc.tassel` 

The output of the following script will be `hapmpap_geo_loc.tassel` in the `output_dir: GEA_ouput` folder.

```{bash}
#!/bin/tcsh
#BSUB -W 10
#BSUB -n 1
#BSUB -o stdout.%J
#BSUB -e stderr.%J
module load conda
conda activate /usr/local/usrapps/maize/sorghum/conda/envs/r_env

# I'll send every thing as is stored in the config

# Quotes are to make it also compatible  with the blank space
# in the Google Drive "My Drive" folder mounted in my mac
# Quotes in declaration, quotes on invocation
set RCMD="$GEA_SCRIPTS"/preprocessing/make_hapmap_geo_loc.R

set geo_loc=`yq '.geo_loc | envsubst' $GEA_CONFIG`

set id_map=`yq '.id_map | envsubst' $GEA_CONFIG`

set hapmap_geo_loc=`yq '.hapmap_geo_loc| envsubst' $GEA_CONFIG`

# Probably it will also run if I just give it the --config file
# but here I am showing how to pass the command line arguments to
# the $RCMD script  
Rscript --verbose "$RCMD" \
        --config=$GEA_CONFIG \
        --geo_loc=$geo_loc \
        --id_map=$id_map \
        --hapmap_geo_loc=$hapmap_geo_loc


# if the shebang worked it would be like thiis:

# "$RCMD" --config=$GEA_CONFIG \
#         --geo_loc=$geo_loc \
#         --id_map=$id_map \
#         --hapmap_geo_loc=$hapmap_geo_loc

```
Now I will send it as a job in the HPC cluster.

```{bash}
#on tsch

mkdir GEA_ouput

# copy the script
cp $GEA_SCRIPTS/preprocessing/batch/q_make_hapmap_geo_loc.sh  /share/$GROUP/$USER/

# go to scratch
cd /share/$GROUP/$USER/

# add permission to execute
chmod u+x q_make_hapmap_geo_loc.sh

# Submit
bsub < q_make_hapmap_geo_loc.sh

# wait 30 seconds
sleep 30

```


