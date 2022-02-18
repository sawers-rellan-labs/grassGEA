library(tidyr)


georef <- read.csv(file = "georef.csv", na.strings = "NA")
georef$
hapmap <- read.table(file = "genotype_ids.txt", header = FALSE)
colnames(hapmap )[1] = "hapmap_id"


colnames(georef)
by_IS <- georef %>%
  inner_join(hapmap, by = c(is_no = "V2")) %>% print()

by_PI <- georef %>%
  inner_join(hapmap, by = c(pi = "V2")) %>% print()

nrow(by_IS) + nrow(by_PI)
nrow(georef)

geo_hap <-  rbind(
  georef %>%
    inner_join(hapmap, by = c(is_no = "V2")),
  georef %>%
    inner_join(hapmap, by = c(pi = "V2"))
) %>%
  group_by(hapmap_id, Latitude, Longitude) %>%
  summarise(count = length(hapmap_id)) %>%
  arrange(-count)


library(sp)
library(raster)

var_tif <- "soilP_raster/sol_VL.tif"
var_raster <- raster(var_tif)
geo_hap$sol_VL <- raster::extract(x = var_raster, y = geo_hap[, c("Longitude", "Latitude")])
geo_hap

quartz()
geo_hap$sol_VL







