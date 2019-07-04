#############
# RDA Shape # 
#############
ls()
rm(list=ls())
ls()
setwd("")

#### Step1: As the RDA does not allows for missing data, we propose an intra-population inputation of missing data using machine learning
################################# RF imputations of NAs - stackR ####
if (!require("devtools")) install.packages("devtools") # to install
devtools::install_github("thierrygosselin/stackr")
library(stackr)
if (!require("devtools")) install.packages("devtools") # to install
devtools::install_github("thierrygosselin/radiator")
library(radiator)
devtools::install_github("zhengxwen/SeqArray")
source("https://bioconductor.org/biocLite.R")
biocLite("SeqArray")
library(SeqArray)
biocLite("SeqVarTools")
library(SeqVarTools)


# Impute & Write VCF
pop.levels <- c()
pop.labels <- c()

lavaretus <- genomic_converter(data = "genotype.vcf",
  output = c("vcf"),
  #pop.levels = pop.levels, 
  #pop.labels = pop.labels, 
  strata = "population_map",
  imputation.method = "rf", 
  #hierarchical.levels = "populations", 
  #num.tree = 100, 
  #iteration.rf = 10, 
  #split.number = 100, 
  verbose = TRUE, 
  parallel.core = 4
  )

### ---> Step2: Formating VCF files in order to get a 012 matrix without NAs for the RDA
### Got to Unix VCF formating to RDA analysis (02_vcf2cRDA_formating.sh)

#### Step3: Run the RDA
################################# RDA analysis ####
library(data.table)
library(vegan)

### Charger les facteurs de contraintes pour la matrice explicative (indépendante) ####
indep <- read.table("independante_matrix.txt",header=TRUE, sep="\t")

### Charger la matrice des données d'expression pour la matrice dépendante ####
dep <- read.table("dependante_matrix.txt",header=TRUE, sep="\t")
dep <- as.matrix(dep)

### Lancer la RDA partielle ####
rda_cond_geno_all <- rda(dep ~ Form + Condition(Lake+Continent), scale=T, data=indep, na.action=na.omit)
### Résultat de la RDA :
summary(rda_cond_geno_all, display=NULL)

#Calcul du R2 ajusté de la RDA partielle ####
(R2_cond_all <- RsquareAdj(rda_cond_geno_all)$r.squared)

#Test de la significativité des axes ####
anova.cca(rda_cond_geno_all, step=10, by="axis")
score_rda_cond_geno_all<- scores(rda_cond_geno_all)
score_rda1_cond_geno_all <- score_rda_cond_geno_all$species
write.table(x = score_rda1_cond_geno_all, "score_RDA1_cond.txt", sep="\t")

### Plot the RDA ####
plot(rda_cond_geno_all, main = "cRDA genotypes all individuals")
points(scores(rda_cond_geno_all)$sites[1:24,], pch=19, cex=1, bg="black")
col = c("steelblue", "orange")
ordihull(rda_cond_geno_all, indep$Form, col=col, lwd=1)
rp <- vector('expression',1)
rp[2] <- substitute(expression(italic(P) == valueB), 
                    list(valueB = format(0.001, digits = 2)))[2]
legend("bottomleft",legend = rp, bty = 'n')


##### Explore the SNPs associated with divergence between ecotypes
rda1_SUI_geno <- read.table("score_RDA1_cond.txt", header = TRUE)
#check the distribution of the score
hist(rda1_SUI_geno$RDA1)
#Transform the distribution into normal distribution if needed
zrda1 <- (rda1_SUI_geno$RDA1 - mean(rda1_SUI_geno$RDA1)) / sd(rda1_SUI_geno$RDA1)
hist(zrda1)
write.table(x = zrda1, "~/Dropbox/MacBookPro_iMac_shared/02_RNAseq/11_RDA_analysis/03_outputs_RDA/Zscore_RDA1_cond_SUI_geno.txt", sep="\t")

#Define value (2.6) for a significant threshold level at P=0.01, in order to identify outlier loci.
(1-pnorm(2.6, mean = 0, sd = 1))*2 # =0.009322376


