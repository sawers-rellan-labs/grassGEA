Table of Contents
=================

* [Pipeline on HPC](#pipeline-on-hpc)
   * [Rscript submission example](#rscript-submission-example)
   * [HPC yaml configuration file.](#hpc-yaml-configuration-file)
   * [Matching geolocations to genotypes in hapmap files.](#matching-geolocations-to-genotypes-in-hapmap-files)
      * [Making hapmpap_geo_loc.tassel](#making-hapmpap_geo_loctassel)
   * [Making phenotype table](#making-phenotype-table)
   * [Run GLM.](#run-glm)
   * [Make LOCO genotype files for kinship matrix.](#make-loco-genotype-files-for-kinship-matrix)
   * [Make kinship matrix for mixed model.](#make-kinship-matrix-for-mixed-model)
   * [Run MM.](#run-mm)
   
# Pipeline on HPC


## `Rscript` submission example

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
# As inputs and outputs of each script may clash
# (you don't want to ovewrite the the hardly won results of previous scripts)
# I will separate scripts into different branches of the yaml tree
# then the configuration at the start of each script
# will read it's own options and the shared/general options
# this way I have a record of the deafault values at each step
# In any case the output is probably better called  output
# at every step no matter the script. This mitigates the risk of over writing.
shared:
  config_file: $GEA_CONFIG
  pheno_dir: /rsstu/users/r/rrellan/sara/SorghumGEA/data/Lasky2015/traits
  output_dir: gea_out
  batch_test_dir: $GEA_EXTDATA/batch_test
  # Sorghum bicolor chromosome 10
  geno_test_file: /rsstu/users/r/rrellan/sara/SorghumGEA/data/Lasky2015/sb_snpsDryad_sept2013_filter.c10.imp.hmp.txt

make_hapmap_geo_loc:
  id_map: /rsstu/users/r/rrellan/sara/SorghumGEA/data/Lasky2015/hapmap_ids.txt
  geo_loc: /rsstu/users/r/rrellan/sara/SorghumGEA/data/Lasky2015/geo_loc.csv
  hapmap_geo_loc: gea_out/hapmap_geo_loc.tassel

make_phenotype_table:
  # probability of very low  P solubility raster
  raster_file: /rsstu/users/r/rrellan/sara/SorghumGEA/data/soilP/sol_VL.tif
  #probabilty of very low P solubility table TASSEL4 format
  pheno_file: gea_out/sol_VL.tassel

run_GLM:
  glm_prefix: glm
# here we have moved the file to a more permanent destination
  pheno_file: /rsstu/users/r/rrellan/sara/SorghumGEA/data/Lasky2015/traits/sol_VL.tassel
  geno_dir:  /rsstu/users/r/rrellan/sara/SorghumGEA/data/Lasky2015/filtered/

make_kinship_matrix:
  km_prefix: km
  geno_dir:  /rsstu/users/r/rrellan/sara/SorghumGEA/data/Lasky2015/kinship_sample/
  mds_prefix: mds
  pheno_file: /rsstu/users/r/rrellan/sara/SorghumGEA/data/Lasky2015/traits/sol_VL.tassel
  geno_file:  /rsstu/users/r/rrellan/sara/SorghumGEA/data/Lasky2015/kinship_sample/loco_chr_1.hmp.txt

run_MM:
  mm_prefix: mm
  # here we have moved the file to a more permanent destination
  pheno_file: /rsstu/users/r/rrellan/sara/SorghumGEA/data/Lasky2015/traits/sol_VL.tassel
  geno_dir:  /rsstu/users/r/rrellan/sara/SorghumGEA/data/Lasky2015/filtered/

plot_manhattan:
  # here we have moved the file to a more permanent destination
  trait: sol_VL
  rds_dir: /rsstu/users/r/rrellan/sara/SorghumGEA/data/Lasky2015/traits/sol_VL.tassel
  png_dir: /rsstu/users/r/rrellan/sara/SorghumGEA/results
```

## Matching geolocations to genotypes in hapmap files. 

There are a series of steps I took to obtain `id_map: hapmap_ids.txt` from
the Lasky2015 suplementary materials. Those shell scripts are in the folder
`preprocessing` and need documentation. The end product is the `hapmap_ids.txt`.
Then we matched them to the passport data in other table Lasky2015 suplementary materials that we store as `geo_loc: geo_loc.csv`.

### Making `hapmpap_geo_loc.tassel` 

The output of the following script will be `hapmpap_geo_loc.tassel` in the `output_dir: gea_out` folder.


```{bash}
#!/bin/tcsh
#BSUB -W 10
#BSUB -n 1
#BSUB -o stdout.%J
#BSUB -e stderr.%J
module load conda
conda activate /usr/local/usrapps/maize/sorghum/conda/envs/r_env

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

# if the shebang worked it would be like this:

# "$RCMD" --config=$GEA_CONFIG \
#         --geo_loc=$geo_loc \
#         --id_map=$id_map \
#         --hapmap_geo_loc=$hapmap_geo_loc

```

Now I will send it as a job to the HPC cluster.

```{sh}
#on tcsh

# copy the script
cp $GEA_SCRIPTS/preprocessing/batch/q_make_hapmap_geo_loc.sh  /share/$GROUP/$USER/

# go to scratch
cd /share/$GROUP/$USER/

# add permission to execute
chmod u+x q_make_hapmap_geo_loc.sh

# make output dir
mkdir gea_out

# Submit
bsub < q_make_hapmap_geo_loc.sh

# wait 30 seconds
sleep 30

#check the output
ls gea_out/
# hapmap_geo_loc.tassel  lat.tassel  lon.tassel
# Ran successfully!

```

## Making phenotype table
I decided to make a phenotype table for each environmental trait.
We'll start with only one. 
The script will take the tif file name without the extension and usefor the trait column name in the Tassel output file.

Contents of `q_make_phenotype_table.sh`
```{sh}
#!/bin/tcsh
#BSUB -W 10
#BSUB -n 1
#BSUB -o stdout.%J
#BSUB -e stderr.%J
module load conda
conda activate /usr/local/usrapps/maize/sorghum/conda/envs/r_env

# Quotes are to make it also compatible  with the blank space
# in the Google Drive "My Drive" folder mounted in my mac.
# Quotes in declaration, quotes on invocation
set RCMD="$GEA_SCRIPTS"/preprocessing/make_phenotype_table.R

set hapmap_geo_loc=`yq '.hapmap_geo_loc | envsubst' $GEA_CONFIG`

set raster_file=`yq '.raster_file | envsubst' $GEA_CONFIG`

set output_dir=`yq '.output_dir | envsubst' $GEA_CONFIG`


# this script needs to be transformed into a cycle for many phenotypes
Rscript --verbose "$RCMD" \
        --config=$GEA_CONFIG \
        --hapmap_geo_loc=$hapmap_geo_loc \
        --raster_file=$raster_file \
        --output_dir=$output_dir


# if the shebang worked it would be like this:

# "$RCMD" --config=$GEA_CONFIG \
#         --geo_loc=$geo_loc \
#         --id_map=$id_map \
#         --hapmap_geo_loc=$hapmap_geo_loc
```


Submiting to HPC

```{bash}
# on tcsh
# activate the r_env
# module load conda
conda activate /usr/local/usrapps/maize/sorghum/conda/envs/r_env

# copy the script
cp $GEA_SCRIPTS/preprocessing/batch/q_make_phenotype_table.sh /share/$GROUP/$USER/

# go to scratch
cd /share/$GROUP/$USER/

# add permission to execute
chmod u+x q_make_phenotype_table.sh

# make output dir
mkdir gea_out

# Submit
bsub < q_make_phenotype_table.sh

# wait 30 seconds
sleep 30

#check the output
ls gea_out/
# hapmap_geo_loc.tassel  lat.tassel  lon.tassel
# Ran successfully!

```


## Run GLM. 

Wrapper for the `run_GML.R` script in `tcsh`.


```{sh}
#!/usr/bin/tcsh

# When running a test with an interactive terminal:
# open the terminal with
## bsub -Is -n 4 -R "span[hosts=1]" -W 10 tcsh
# then run
# Activating conda r_env for reading config
# module load conda
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


Sumbission (queue) script: `q_run_chr_GLM.sh`

I usedd `bash` because it allowed me to make a function to get the configuration setting from the `YAML` file.
`tcsh` has no functions
Activate the conda `r_env` then run it.

```{sh}
#!/usr/bin/env bash

# Activating conda r_env for config reading

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

# Looping over the chromosome numbers for submitting the jobs

for c in {1..10}
do

  chr=$(printf "%02d\n" $c)
  geno_file=${hm_prefix}${c}${hm_suffix}
  glm_prefix=${out_prefix}_${pheno_name}_${chr}

  bsub $q_opts ./run_chr_GLM.sh "$geno_dir"/"$geno_file" $glm_prefix

done

```
Now I will send it as a job to the HPC cluster.


```{sh}
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



Cleanup

```{sh}
# this can be replaced with better folder naming in config file and scripts

output_dir=gea_out

mkdir $output_dir/log
mv $output_dir/*.log  $output_dir/log/

mkdir $output_dir/rds
mv $output_dir/*.RDS $output_dir/rds/

mkdir $output_dir/plot
mv $output_dir/*.png  $output_dir/plot/

mkdir $output_dir/stdout

mkdir $output_dir/stdout
mv stdout* $output_dir/stdout

mkdir $output_dir/stderr
mv stderr* $output_dir/stderr
```
## Make LOCO genotype files for kinship matrix. 

I will build a kinship matrix leaving each chromosome out for the mixed model.
First I will take a random sample of 10000 SNPs.
I need to set a random seed for reproducibility in `power_shuff.py`

`sample_kinship_snps.sh`

```{sh}
#!/usr/bin/tcsh
conda activate /usr/local/usrapps/maize/sorghum/conda/envs/r_env

echo "Usage: $0 -n snp_sample_size"

# I installed  powershuf.py to the $PATH location:
# /usr/local/usrapps/maize/sorghum/conda/envs/r_env/bin
# I need to set the random number seed in the powershuf.py script
# for reproducible results.
# Branch from gitlabs?
# https://gitlab.com/aapjeisbaas/shuf

# Yes I filtered the genotypes with the TASSEL5 java executable.
# The filtering step should go to preprocessing.

set geno_dir="/rsstu/users/r/rrellan/sara/SorghumGEA/data/Lasky2015/filtered"


# merge all chromosomes ~2GB fiile!
echo "Merging genotype files"
tail -n +2 $geno_dir/*.hmp.txt > tmp/sorghum/markers.txt

# Take the random sample, sort by chromosome and position
echo "sampling $1 random SNPs with powershuf.py."
echo "from: $geno_dir"

powershuf.py -n $1 --file tmp/sorghum/markers.txt > tmp/kinship_sample.txt

# Add hapmap header
head -n 1 $geno_dir/Lasky2015_c01_001.hmp.txt > tmp/kinship_sample_sorted.txt

echo "Sorting sample..."
sort -k3,3n -k4,4n tmp/kinship_sample.txt >> tmp/kinship_sample_sorted.txt

# The TASSEL java library of rTASSEL has some kind of bug
# that does not allow it to read this random sample file
# so I had to use command line TASSEL5 to make it readable
# Because I sorted the file I think it might be the line breaks \n\r?

echo "Converting to diploid hapmap..."

set TASSEL5=/usr/local/usrapps/maize/tassel-5-standalone/run_pipeline.pl

$TASSEL5 -h tmp/kinship_sample_sorted.txt\
    -export all_chr_10K \
    -exportType HapmapDiploid

# Make histogram

echo "Marker frequency per chromosome"
tail -n + 2 all_chr_10K.hmp.txt \
  | cut -f 3 \
  | sort -n -k1,1 \
  | uniq -c \
  | perl -pe "s/^ +//; s/ +/\t/" \
  | awk ' { t = $1; $1 = $2; $2 = t; print; } ' \
  | perl -lane 'print $F[0], "\t", $F[1], "\t", "=" x ($F[1] / 25)'

#TODO:(frz) set the random number seed in the powershuf.py script #
#^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #
```


```{sh}
bsub -n1 -W20 -o stdout.%J  -e stderr.%J ./sample_kinship_snps.sh 10000
```

Then I grep out each chromosome.

`make_loco_sample.sh`

```{sh}
#!/usr/bin/env bash
# this way of making these genotype files is very simple
# another way might be using TASSEL

out_dir=kinship_sample

mkdir $out_dir

for c in {1..10}
do
# chr=$(printf "%02d" $c)
 grep -v "^S${c}_" all_chr_10K.hmp.txt > $out_dir/loco_chr_${c}.hmp.txt
done
mv all_chr_10K.hmp.txt $out_dir
```

```{sh}
# copy the script
cp $GEA_SCRIPTS/preprocessing/batch/make_loco_sample.sh  /share/$GROUP/$USER/

# go to scratch
cd /share/$GROUP/$USER/

# add permission to execute
chmod u+x make_loco_sample.sh

bsub -n1 -W20 -o stdout.%J  -e stderr.%J ./make_loco_sample.sh
```

Copying to a more permanent location:

```{sh}
# in tcsh

set data_dir=/rsstu/users/r/rrellan/sara/SorghumGEA/data/Lasky2015/

echo "Copying to a more permanent location: "
echo $data_dir/kinship_sample

cp -r kinship_sample   $data_dir/kinship_sample

head $data_dir/kinship_sample/all_chr_10K.hmp.txt | cut -f1-15
```

## Make kinship matrix for mixed model. 

Now having the LOCO genotype matrices, I can calculate the kinship matrices.

Wrapper for the `make_kinship_matrix.R` script in `tcsh`.

```{sh}
#!/usr/bin/tcsh

# When running a test with an interactive terminal:
# open the terminal with
## bsub -Is -n 4 -R "span[hosts=1]" -W 10 tcsh
# then run
# Activating conda r_env for reading config
conda activate /usr/local/usrapps/maize/sorghum/conda/envs/r_env

set RCMD="$GEA_SCRIPTS"/make_kinship_matrix.R

# get help
#  Rscript --verbose "$RCMD" --help

set pheno_file=$1
set geno_file=$2
set km_prefix=$3
set mds_prefix=$4
set output_dir=`yq '.shared.output_dir | envsubst' $GEA_CONFIG`


if (! -d $output_dir) then
    mkdir $output_dir
else
    echo "$output_dir already exists."
endif


# all other options will be set by the default config file
Rscript --verbose "$RCMD" \
        --pheno_file=$pheno_file\
        --geno_file=$geno_file\
        --km_prefix=$km_prefix\
        --mds_prefix=$mds_prefix

```

Sumbission (queue) script: `q_make_kinship_matrix.sh`

```{sh}
#!/usr/bin/env bash

# Activating conda r_env for config reading
conda activate /usr/local/usrapps/maize/sorghum/conda/envs/r_env

# setting up options from config
# from bash I can set up a read_config function inside the script
# In tcsh I have to make another executable script
# and get it into $PATH, so meh...

script="make_kinship_matrix"

get_config ( ) {
  opt=$1

  value=$(script=$script yq '.shared, .[env(script)]' $GEA_CONFIG | opt=$opt yq '.[env(opt)]')

  echo "$value"
}

# rTASSEL calculates the kinship matrix from a GenoPheno Object so
# we need a phenotype file :/

pheno_file=$(get_config pheno_file)

# we are gonna read from the 10K LOCO genotype hapmap files
geno_dir=$(get_config geno_dir)

output_dir=$(get_config output_dir)


# I'll wait for each process 60 min
q_opts="-n 1 -W 60 -o stdout.%J -e stderr.%J"

# Working from the kinship sample

hm_prefix="loco_chr_"
hm_suffix=".hmp.txt"

if [ ! -d "$output_dir" ]
then
    mkdir "$output_dir"
else
    echo "$output_dir already exists."
fi

# Looping over chromosome number

for c in {1..10}
do
# change to padded left 0s
  chr=$(printf "%02d\n" $c)
  geno_file="$geno_dir"/${hm_prefix}${c}${hm_suffix}

  km_prefix=$(get_config km_prefix)
  mds_prefix=$(get_config mds_prefix)

  km_prefix=${km_prefix}_loco_${chr}
  mds_prefix=${mds_prefix}_loco_${chr}

#Submit the job
  bsub $q_opts ./make_kinship_matrix.sh \
                 $pheno_file \
                 $geno_file \
                 $km_prefix \
                 $mds_prefix
done

```

```{sh}
# on tcsh
# activate the r_env
# module load conda
conda activate /usr/local/usrapps/maize/sorghum/conda/envs/r_env

# copy the script
cp $GEA_SCRIPTS/batch/*make_kinship_matrix.sh  /share/$GROUP/$USER/

# go to scratch
cd /share/$GROUP/$USER/

# add permission to execute
chmod u+x *make_kinship_matrix.sh

./q_make_loco_sample.sh
```

Cleanup

```{sh}
mv gea_out kinship

output_dir=kinship

mkdir $output_dir/log
mv $output_dir/*.log  $output_dir/log/

mkdir $output_dir/km
mv $output_dir/km*.RDS $output_dir/km/

mkdir $output_dir/mds
mv $output_dir/mds*.RDS $output_dir/mds/

mkdir $output_dir/stdout

mkdir $output_dir/stdout
mv stdout* $output_dir/stdout

mkdir $output_dir/stderr
mv stderr* $output_dir/stderr


set results_dir=/rsstu/users/r/rrellan/sara/SorghumGEA/results/

cp -r  $output_dir $results_dir/

head $kinship_dir/kinship_sample_10K.hapmap.txt | cut -f1-15
```

## Run MM. 
