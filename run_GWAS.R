#Setting Memory
#options(java.parameters = "-Xmx10000m")
#at the command line
#>R CMD javareconf
#>ls -ltr /usr/local/lib/libjvm.dylib
#>rm /usr/local/lib/libjvm.dylib
#>sudo ln -s $(/usr/libexec/java_home)/lib/server/libjvm.dylib /usr/local/lib

library(rJava)
#dyn.load('/Library/Java/JavaVirtualMachines/jdk1.8.0_162.jdk/Contents/Home/jre/lib/server/libjvm.dylib')
library(rTASSEL)
#system("java -version")

#Logging file
rTASSEL::startLogger(fullPath = NULL, fileName = NULL)



#####################################################################################################################################
#Loading genotype and phenotype data
#####################################################################################################################################

#Genotype
#From a path
hmp_file <- "hapmap.hmp.txt"
data_dir <- file.path(
  "/Users","nirwantandukar","Documents","RubenLab","Data for sorghum","sorghum"
)
genoPathHMP <- file.path(data_dir, hmp_file)
genoPathHMP


#Load in hapmap file
tasGenoHMP <- rTASSEL::readGenotypeTableFromPath(
  path = genoPathHMP
)

#Phenotype
# Read from phenotype path
pheno_file <- "VL_P.txt"
data_dir <- file.path(
  "/Users","nirwantandukar","Documents","RubenLab","Data for sorghum","sorghum"
)

phenoPath  <- file.path(data_dir,pheno_file)
phenoPath

# Load into pheno file
tasPheno <- rTASSEL::readPhenotypeFromPath(
  path = phenoPath
)


# Load into rTASSEL `TasselGenotypePhenotype` object
tasGenoPheno <- rTASSEL::readGenotypePhenotype(
  genoPathOrObj = tasGenoHMP,
  phenoPathDFOrObj = tasPheno
)
tasGenoPheno

#Get genotype data
tasSumExp <- rTASSEL::getSumExpFromGenotypeTable(
  tasObj = tasGenoPheno
)
tasSumExp

SummarizedExperiment::colData(tasSumExp)


#Extract phenotype data
tasExportPhenoDF <- rTASSEL::getPhenotypeDF(
  tasObj = tasGenoPheno
)
tasExportPhenoDF

#####################################################################################################################################
#Filtering genotype data
#####################################################################################################################################

tasGenoPhenoFilt <- rTASSEL::filterGenotypeTableSites(
  tasObj = tasGenoPheno,
  siteMinCount = 150,
  siteMinAlleleFreq = 0.05,
  siteMaxAlleleFreq = 1.0,
  siteRangeFilterType = "none"
)
tasGenoPhenoFilt
tasGenoPheno

#####################################################################################################################################
#Distance and Kinship matrix
#####################################################################################################################################

#distance matrix
tasDist <- distanceMatrix(tasObj = tasGenoPheno)
tasDist

#Kinship matrix
tasKin <- kinshipMatrix(tasObj = tasGenoPheno)

#TasselDistanceMatrix objects
tasKin


#Coercing kinship matrix to general R data object
library(magrittr)
tasKinR <- tasKin %>% as.matrix()
tasKinR[1:5,1:5]


#####################################################################################################################################
#PCA and MDS
#####################################################################################################################################

#Principal Component Analysis (PCA) and Multidimensional Scaling (MDS)
tasGenoHMP
pcaRes <- pca(tasGenoHMP)
tasDist

mdsRes <- mds(tasDist)
mdsRes


#####################################################################################################################################
#GLM and MLM
#####################################################################################################################################

#Calculate GLM or MLM (add tasKin to kinship)
tasGLM <- rTASSEL::assocModelFitter(
  tasObj = tasGenoPheno,             # <- our prior TASSEL object
  formula = VL ~ .,        # <- only phenotype
  fitMarkers = TRUE,                 # <- set this to TRUE for GLM
  kinship = NULL,
  fastAssociation = FALSE
)

#saveRDS(tasGLM,"manhattan_GLM.RDS") 


tasMLM <- rTASSEL::assocModelFitter(
  tasObj = tasGenoPheno,             # <- our prior TASSEL object
  formula = VL ~ .,        # <- only phenotype
  fitMarkers = TRUE,                 # <- set this to TRUE for GLM
  kinship = tasKin,
  fastAssociation = FALSE
)



#saveRDS(tasGLM,"manhattan_MLM.RDS")

# Return GLM and MLM output
str(tasGLM)
str(tasMLM)



#####################################################################################################################################
#Manhattan plots
#####################################################################################################################################

# Generate Manhattan plot for VL
manhattanGLM <- manhattanPlot(
  assocStats = tasGLM$GLM_Stats,
  trait      = "VL",
  threshold  = 25
)
manhattanGLM

manhattanMLM <- manhattanPlot(
  assocStats = tasMLM$MLM_Stats,
  trait      = "VL",
  threshold  = 5
)
manhattanMLM

#####################################################################################################################################
#LD plots
#####################################################################################################################################

# Filter genotype table by position
tasGenoPhenoFilt <- filterGenotypeTableSites(
  tasObj              = tasGenoPheno,
  siteRangeFilterType = "position",
  startPos            = 55000000,
  endPos              = 60900000,
  startChr            = 10,
  endChr              = 10
)


# Generate and visualize LD
myLD <- ldPlot(
  tasObj  = tasGenoPhenoFilt,
  ldType = "All",
  plotVal = "r2",
  verbose = FALSE
)

myLD

