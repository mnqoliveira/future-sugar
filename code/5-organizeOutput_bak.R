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

resultsD <- read.csv(paste0(pathLargeOut, "dssatRes.csv"), header = FALSE)
colnames(resultsD) <- header
rm(header)

# APSIM -------------------------------------------------------------------
header <- read.csv(paste0(pathOut, "header-apsim.csv"), header = FALSE)
header <- header[1,-1]
header <- c(as.matrix(header))

resultsA <- read.csv(paste0(pathLargeOut, "apsimRes.csv"), header = FALSE)
resultsA <- resultsA[,-c(1,2)]
colnames(resultsA) <- header

# Adjust names ------------------------------------------------------------
#redu
#resultsA2 <- resultsA
#resultsD2 <- resultsD
#andu
#resultsA <- resultsA2
#resultsD <- resultsD2

# Change name for baseline, from 0 to X
condition <- substring(resultsA$exp, 2, 2) == 0
resultsA$exp[condition] <- paste0(substring(resultsA$exp[condition], 1, 1),
                                  "X",
                                  substring(resultsA$exp[condition], 3, 8))

# Order: RCP, GCM, Method (Same as AgMIP)
adjustNames <- function(name){
  
  newName <- paste0(substring(name, 1, 1),
                    substring(name, 3, 3),
                    substring(name, 4, 4),
                    substring(name, 2, 2),
                    substring(name, 5, 8))
  return(newName)
}

resultsD$exp <- adjustNames(resultsD$exp)

# Convert column names ----------------------------------------------------
build_name = function(colname, period){ return(paste0(colname, '_', period)) }
build_keep = function(a,b) return(paste0(a, '_' ,b))

conv <- read.csv(paste0(pathOut, "conversion.csv"))
conv$dssat <- tolower(conv$dssat)

keep = expand.grid(conv$dssat, 0:3)
keepers = mapply(build_keep, keep[,1], keep[,2])
keepers = c('exp', sort(keepers))

for(i in 1:nrow(conv)){
  for(period in 0:3){
    apos = match(build_name(conv$apsim[i], period), colnames(resultsA))
    dname = build_name(conv$dssat[i], period)
    resultsA[, apos] = resultsA[, apos]*conv$units[i]
    colnames(resultsA)[apos] = dname
  }
}

resultsA <- resultsA[, keepers]
drop_years = c('year_1', 'year_2','year_3')
resultsA = resultsA[, -match(drop_years, colnames(resultsA))]

keepers = gsub('year_0', 'year', keepers)
keepers = keepers[-match(drop_years, keepers)]

resultsD <- resultsD[, keepers]
colnames(resultsA)[grep("year_0", colnames(resultsA))] <- "year"

# Remove additional simulations  ------------------------------------------
resultsA <- resultsA[resultsA$year != 2010,]

# Merge two datasets ------------------------------------------------------
results <- rbind(resultsA, resultsD)

results <- results %>%
  group_by(year, exp) %>%
  summarise_all(funs(mean(.,na.rm = TRUE))) %>%
  as.data.frame()

# Extract additional info from the filename -------------------------------
results$city <- sapply(X = substring(results$exp, (1), (1)), 
                       FUN = switch, 
                       "P" = "piracicaba",
                       "R" = "presidente",
                       "J" = "jatai")

results$rcp <- NA
results$rcp[substring(results$exp, (2), (2)) == "X"] <- "baseline"
results$rcp <- sapply(X = substring(results$exp, (2), (2)), 
                      FUN = switch, 
                      "C" = "10-40-4.5",
                      "E" = "10-40-8.5",
                      "G" = "40-70-4.5",
                      "I" = "40-70-8.5",
                      "baseline" = "baseline")

results$gcm <- substring(results$exp, (3), (3))

results$approach <- NA
results$approach[substring(results$exp, (4), (4)) == "X"] <- "baseline"
results$approach <- sapply(X = substring(results$exp, (4), (4)), 
                           FUN = switch, 
                           "A" = "delta",
                           "F" = "mav",
                           "baseline" = "baseline")

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

results <- results[,c(1:2, 83:89, 3:82)]
colnames(results)

#results <- results[,-c(2)]

results2 = results %>% 
  select(city, rcp, var, date,irr,year, sudmd_3, sucmd_3) %>%
  filter(rcp == 'X') %>% select(-rcp) %>%
  right_join(results, by=c('city', 'var', 'date', 'irr', 'year'),
             suffix=c('', '_base'))



save(results, file="../data/dssat-proc/dssatResults.RData")

