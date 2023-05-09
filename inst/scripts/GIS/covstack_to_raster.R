library(dplyr)
library(raster)
library(stars)
library(rgdal)
library(sp)
library(maps)
library(rworldmap)
library(countrycode)
library(ggmap)
library(maptools)

### Add elevation from the aster30m DEM in opentopo (30 meter resolution)
#### get spatial data
# key <- "f5c065f8fa8409eaf31a760127dedf3f"

#### Set up example spatial data with lat/long projection
# proj_wgs84 <- sp::CRS(SRS_string = "EPSG:4326")
# x <- traits[1:3,c("lon","lat")] %>% as.matrix()

# ele <- query_open_topo(x = x, db = "aster30m")


# Here I 'll get the predictors for stp10 from He2022


dir <- "/Users/fvrodriguez/Projects/NCSU/06_GEA/GIS/He2022/14583375"
file <- "covstack.dat.csv"
cov <- read.csv(file = file.path(dir,file), header = TRUE)
colnames(cov)
nrow(cov)

# add weathering moosdorf2018

dir <- "~/Desktop"
file <- "Global_BQART_Lithology_GLiMv1.1_06min_Static.tif"
erodability <- raster::raster(file.path(dir,file))
summary(erodability)
cov$EROIDX <- raster::extract(erodability , cov[,c("x","y")])

#add calcium carbonate

# from wise
# https://www.sciencedirect.com/science/article/pii/S0016706116300349
# a pain in the neck

dir <-"/Users/fvrodriguez/Desktop/WISE30sec/Interchangeable_format/"
file <- "wise_30sec_v1.tif"
rat_file <- "HW30s_FULL.txt"
base_rat_file <- "wise_30sec_v1.tsv"
mu_file <- "HW30s_MapUnit.txt"

#
# base_rat <- read.table( file.path(dir,base_rat_file),header=TRUE, sep ="\t")[,1:2]
# hist(base_rat$pixel_vaue)
# head(base_rat)
# colnames(base_rat) <- c("ID","NEWSUID")
#
#
#
# rat <- dplyr::left_join(base_rat,
#                         read.csv(file.path(dir,rat_file))%>%
#                           dplyr::filter(Layer=="D1") %>%
#                           dplyr::group_by(NEWSUID ) %>%
#                           dplyr::slice_max(PROP,with_ties = FALSE) ,
#                         by = "NEWSUID") %>%
#   dplyr::arrange(ID)
#
# hist(rat$TCEQ[grepl("AN.*",rat$CLAF, perl =TRUE)])
# hist(rat$TCEQ[grepl("F.*",rat$CLAF, perl =TRUE)])
#
# hist(rat$TCEQ[grepl("CL.*",rat$CLAF, perl =TRUE)])
#
# hist(rat$TCEQ[grepl("FLc",rat$CLAF, perl =TRUE)])
# hist(rat$TCEQ[grepl("GLk",rat$CLAF, perl =TRUE)])
#
# hist(rat$TCEQ[grepl("GY",rat$CLAF, perl =TRUE)])
# hist(rat$TCEQ[grepl("GY",rat$CLAF, perl =TRUE)])
#
# nrow(rat)
# wise <- raster::raster(file.path(dir,file)) %>% raster::ratify()
# levels(wise) <- rat

#TCEQ <- raster::deratify(wise, "TCEQ")
# writeRaster(TCEQ,
# file = out_tif,
# datatype = 'INT1U',
# overwrite = TRUE)



out_tif <- file.path( "~/Desktop", "WISE_TCEQ_dominant.tif")
TCEQ <- raster::raster(out_tif)
hist(TCEQ)
cov$TCEQ <- raster::extract(TCEQ , cov[,c("x","y")])
library(ncdf4)


dir <-"/Users/fvrodriguez/Desktop/"
file <- "CACO31.nc"
CACO3 <- raster(file.path(dir,file))

cov$CACO3<- raster::extract(CACO3 , cov[,c("x","y")], layer = 1)


