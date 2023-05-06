# I need to make a case that the  observed POLsen in the McDowell database is correlated to
# The phosphorus parameters I've been working with.

# So 1st I need a table with: x,y, POlsen_obs, POLsen_pre. # MCdowell filtered data

# Global Olsen P (including predictions form Bray)                #######

dir <-"/Users/fvrodriguez/Projects/NCSU/06_GEA/GEA/Zea_traits/McDowell2023"

file <- "Final_filtered_data.csv"

mcdowell  <- read.csv(file = file.path(dir,file), header = TRUE)

# table(mcdowell[mcdowell$Database.ID != "WoSIS",c("Converted.from","Database.ID") ])
# table(mcdowell[mcdowell$Database.ID != "WoSIS",c("Converted.from","Database.ID") ])
# table(mcdowell$Converted.from, mcdowell$Database.ID)

colnames(mcdowell)
nrow(mcdowell)
mcdowell  <- read.csv(file = file.path(dir,file), header = TRUE) %>%
  dplyr::rename(x="Long", y="Lat")  %>%
  dplyr::select(x,y,OlsenP, Predicted) %>%
  dplyr::group_by(x,y,OlsenP, Predicted)%>% 
  dplyr::slice(1)
nrow(mcdowell)

write.csv(mcdowell, file="POlsen_obs_pred_mcdowell2023_filtered.csv", row.names = FALSE)

# Then I need to recover the phenotypes from all the rasters at the known resolution

library(raster)
# file <- "POlsen_obs_pred_mcdowell2023_filtered.csv"
file <- "POlsen_obs_pred_mcdowell2023_otherP.csv"
map_points <- read.csv(file)
colnames(map_points)



data_dir <- "/rsstu/users/r/rrellan/sara/gisdata/tif"
#for(file in list.files(data_dir,pattern="sol.*.tif$")){
for(file in list.files(data_dir,pattern=".*.tif$")){
  #file <- "NPlim.tif"
  trait <- tools::file_path_sans_ext(basename(file))
  print(trait)
  raster_file <- file.path(data_dir,file)
  env_raster <- raster::raster(raster_file) 
  map_points[,trait] <- raster::extract(env_raster,map_points[,c("x","y")])
}

colnames(map_points)

data_dir <- "/rsstu/users/r/rrellan/sara/gisdata/soilP" 
for(file in list.files(data_dir,pattern="*.tif$")){
  trait <- tools::file_path_sans_ext(basename(file))
  print(trait)
  raster_file <- file.path(data_dir,file)
  env_raster <- raster::raster(raster_file) 
  map_points[,trait] <- raster::extract(env_raster,map_points[,c("x","y")])
}


write.csv(map_points, file = "POlsen_obs_pred_mcdowell2023_otherP.csv")

get_GSDE_brick <- function(nc_file){
  var_name <- tools::file_path_sans_ext(basename(nc_file))
  #  "PBR1.nc" and "PBR2.nc" have the same varriable name: "PBR" nightmare!
  #  omit *2.nc from analysis for  now
  #  getting just the first depth
  brick <- raster::brick(
    raster::raster(nc_file, lvar=4, level=1)
  )
  names(brick) <- var_name
  brick
}


extract_brick <- function(brick, geo_loc, lon ="x", lat = "y") {
  for (var_name in names(brick)) {
    geo_loc[var_name] <- raster::extract(x = brick[[var_name]],
                                         y = geo_loc[, c(lon, lat)])
  }
  geo_loc
}

data_dir <- "/rsstu/users/r/rrellan/sara/gisdata/Shangguan2014/"
for(file in list.files(data_dir,pattern=".*.nc$")){
  print(file)
  nc_file <- file.path(data_dir,file)
  map_points <- extract_brick(get_GSDE_brick(nc_file),
                              map_points)
}

write.csv(map_points, file = "POlsen_obs_pred_mcdowell2023_otherP.csv")

get_ORNL_brick <- function(nc_file){
  phospho_nc <- ncdf4::nc_open(nc_file)
  vars <- names(phospho_nc$var)
  #  "PBR1.nc" and "PBR2.nc" have the same varriable name: "PBR" nightmare!
  # omit *2.nc frrom analysis for  now
  lst_by_var <- lapply(
    1:length(vars),
    function(i) {
      raster::brick(nc_file, varname = vars[i])
    }
  )
  brick <- raster::brick(lst_by_var)
  names(brick) <- vars
  brick
}


data_dir <- "/rsstu/users/r/rrellan/sara/gisdata//Yang2014/Global_Phosphorus_Dist_Map_1223/data"
file <- "pforms_den.nc"
print(file)
nc_file <- file.path(data_dir,file)
nrow
map_points <- extract_brick(get_ORNL_brick(nc_file),
                            map_points)

