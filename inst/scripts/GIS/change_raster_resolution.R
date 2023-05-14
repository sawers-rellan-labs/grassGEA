# I am thinking on splitting this script by data source.

# I want to upgrade the resolution of stp10
# from 55 km (30 arc minutes) to 10 km (~5 arc minutes?)


# I'll start by having all the predictors at 10 km resolution
library(dplyr)
library(raster)
library(stars)

gis_dir <- "/Users/fvrodriguez/Projects/NCSU/06_GEA/GIS"

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#### 1. PH Soil pH                                                        ####
# SoilGrids 1km data (Hengl2017)
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dir <- file.path(gis_dir,"predictors/source/raster")

file <-"phh2o_0-5cm_mean_5000.tif"
r <- raster(file.path(dir,file))
summary(r)
r
# the units of this raster are meters
# extent     : -19949750, 19860250, -6149000, 8361000
log2(2*19860250)
# 25 bits

# this raster needs 32 bits to store meter coordinates with 8 figures

# First aggregate to 10000 m
# thes soilgrids data are as integer with a conversion faactor of 10
r <- round(aggregate(r, 2))
r
summary(r)
# the soil grid rasters are in Interrupted Goode Homolosine projection
# proj=igh
# not in lonlat  WGS84

# Project to lonlat WGS84

# proj_wgs84 <- sp::CRS(SRS_string = "EPSG:4326")
# km10 <- round(raster::projectRaster(r, crs= proj_wgs84))
# km10

# resolution : 0.0912, 0.0898  (x, y)
# extent     : -180.4535, 180.4249, -56.47072, 83.16828

# Now we have decimal degree coordinates corresponding to 10 km at the equator
# I'll scale every other lower resolution raster to this one

# dir <- file.path(gis_dir,"predictors/10km/raster"
# out_file <-"PH.tif"
# raster::writeRaster(
#   r,
#   filename = file.path(dir,out_file),
#   format ="GTiff" #, overwrite=TRUE
# )

dir <- file.path( gis_dir,"predictors/rfin/10km/raster")

file <-"PH.tif"
km10 <- raster(file.path(dir,file))
km10

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#### 2. SOC Soil organic carbon                                           ####
# SoilGrids 1km data (Hengl2017)
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dir <- file.path(gis_dir,"predictors/source/raster")

file <-"soc_0-5cm_mean_5000.tif"
r <- raster(file.path(dir,file))

# first check for +proj=longlat +datum=WGS84
summary(r)
r
summary(r)
km10
summary(km10)

# Now project to km10
r <- round(raster::projectRaster(r,km10))
r
summary(r)


dir <- file.path(gis_dir,"predictors/10km/raster")
out_file <-"SOC.tif"
raster::writeRaster(
  r,
  filename = file.path(dir,out_file),
  format ="GTiff" #, overwrite=TRUE
)

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#### 3. SAND Sand                                                         ####
# SoilGrids 1km data (Hengl2017)
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dir <- file.path(gis_dir,"predictors/source/raster")
file <-"sand_0-5cm_mean_5000.tif"
r <- raster(file.path(dir,file))

# first check for +proj=longlat +datum=WGS84
summary(r)
r
summary(r)
km10
summary(km10)

# Now project to km10
r <- round(raster::projectRaster(r,km10))
r
summary(r)

dir <- file.path(gis_dir,"predictors/rfin/10km/raster")
out_file <-"SAND.tif"
raster::writeRaster(
  r,
  filename = file.path(dir,out_file),
  format ="GTiff" #, overwrite=TRUE
)

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# SoilGrids 1km data (Hengl2017)
#### 4. CLAY Clay                                                         ####
# SoilGrids 1km data (Hengl2017)
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dir <- file.path(gis_dir,"predictors/source/raster")
file <-"clay_0-5cm_mean_5000.tif"
r <- raster(file.path(dir,file))

# first check for +proj=longlat +datum=WGS84
summary(r)
r
summary(r)
km10
summary(km10)

# Now project to km10
r <- round(raster::projectRaster(r,km10))
r
summary(r)

