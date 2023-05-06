# I want to upgrade the resolution of stp10
# from 55 km (30 minutes) to 10 km (6 minutes?)

# I'll start by haaving aall the predictors at 10 km resolution

library(raster)


# load landcover
dir <- "/Users/fvrodriguez/Projects/NCSU/06_GEA/GIS/He2020predictors/10km/raster"
# 5 minute resolution ~ 10km (11.111) at the equator
file <-"landcover10km.tif"
landcover10km <- raster(file.path(dir,file))

dir <- "/Users/fvrodriguez/Projects/NCSU/06_GEA/GIS/soilgrids"
file <-"phh2o_0-5cm_mean_5000.tif"
r <- raster(file.path(dir,file))


summary(r)
r
# the soil grid rasters are not in WS84
# the fist thing is to change to WS84 lon lat

proj_wgs84 <- sp::CRS(SRS_string = "EPSG:4326")
lon_lat <- raster::projectRaster(r, crs= proj_wgs84)


km10 <- resample(lon_lat, landcover10km )

quartz()
plot(km10)

dir <- "/Users/fvrodriguez/Projects/NCSU/06_GEA/GIS/He2020predictors/10km/raster"
out_file <- paste0("phh2o10km.tif")

raster::writeRaster(km10,
  filename = file.path(dir,out_file),
  forrmat ="GTiff", datatypeCharacter= "INT1U") # 8 bit raster








