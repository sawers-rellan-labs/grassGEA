#!/usr/bin/env Rscript --verbose

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Exit if no command line arguments given
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cmd_args <- commandArgs(trailingOnly=TRUE)
if (length(cmd_args) == 0){
  stop("\n\nNo argumments provided. Run with --help for options.\n\n")
}


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Loading libraries (this is slow)
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

library(magrittr)
library(optparse)
library(grassGEA)

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Command line options                                                    -----
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# If I read the config first I can show the actual defaults here!!!
default_config <- get_script_config()

option_list <- c(
  optparse::make_option(
    "--pheno_file", default = default_config$pheno_file,
    type = "character",
    help= paste0(
      "Phenotype file named after the trait to analyse.\n\t\t",
      "In Tassel4 format: <Trait> as first coulmn header.\n\t\t",
      "see https://bitbucket.org/a/tassel-5-source/wiki/UserManual/Load/Load\n\t\t",
      "[default %default]")
  ),

  optparse::make_option(
    "--geno_file", default = default_config$geno_file,
    type = "character",
    help= paste0(
      "Genotype, hapmap format, no quotes.\n\t\t",
      "see https://bitbucket.org/a/tassel-5-source/wiki/UserManual/Load/Load\n\t\t",
      "[default %default]")
  ),

  optparse::make_option(
    "--output_dir", default = default_config$output_dir,
    type = "character",
    help= "Output directory for GLM results.\n\t\t[default %default]"),

  optparse::make_option(
    "--km_prefix", default = default_config$km_prefix,
    type = "character",
    help= "Kinship mattrix output prefix.\n\t\t[default '%default']"),

  optparse::make_option(
    "--mds_prefix", default = default_config$mds_prefix,
    type = "character",
    help = paste0( "MDS output prefix.\n\t\t",
          "Principal Components for population structure correction.\n\t\t",
          "[default '%default']")
  ),

  optparse::make_option(
    "--config_file", default = default_config_file(),
    type = "character",
    help = "configuration file, YAML format.\n\t\t[default %default]")

)

usage <-  "%prog [options]"
opt_parser <- OptionParser(
  usage = usage,
  option_list = option_list
)

args <- parse_args2(opt_parser)

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Initializing configuration ----
# How to merge config with opts depending on what are you testing
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


# custom ----
#
# This case is the most common and useful to test custom configuration.
# omitting command line arguments usually when running the code from Rstudio
# while editing the config yaml to test different config values.
#
# custom_file <- "/Volumes/GoogleDrive/My Drive/repos/grassGEA/inst/extdata/hayu_config.yaml"
#
# opts <- init_config(args, mode = 'custom', config_file = custom_file)

# cmd_line ----
#
# Useful to test the script when run from shell using Rscript.
# the main intended use and the typical case when run in HPC.
# command line options  will overide config specs
#

 opts <- init_config(args, mode = 'cmd_line')

# default ----
#
# This case is very rare.
# Testing script with just the default config file no command line input.
# this case will test config.yaml in extdata from the R installation as is.
#
# opts <- init_config(args, mode = 'default')

log_opts(opts)

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Start script                                                              ----
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


# Setting output prefix

opts$time_suffix <- time_suffix()

# Logging
dir.create(opts$output_dir)

log_time()

rTASSEL::startLogger(
  fullPath = opts$output_dir ,
  fileName = name_log( prefix = opts$km_prefix,
                       suffix = opts$time_suffix)
)

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Loading genotype and phenotype data                                       ----
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# I had to use command line TASSEL5 to havee a readable
# hapmap file see sample_kinship_snps.sh

tasGenoHMP <- rTASSEL::readGenotypeTableFromPath(
  path = opts$geno_file
)


# Load into pheno file
tasPheno <- rTASSEL::readPhenotypeFromPath(
  path = opts$pheno_file
)


# Load into rTASSEL `TasselGenotypePhenotype` object
tasGenoPheno <- rTASSEL::readGenotypePhenotype(
  genoPathOrObj = tasGenoHMP,
  phenoPathDFOrObj = tasPheno
)
tasGenoPheno

rTASSEL::getPhenotypeDF(tasGenoPheno)



#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Kinship matrix                                                   ----
# Make a kinship matrix leaving out one chromosome a time
# this  just depends on the input
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#Kinship matrix
tasKin <- kinshipMatrix(tasObj = tasGenoPheno)

opts$km_file <- paste0(opts$km_prefix,".RDS")

saveRDS(tasKin %>% as.matrix(),
        file = file.path(opts$output_dir, opts$km_file)
)

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Distance matrix  and   MDS                                                ----
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#options(java.parameters = "-Xmx10000m")
# PCA requires a lot of memory
# pcaRes <- pca(tasGenoHMP,
#               limitBy ="total_variance",
#               totalVar = 0.3)

tasDist <- distanceMatrix(tasObj = tasGenoPheno)

opts$mds_file <- paste0(opts$mds_prefix,".RDS")

mdsRes <- mds(
  tasDist
  # nAxes = 12
)

saveRDS(mdsRes,
        file = file.path(opts$output_dir, opts$mds_file)
)

log_opts(opts)
log_done()
log_time()