dir <- file.path(gis_dir,"predictors/rfin/10km/raster")
out_file <-"CLAY.tif"
raster::writeRaster(
  r,
  filename = file.path(dir,out_file),
  format ="GTiff" #, overwrite=TRUE
)

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# SoilGrids 1km data (Hengl2017)
#### 5. DENSITY Soil bulk density.                                        ####
# SoilGrids 1km data (Hengl2017)
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dir <- file.path(gis_dir,"predictors/source/raster")
file <-"bdod_0-5cm_mean_5000.tif"
r <- raster(file.path(dir,file))

# first check for +proj=longlat +datum=WGS84
r
summary(r)

km10
summary(km10)

# Now project to km10
r <- round(raster::projectRaster(r,km10))
r
summary(r)

dir <- file.path(gis_dir,"predictors/rfin/10km/raster")
out_file <-"DENSITY.tif"

raster::writeRaster(
  r,
  filename = file.path(dir,out_file),
  format ="GTiff" #, overwrite=TRUE
)


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#### 6. SOIL.USDA USDA soil great groups                                              ####
# SoilGrids 1km data (Hengl2017) merged with metadata from He2020 & Hengl2019
# forUSDA soil taxonomy (2014)
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# Get SoilGrids (Hengl2017) metadata first
dir <- file.path(gis_dir,"predictors/source/raster/metadata")
file <-"TAXOUSDA_250m_ll.tif.csv"
metadata <-read.csv(file.path(dir,file), na.strings = "")


# there are raster values wiyh no soil assignments
# I am guessing those are soil units with no soil????
metadata$Group


# correct the great group names, plurals missed
metadata$Generic[metadata$Generic=="Histosol"] <- "Histosols"
metadata$Generic[metadata$Generic=="Oxisol"] <- "Oxisols"

# make a raster attribute table with Hengl2017 metadata
rat <- data.frame(ID=metadata$Number, great.group = metadata$Generic)


# Get He2020 metadata for SOIL.TYPE raster
# The value-name correspondece is the same as Openlandmap (Hengl2019) metadata
# Openlandmap (Hengl2019) is a more recent prediction than Soilgrids (Hengl2014)
# presumably are different models, and different data too

# I changed the column names for convinience
# originally:
# "Code","Soil order","weathering stage"

USDA <-read.csv(
  text="SOIL.USDA,great.group,weathering
1,Gelisols,slightly
2,Histosols,slightly
3,Spodosols,strongly
4,Andisols,slightly
5,Oxisols,strongly
6,Vertisols,intermediately
7,Aridisols,intermediately
8,Ultisols,strongly
9,Mollisols,intermediately
10,Alfisols,intermediately
11,Inceptisols,slightly
12,Entisols,slightly"
)

# Merge Hengl2017 and  He2020 metadata

USDA$great.group <- factor(USDA$great.group, levels = USDA$great.group)
rat$great.group <-  factor(rat$great.group, levels = USDA$great.group)
levels(rat$great.group)

rat <- rat %>%
  dplyr::left_join(USDA)
rat[1:10,]

# Now get the raster
dir <- file.path(gis_dir,"predictors/source/raster")
file <-"TAXOUSDA_10km_ll.tif"
r <- ratify(raster(file.path(dir,file)))
r
# Actually 0.1 deg resolution, ~ 11.1km around the equator not strictly 10km
# resolution : 0.1, 0.1  (x, y)

levels(r) <- rat
levels(r)

SOIL.USDA <- raster::deratify(r, "SOIL.USDA")
SOIL.USDA
# Resample to exactly 10 km
SOIL.USDA <- raster::resample(SOIL.USDA,km10, method = 'ngb')
SOIL.USDA

names(SOIL.USDA)
summary(SOIL.USDA)

summary(SOIL.USDA)

dir <- file.path(gis_dir,"predictors/rfin/10km/raster")
out_file <-"SOIL.USDA.tif"

writeRaster(SOIL.USDA,
            file = file.path(dir,out_file) #, overwrite = TRUE
)

plot(SOIL.USDA)
SOIL.USDA <-NULL
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#### 7. SOIL.WRB  Soil group (WRB)                                         ####
# SoilGrids 1km data (Hengl2017)
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dir <- file.path(gis_dir,"predictors/source/raster/metadata")
file <-"TAXNWRB_250m_ll.tif.csv"

