#!/usr/bin/env Rscript --verbose

library(grassGEA)
library(dplyr)
library(raster, include.only = c("raster", "extract"))

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Command line options                                                    -----
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

option_list <-c(
  optparse::make_option(
    "--hapmap_geo_loc", type = "character", default = "hapmap_geo_loc.tassel",
    help = "Script input, geolocations of hapmap ids, TASSEL4 format, full file path"),

  optparse::make_option(
    "--tif", type = "character",
    help = paste0(
      "Geotiff raster with environmental data, ",
      "file base name will be used as trait column and output file name",
      "but with .tassel extension instead of tif, ",
      "full file path")
    ),

  optparse::make_option(
    "--output_dir", type = "character", default = "./",
    help = "output directory file path"),

  optparse::make_option(
    "--config", type = "character", default = default_config_file(),
    help = "configuration file, YAML format")
)

usage <-  "%prog [options]"

opt_parser <- OptionParser(
  usage = usage,
  option_list = option_list
)

args <- parse_args2(opt_parser)

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Initialazing configuration ----
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
# command line options  will overriade config specs
opts <- init_config( args = args, mode = "cmd_line")

# default ----
#
# This case is very rare.
# Testing script with just the default config file no command line input.
# this case will test config.yaml in extdata from the R installation as is.
#
# opts <- init_config( args = args, mode = "default")

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

var_raster <- raster::raster(opts$tif)

trait <- tools::file_path_sans_ext(
  basename(opts$tif)
)

phenotype_table[,trait] <- raster::extract(
  x = var_raster,
  y = phenotype_table[, c("lon", "lat")]
)


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Write output                                                 ----
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



# We will output a single table per phenotype

opts$pheno_file <- file.path(opts$output_dir,
                        paste0(trait,".tassel"))

cat(paste0("--pheno_file replaced by ",
             opts$pheno_file,"\n\n"),
      file = stderr())

#weird naming but it is because of TASSEL4 format
out_cols <- c("<Trait>",trait)

write.table(
  phenotype_table %>% dplyr::select(
      all_of(out_cols)),
  file = opts$pheno_file,
  quote = FALSE,
  row.names = FALSE,
  sep ="\t")

log_opts(opts)
log_time()

print(paste0("Output to ",opts$pheno_file), file = stderr())
print("DONE", file = stderr())
