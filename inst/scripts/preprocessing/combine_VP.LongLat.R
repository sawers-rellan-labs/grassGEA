###Packages Used:
library(stringr)
library(dplyr)

##Reading the genotype ids
allgeno <- read.table("genotype_ids.txt")
head(allgeno)
colnames(allgeno) <- c("Name","is_no.PI","NA","NA2","NA3")

##Subsetting IS and PI names
is <- allgeno %>%
  filter(str_detect(is_no.PI, "IS"))
pi <- allgeno %>%
  filter(str_detect(is_no.PI, "PI"))


##Reading the VL_P phenotype ids
VL_P <- read.table("VL_P.txt")
head(VL_P)
x <- row.names(VL_P)
VL_P$Name <- x
VL_P <- as.data.frame(VL_P[c(-1,-2),])
colnames(VL_P) <- c("VL_P","Name")
head(VL_P)


##Reading the Longitude and Latitude table
ll <- read.table("georef.csv", sep=",")
head(ll)
colnames(ll) <- ll[1,]
head(ll)
ll <- ll[-1,]
head(ll)


##Common IS
is.allgeno <- inner_join(is, allgeno, by = "Name")
colnames(is.allgeno)[2] <- "is_no"
is.allgeno.ll <- inner_join(is.allgeno,ll, by = "is_no")
#Remaining IS
rem.is <- left_join(is, allgeno, by="Name")

##Common PI
pi.allgeno <- inner_join(pi, allgeno, by = "Name")
colnames(pi.allgeno)[2] <- "pi"
pi.allgeno.ll <- inner_join(pi.allgeno,ll, by = "pi")

##Total in IS and PI
1122+844

#Combining IS with VL_P
is.VL_P <- inner_join(VL_P, is.allgeno.ll, by = "Name")
#Removing Duplicates
is.VL_P <- is.VL_P[!duplicated(is.VL_P$Name), ]

my_data[!duplicated(my_data$Sepal.Width), ]

#Combining PI with VL_P
pi.VL_P <- inner_join(VL_P, pi.allgeno.ll, by = "Name")

#Total table with IS and PI
1099+844
1943
#Total in VL_P
1943

#Combining the two tables 
onlyis <- is.VL_P[,c(2,1,12,13)]
onlypi <- pi.VL_P[,c(2,1,12,13)]
is.pi.allpheno <- rbind(onlyis,onlypi)

#setwd("~/Library/Mobile Documents/com~apple~CloudDocs/Data for sorghum/sorghum/Gemma.gwas")
#write.csv(is.pi.allpheno,"VL_P.and.LongLat.csv")
