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
default_config <- configr::read.config(default_config_file())

option_list <- c(optparse::make_option(
                   "--pheno_file", default = default_config$pheno_file,
                   type = "character",
                   help= "Phenotype file named after the trait to analyse, Tassel4 format"),

                optparse::make_option(
                   "--geno_file", default = default_config$geno_file,
                   type = "character",
                   help= "Genotype, hapmap format"),

                optparse::make_option(
                  "--output_dir", default = default_config$output_dir,
                  type = "character",
                  help= "Genotype, hapmap format"),

                optparse::make_option(
                  "--glm_prefix", default = default_config$glm_prefix,
                  type = "character",
                  help= "GLM output preffix"),

                optparse::make_option(
#TODO: (frz) change --config to --config_file you will need to change cconfig.R functions too
                  "--config", default = default_config_file(),
                  type = "character",
                  help = "configuration file, YAML format")

)

usage <-  "%prog [options]"
opt_parser <- OptionParser(
  usage = usage,
  option_list = option_list
)

args <- parse_args2(opt_parser)

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Initializing configuration ----
# I merge it with opts
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# custom ----
#
# This case is the most common and useful to test custom configuration.
# Usually  when running the code from Rstudio
# while editing the config yaml to test different config values.
#
# custom_file <- "/Volumes/GoogleDrive/My Drive/repos/grassGEA/inst/extdata/hayu_config.yaml"
# opts <-  init_config( args = args, mode = "custom", config_file = custom_file)

# cmd_line ----
#
# Useul to test the script when run from shell using Rscript.
# the main intended use and the typical case when run in HPC.
# command line optiions  will overriade config specs
opts <- init_config( args = args, mode = "cmd_line")

# default ----
#
# This case is very rare.
# Testing script with just the default config file no command line input.
# this case will test config.yaml in extdata from the R installation as is.
#
# opts <- init_config( args = args, mode = "default")

print(opts)

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Start script                                                              ----
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

log_time()

dir.create(opts$output_dir)

#Logging file

opts$time_suffix <- time_suffix()



rTASSEL::startLogger(
  fullPath = opts$output_dir ,
  fileName = name_log( prefix = opts$glm_prefix,
                       suffix = opts$time_suffix)
  )

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Loading genotype and phenotype data                                       ----
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#Load in hapmap file
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

#Get genotype data
tasSumExp <- rTASSEL::getSumExpFromGenotypeTable(
  tasObj = tasGenoPheno
)
tasSumExp

SummarizedExperiment::colData(tasSumExp)


#Extract phenotype data
tasExportPhenoDF <- rTASSEL::getPhenotypeDF(
  tasObj = tasGenoPheno
)
tasExportPhenoDF

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#Filtering genotype data                                                    ----
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tasGenoPhenoFilt <- rTASSEL::filterGenotypeTableSites(
  tasObj = tasGenoPheno,
  siteMinCount = 150,
  siteMinAlleleFreq = 0.05,
  siteMaxAlleleFreq = 1.0,
  siteRangeFilterType = "none"
)
tasGenoPhenoFilt
tasGenoPheno

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Calculate GLM                                                             ----
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

trait <- tools::file_path_sans_ext(
  basename(opts$pheno_file)
  )

tasGLM <- simple_GLM(tasObj = tasGenoPheno, trait = trait )

opts$glm_output_file <- paste0(opts$glm_prefix, "_",
                          trait, "_",
                          opts$time_suffix,".RDS")

saveRDS(tasGLM, file.path(opts$output_dir, opts$glm_output_file))

log_time()
log_done()

