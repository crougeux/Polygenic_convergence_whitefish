##################################################################################################################################################################
############################################################  SIGNET  ############################################################################################
##################################################################################################################################################################

# Please, refer to the R packages published by A. Gouy et al. (2017) for more details and citation.

# Load lirairies
devtools::install_github('CMPG/signet', force=TRUE)
source("https://bioconductor.org/biocLite.R")
biocLite("mygene")
biocLite("graphite")
biocLite("org.Hs.eg.db")
biocLite("graph") 
biocLite("RBGL")
biocLite("Rgraphviz")
library(RBGL)
library(Rgraphviz)
library(graph)
library(RCytoscape)
library(mygene)
library(graphite)
library(signet)
library(org.Hs.eg.db)
library(stats)

######################################################### GRAPHITE
pathwayDatabases() #to check pathways and species available
paths <- pathways("hsapiens", "kegg") #get the pathway list
pathway <- lapply(paths, pathwayGraph) #apply the conversion to graph to the list of "pathways" object (graphNEL graph)
########################################################## SIGNET (eXpress) 
# Read the input file with gene and pvalues associated to the fold-change
DE<-read.table("scoreRDA_geneID.txt", header=T, sep="\t")

# Score determination (zScore) and add this info to the input file
#score = 1-qnorm(DE$scoreRDA)
#DE$scoreRDA = score
score_scaled <- scale(DE$scoreRDA, center = TRUE, scale = TRUE)
DE$scoreRDA <- score_scaled
# Prepare signet input 
signet <- subset(DE, select=c("geneID", "scoreRDA"))

# Generate the background distribution
bgDist_cocl <- backgroundDist(pathway, 
               signet, 
               iterations = 5000)

# Apply the simulated annealing algorithm on pathways of your choice
HSS_cocl <- searchSubnet(pathway, 
             signet, 
             iterations = 10000)
            
# Generate the null distribution of the subnetworks scores
null_cocl <- nullDist(pathway,
                 signet,
                 n = 5000,
                 bgDist_cocl)

#Compute p-values
HSS_cocl <- testSubnet(HSS_cocl, null_cocl)
# Results
tab_cocl <- summary(HSS_cocl)
#write the summary table
write.table(tab_cocl,
            file = "",
            sep = "\t",
            quote = FALSE,
            row.names = TRUE)

#Inspect a single pathway and export this pathway in .xgmml format
plot(HSS[[91]]) 
writeXGMML(HSS[[91]], filename = "signet_output.xgmml", threshold = 0.01)



