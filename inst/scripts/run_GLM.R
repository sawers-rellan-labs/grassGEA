#!/usr/bin/env Rscript --verbose

library(magrittr)
library(optparse)
library(grassGEA)


cat(as.character(Sys.time()),"\n\n", file = stderr())

# Set up and document options for current script

option_list <- c(optparse::make_option(
                   "--pheno_file", type = "character", default = "sol_VL.txt",
                   help= "Phenotype file named after the trait to analyse,  Tassel format"),

                optparse::make_option(
                   "--geno_file", type = "character", default = "genotype.hmp",
                   help= "Genotype, hapmap format"),

                optparse::make_option(
                  "--output_dir", type = "character", default = "./",
                  help= "Genotype, hapmap format"),

                optparse::make_option(
                  "--glm_preffix", type = "character", default = "glm",
                  help= "GLM output preffix")

)


usage <-  "%prog [options]"

opt_parser <- OptionParser(
  usage = usage,
  option_list = option_list
)

args <- parse_args2(opt_parser)

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Reading config                                                           ----
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# Use default_config
# if(is.null(args$options$config)){
#   print(paste0("Usiing default config at ", default_config_file()))
# }

# To test local_config
config_file <- "/Volumes/GoogleDrive/My Drive/repos/grassGEA/inst/extdata/hayu_config.yaml"
my_config <- configr::read.config(file = config_file)

opts <- override_opts(
  opts = args$options,
  config = my_config)


# to use command line parameters
# opts <- override_(
#   opts = args$options,
#   config = my_config)


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

