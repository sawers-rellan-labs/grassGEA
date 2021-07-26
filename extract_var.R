library(sp)
library(raster)


georef_file <- "germinate_SeeD_GWAS_GBS_4022.tab"

georef <- read.table(file = georef_file, header = TRUE, quote = "",sep ="\t")
var_tif <- "sol.tif"
var_raster <- raster(var_tif)
sol <- raster::extract(x = var_raster, y = georef[, c("locations_longitude", "locations_latitude")])