write.csv(map_points, file = "POlsen_obs_pred_mcdowell2023_otherP.csv")


#  check the distributions

dir <-"~/Desktop"

file <- "POlsen_obs_pred_mcdowell2023_otherP.csv"

mcdowellP <- read.csv(file = file.path(dir,file), header = TRUE) %>% 
  filter(!is.na(x)) %>%
  rename(id= "X") %>%
  dplyr::select(-stp100,-stp20,-stp30 )
mcdowellP <- mcdowellP[,-which(grepl("2$",colnames(mcdowellP)))]
mcdowellP[mcdowellP==-999] <-NA
colnames(mcdowellP)
p_vars <- colnames(mcdowellP)[-(1:3)]

out<- mcdowellP

# I need to add AFR an LAC labels

# add Country and GEO3Major Region
country <- data.frame( 
  id = out$id,
  mapname = maps::map.where(database="world", 
                            out$x, out$y)) %>%
  inner_join(iso3166) %>%
  inner_join(countryRegions, by =c(a3="ISO3")) 


#check number of samples
table(country$GEO3major)

mcdowellP <- mcdowellP %>% 
  left_join(
    country %>% dplyr::select(id, Region = "GEO3major")
  )
mcdowellP$Region[is.na(mcdowellP$Region)] <-"other"
mcdowellP$Region[!(mcdowellP$Region %in% c("Latin America and the Caribbean", "Africa"))] <-"other"

table(mcdowellP$Region)
mcdowellP$Region <- factor(mcdowellP$Region, levels = c("other", "Africa","Latin America and the Caribbean"))
### Check distributions
library(tidyr)
plots <- list()

plots$density <- mcdowellP  %>%
  tidyr::gather(key="var", value="value", all_of(p_vars)) %>%   # Convert to key-value pairs
  ggplot(aes(value, group = Region)) +  # Plot the values
  xlab("Mass") +
  facet_wrap(~ var, scales = "free") +     # In separate panels
  geom_density( aes(col = Region)) + 
  ggpubr::theme_classic2() 

quartz()
plots$density

plots$box <- mcdowellP  %>%
  tidyr::gather(key="var", value="value", all_of(p_vars)) %>% 
  dplyr::mutate(var =factor(var)) %>%# Convert to key-value pairs
  ggplot(aes(x=value, y = Region, group = Region, col= Region)) +                     # Plot the values
  facet_wrap(~ var, scales = "free_x") +    # In separate panels
  geom_boxplot()  + 
  ggpubr::theme_classic2() +
  ggplot2::theme(legend.position = "none")


transformed <- mcdowellP


colnames(mcdowellP)
with(mcdowellP,{
  data.frame(
  OlsenP.Predicted = cor(OlsenP,Predicted,use= "pairwise.complete.obs"),
  OlsenP.POL1 = cor(OlsenP,POL1,use= "pairwise.complete.obs"),
  OlsenP.stp10 = cor(OlsenP,stp10,use= "pairwise.complete.obs"),
  OlsenP.TP1 = cor(OlsenP,TP1,use= "pairwise.complete.obs")
  ) %>% t()
})



transformed <- mcdowellP
colnames(transformed)


transformed <- within(transformed,{
  apa <- log2(apa+1)
  lab <- log2(lab+1)
  occ <- log2(occ+1)
  OlsenP <- log2(OlsenP+1)
  org <- log2(org+1)
  POL1 <- log2(POL1+1)
  Predicted <- log2(Predicted+1)
  stp10 <- log2(stp10+1)
  ret_Hi <-  qlogis((ret_Hi/100)+0.001)
  ret_Lo <-  qlogis((ret_Lo /100)+0.001)
  ret_VH <-  qlogis((ret_VH /100)+0.001)
  ret_Mo <-  qlogis((ret_Mo /100)+0.001)
  sec <- log2(sec+1)
  stp10 <- log2(stp10+1)
  tot <- log2(tot+1)
  TP1 <- log2(TP1+1)
}
)

cor(mcdowellP$OlsenP,mcdowellP$Predicted)
cor(transformed$OlsenP,transformed$Predicted)
  
r <- cbind(
  cor(mcdowellP[p_vars],use= "pairwise.complete.obs")[,c("OlsenP","Predicted")],
  cor(transformed[p_vars],use= "pairwise.complete.obs")[,c("OlsenP","Predicted")]
)



r2t <- r2[,"Predicted"]
sort(r2t,decreasing = TRUE)
transformed$ret_Hi
hist(transformed)

# Then I have to logit transform the ret probabilities 


# I have to log transform all variables that look log normal 

# so you have to check distribution beforrehan


# after all variables are tranfromed accordingly check for correlations


# Check Global agreement


# Check AFRRLAC agreement




