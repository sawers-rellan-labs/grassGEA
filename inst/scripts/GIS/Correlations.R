require(FactoMineR)
require(factoextra)
require(ggplot2)
require(tidyr)
require(dplyr)
require(MASS)
require(reshape2)
require(cowplot)
library(maps)
library(rworldmap)
library(countrycode)


# Shangguan2014: it has the greatest number of predicted parameters 
# but there is no training set established.
# Because the mapping approach was procedural it does not use machine learning
# Similar to Batjes2011 it is based on a set of hardcoded rules operatnig 
# on harmonized data from various sources

# Batjes2019: here different parameters have different sample sizes
# Africa and Latin America are vastly under represented for Olsen Bray mehlich ~ 150 profiles at most
# But it has a 2K samples for total phosphorus in Africa
# however correlation with other parameters is low. ????

# Yang2014:Similar procedural approach as Batjes2011 , therefore no prediction
# just accuracy data associated with that source.

# He2021 has ~500 samples for Africa and 400 for Latam
# which make this data set the more balanced for predictions in Africa and Latam
# but just fort total phosphorus

# Macdowell2023 has  a similar amount of info ~500 samples for Africa and 400 for Latam
# but on Olsen measurements.

# So the 2 yardsticks should be He2021 for total phosphorus
# Macdowell2023 for labile phosphorus, Olsen.
# I do not know whether the profiles overlap
# But I would expect so in some degree.
# When comparing other labile phosphorus measurements the 
# the highest correlation should be to Macdowell, because it is all the training set
# Shangguan2014 should be lower




# You must make a figure comparing number of Africa-Latam samples
# in references

# He2021
# Batjes2019
# Shangguan2014

# Batjes 2019


php <- read.table("php.tsv", quote="", sep = "\t", header = TRUE) %>%
  filter(if_any(phpbyi_value_avg:phpwsl_value_avg, ~ !is.na(.)))
php
colnames(php) <- sub("_value_avg","",colnames(php))
nrow(php)
php$upper_depth



cat(colnames(php))

sum(!is.na(php$phpbyi))

nrow(php)

soil_profile <- read.table("wosis_201909_profiles.tsv", quote="", sep = "\t", header = TRUE)


geo_loc_php <- soil_profile  %>%
  inner_join(php, multiple = "all")  %>%
  group_by(profile_id) %>%
  arrange(upper_depth) %>% slice(1) %>%
  dplyr::select(profile_id,upper_depth, longitude, latitude,phpbyi:phpwsl) %>%
  filter(upper_depth ==0) #topsoil measurements


nrow(geo_loc_php)


quartz()
geo_loc_php %>%
  gather(key="var", value="value", latitude,phpbyi:phpwsl) %>%   # Convert to key-value pairs
  ggplot(aes(value)) +                     # Plot the values
  facet_wrap(~ var, scales = "free") +     # In separate panels
  geom_density()


m <- geo_loc_php[,-1] %>% as.matrix()



cor(geo_loc_php$phpols, log(geo_loc_php$phpmh3), use = "pairwise.complete.obs")


hist(car::logit(geo_loc_php$phprtn, adjust =0.025))
quartz()
hist(geo_loc_php$phprtn)


cor((geo_loc_php$phpols+0.01), log(geo_loc_php$phpmh3+0.01), use = "pairwise.complete.obs")

cor(geo_loc_php$phpols, car::logit(geo_loc_php$ph), use = "pairwise.complete.obs")

cor(geo_loc_php$phpols, geo_loc_php$phprtn, use = "pairwise.complete.obs")

colnames(geo_loc_php)
hist(geo_loc_php$upper_depth)
hist(geo_loc_php$php)


# Check for data in LAC-AFR
# Olsen
geo_loc_ols <- geo_loc_php %>%
  dplyr::filter(!is.na(phpols))
geo_loc_ols 

country <- data.frame( 
  mapname = maps::map.where(database="world", 
                            geo_loc_ols$longitude, geo_loc_ols$latitude)) %>%
  inner_join(iso3166) %>%
  inner_join(countryRegions, by =c(a3="ISO3"))


table(country$GEO3major)

# Bray
geo_loc_byi <- geo_loc_php %>%
  dplyr::filter(!is.na(phpbyi))
geo_loc_byi 


country <- data.frame( 
  mapname = maps::map.where(database="world", 
                            geo_loc_byi$longitude, geo_loc_byi$latitude)) %>%
  inner_join(iso3166) %>%
  inner_join(countryRegions, by =c(a3="ISO3"))
