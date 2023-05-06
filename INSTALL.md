Table of Contents
=================

* [HPC installation](#hpc-installation)
   * [Conda environment basic setup](#conda-environment-basic-setup)
   * [Install rJava](#install-rjava)
   * [Install rTASSEL](#install-rtassel)
   * [Install our package grassGEA](#install-our-package-grassgea)
   * [Add environment variables](#add-environment-variables)
   * [yq insallaion](#yq-insallaion)
   
# HPC installation

## Conda environment basic setup
```{sh}
# install R with compatible versions of BLAS/LAPACK
# for matrix algebra
conda create --prefix /usr/local/usrapps/maize/sorghum/conda/envs/r_env\
      -c conda-forge r-base blas lapack
```
Add packages

```{sh}
# Activate r_env
conda activate /usr/local/usrapps/maize/conda/envs/r_env

conda config --add channels conda-forge   
conda config --set channel_priority strict
# install mamba?
# conda install mamba
conda install r-essentials
conda install r-devtools
conda install r-xml
conda install r-raster
conda install r-rgdal
conda install openjdk

```

## Install `rJava`

As discussed [here](https://stackoverflow.com/questions/58607146/unable-to-run-a-simple-jni-program-error-message-when-installing-rjava-on-r-3)

I need to find the directory where `libjvm.so` is:

```{sh}
# I know, wrong use of find but it works:
find /usr/local/usrapps/maize/sorghum/conda/envs/r_env | grep libjvm.so
```

It seems that you need to reset `R_JAVA_LD_LIBRARY_PATH` in the file `R/etc/ldpaths` from the R installation, [according to this post](https://orinanobworld.blogspot.com/2016/12/rjava-gift-that-keeps-on-giving.html) 

```{sh}
# I know, wrong use of find but it works:
find /usr/local/usrapps/maize/sorghum/conda/envs/r_env | grep ldpaths
# /usr/local/usrapps/maize/sorghum/conda/envs/r_env/lib/R/etc/ldpaths #
```
You could edit it by hand but the intended way is giving the path to `R CMD javareconf`.
As stated in the help page, `R CMD javareconf --help`, you can give it a path for `JAVA_LD_LIBRARY_PATH`. 

```{sh}
#from tcsh
R CMD javareconf \
   JAVA_HOME=$CONDA_PREFIX/jre
   JAVA_LD_LIBRARY_PATH=$CONDA_PREFIX/jre/lib/amd64/server
```

This was not enough and I finally had to add the $LD_LIBRARY_PATH to the environment via `conda`
I'll also add some othe useful environment variables for the installation.

## Add environment variables

```{sh}
# in tcsh
conda env config vars set env R_ENV=$CONDA_PREFIX
conda env config vars set env OLD_LD_LIBRARY_PATH=$LD_LIBRARY_PATH
conda env config vars set env LD_LIBRARY_PATH=$CONDA_PREFIX/jre/lib/amd64/server:$LD_LIBRARY_PATH
conda env config vars set env GEA_CONFIG=$CONDA_PREFIX/lib/R/library/grassGEA/extdata/config.yaml
conda env config vars set env GEA_EXTDATA=$CONDA_PREFIX/lib/R/library/grassGEA/extdata
conda env config vars set env GEA_SCRIPTS=$CONDA_PREFIX/lib/R/library/grassGEA/scripts
conda deactivate 

conda activate /usr/local/usrapps/maize/sorghum/conda/envs/r_env

#
# upon activation it throws the following warning:

# WARNING: overwriting environment variables set in the machine
# overwriting variable LD_LIBRARY_PATH

# Let's hope the change in path will be ok
```

Now I can install rJava from `R` (I did try from `conda`,but  it did not work because of that `LD_LIBRARY_PATH` variable).

But first activate the conda environment

```{bash}
conda activate /usr/local/usrapps/maize/sorghum/conda/envs/r_env
R
```

## Install `rTASSEL`

```{r}
# this will install rJava as a dependency

if (!require("devtools")) install.packages("devtools")
 devtools::install_bitbucket(
    repo = "bucklerlab/rTASSEL",
     ref = "master",
    build_vignettes = FALSE
)
# RcppTOML a configr  dependency did not compile using system gcc [4.85]
# this was the whole reson I ended up using a conda environment for R
# install.packages('RcppTOML')
```

## Install our package `grassGEA`

```{r}

devtools::install_github("sawers-rellan-labs/grassGEA")
q()
```


## `yq` installaion

Now I  will install `yq` 4.20.1  to retrieve config values.
The version of  `yq` is critical because the syntax and options change a lot between 2, 3, and 4.

```{sh}
#Go home

cd 
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
yq .geno_dir $GEA_CONFIG
```

***for local tests you should install `yq` 4 as well***

[Homebrew has yq version 4!](https://formulae.brew.sh/formula/yq)

***most likely in mac you won't be using the `conda` `r_env`***








