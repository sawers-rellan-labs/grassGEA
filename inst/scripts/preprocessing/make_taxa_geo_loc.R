#!/usr/bin/env Rscript --verbose

library(grassGEA)
library(dplyr)

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Command line options ----
# the main use of this section is for documentation of the
# command line arguments and the default input
# it is necessary to always declare the --config option
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

option_list <-c(
  optparse::make_option(
  "--geo_loc", type = "character", default = "geo_loc.csv",
  help = "Passport Data, geo_locations of plants as table, full file path"),

  optparse::make_option(
  "--id_map", type = "character", default = "genotype_id_map.txt",
    help = "Table file mapping hapmap ids to passport data (geo_loc) ids, full file path"),

  optparse::make_option(
    "--hapmap_geo_loc", type = "character", default = "hapmap_geo_loc.tassel",
    help = "Script output, geolocations of hapmap ids, TASSEL4 format, full file path"),

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
# my_config_file <- "/Volumes/GoogleDrive/My Drive/repos/grassGEA/inst/extdata/hayu_config.yaml"
# opts <-  init_config( args = args, mode = "custom", config_file = my_config_file)

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

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Build sample taxa (Hapmap id) to passport data (geo_loc id) table ----
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

log_time()

geo_loc <- read.csv(file = opts$geo_loc, na.strings = "NA")

id_map <- read.table(opts$id_map, header = F)
colnames(id_map)[1] = "hapmap_id"

by_IS <- geo_loc %>%
  inner_join(id_map, by = c(is_no = "V2"))

by_PI <- geo_loc %>%
  inner_join(id_map, by = c(pi = "V2"))

# checking the amount of coincidence between the two columns
nrow(by_IS) + nrow(by_PI)
nrow(geo_loc)
# 1952 >1943
# there must be repeated ids

phenotype_table <-  rbind(
  geo_loc %>%
    inner_join(id_map, by = c(is_no = "V2")),
  geo_loc %>%
    inner_join(id_map, by = c(pi = "V2"))
  ) %>%
  group_by(hapmap_id, Latitude, Longitude) %>%
  summarise(count = length(hapmap_id)) %>%
  arrange(-count) %>% print() %>% # These samples have identifiers in both columns
  rename(lat ="Latitude", lon = "Longitude") %>%
  dplyr::select(-count) %>%
  ungroup()

colnames(phenotype_table)[1] <-'<Trait>'



lon_file   <- file.path(opts$output_dir, "lon.tassel")
lat_file   <- file.path(opts$output_dir, "lat.tassel")


if(!file.exists(lon_file)){
  write.table(
    phenotype_table %>% dplyr::select(`<Trait>`, lon),
    file = lon_file ,
    quote = FALSE, row.names = FALSE, sep ="\t")
}

if(!file.exists(lat_file)){
  write.table(
    phenotype_table %>% dplyr::select(`<Trait>`, lat),
    file = lat_file ,
    quote = FALSE, row.names = FALSE, sep ="\t")
}


write.table(
  phenotype_table,
  file = opts$hapmap_geo_loc,
  quote = FALSE,
  row.names = FALSE,
  sep ="\t")

log_opts(opts)
log_time()

print("DONE", file = stderr())