with(cov,
cor(CACO3,TCEQ, use="pairwise.complete.obs")
)



cov$EROIDX <- raster::extract(erodability , cov[,c("x","y")])
#cov$CACO3 <- raster::extract(CACO3 , cov[,c("x","y")])
# cov$TCEQ <- raster::extract(TCEQ,cov[,c("x","y")])
# hist(cov$TCEQ)


#cov$is_calcareous <- cov$CACO3 >10*100
#cov$is_calcareous[is.na(cov$is_calcareous)] <- FALSE
#hist(cov$TCEQ[cov$is_calcareous], breaks= 10*(0:25))


# then I'll build a raster for each one of them
# he2022 predictors

proj_wgs84 <- sp::CRS(SRS_string = "EPSG:4326")
he2022 <- rasterFromXYZ(cov, crs = proj_wgs84)
he2022
he2022
summary(he2022[["SOIL.TYPE"]])
names(he2022)

quartz()
plot(he2022[["SOIL.TYPE"]])

# this raster is 0.5 degree = 30 min resolution lon lat grid
#  extent 720 pixels lomgitude ~ 55 km  at the equator
quartz()
plot(he2022)

quartz()
plot(he2022[[1]], main= names(he2022)[[1]])

# Then I'll get the coordinates from Mcdowell
# Global Olsen P (including predictions form Bray)                #######

dir <-"/Users/fvrodriguez/Projects/NCSU/06_GEA/GEA/Zea_traits/McDowell2023"

file <- "Final_filtered_data.csv"

mcdowell  <- read.csv(file = file.path(dir,file), header = TRUE)

table(mcdowell[mcdowell$Database.ID != "WoSIS",c("Converted.from","Database.ID") ])
table(mcdowell[mcdowell$Database.ID != "WoSIS",c("Converted.from","Database.ID") ])
table(mcdowell$Converted.from, mcdowell$Database.ID)

mcdowell  <- read.csv(file = file.path(dir,file), header = TRUE) %>%
             dplyr::rename(x="Long", y="Lat", p_avg ="OlsenP")  %>%
             dplyr::select(x,y,p_avg) %>%
             arrange(x,y) %>%
             unique()
nrow(mcdowell)


# Merge with He2022 predictors

out <- cbind( mcdowell %>% dplyr::select(x,y,p_avg),
 raster::extract(
  he2022,
  mcdowell[,c("x","y")] %>% as.matrix(), # what to value to extract
  df=TRUE)) %>%
  dplyr::select(-ID)  %>%
  dplyr::filter(!is.na(SOC))
nrow(out)


# To He2022 random forest script

write.csv(out, file="P_Olsen_mcdowell2023_predictors_he2022_global.csv", row.names = FALSE)


# LAC_AFR Olsen P (including predictions form bray) ####

# add Country and GEO3Major Region
country <- data.frame(
  # Number = 1:nrow(out),
  mapname = maps::map.where(database="world",
                            out$x, out$y,)) %>%
  inner_join(iso3166) %>%
  inner_join(countryRegions, by =c(a3="ISO3"))

#check number of samples
table(country$GEO3major)
# Africa
#                             553
# Latin America and the Caribbean
#                             268



# Make input for the He2022 random forest script

AFRLAC <- c("Africa","Latin America and the Caribbean")

write.csv(
  #subset to LAC AFR
  out[country$GEO3major %in% AFRLAC,],
  file="P_Olsen_mcdowell2023_predictors_he2022_AFRLAC.csv", row.names = FALSE)


#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Global Bray P  from WoSIS ISRIC NCSS                                   ####
# are WOSIS and ISRIC duplicates?
#
#%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#WoSIS#
dir <-"/Users/fvrodriguez/Projects/NCSU/06_GEA/GEA/Zea_traits/McDowell2023"

cov_file <- "WoSIS_clean.csv"

wosis_mcdowell  <- read.csv(file = file.path(dir,cov_file), header = TRUE) %>%
  dplyr::filter(Passed.filtering. == "Yes")
