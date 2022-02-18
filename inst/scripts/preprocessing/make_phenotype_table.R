library(optparse)
library(configr)
library(tidyr)
library(dplyr)
library(grassGEA)

cat(as.character(Sys.time()),"\n\n", file = stderr())


# Initialize opts from configuration file


option_list <-c(

  optparse::make_option(
  "--geoloc", type = "character",
  help = "Passport Data, geolocations of plants as table, full file path",
  metavar = "character"),

  optparse::make_option(
  "--id_map", type = "character",
    help = "Genotype id map between hamap file and passport data file, full file path",
    metavar = "character"),

  optparse::make_option(
    "--tif", type = "character",
    help = "Geotiff raster with environmental data, full file path",
    metavar = "character"),

  optparse::make_option(
    "--phenotype", type = "character",
    help = "output phenotype table, full file path, add header for use with TASSEL",
    metavar = "character")
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



geoloc <- read.csv(file = opts$geoloc, na.strings = "NA")

hapmap <- read.table(opts$id_map, header = F)
colnames(hapmap)[1] = "hapmap_id"

by_IS <- geoloc %>%
  inner_join(hapmap, by = c(is_no = "V2")) %>% print()

by_PI <- geoloc %>%
  inner_join(hapmap, by = c(pi = "V2")) %>% print()

# checking the amount of coincidence between the two columns
nrow(by_IS) + nrow(by_PI)
nrow(geoloc)
# 1952 >1943
# there must be repeated ids

geo_hap <-  rbind(
  geoloc %>%
    inner_join(hapmap, by = c(is_no = "V2")),
  geoloc %>%
    inner_join(hapmap, by = c(pi = "V2"))
) %>%
  group_by(hapmap_id, Latitude, Longitude) %>%
  summarise(count = length(hapmap_id)) %>%
  arrange(-count)

library(sp)
library(raster)
library(rgdal)

var_raster <- raster(opts$tif)
geo_hap$sol_VL <- raster::extract(x = var_raster, y = geo_hap[, c("Longitude", "Latitude")])

write.table(geo_hap, file = opts$phenotype, quote = FALSE, row.names = FALSE)