table(country$GEO3major)




country %>% dplyr::filter(GEO3major == "Latin America and the Caribbean") %>% pull(ISOname)

sum(!is.na(geo_loc_php$phptot))

cols.cor <- cor(m, use = "pairwise.complete.obs")


quartz()
corrplot::corrplot(cols.cor)


pca1 <- PCA(m[,-1], ncp=9, graph = FALSE,)
X <- pca1$call$X
corrplot::corrplot(cor(X))


# Mcdowell 2023

# wosis data

wosis_mcdowell  <- read.csv("../McDowell2023/WoSIS_clean.csv",  header = TRUE) %>%
  dplyr::filter(isBray==1 & Passed.filtering. == "Yes")


wosis_mcdowell$isBray
country <- data.frame( 
  mapname = maps::map.where(database="world", 
                            wosis_mcdowell$x, wosis_mcdowell$y)) %>%
inner_join(iso3166) %>%
inner_join(countryRegions, by =c(a3="ISO3"))


wosiscountry <- data.frame( 
  bray = wosis_mcdowell$p_avg,
  x = wosis_mcdowell$x,
  y = wosis_mcdowell$y,
  mapname = map.where(database="world", 
                      wosis_mcdowell$x,wosis_mcdowell$y)) %>%
  inner_join(iso3166) %>%
  inner_join(countryRegions, by =c(a3="ISO3")) %>% 
  dplyr::select(x,y, bray, a2,a3,ISOname, GEO3major,REGION, continent, GEO3)

table(country$GEO3major)

mapWorld <- borders("world", colour="gray50", fill="white")
mp <- ggplot() + mapWorld


to_plot <- wosiscountry  %>%
  dplyr::filter(GEO3major == "Latin America and the Caribbean" | GEO3major == "Africa" ) 

quartz()
mp + geom_point(data = to_plot , aes(x = x, y = y, color = GEO3major), alpha = 0.5)+
  coord_equal()



write.csv(to_plot %>% dplyr::select(lat,lon,OlsenP), 
          file ="mcdowell2023.csv", 
          quote =FALSE, row.names = FALSE)
colnames(mcdowell)

# mcdowell  <- read.csv("Final_filtered_data.csv",  header = TRUE) %>%
mcdowell  <- read.csv("../McDowell2023/Final_filtered_data.csv",  header = TRUE) %>%
  dplyr::select(Number:OlsenP, Pred_Corrected, lat = "Lat", lon = "Long","Continent" ) %>%
  dplyr::filter(!is.na(OBJECTID))


write.csv(to_plot %>% dplyr::select(lat,lon,OlsenP), 
          file ="mcdowell2023.csv", 
          quote =FALSE, row.names = FALSE)
colnames(mcdowell)

table(mcdowell$Continent)

mcdowell$OlsenP

library(maps)
library(rworldmap)
library(countrycode)
country <- data.frame( 
  mapname = map.where(database="world", 
                      mcdowell$lon, mcdowell$lat)) %>%
  inner_join(iso3166) %>%
  inner_join(countryRegions, by =c(a3="ISO3"))

mccountry <- data.frame( 
  OlsenP = mcdowell$OlsenP,
  Pred_Corrected =  mcdowell$Pred_Corrected,
  lat = mcdowell$lat,
  lon = mcdowell$lon,
  mapname = map.where(database="world", 
                      mcdowell$lon, mcdowell$lat)) %>%
  inner_join(iso3166) %>%
  inner_join(countryRegions, by =c(a3="ISO3")) %>% 
  dplyr::select(lat,lon,OlsenP,Pred_Corrected, a2,a3,ISOname, GEO3major,REGION, continent, GEO3)


df <- mccountry %>%
  dplyr::filter(GEO3major == "Latin America and the Caribbean" | GEO3major == "Africa" )

df %>%
  ggplot(aes(x = OlsenP, y = Pred_Corrected)) +
  ylab("Predicted Olsen P, Pred_Corrected, GMacdowell2023") +
  xlab("Observed Olsen P, OlsenP,  Macdowell2023") +
  geom_point(aes(col = continent)) +
  geom_smooth(method = "lm") +
  geom_text(x = 30, y = 1200, label = lm_eqn(toplot), parse = TRUE) +
  ggpubr::theme_classic2()

 

