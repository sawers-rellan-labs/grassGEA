# I need a raster with land coverage
# I'll start with FAO74.tif

# this is an 16bit raster keeping a mapunit number (0, 6998)
# in order to retrieve the aactual FAO soil class we would need
# to merge the mapunit number with the FAO id (mu in soilclass package)
# (I'll come to this later) and
# 0 is for water

# library(raster)
#
# dir <- "/Users/fvrodriguez/Projects/NCSU/06_GEA/GIS/soilP"
# file <-"FAO74.tif"
# r <- raster(file.path(dir,file))
# names(r)[1] <- "z"
# hist(r)

#raster_df <- as.data.frame(r , xy=TRUE)

# raster::writeRaster(raster_df,
# filename = file.path(dir,"landcover10km.tif"),
# forrmat ="GTiff", datatypeCharacter= "LOG1S")


# write.csv(raster_df,
#          file = file.path(dir,"landcover10km.csv"),
#          quote = FALSE, row.names = FALSE)



library(raster)
dir <- "/Users/fvrodriguez/Projects/NCSU/06_GEA/GIS/soilP"
file <-"landcover10km.tif"
r <- raster(file.path(dir,file))
names(r) <- "z"
summary(r)
r

raster_df <- as.data.frame(r, xy = TRUE)

# Split dataframe in 25

n_rows <- nrow(raster_df)
num_splits <- 25
rows_per_split <- ceiling(n_rows / num_splits)
split_indices <- seq(1, n_rows, by = rows_per_split)
split_indices <- c(split_indices, n_rows + 1) # Add the final row as an endpoint

for (i in 1:(length(split_indices) - 1)) {

  start <- split_indices[i]
  end <- split_indices[i + 1] - 1
  out_file <- paste0("landcover10km", sprintf("%02d", i), ".csv")
  write.table( raster_df[start:end, ],
               file = file.path(dir, out_file), sep=",",
               quote = FALSE,
               col.names = FALSE)
}






