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

# WD ----------------------------------------------------------------------

#setwd(dirname(rstudioapi::getActiveDocumentcountext()$path))

# Paths -------------------------------------------------------------------

pathLargeOut <- "D:/documentos/Pesquisa/Projetos/futureSugar/data/dssat-proc/"
pathOut <- "../data/dssat-proc/"

# Load files --------------------------------------------------------------


# Define column names
header <- read.csv(paste0(pathOut, "header.csv"), header = FALSE)
#header <- read.csv(paste0(pathOut, "dssatHeader.csv"), header = FALSE)
header <- header[1,]
header <- c(as.matrix(header))
header <- tolower(header)

results <- read.csv(paste0(pathLargeOut, "dssatRes.csv"), header = FALSE)
colnames(results) <- header

# Extract additional info from the filename -------------------------------
results$city <- sapply(X = substring(results$exp, (1), (1)), 
                       FUN = switch, 
                       "P" = "piracicaba",
                       "R" = "presidente",
                       "J" = "jatai")

results$approach <- NA
results$approach[substring(results$exp, (2), (2)) == "X"] <- "baseline"
results$approach <- sapply(X = substring(results$exp, (2), (2)), 
                       FUN = switch, 
                       "A" = "delta",
                       "F" = "mav",
                       "baseline" = "baseline")

results$rcp <- NA
results$rcp[substring(results$exp, (3), (3)) == "X"] <- "baseline"
results$rcp <- sapply(X = substring(results$exp, (3), (3)), 
                      FUN = switch, 
                      "C" = "10-40-4.5",
                      "E" = "10-40-8.5",
                      "G" = "40-70-4.5",
                      "I" = "40-70-8.5",
                      "baseline" = "baseline")

results$gcm <- substring(results$exp, (4), (4))

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

results <- results[,-1]
results <- results[,c(298:305,1:297)]

save(results, file="../data/dssat-proc/dssatResults.RData")

