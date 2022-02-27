# author: Monique Pires Gravina de Oliveira
# date: 2016-09-07

# This script is meant to: 
# Join the different outputs in one data-frame
# Aggregate variables in pre-defined time periods
# Create dependent variable and other interest variables

rm(list = ls())
options(stringsAsFactors = FALSE)

# Load Library ------------------------------------------------------------

library("stringr")
library("tidyverse")

# WD ----------------------------------------------------------------------

#setwd(dirname(rstudioapi::getActiveDocumentcountext()$path))

# Paths -------------------------------------------------------------------

pathLargeOut <- "D:/documentos/Pesquisa/Projetos/futureSugar/data/outputs/"
pathOut <- "../data/outputs/"


# DSSAT -------------------------------------------------------------------
header <- read.csv(paste0(pathOut, "header-dssat.csv"), header = FALSE)
header <- header[1,]
header <- c(as.matrix(header))
header <- tolower(header)
header <- header[-1]

resultsD <- read.csv(paste0(pathOut, "dssatRes.csv"), header = FALSE)
#resultsD <- read.csv(paste0(pathLargeOut, "dssatRes.csv"), header = FALSE)
colnames(resultsD) <- header
rm(header)
gc()

# APSIM -------------------------------------------------------------------
header <- read.csv(paste0(pathOut, "header-apsim.csv"), header = FALSE)
header <- header[1,-1]
header <- c(as.matrix(header))

resultsA <- read.csv(paste0(pathOut, "apsimRes.csv"), header = FALSE)
#resultsA <- read.csv(paste0(pathLargeOut, "apsimRes.csv"), header = FALSE)
resultsA <- resultsA[,-c(1)]
colnames(resultsA) <- header

rm(header)
gc()
# Adjust names ------------------------------------------------------------
#redo
# resultsA2 <- resultsA
# resultsD2 <- resultsD
#undo
# resultsA <- resultsA2
# resultsD <- resultsD2

# Change name for baseline, from 0 to X
condition <- substring(resultsA$exp, 2, 2) == 0
resultsA$exp[condition] <- paste0(substring(resultsA$exp[condition], 1, 1),
                                  "X",
                                  substring(resultsA$exp[condition], 3, 8))

# Order: City, RCP, GCM, Method (Same as AgMIP)
adjustNames <- function(name){
  
  newName <- paste0(substring(name, 1, 1),
                    substring(name, 3, 3),
                    substring(name, 4, 4),
                    substring(name, 2, 2),
                    substring(name, 5, 8))
  return(newName)
}

resultsD$exp <- adjustNames(resultsD$exp)

# Fix irrigation from DSSAT

resultsD$irrc_3 <- resultsD$irrc_3 - resultsD$irrc_2
resultsD$irrc_2 <- resultsD$irrc_2 - resultsD$irrc_1
resultsD$irrc_1 <- resultsD$irrc_1 - resultsD$irrc_0

# Convert column names ----------------------------------------------------
# Determine the equivalence between the outputs from DSSAT and from APSIM
build_name <- function(colname, period){ return(paste0(colname, '_', period)) }
build_keep <- function(a,b) return(paste0(a, '_' ,b))

conv <- read.csv(paste0(pathOut, "conversion.csv"))
conv$dssat <- tolower(conv$dssat)

keep <- expand.grid(conv$dssat, 0:3)
keepers <- mapply(build_keep, keep[,1], keep[,2])
keepers <- c('exp', sort(keepers))

for(i in 1:nrow(conv)){
  for(period in 0:3){
    apos <- match(build_name(conv$apsim[i], period), colnames(resultsA))
    dname <- build_name(conv$dssat[i], period)
    resultsA[, apos] <- resultsA[, apos]*conv$units[i]
    colnames(resultsA)[apos] <- dname
  }
}

resultsA <- resultsA[, keepers]
drop_years <- c('year_1', 'year_2','year_3')
resultsA <- resultsA[, -match(drop_years, colnames(resultsA))]

keepers <- gsub('year_0', 'year', keepers)
keepers <- keepers[-match(drop_years, keepers)]

resultsD <- resultsD[, keepers]
colnames(resultsA)[grep("year_0", colnames(resultsA))] <- "year"

rm(apos, condition, dname, drop_years, i, 
   keepers, period)

# Remove additional simulations  ------------------------------------------
resultsA <- resultsA[resultsA$year != 2010,]

# Fix variables that need to be further processed -------------------------

# The scale for stress variables is inverted. 
# Also, respcf has no equivalent on APSIM

for (i in 0:3){
  stGrowth <- paste("wsgd", i ,sep = "_")
  stPhoto <- paste("wspd", i ,sep = "_")
  stResp <- paste("respcf", i ,sep = "_")
  stWat <- paste("cwsi", i ,sep = "_")
  
  #Change APSIM outputs to consider 1 as the most stressful condition
  resultsA[,stGrowth] <- abs(1-resultsA[,stGrowth])
  resultsA[,stPhoto] <- abs(1-resultsA[,stPhoto])
  resultsA[,stResp] <- NA
  resultsA[,stWat] <- NA
}

