# HPC installation

## Github repository
```{bash}
git clone https://github.com/faustovrz/grassGEA.git
```


## Conda environment basic setup
```{bash}
conda create --prefix /usr/local/usrapps/maize/sorghum/conda/envs/r_env  -c  conda-forge r-base
```
Added repositories

```{bash}
conda config --add channels conda-forge   
conda config --set channel_priority strict
conda install r-essentials
conda install r-devtools
conda install openjdk
# for yaml config file handling
conda install -c conda-forge yq
```

## Install `rJava`
reconfigured R with the java directory

```{bash}
R CMD javareconf /usr/local/usrapps/maize/sorghum/conda/envs/r_env/jre
conda deactivate 
```

As discussed [here](https://stackoverflow.com/questions/58607146/unable-to-run-a-simple-jni-program-error-message-when-installing-rjava-on-r-3)

I need to find the directory where `libjvm.so` is:

```{bash}
# I know wrong use of find but it works
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

Now I can install rJava from `R` (I did not try from `conda`).
But first activate the conda environment

```{bash}
conda activate /usr/local/usrapps/maize/sorghum/conda/envs/r_env

R
```

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
install.packages('RcppTOML')
devtools::install_github("sawers-rellan-labs/grassGEA")
q()
```

## Add environmental variables

I installed  yq to read the config.yaml file
I will add  `R_ENV` and `GEA_CONFIG`
to the conda r_env environment

```{bash}
conda env config vars set R_ENV="/usr/local/usrapps/maize/sorghum/conda/envs/r_env"
conda env config vars set env GEA_CONFIG="$R_ENV/lib/R/library/grassGEA/extdata/config.yaml"
```

now I can use `yq` to retrieve config values

```{bash}
yq .genotype_folder $GEA_CONFIG
```

***for local tests you should install yq as well***
***and in mac you wontt be using the conda r_env***
***most likely***