colnames(wosis_mcdowell)
wosis_mcdowell$Number <- 1:nrow(wosis_mcdowell)
wosis_mcdowell$upper_depth

bray_wosis <-  wosis_mcdowell[wosis_mcdowell$isBray==1, c("Number","x","y","p_avg")]
bray_wosis$Database.ID <-"WoSIS"

bray_wosis <- bray_wosis %>% dplyr::select(Database.ID, everything())



#ISRIC#

dir <-"/Users/fvrodriguez/Projects/NCSU/06_GEA/GEA/Zea_traits/McDowell2023"

cov_file <- "ISRIC_clean.csv"


ISRIC_mcdowell  <- read.csv(file = file.path(dir,cov_file), header = TRUE) %>%
  dplyr::filter(Passed.filtering. == "Yes")

ISRIC_mcdowell$Number <- 1:nrow(ISRIC_mcdowell )



colnames(ISRIC_mcdowell)

bray_ISRIC <-  ISRIC_mcdowell[!is.na(ISRIC_mcdowell$p_brayI..mg.kg.),
                              c("Number","lat_point","long_point","p_brayI..mg.kg.")]


colnames(bray_ISRIC) <-c("Number","x","y","p_avg")
nrow(bray_ISRIC)

bray_ISRIC$Database.ID <-"ISRIC"

bray_ISRIC <- bray_ISRIC%>% dplyr::select(Database.ID, everything())

#NSCC#
dir <-"/Users/fvrodriguez/Projects/NCSU/06_GEA/GEA/Zea_traits/McDowell2023"

cov_file <- "NSCC_clean.csv"


NSCC_mcdowell  <- read.csv(file = file.path(dir,cov_file), header = TRUE) %>%
  dplyr::filter(Passed.filtering. == "Yes")

colnames(NSCC_mcdowell)

NSCC_mcdowell$Number <- 1:nrow(NSCC_mcdowell)

NSCC_mcdowell$p_bray1

bray_NSCC <-  NSCC_mcdowell[!is.na(NSCC_mcdowell$p_bray), c("Number","latitude_decimal_degrees","longitude_decimal_degrees","p_bray1")]

colnames(bray_NSCC) <- c("Number","x","y","p_avg")
bray_NSCC$Database.ID <-"NSCC"

bray_NSCC <- bray_ISRIC %>% dplyr::select(Database.ID, everything())

bray <- rbind(bray_NSCC,bray_ISRIC,bray_wosis)
nrow(bray)

bray <- bray %>%
        dplyr::select(-Database.ID, - Number) %>%
        dplyr::arrange(x,y,p_avg) %>%
        dplyr::distinct()

nrow(bray)




out <- cbind( bray,
              raster::extract(
                he2022,
                bray [,c("x","y")] %>% as.matrix(), # what to value to extract
                df=TRUE)
) %>%
  dplyr::filter(!is.na(SOC))
nrow(out)

colnames(out)
write.csv(out,
          file="P_Bray_mcdowell2023_predictors_he2022_global.csv", row.names = FALSE)

table(out$SOIL.TYPE)
out$SOIL.TYPE[out$is_calcareous] %>% table()

# LAC_AFR Bray P (including predictions from Olsen) ####

# add Country and GEO3Major Region
country <- data.frame(
  Number = out$Number,
  mapname = maps::map.where(database="world",
                            out$x, out$y,)) %>%
  inner_join(iso3166) %>%
  inner_join(countryRegions, by =c(a3="ISO3"))

#check number of samples
table(country$GEO3major)
# Africa
#                             153
# Latin America and the Caribbean
#                             113



# Make input to He2022 random forest script

AFRLAC <- c("Africa","Latin America and the Caribbean")

write.csv(
  #subset to LAC AFR
  out[country$GEO3major %in% AFRLAC,],
  file="P_Bray_mcdowell2023_predictors_he2022_AFRLAC.csv", row.names = FALSE)


getwd()