rm(stGrowth, stPhoto, stResp, stWat)

# LDDMD = trash (DSSAT) and was alocated as equivalent to biomass (APSIM)
# A trash variable has to be created for APSIM and a biomass variable, for DSSAT
# The APSIM trash variable (named after the variable from DSSAT) is the difference
# between biomass and green biomass.
# The DSSAT biomass variable refers to the sum of the trash variable and the green
# biomass variable

for (i in 0:3){
  varBiom <- paste("biomass", i ,sep = "_")
  varTrash <- paste("lddmd", i ,sep = "_")
  varGreen <- paste("lgdmd", i ,sep = "_")
  
  #biomass = trash + green
  resultsD[,varBiom] <- resultsD[,varTrash] + resultsD[,varGreen]
  
  #trash = biomass - green
  resultsA[,varBiom] <- resultsA[,varTrash]
  resultsA[,varTrash] <-  resultsA[,varBiom] - resultsA[,varGreen]
}

rm(varBiom, varTrash, varGreen)

# sstem_wt only exists in APSIM and was saved as equivalent to DOY, as a 
# temporary solution. It must be fixed to correspond to smdmd - sucmd.

for (i in 0:3){
  varDM <- paste("smdmd", i ,sep = "_")
  varSucDM <- paste("sucmd", i ,sep = "_")
  varStalkDM <- paste("stalk", i ,sep = "_")
  resultsD[,varStalkDM] <- resultsD[,varDM] - resultsD[,varSucDM]
  
  varTemp <- paste("doy", i ,sep = "_")
  resultsA[,varStalkDM] <- resultsA[,varTemp]
  
  resultsA[,varTemp] <- NULL
  resultsD[,varTemp] <- NULL
}

rm(varTemp, varDM, varSucDM, varStalkDM)

# Merge two datasets ------------------------------------------------------
resultsA$mod <- "A"
resultsD$mod <- "D"

#load("../data/outputs/resultsPartial.RData")
results <- rbind(resultsA, resultsD)

save(resultsA, resultsD, file = "../data/outputs/resultsPartial.RData")

# results <- results %>%
#   group_by(year, exp) %>%
#   summarise_all(funs(mean(.,na.rm = TRUE))) %>%
#   as.data.frame()

#rm(resultsA2, resultsD2)
rm(resultsA, resultsD)
gc()

# Extract additional info from the filename -------------------------------
results$city <- sapply(X = substring(results$exp, (1), (1)), 
                       FUN = switch, 
                       "P" = "piracicaba",
                       "R" = "presidente",
                       "J" = "jatai")

results$rcp <- substring(results$exp, (2), (2))
# results$rcp <- NA
# condition <- substring(results$exp, (2), (2)) == "X" 
# results$rcp[condition] <- "baseline"
# results$rcp <- sapply(X = substring(results$exp, (2), (2)), 
#                       FUN = switch, 
#                       "C" = "10-40-4.5",
#                       "E" = "10-40-8.5",
#                       "G" = "40-70-4.5",
#                       "I" = "40-70-8.5",
#                       "baseline" = "baseline")

results$gcm <- substring(results$exp, (3), (3))

results$approach <- substring(results$exp, (4), (4))
# results$approach <- NA
# condition <- substring(results$exp, (4), (4)) == "X"
# results$approach[condition] <- "baseline"
# results$approach <- sapply(X = substring(results$exp, (4), (4)), 
#                            FUN = switch, 
#                            "A" = "delta",
#                            "F" = "mav",
#                            "baseline" = "baseline")

results$var <- sapply(X = substring(results$exp, (5), (5)), 
                       FUN = switch, 
                       "1" = "RB867515",
                       "2" = "RB73454")

results$date <- sapply(X = substring(results$exp, (6), (6)), 
                       FUN = switch, 
                       "1" = "may",
                       "2" = "aug",
                       "3" = "nov")

results$soil <- sapply(X = substring(results$exp, (7), (7)), 
                       FUN = switch, 
                       "1" = "clayey",
                       "2" = "sandy")

results$irr <- sapply(X = substring(results$exp, (8), (8)), 
                       FUN = switch,
                       "1" = "rainfed",
                       "2" = "irrigated")

colnames(results)
results <- results[,c(1, 114, 123:131, 2:113, 115:122)]
colnames(results)

#results <- results[,-c(2)]

save(results, file="../data/outputs/resultsPreBaseline.RData")
# load("../data/outputs/resultsPreBaseline.RData")

gc()

results = results %>%
  select(mod, city, rcp, var, date,irr,year, soil,
         smdmd_3, smfmd_3, sudmd_3, sucmd_3, sufmd_3) %>%
  filter(rcp == 'X') %>% select(-rcp) %>%
  right_join(results, by=c('mod', 'city', 'var', 'date', 'irr', 'year', 'soil'),
             suffix=c('_base', ''))

print(summary(results[, c('smdmd_3', 'smfmd_3', 'sudmd_3',
                          'sucmd_3', 'sufmd_3')]))

save(results, file = "../data/outputs/resultsPosBaselineSplit.RData")