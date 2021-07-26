library(sp)
library(raster)


georef_file <- "passport_data.csv" # you need to load  a file to a dataframe

georef <- read.table(file = georef_file, header = TRUE, quote = "",sep ="\t")

var_tif <- "sol.tif"
var_raster <- raster(var_tif)
sol <- raster::extract(x = var_raster, y = georef[, c("Longitude", "Latitude")])




