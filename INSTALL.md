Table of Contents
=================


* [HPC installation](#hpc-installation)
   * [Conda environment basic setup](#conda-environment-basic-setup)
   * [Install rJava](#install-rjava)
   * [Install rTASSEL](#install-rtassel)
   * [Install our package grassGEA](#install-our-package-grassgea)
   * [Add environmental variables](#add-environmental-variables)
   * [yq insallaion](#yq-insallaion)
   
# HPC installation

## Conda environment basic setup
```{bash}
conda create --prefix /usr/local/usrapps/maize/sorghum/conda/envs/r_env  -c  conda-forge r-base
```
Add packages

```{bash}
conda config --add channels conda-forge   
conda config --set channel_priority strict
conda install r-essentials
conda install r-devtools
conda install openjdk
```

## Install `rJava`
reconfigured `R` with the `java` directory

```{bash}
R CMD javareconf /usr/local/usrapps/maize/sorghum/conda/envs/r_env/jre
conda deactivate 
```

As discussed [here](https://stackoverflow.com/questions/58607146/unable-to-run-a-simple-jni-program-error-message-when-installing-rjava-on-r-3)

I need to find the directory where `libjvm.so` is:

```{bash}
# I know, wrong use of find but it works:
find /usr/local/usrapps/maize/sorghum/conda/envs/r_env | grep libjvm.so
```
And add it to the path. Surprisingly, `conda` did the trick neatly!!!

```{bash}
conda env config vars set LD_LIBRARY_PATH="/usr/local/usrapps/maize/sorghum/conda/envs/r_env/jre/lib/amd64/server:$LD_LIBRARY_PATH"

# upon activation it throws this warning:

# WARNING: overwriting environment variables set in the machine
# overwriting variable LD_LIBRARY_PATH

# I think this change in the search path will be OK 
```

Now I can install rJava from `R` (I did try from `conda`, it did not work).

But first activate the conda environment

```{bash}
conda activate /usr/local/usrapps/maize/sorghum/conda/envs/r_env

R
```

Now from `R` console
```{r}
install.packages("rJava")
```

## Install `rTASSEL`

```{r}
if (!require("devtools")) install.packages("devtools")
 devtools::install_bitbucket(
    repo = "bucklerlab/rTASSEL",
     ref = "master",
    build_vignettes = FALSE
)
```

## Install our package `grassGEA`

```{r}
# RcppTOML a configr  dependency did not compile using system gcc [4.85]
# this was the whole reson I ended up using a conda environment for R
# install.packages('RcppTOML')

devtools::install_github("sawers-rellan-labs/grassGEA")
q()
```

## Add environmental variables

I installed  `yq` 2.13.0 to read the config.yaml file
I will add  `R_ENV` and `GEA_CONFIG`
to the conda `r_env` environment

```{bash}
# in tcsh
conda env config vars set R_ENV="/usr/local/usrapps/maize/sorghum/conda/envs/r_env"
conda env config vars set env GEA_CONFIG="$R_ENV/lib/R/library/grassGEA/extdata/config.yaml"
conda env config vars set env GEA_SCRIPTS="$R_ENV/lib/R/library/grassGEA/scripts"
```

## `yq` insallaion

Now I  will install `yq` 4.20.1  to retrieve config values.
The version of  `yq` is critical because the syntax and options change a lot between 2, 3, and 4.

```{bash}
mkdir yq; cd yq
wget https://github.com/mikefarah/yq/releases/download/v4.20.1/yq_linux_386.tar.gz
tar -zxvf yq_linux_386.tar.gz
mv yq_linux_386 $R_ENV/bin
ln -s $R_ENV/bin/yq_linux_386 $R_ENV/bin/yq
chmod a+x $R_ENV/bin/yq $R_ENV/bin/yq_linux_386
conda deactivate
conda activate /usr/local/usrapps/maize/sorghum/conda/envs/r_env
```

```{bash}
yq --version
# yq (https://github.com/mikefarah/yq/) version 4.20.1
yq .genotype_folder $GEA_CONFIG
```

***for local tests you should install `yq` 4 as well***
[Homebrew has yq version 4!](https://formulae.brew.sh/formula/yq)
So choose wisely.
***most likely in mac you won't be using the `conda` `r_env`***












