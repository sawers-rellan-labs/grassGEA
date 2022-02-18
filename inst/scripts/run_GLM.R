#!/usr/local/bin/Rscript --verbose
library(optparse)
library(grassGEA)
library(magrittr)

cat(as.character(Sys.time()),"\n\n", file = stderr())

# Initialize opts from configuration file

system.file( package = "grassGEA", mustWork = FALSE)

option_list <-c(optparse::make_option(
                 "--phenotype", type = "character", default = "genotype.hmp",
                 help= "Phenotype file, Tassel format",
                 metavar = "character"),
                optparse::make_option(
                 "--genotype", type = "character", default = "genotype.hmp",
                 help= "Genotype, hapmap format",
                 metavar = "character"),
                 optparse::make_option(
                   "--config", type = "character", default = "config.yaml",
                   help = "configuration file",
                   metavar = "character"
                 )
)

usage <-  "%prog [options]"

opt_parser <- OptionParser(
  usage = usage,
  option_list = option_list
)

args <- parse_args2(opt_parser)

# To test local_config
config_file <- "/Volumes/GoogleDrive/My Drive/repos/grassGEA/local_config.yml"
args$options$config <- config_file
opts <- override_opts(args$options)

# to use default config
# opts <- override_config(args$options)

################################################################################

time_suffix <- format(Sys.time(), "%Y%m%d_%H_%M")

log_file <- paste0(opts$glm_log_prefix,"_", time_suffix, ".log")

opts$phenotype

#Logging file
rTASSEL::startLogger(fullPath = "./",
                     fileName = log_file )


#Load in hapmap file
tasGenoHMP <- rTASSEL::readGenotypeTableFromPath(
  path = opts$genotype
)

# Read from phenotype path
pheno_file <- opts$phenotype
pheno_dir  <- opts$phenotype_folder
phenoPath  <- file.path(data_dir,pheno_file)

# Load into pheno file
tasPheno <- rTASSEL::readPhenotypeFromPath(
  path = phenoPath
)


# Load into rTASSEL `TasselGenotypePhenotype` object
tasGenoPheno <- rTASSEL::readGenotypePhenotype(
  genoPathOrObj = tasGenoHMP,
  phenoPathDFOrObj = tasPheno
)

#Get genotype data
tasSumExp <- rTASSEL::getSumExpFromGenotypeTable(
  tasObj = tasGenoPheno
)


 SummarizedExperiment::colData(tasSumExp)


#Extract phenotype data
tasExportPhenoDF <- rTASSEL::getPhenotypeDF(
  tasObj = tasGenoPheno
)

tasExportPhenoDF


#Filtering genotype data
tasGenoPhenoFilt <- rTASSEL::filterGenotypeTableSites(
  tasObj = tasGenoPheno,
  siteMinCount = 150,
  siteMinAlleleFreq = 0.05,
  siteMaxAlleleFreq = 1.0,
  siteRangeFilterType = "none"
)
tasGenoPhenoFilt
tasGenoPheno


#Calculate GLM or MLM (add tasKin to kinship)
tasGLM <- rTASSEL::assocModelFitter(
  tasObj = tasGenoPhenoFilt,             # <- our prior TASSEL object
  formula = VL ~ .,                  # <- only phenotype
  fitMarkers = TRUE,                 # <- set this to TRUE for GLM
  kinship = NULL,
  fastAssociation = FALSE
)




