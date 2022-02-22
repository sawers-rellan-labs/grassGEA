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

library(grassGEA)
library(dplyr)
library(raster, include.only = c("raster", "extract"))

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Command line options                                                    -----
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# If I read the config first I can show the actual defaults here!!!
default_config <- configr::read.config(default_config_file())

option_list <-c(
  optparse::make_option(
    "--hapmap_geo_loc", default = default_config$hapmap_geo_loc,
    type = "character",
    help = paste0(
      "Script input, geolocations of hapmap ids, TASSEL4 format, full file path.\n",
      "[default %default]")
    ),

  optparse::make_option(
    "--raster_file", default = default_config$raster_file,
    type = "character",
    help = paste0(
      "Geotiff raster with environmental data,",
      " file base name will be used as trait column and output file name",
      " but with .tassel extension instead.",
      "Full file path.\n",
      "[default %default]")
    ),

  optparse::make_option(
    "--output_dir", default = default_config$output_dir,
    type = "character",
    help = "output directory file path\n[default %default]"),

  optparse::make_option(
    "--pheno_file", default = "output_dir/basename.tassel", # this is for a trick
    type = "character",
    help = paste0(
      "phenotype file output, TASSEL4 format, full file path.\n",
      "[default ", default_config$output_dir,"]")
    ),

  optparse::make_option(
    "--config", default = default_config_file(),
    type = "character",
    help = "configuration file, YAML format.\n[default %default]")
)

usage <-  "%prog [options]"

opt_parser <- OptionParser(
  usage = usage,
  option_list = option_list
)

args <- parse_args2(opt_parser)
args$options
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Initializing configuration ----
# Merging config file with command line options
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# custom ----
#
# This case is the most common and useful to test custom configuration.
# Usually  when running the code from Rstudio
# while editing the config yaml  to test different config values.
#
# custom_file <- "/Volumes/GoogleDrive/My Drive/repos/grassGEA/inst/extdata/hayu_config.yaml"
# opts <-  init_config( args = args, mode = "custom", config_file = custom_file)

# cmd_line ----
#
# Useul to test the script when run from shell using Rscript.
# the main intended use and the typical case when run in HPC.
# command line options  will override config specs
opts <- init_config( args = args, mode = "cmd_line")

# default ----
#
# This case is very rare.
# Testing script with just the default config file no command line input.
# this case will test config.yaml in extdata from the R installation as is.
#
# opts <- init_config( args = args, mode = "default")

print(opts)

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Build sample taxa (sample) id table                                      ----
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

log_time()

#opts$hapmap_geo_loc <- "/Users/fvrodriguez/Desktop/sorghum/hapmap_geo_loc.tassel"

phenotype_table <- read.table(
  file = opts$hapmap_geo_loc, na.strings = "NA",
  sep ="\t", header = TRUE)

# TASSEL4 format
colnames(phenotype_table)[1] <-'<Trait>'

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Extract data from raster                                                 ----
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

var_raster <- raster::raster(opts$raster_file)

trait <- tools::file_path_sans_ext(
  basename(opts$raster_file)
)

phenotype_table[,trait] <- raster::extract(
  x = var_raster,
  y = phenotype_table[, c("lon", "lat")]
)


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Write output                                                 ----
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# We will output a single table per phenotype
#  I could check user provided info if tha name is ok
# I don't have to change this option nor make the warning

if( opts$pheno_file == "output_dir/basename.tassel"){
  opts$pheno_file <- file.path(opts$output_dir,
                          paste0(trait,".tassel"))

  cat(paste0("--pheno_file from config replaced by ",
             opts$pheno_file,"\n\n"),
      file = stderr())
}


#weird naming but it is because of TASSEL4 format
out_cols <- c("<Trait>",trait)

write.table(
  phenotype_table %>% dplyr::select(
      all_of(out_cols)),
  file = opts$pheno_file,
  quote = FALSE,
  row.names = FALSE,
  sep ="\t")


cat(paste0("Output to: ",opts$pheno_file,"\n\n"), file = stderr())
log_opts(opts)
log_time()
log_done()