library(ggmap)
library(maptools)
library(maps)
mapWorld <- borders("world", colour="gray50", fill="white")
mp <- ggplot() + mapWorld


to_plot <- mccountry %>%
  dplyr::filter(GEO3major == "Latin America and the Caribbean" | GEO3major == "Africa" ) 

to_plot$logOlsenP <- log10(to_plot$OlsenP)
hist(to_plot$OlsenP)
hist(to_plot$logOlsenP)


write.csv(to_plot %>% dplyr::select(lat,lon,OlsenP), 
          file ="mcdowell2023_Latam_Africa.csv", 
          quote =FALSE, row.names = FALSE)



quartz()
mp + geom_point(data = to_plot , aes(x = lon, y = lat, color = GEO3major), alpha = 0.5)+
  coord_equal()

quartz()
hist(to_plot$logOlsenP, breaks = 100)

qqnorm(to_plot$logOlsenP)
qqline(to_plot$logOlsenP, col = "red") 


# Histogram with kernel density

quartz()
to_plot %>%
ggplot(aes(x = logOlsenP)) + 
  geom_histogram(aes(y = ..density..),
                 colour = 1, fill = "white") +
  geom_density() +
  stat_function(fun = dnorm,
                args = list(mean = mean(to_plot$logOlsenP),
                            sd = sd(to_plot$logOlsenP)),
                col = "#1b98e0",
                size = 1)


# he2022 <- read.csv("../he2022/14583375/RAW.DATA.CSV")



he2022 <- read.csv("../He2022/14583375/rf.dat.csv")
nrow(he2022)
hecountry <- data.frame( 
  TOTAL_P = he2022$Total_P,
  lat = he2022$LATITUDE,
  lon = he2022$LONGITUDE,
  mapname = map.where(database="world", 
                      he2022$LONGITUDE, he2022$LATITUDE)) %>%
  inner_join(iso3166) %>%
  inner_join(countryRegions, by =c(a3="ISO3")) %>% 
  dplyr::select(lat,lon,TOTAL_P,, a2,a3,ISOname, GEO3major,REGION, continent, GEO3)




to_plot <- hecountry  %>%
  dplyr::filter(GEO3major == "Latin America and the Caribbean" | GEO3major == "Africa" ) 

table(to_plot$GEO3major)
table(to_plot$GEO3)

quartz()
mp + geom_point(data = to_plot , aes(x = lon, y = lat, color = GEO3major), alpha = 0.5)+
  coord_equal()


hist(log10(to_plot$TOTAL_P), breaks = 50)


library(dplyr)
library(ggplot2)

soilp <- read.csv("mcdowell2023_soilp.csv") %>% dplyr::select(-(X:OlsenP))
GEA_other <- read.csv("mcdowell2023_GEA_php.csv")

AFRLAT_merge <- cbind(GEA_other,soilp)
AFRLAT_merge[AFRLAT_merge == -999] <- NA
AFRLAT_merge 

write.csv(AFRLAT_merge, quote = FALSE, row.names =FALSE, 
           file = "mcdowell2023_AFRLAT_merge_to_validate.csv")


m <- AFRLAT_merge %>% dplyr::select(-X,-starts_with("sol"), ends_with("2")) %>% as.matrix()
cols.cor <- cor(m, use = "pairwise.complete.obs")


quartz()
corrplot::corrplot(cols.cor)


lm_eqn <- function(df){
  m <- lm(POL1 ~ OlsenP, df);
  eq <- substitute(italic(y) == a + b %.% italic(x)*","~~italic(r)^2~"="~r2, 
                   list(a = format(unname(coef(m)[1]), digits = 2),
                        b = format(unname(coef(m)[2]), digits = 2),
                        r2 = format(summary(m)$r.squared, digits = 3)))
  as.character(as.expression(eq));
}


toplot <- GEA_other %>%
  dplyr::filter(POL1 >0) %>%
  dplyr::mutate(continent = ifelse(lon < -65, "LAC", "Africa")) 

quartz()

toplot %>%
  ggplot(aes(x = OlsenP, y = POL1)) +
  ylab("Predicted Olsen P, POL1, GDEAS Yang2014") +
  xlab("Observed Olsen P, OlsenP,  Macdowell2023") +
  geom_point(aes(col = continent)) +
  geom_smooth(method = "lm") +
  geom_text(x = 30, y = 1200, label = lm_eqn(toplot), parse = TRUE) +
  ggpubr::theme_classic2()


lm_eqn(toplot)
