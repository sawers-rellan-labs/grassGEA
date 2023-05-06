# GEMMA
* It fits a univariate linear mixed model (LMM), multivariate linear mixed model (mvLMM) and Bayesian sparse linear mixed model (BSLMM). 
* It also fits HE, REML, and MQS for variance component estimation using either individual-data or GWAS summary statistics. 
* It is very efficient for large scale GWAS
* More info on [Zhou lab](https://www.xzlab.org/software/GEMMAmanual.pdf).


## vcf2gwas
* It is a Python-built API for **GEMMA** for running Genome-wide association studies (GWAS) with only a VCF file and a phenotype file. 
* Dimensionality reduction via PCA or UMAP can be performed on phenotypes / genotypes and used for analysis.
* Figures are publication-ready.
* More info can be found on [Vogt lab](https://github.com/frankvogt/vcf2gwas/blob/main/MANUAL.md).

### Prerequisites
Only [conda](https://conda.io/projects/conda/en/latest/user-guide/install/index.html) is required

### Installation

*vcf2gwas* works on macOS and Linux systems.\
First create and activate a new environment 
```
conda create -n myenv
conda activate myenv
```
*vcf2gwas* package can be installed by:
```
conda install vcf2gwas -c conda-forge -c bioconda -c fvogt257 
```
To run a test analysis, for checking if everything is working.
```
vcf2gwas -v test
```

## USAGE

### Input Files
The following files are required for running the analysis
#### VCF file:
A VCF file containing the SNP data is required for input.\
This can be obtained using TASSEL. Open the **Hapmap** file on TASSEL and *save as* a **VCF** file

#### Phenotype file(s):
The phenotype file should be in a `.csv` format.\
The IDs should be on the first column and phenotype(s) in the correponding column(s).\
NOTE: Missing values are identified as "-9" or "NA". So, change any values with "-9"\
An example of the phenotype file is as follows:
||VL_P|Temp|
|---|---|---|
|IS123|80|26|
|IS456|20|25|
|IS789|0|32|
|PI123|0|43|
|PI456|90|18|

#### Covariate file:
This is **optional**.\
It is formatted in the same way as the phenotype file. 

#### Gene file:
*vcf2gwas* has some GFF files built for some common species (Maize included but not Sorghum). You can also input your own GFF3 formattated gene file.\
The results of the GWAS can be compared using `-gf` / `--genefile` option. 
|Species|Abbreviation|Scientific name|Reference|Source|
|---|---|---|---|---|
|Anopheles|AG|anopheles gambiae|AgamP4.51|[link](http://ftp.ensemblgenomes.org/pub/metazoa/release-51/gff3/anopheles_gambiae/)|
|Arabidopsis|AT|arabidopsis thaliana|TAIR10.51|[link](http://ftp.ensemblgenomes.org/pub/plants/release-51/gff3/arabidopsis_thaliana/)|
|C. elegans|CE|caenorhabditis elegans|WBcel235|[link](http://ftp.ensembl.org/pub/release-104/gff3/caenorhabditis_elegans/)|
|Fruit fly|DM|drosophila melanogaster|BDGP6.32|[link](http://ftp.ensembl.org/pub/release-104/gff3/drosophila_melanogaster/)|
|Zebrafish|DR|danio rerio|GRCz11|[link](http://ftp.ensembl.org/pub/release-104/gff3/danio_rerio/)|
|Chicken|GG|gallus gallus|GRCg6a|[link](http://ftp.ensembl.org/pub/release-104/gff3/gallus_gallus/)|
|Human|HS|homo sapiens|GRCh38.p13|[link](http://ftp.ensembl.org/pub/release-104/gff3/homo_sapiens/)|
|Mouse|MM|mus musculus|GRCm39|[link](http://ftp.ensembl.org/pub/release-104/gff3/mus_musculus/)|
|Rice|OS|oryza sativa|IRGSP-1.0.51|[link](http://ftp.ensemblgenomes.org/pub/plants/release-51/gff3/oryza_sativa/)|
|Rat|RN|rattus norvegicus|Rnor_6.0|[link](http://ftp.ensembl.org/pub/release-104/gff3/rattus_norvegicus/)|
|Yeast|SC|saccharomyces cerevisiae|R64-1-1|[link](http://ftp.ensembl.org/pub/release-104/gff3/saccharomyces_cerevisiae/)|
|Tomato|SL|solanum lycopersicum|SL3.0.51|[link](http://ftp.ensemblgenomes.org/pub/plants/release-51/gff3/solanum_lycopersicum/)|
|Grape|VV|vitis vinifera|12X.51|[link](http://ftp.ensemblgenomes.org/pub/plants/release-51/gff3/vitis_vinifera/)|
|Maize|ZM|zea mays|Zm-B73-REFERENCE-NAM-5.0.51|[link](http://ftp.ensemblgenomes.org/pub/plants/release-51/gff3/zea_mays/)|

#### Relatedness matrix:
*vcf2gwas* will calculate related matrix by default. We can also provide one manually. \
This is done by `-k/--relmatrix` option:
```
vcf2gwas -v [filename] -pf [filename] -p 1 -lmm -k [filename]
```
To use *vcf2gwas* to just calculate a relatedness matrix from the VCF file, run the `-gk` option:

```
vcf2gwas -v [filename] -gk 
```
To calculate the relatedness matrix and perform its eigen-decomposition in the same run, use the `-eigen` option:

```
vcf2gwas -v [filename] -eigen
```

### Running *vcf2gwas*
*vcf2gwas* can be run through the command-line, specifying the required input files. \
An example of a linear mixed model `lmm` for all phenotypes `ap`, using a vcf formatted file `-v` are shown below.
```
vcf2gwas -v example.vcf.gz -pf example.csv -ap -lmm
```
The vcf file can be in a `.gz` format.
If you want to specify certain phenotypes, use the `-p` followed by the column number of the phenotype. A gene file can aslo be abbreviated.
```
vcf2gwas -v example.vcf.gz -pf example.csv -p 1 -lmm -gf ZM
```
#### Some available options
* `-lm` {1,2,3,4}  
Association Tests with a Linear Model.  
optional: specify which frequentist test to use (default: 1)  
1: performs Wald test  
2: performs likelihood ratio test  
3: performs score test  
4: performs all three tests

* `-gk` {1,2}  
Estimate Relatedness Matrix from genotypes.  
optional: specify which relatedness matrix to estimate (default: 1)  
1: calculates the centered relatedness matrix  
2: calculates the standardized relatedness matrix

* `-eigen`  
Perform Eigen-Decomposition of the Relatedness Matrix.

* `-lmm` {1,2,3,4}  
Association Tests with Univariate Linear Mixed Models.  
optional: specify which frequentist test to use (default: 1)  
1: performs Wald test  
2: performs likelihood ratio test  
3: performs score test  
4: performs all three tests  
To perform Association Tests with Multivariate Linear Mixed Models, set '-multi' option

* `-bslmm` {1,2,3}  
Fit a Bayesian Sparse Linear Mixed Model  
optional: specify which model to fit (default: 1)  
1: fits a standard linear BSLMM  
2: fits a ridge regression/GBLUP  
3: fits a probit BSLMM

* `-m` / `--multi`  
performs multivariate linear mixed model analysis with specified phenotypes  
only active in combination with '-lmm' option

* `-w` / `--burn`  
specify burn-in steps when using BSLMM model.  
Default value: 100,000

* `-s` / `--sampling`  
specify sampling steps when using BSLMM model.  
Default value: 1,000,000

* `-smax` / `--snpmax`  
specify maximum value for 'gamma' when using BSLMM model.  
Default value: 300

* `-v` / `--vcf` <filename>  
Specify genotype `.vcf` or `.vcf.gz` file (required).

* `-pf` / `--pfile` <filename>  
Specify phenotype file.

* `-p` / `--pheno` <int>  
Specify phenotypes used for analysis:  
Type the phenotype name  
OR  
'1' selects first phenotype from phenotype file (second column), '2' the second phenotype (third column) and so on.

* `-ap` / `--allphentypes`  
All phenotypes in the phenotype file will be used.

* `-cf` / `--cfile` <filename>  
Type 'PCA' to extract principal components from the `VCF` file  
OR  
Specify covariate file.

* `-c` / `--covar` <int>  
If 'PCA' selected for the `-cf` / `--cfile` option, set the amount of PCs used for the analysis  
Else:  
Specify covariates used for analysis:  
Type the covariate name  
OR  
'1' selects first covariate from covariate file (second column), '2' the second covariate (third column) and so on.

* `-ac` / `--allcovariates`  
All covariates in the covariate file will be used.

* `-chr`/ `--chromosome` <str>  
Specify chromosomes for analysis.  
By default, all chromosomes will be analyzed.  
Input value has to be in the same format as the CHROM value in the VCF file

* `-gf` / `--genefile` <filename>  
Specify gene file.

* `-gt` / `--genethresh` <int>  
Set a gene distance threshold (in bp) when comparing genes to SNPs from GEMMA results.  
Only SNPs with distances below threshold will be considered for comparison of each gene.

* `-k` / `--relmatrix`  
Specify relatedness matrix file.

* `-o`/ `--output`  
Change the output directory.  
Default is the current working directory.

#### Filtering out SNPs
By default, *vcfgwas* will filter out SNPs with a minimum allele frequency of 0.01. This can be change by the `-q/--minaf` option
  ```
  vcf2gwas -v [filename] -pf [filename] -p 1 -lmm -q 0.05
  ```
  
 #### Manhattan plots
 By default, the significance level is 0.05. To change it manually use the following:
  ```
  vcf2gwas -v [filename] -pf [filename] -p 1 -lmm -sv 7
  ```
  The line will now be drawn at *-log10(1e-7)*.  
To disable the line and not label any SNPs, change the value to 0.\
To remove the SNP lables completely, utilize the `-nl/--nolabel` option. 
  

