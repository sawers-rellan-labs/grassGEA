#Reaading the files
sap.1 <- read.delim("~/Documents/RubenLab/Data for sorghum/sorghum/SAP genotype/SNP_genotype/SAP_358_imputed.txt", header=F)
sap.2 <- read.delim("~/Documents/RubenLab/Data for sorghum/sorghum/SAP genotype/SNP_genotype/SAP.377.accessions.filteredSNP.imp.all.hmp.txt", header=F)
geno <- read.delim("sb_snpsDryad_sept2013_filter.c10.imp.hmp.txt",header=F)


#Separating the genotype names
sap2_geno <- as.data.frame(sap.2[1,])
#write.csv(sap2_geno,"sap2_geno.csv", row.names=T)
sap2_geno <- read.delim("sap2_geno.txt", header=F)


geno_geno <- as.data.frame(geno[1,])
#write.csv(geno_geno,"geno_geno.csv", row.names=T)
geno_geno <- read.delim("geno_geno.txt", header=F)


#Phenotype
pheno <- read.csv("Phenotype_Long&Lat.csv", header=F)
head(pheno)
#irisSubset <- iris[grep("osa", iris$Species), ]
is_no <- pheno[grep("IS ", pheno$V1),]
head(is_no)
is_no <- is_no[,c(1,3,4)]
colnames(is_no) <- c("ID", "Latitude","Longtitude")

pi_no <- pheno[grep("PI ", pheno$V2),]
head(pi_no)
pi_no <- pi_no[,c(2,3,4)]
colnames(pi_no) <- c("ID", "Latitude","Longtitude")

#Combining
pheno_all <- rbind(is_no,pi_no)
write.csv(pheno_all,"pheno.all.csv",row.names=T)

#removing space
library(stringr)
as.data.frame(apply(df,2, function(x) str_replace_all(string=x, pattern=” “, repl=””)))
pheno_all <- as.data.frame((apply(pheno_all,2,function(x) str_replace_all(string = x, pattern = " ", repl=""))))

#Available genotypes
avai_geno <- as.data.frame(geno[1,])
write.csv(avai_geno,"avai_geno.csv")

