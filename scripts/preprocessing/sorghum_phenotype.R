library(tidyr)
library(dplyr)

georef <- read.csv(file = "georef.csv", na.strings = "NA")
head(georef)

hapmap <- read.table("genotype_ids.txt", header = F)
colnames(hapmap)[1] = "hapmap_id"
head(hapmap)

colnames(georef)
colnames(hapmap)


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
library(rgdal)

var_tif <- "soilP/sol_VL.tif"
var_raster <- raster(var_tif)
geo_hap$sol_VL <- raster::extract(x = var_raster, y = geo_hap[, c("Longitude", "Latitude")])
head(geo_hap)
geo_hap <- geo_hap[,c(1,5)]
head(geo_hap)
write.table(geo_hap,"VL_F.txt")








