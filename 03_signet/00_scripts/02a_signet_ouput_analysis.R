##############################################  SIGNET output analysis #########################################################################################

library(dplyr)

setwd("~/Dropbox/MacBookPro_iMac_shared/02_RNAseq/12_signet_analysis/")

# SIGNET read output ######
#test with the output of the "ALL" comparison i.e Limnetic Vs Benthic across continents
# Extract directly the 'subnet.score' column
all <- read.table(file = "", header = TRUE, sep = "\t")
all_HSS <- read.table(file = "", header = TRUE, sep = "\t")
all_signet <- read.table(file = "", header = TRUE, sep = "\t")

# plot the distribution of all networks subnet scores ####
hist(all$subnet.score, 
     breaks = 1000, 
     xlim = c(0, 1), 
     main = "Distribution of networks subnet scores",
     xlab = "subnet score",
     ylab = "Density")
lines(density(all$subnet.score, na.rm = T, from = 0, to = 1), lty = 2, lwd = 2, col="blue")

# plot the distribution of HSS showing convergence between continents subnet scores ####
hist(all_HSS$score, 
     breaks = 1000, 
     xlim = c(0, 1), 
     #ylim = c(0,10),
     main = "Distribution of HSS scores \n and density of all gene scores analysed in the KEGG database",
     xlab = "Gene score",
     ylab = "Density")
lines(density(xxvoie.metabo$score, na.rm = T, from = 0, to = 1), lty = 2, lwd = 2, col="blue")

# Get gene score within network to be able to plot 'Gene scores distribution' ####
# -> SEE EXTRACT.OBJECT FUNCTION


# Networks analysis using dplyr ####
# nombre de gènes unique
dplyr::n_distinct(xxvoie.metabo$gene)
# nombre de voie métaboliques
dplyr::n_distinct(xxvoie.metabo$VOIE_METABO)
# nombre de gène actif par voie métabolique
stats <- dplyr::filter(xxvoie.metabo, active) %>%
  dplyr::group_by(VOIE_METABO) %>%
  dplyr::tally(.)
# Pour extraire les top 10% des gènes avec les top score par voie métaboliques
top10 <- xxvoie.metabo %>% 
  dplyr::group_by(VOIE_METABO) %>%
  dplyr::filter(dplyr::cume_dist(x = dplyr::desc(score)) < 0.1)
# Pour extraire les top 10% des gènes actifs avec les top score par voie métaboliques
top10 <- xxvoie.metabo %>% 
  dplyr::group_by(VOIE_METABO) %>%
  dplyr::filter(active) %>% 
  dplyr::filter(dplyr::cume_dist(x = dplyr::desc(score)) < 0.999)

# Analysis one Network ####
foxo <- read.table("", header = TRUE)