metadata <-read.csv(file.path(dir,file))
metadata$WRB_group <- factor(metadata$WRB_group)

rat <- data.frame(ID=metadata$Number, SOIL.WRB = metadata$WRB_group)
rat

dir <- file.path(gis_dir,"predictors/source/raster")
file <-"TAXNWRB_10km_ll.tif"
r <- ratify(raster(file.path(dir,file)))
r
# Actually 0.1 deg resolution, ~ 11.1km around the equator not strictly 10km
# resolution : 0.1, 0.1  (x, y)

levels(r) <- rat

r <- raster::deratify(r, "SOIL.WRB")
summary(r)

# Resample to exactly 10 km
SOIL.WRB <- raster::resample(r,km10, method = 'ngb')
SOIL.WRB

dir <- file.path(gis_dir,"predictors/rfin/10km/raster")
out_file <-"SOIL.WRB.tif"

writeRaster(SOIL.WRB,
            file = file.path(dir,out_file) #, overwrite = TRUE
)

SOIL.WRB <-NULL

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#### 8. SOIL.Type USDA soil taxonomy OpenLandmap                          ####
# Openlandmap data and metada (Hengl2019) for  USDA soil taxonomy (2014)
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

# aggregate to 10000m
# merge with metadata according to He2020 (it should be the same)


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#### 9. BEDROCK Parent material ####
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Get Harmann Mordoof 2012 data
# although the paper says it is polygons I con only find an asc raster
# asc file specs:
# https://www.loc.gov/preservation/digital/formats/fdd/fdd000421.shtml
# dir <- file.path(gis_dir,"/Users/fvrodriguez/Desktop/LiMW_GIS_2015.gdb"
# file <-"glim_wgs84_0point5deg.txt.asc"

# I acquired a copy of a glim gbd database at
# https://csdms.colorado.edu/wiki/Data:GLiM
# https://www.dropbox.com/s/9vuowtebp9f1iud/LiMW_GIS%202015.gdb.zip?dl=0


# I think this might be the polygon version
# Data type: Surface properties
# Data origin: Measured
# Data format:
#   Other format: GDB
# Data resolution: 1:3,750,000
# Datum:

# in shell I use gdal command `ogrinfo`
#
# $ unzip LiMW_GIS_2015.gdb.zip
# $ ogrinfo LiMW_GIS_2015.gdb
# INFO: Open of `LiMW_GIS_2015.gdb'
#       using driver `OpenFileGDB' successful.
# Layer: GLiM_export (Multi Polygon)

dir <- file.path(gis_dir,"predictors/source/vector/")
file <-"LiMW_GIS_2015.gdb"

glim_poly <- sf::st_read(dsn = file.path(dir,file), layer = "GLiM_export")
class(glim_poly)
summary(glim_poly)
glim_poly

# Reading layer `GLiM_export' from data source `/Users/fvrodriguez/Desktop/LiMW_GIS_2015.gdb' using driver `OpenFileGDB'
# Simple feature collection with 1235259 features and 5 fields
# Geometry type: MULTIPOLYGON
# Dimension:     XY
# Bounding box:  xmin: -16653450 ymin: -8460601 xmax: 16653450 ymax: 8376733
# Projected CRS: World_Eckert_IV

# Checked eosg string for World_Eckert_IV
# now ineed to convert the polygons to raster
# https://epsg.io/54012
# ESRI:54012
# Eckert IV
#
# proj_EckertIV <- sp::CRS(SRS_string = "ESRI:54012")

# I need to rasterize the polygons

