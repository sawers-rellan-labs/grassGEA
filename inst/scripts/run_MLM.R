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
options(java.parameters = c("-Xmx4g", "-Xms2g"))
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
       "Genotype, diploid hapmap format, no quotes. Full path\n\t\t",
       "see https://bitbucket.org/a/tassel-5-source/wiki/UserManual/Load/Load\n\t\t",
       "[default %default]")
  ),

  optparse::make_option(
    "--kinship_matrix", default = default_config$geno_file,
    type = "character",
    help= paste0(
      "Kinship matrix an R 'matrix' class object in RDS format.\n\t\t",
      "[default %default]")
  ),

  optparse::make_option(
    "--output_dir", default = default_config$output_dir,
    type = "character",
    help= "Output directory for GLM results.\n\t\t[default %default]"),

  optparse::make_option(
    "--mlm_prefix", default = default_config$mlm_prefix,
    type = "character",
    help= "MLM output preffix.\n\t\t[default '%default']"),

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

opts$trait <- tools::file_path_sans_ext(
  basename(opts$pheno_file)
)

current_prefix <- c(mlm_prefix = opts$mlm_prefix)

opts$mlm_prefix <- no_match_append(current_prefix, opts$trait)

opts$time_suffix <- time_suffix()

# Logging
dir.create(opts$output_dir)

log_time()

rTASSEL::startLogger(
  fullPath = opts$output_dir ,
  fileName = name_log( prefix = opts$mlm_prefix,
                       suffix = opts$time_suffix)
  )

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Loading genotype and phenotype data                                       ----
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#Load in hapmap file
tasGenoHMP <- rTASSEL::readGenotypeTableFromPath(
  path = opts$geno_file
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

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Load MDS dimensions, merge with phenotype                                ----
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# # Load into pheno file
# pheno <- rTASSEL::readPhenotypeFromPath(path = opts$pheno_file) %>%
#   rTASSEL::getPhenotypeDF() %>%
#   as.data.frame()

# mds <- readRDS("chr_mds.RRDS")
#
# pheno_mds <- join(pheno,mds)
# col_types <- c("taxa","data", rep("covriate",10))
# tasPhenoMDS <- readPhenotypeFromDataFrame(
#   pheno_mds , "Taxa",
#   attributeTypes = col_types
# )


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



#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#Load Kinship Matrix                                                        ----
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


tasKin <- readRDS(opts$kinship_matrix) %>% asTasselDistanceMatrix()


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Calculate GLM                                                             ----
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

opts$mlm_output_file <- paste0(
  opts$mlm_prefix, "_",
  opts$time_suffix,".RDS"
)

# kinship_MLM <- fit_kinship_MLM(
#   tasObj = tasGenoPheno,
#   trait = opts$trait,
#   kinship = tasKin)

formula <- as.formula(paste(opts$trait,"~ ."))

tasMLM <- rTASSEL::assocModelFitter(
  tasObj  = tasGenoPheno,             # <- our prior TASSEL object
  formula = formula,                 # <- run only sol_VL
  fitMarkers = TRUE,
  kinship = tasKin,                  # <- our prior kinship object
  fastAssociation = FALSE
)


saveRDS(tasMLM, file.path(opts$output_dir, opts$mlm_output_file))

chr_plot <- manhattanPlot(
  assocStats = tasMLM$MLM_Stats,
  trait = opts$trait,
  threshold = 25
)

opts$chr_plot_file <- paste0(
  opts$mlm_prefix, "_",
  "chr_plot.png"
)

# sanity check
ggplot2::ggsave(
  chr_plot,
  file = file.path(opts$output_dir, opts$chr_plot_file),
  device = "png"
)

log_opts(opts)
log_done()
log_time()