# Metadata as used in He2020
rat <-read.csv(
  text="ID,BEDROCK,NAME
1,su,Unconsolidated sediments
2,vb,Basic volcanic rocks
3,ss,Siliciclastic sedimentary rocks
4,pb,Basic plutonic rocks
5,sm,Mixed sedimentary rocks
6,sc,Carbonate sedimentary rocks
7,va,Acid volcanic rocks
8,mt,Metamorphics
9,pa,Acid plutonic rocks
10,vi,Intermediate volcanic rocks
12,py,Pyroclastics
13,pi,Intermediate plutonic rocks")
rat


# Use the He2020 metadata levels
names(glim_poly)[which(names(glim_poly) =="xx")] <- "z"
glim_poly$z <- factor(glim_poly$z, levels = rat$BEDROCK)
table(glim_poly$z)
class(glim_poly$z)

# Project from  Eckert IV to  WGS84
proj_wgs84 <- sp::CRS(SRS_string = "EPSG:4326")

glim_poly <- st_transform(glim_poly, proj_wgs84)



# Fine I'll crop it
sf_use_s2(FALSE)
glim_poly <- st_make_valid(glim_poly)
glim_poly <- st_crop(glim_poly, xmin = -180, ymin = -57, xmax = 180, ymax = 84)

# dir <- file.path(gis_dir,"~/Desktop"
# file <-"LiMW_GIS_2015_EPSG_4326.RDA"
# class(glim_poly)
# sf_use_s2(TRUE)
#
# save(glim_poly, file=file.path(dir,file) )
#last valid

# dir <- file.path(gis_dir,"~/Desktop"
# file <-"LiMW_GIS_2015_EPSG_4326.RDA"
# load(file=file.path(dir,file))

glim_poly
# Finally it is cropped!

class(glim_poly$z)

st_is_longlat(glim_poly)



# rasterize as star object
# Target resolution and extent
# resolution : 0.0912, 0.0898  (x, y)

# Match to exactly resolution and extent of km10
dir <- file.path(gis_dir,"predictors/rfin/10km/raster/")
file <-"PH.tif"

km10  <- read_stars(file.path(dir,file))
class(km10)
class(glim_poly)
class(glim_poly$z)

rs <- st_rasterize(
  glim_poly %>% dplyr::select(z, Shape),
  template = km10,
  # https://gdal.org/doxygen/gdal__alg_8h.html
  options = c("MERGE_ALG=REPLACE", "ALL_TOUCHED=FALSE")
)

names(rs)[1] <- "BEDROCK"
rat$BEDROCK <- factor(rat$BEDROCK, levels = rat$BEDROCK)

levels(rat$BEDROCK)
levels(rat$BEDROCK)

dim(rs)
summary(rs)
st_crs(rs)
plot(rs)

dir <- file.path(gis_dir,"predictors/rfin/10km/raster")
out_file <-"BEDROCK.tif"

write_stars(rs,file.path(dir,out_file))



###



# here it seems to be an interactive viewer
# https://www.cen.uni-hamburg.de/en/about-cen/news/2017-02-27-lithologischer-globus.html
# it's a broken link as of may 8 2023



#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#### 10. MATEMP Mean Annual Temperature 1970-2015####
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dir <- file.path(gis_dir,"predictors/source/raster")
file <-"wc2.1_5m_bio_1.tif"
r <- raster(file.path(dir,file))

# first check for +proj=longlat +datum=WGS84
summary(r)
r
summary(r)

dir <- file.path(gis_dir,"predictors/rfin/10km/raster/")
file <-"PH.tif"
km10 <- raster(file.path(dir,file))

km10
summary(km10)

# Now project to km10
r <- round(raster::projectRaster(r,km10))
r
summary(r)

dir <- file.path(gis_dir,"predictors/rfin/10km/raster")
out_file <-"MATEMP.tif"
raster::writeRaster(
  r,
  filename = file.path(dir,out_file),
  format ="GTiff" #, overwrite=TRUE
)

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#### 11. MAPRECIP Mean Annual  Precipitation 2000 2015?                   ####
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dir <- file.path(gis_dir,"predictors/rfin/10km/raster/")
file <-"PH.tif"
km10 <- raster(file.path(dir,file))

km10
summary(km10)

dir <- file.path(gis_dir,"predictors/source/raster")
file <-"wc2.1_5m_bio_12.tif"
r <- raster(file.path(dir,file))

# first check for +proj=longlat +datum=WGS84
summary(r)
r
summary(r)



# Now project to km10
r <- round(raster::projectRaster(r,km10))
r
summary(r)

dir <- file.path(gis_dir,"predictors/rfin/10km/raster")
out_file <-"MAPRECIP.tif"
raster::writeRaster(
  r,
  filename = file.path(dir,out_file),
  format ="GTiff" #, overwrite=TRUE
)
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#### 12. BIOMES Terrestrial Ecoregions of the world                       ####
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
library(sf)
dir <- file.path(gis_dir,"predictors/source/vector/Ecoregions2017")
file <- "Ecoregions2017.shp"
ecoregion <- st_read(file.path(dir,file))
# Bounding box:  xmin: -180 ymin: -89.89197 xmax: 180 ymax: 83.62313
# Geodetic CRS:  WGS 84
st_crs(ecoregion)$proj4string
summary(ecoregion)


# remove the "N/A" value row. coded as 11 in the map
# it seems to correspond to Arctic/Antartic ice regions
# I could change the  value to 0
# replace "N/A" value from 11 to 0
ecoregion$BIOME_NUM[ecoregion$BIOME_NAME == "N/A"] <- 0

# get the correspondence between raster int values
# and biome names

biome <-  as.data.frame(table(ecoregion$BIOME_NUM,ecoregion$BIOME_NAME))
biome <- biome[biome$Freq>0,-3]
colnames(biome) <- c("ID","NAME")

# do the same for colors

color  <-  as.data.frame(table(ecoregion$COLOR_BIO,ecoregion$BIOME_NAME))
color <- color[color$Freq>0,-3]
colnames(color) <- c("COLOR","NAME")

# Now I got the colors right!

rat <- biome %>%
  dplyr::inner_join(color, by="NAME") %>%
  arrange(ID)

rat$COLOR


# this is the pallete goes with values in the vector file
# '#FFEAAF' '#38A700' '#CCCD65' '#88CE66' '#00734C'
# '#458970' '#7AB6F5' '#FEAA01' '#FEFF73' '#BEE7FF'
# '#D6C39D' '#9ED7C2' '#FE0000' '#CC6767' '#FE01C4'

# dir <- file.path(gis_dir,"predictors/source/raster/metadata"
# file <- "biomes.csv"

# write.csv( rat, file =file.path(dir,file), row.names = FALSE)

rat <- read.csv( file = file =file.path(dir,file))

ecoregion$BIOME_NAME<- factor(ecoregion$BIOME_NAME)

ecoregion$BIOME_NAME <- factor(ecoregion$BIOME_NAME, levels=rat$NAME)
table(ecoregion$BIOME_NAME)

# Fine I'll crop it
sf_use_s2(FALSE)
ecoregion <- st_make_valid(ecoregion)
ecoregion <- st_crop(ecoregion, xmin = -180, ymin = -57, xmax = 180, ymax = 84)

head(ecoregion)
# Finally it is cropped!

# rasterize as star object
# Target resolution and extent
# resolution : 0.0912, 0.0898  (x, y)

# Match to exactly resolution and extent of km10
dir <- file.path(gis_dir,"predictors/rfin/10km/raster/")
file <-"PH.tif"

km10  <- read_stars(file.path(dir,file))
class(km10)

st_is_longlat(ecoregion)

rs <- st_rasterize(
  ecoregion %>% dplyr::select(BIOME_NAME, geometry),
  template = km10,
  options = c("MERGE_ALG=REPLACE", "ALL_TOUCHED=FALSE")
)

class(rs)
str(rs)
rat$NAME
levels(rs) <- factor(rat$NAME,levels=rat$NAME)

class(rs)
rat <- droplevels(rat)
names(rs) <-"BIOME"
dim(rs)
summary(rs)
st_crs(rs)




# this pallete goes with this order
# > rat$NAME
# [1] "Tropical & Subtropical Moist Broadleaf Forests"
# [2] "Tropical & Subtropical Dry Broadleaf Forests"
# [3] "Tropical & Subtropical Coniferous Forests"
# [4] "Temperate Broadleaf & Mixed Forests"
# [5] "Temperate Conifer Forests"
# [6] "Boreal Forests/Taiga"
# [7] "Tropical & Subtropical Grasslands, Savannas & Shrublands"
# [8] "Temperate Grasslands, Savannas & Shrublands"
# [9] "Flooded Grasslands & Savannas"
# [10] "Montane Grasslands & Shrublands"
# [11] "Tundra"
# [12] "Mediterranean Forests, Woodlands & Scrub"
# [13] "Deserts & Xeric Shrublands"
# [14] "Mangroves"

# Plot the raster
# quartz(height =9, width=16)
# plot(rs, col = rat$COLOR,key.pos =4,key.width =lcm(8))

dir <- file.path(gis_dir,"predictors/rfin/10km/raster")
out_file <-"BIOME.tif"

write_stars(rs,file.path(dir,out_file),
            driver ="GTiff",type = "Byte")


# yet to use this from He2020:
# but they match the info on the data source for biomes
# biome <-read.csv(
#   text="ID,BIOME
# 1,Tundra
# 3,Boreal
# 5,Mediterranean
# 7,Temperate"
# 9,Desert
# 12, Tropics)



#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#### 13. DEPTH Soil depth                                                 ####
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
library(ncdf4)
dir <- file.path(gis_dir,"predictors/source/raster")
file <-"BDTICM_M_10km_ll.tif"
r <-  raster(file.path(dir,file))

# Now project to km10
r <- round(raster::projectRaster(r,km10))
r
summary(r)
names(r)[1] <- "DEPTH"
dir <- file.path(gis_dir,"predictors/rfin/10km/raster")
out_file <-"DEPTH.tif"
raster::writeRaster(
  r,
  filename = file.path(dir,out_file),
  format ="GTiff" #, overwrite=TRUE
)


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#### 14. MANPP Mean Anual Net Primary Production 2000-2015                ####
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# I have the 2000-2015 average
# http://files.ntsg.umt.edu/data/NTSG_Products/MOD17/GeoTIFF/MOD17A3/GeoTIFF_30arcsec/MOD17A3_Science_NPP_mean_00_15.tif
# But I want the "long term" average over 2001-2019.
# Geotiff available for USA, not global.
# http://files.ntsg.umt.edu/data/NTSG_Products/MOD17/GeoTIFF/MOD17A3/GeoTIFF_30arcsec/

dir <- file.path(gis_dir,"predictors/source/raster")
file <-"MOD17A3_Science_NPP_mean_00_15.tif"
r <- raster(file.path(dir,file))

# first check for +proj=longlat +datum=WGS84
summary(r)
r
summary(r)

dir <- file.path(gis_dir,"predictors/rfin/10km/raster")
file <-"PH.tif"
km10 <- raster(file.path(dir,file))
km10

summary(km10)

# Now project to km10

# Now project to km10
r <- round(raster::projectRaster(r,km10))
# Error: vector memory exhausted (limit reached?)
# do it on the server
summary(r)
names(r)[1] <- "NPP"

dir <- file.path(gis_dir,"predictors/rfin/10km/raster")
out_file <-"NPP.tif"
raster::writeRaster(
  r,
  filename = file.path(dir,out_file),
  format ="GTiff"
)

#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#### 15. SLOPE Slope                                                      ####
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dir <- file.path(gis_dir,"predictors/rfin/10km/raster")
file <-"PH.tif"
km10 <- raster(file.path(dir,file))
km10

dir <- file.path(gis_dir,"predictors/source/raster")
file <-"slope_10KMmd_GMTEDmd.tif"
r <-  raster(file.path(dir,file))
r
summary(r)

# quartz()
# hist(r,breaks =0:60)

quartz()
plot(r)
# Now project to km10
r <- round(raster::projectRaster(r,km10, method="ngb"))
summary(r)
# quartz()
# hist(s,breaks =0:60)
# quartz(height = 9, width = 16)
# plot(s)

names(r)[1] <- "SLOPE"
dir <- file.path(gis_dir,"predictors/rfin/10km/raster")
out_file <-"SLOPE.tif"
raster::writeRaster(
  r,
  filename = file.path(dir,out_file),
  format ="GTiff" , overwrite=TRUE
)


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
#### 16. ELEVATION Elevation ####
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dir <- file.path(gis_dir,"predictors/source/raster")
file <- "elevation_10KMmd_GMTEDmd.tif"
r <-  raster(file.path(dir,file))

# Now project to km10
r <- round(raster::projectRaster(r,km10))
r
summary(r)
names(r)[1] <- "ELEVATION"
dir <- file.path(gis_dir,"predictors/rfin/10km/raster")
out_file <-"ELEVATION.tif"
raster::writeRaster(
  r,
  filename = file.path(dir,out_file),
  format ="GTiff" #, overwrite=TRUE
)


