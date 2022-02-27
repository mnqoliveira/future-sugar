# author: Monique Pires Gravina de Oliveira
# date: 2017-07-23

# This script is meant to: 
# Separate variables and plot trees

rm(list = ls())
gc()
options(stringsAsFactors = FALSE)

# Load Library ------------------------------------------------------------

library(tidyverse)
# WD ----------------------------------------------------------------------

#setwd(dirname(rstudioapi::getActiveDocumentcountext()$path))

# # Tree analysis -----------------------------------------------------------
# # Load files --------------------------------------------------------------
# 
# load("../data/outputs/resultsPosBaselineSplit.RData")
# 
# # Choose target attribute -------------------------------------------------
# results <- results[results$sucmd_3 != 0,]
# results <- results[!is.na(results$sucmd_3),]
# results <- results[results$approach != "X",]
# 
# # Sugar Content
# results$targetSC <- results$sufmd_3 - results$sufmd_3_base
# 
# summary(results$sufmd_3)
# summary(results$targetSC)
# 
# hist(results$sufmd_3)
# hist(results$targetSC)
# 
# # # Sugar Yield
# # results$targetSY <- results$sucmd_3 - results$sucmd_3_base
# #
# # summary(results$sucmd_3)
# # summary(results$targetSY)
# #
# # hist(results$sucmd_3)
# # hist(results$targetSY)
# #
# # # Fresh Mass
# # results$targetFM <- results$smfmd_3 - results$smfmd_3_base
# #
# # summary(results$smfmd_3)
# # summary(results$targetFM)
# #
# # hist(results$smfmd_3)
# # hist(results$targetFM)
# #
# # # Sugar content (SDM)
# # results$targetSDM <- results$sudmd_3 - results$sudmd_3_base
# # summary(results$sudmd_3)
# # summary(results$targetSDM)
# #
# # hist(results$sudmd_3)
# # hist(results$targetSDM)
# #
# # # Dry mass (stalk)
# # results$targetDM <- results$smdmd_3 - results$smdmd_3_base
# # summary(results$smdmd_3)
# # summary(results$targetDM)
# #
# # hist(results$smdmd_3)
# # hist(results$targetDM)
# 
# # Create class ------------------------------------------------------------
# # Class: sudmd_3
# 
# devBaseline <- results %>%
#   group_by(city, gcm, rcp, approach, var, date, soil, irr, mod) %>%
#   summarise(periodDev = sd(sufmd_3_base, na.rm = TRUE)) %>%
#   as.data.frame()
# 
# results <- results[!is.na(results$sufmd_3),]
# results$class <- NA
# 
# results <- results %>%
#   right_join(devBaseline, by = c('city', 'gcm', 'rcp', 'approach', 'var',
#                                  'date', 'irr', 'soil', 'mod')) %>%
#   group_by(city, gcm, rcp, approach, var, date, soil, irr, mod) %>%
#   mutate(class = ifelse(targetSC < -periodDev, "lower", "eqHigher")) %>%
#   as.data.frame()
# 
# table(results$class)
# 
# # Remove variables --------------------------------------------------------
# 
# exclude <- grep("exp", x = colnames(results))
# colnames(results)[exclude]
# results <- results[,-exclude]
# 
# save(results, file = "../data/outputs/resultsTarget.RData")

# Economic Analysis -------------------------------------------------------

load("../data/outputs/resultsPreBaseline.RData")
sort(colnames(results))

# tst <- c('badmd_3', 'lgdmd_3', 'smfmd_3')
# con <- results$mod == "D"
# tst2 <- results[con,tst]
# par(mfrow = c(3,1))
# hist((tst2$smfmd_3), main = "tch")
# hist((tst2$badmd_3), main = "green + trash")
# hist((tst2$lgdmd_3), main = "green")
# b <- tst2$badmd_3 - tst2$lgdmd_3
# 
# par(mfrow = c(1,1))
# hist((tst2$badmd_3/tst2$smfmd_3), main = "g+t/tch")
# 
# hist((tst2$badmd_3 - tst2$lgdmd_3))

outputs <- c('smfmd_3', 'sufmd_3', "stalk_3", "lddmd_3")
descriptors <- c('mod', 'city', 'var', 'date', 'irr', 'year', 'soil')
scenarios <- c('rcp', 'gcm', 'approach')

results <- results[,c(descriptors, scenarios, outputs)]

renameFrom <- paste(outputs, collapse = "|")
renameTo <- c("tch", "pol", "fiber", "trash")
renamePos <- grep(renameFrom, colnames(results))

colnames(results)[renamePos] <- renameTo

# Limit cultivar only to RB867515
results <- results[results$var == "RB867515",]
results <- results[,-match('var', colnames(results))]

# Adjust yields to account for ratoon yield decline
# For rainfed simulations, yield drops 20% each year up to the 5th ratoon
# Therefore, the final yield = (1 + 0.8 + 0.8^2 + 0.8^3 + 0.8^4)*yield/5
constant <- (1 + 0.8 + 0.8^2 + 0.8^3 + 0.8^4)/5
condition <- results$irr == "rainfed" 
results$tch[condition] <- constant*results$tch[condition]
results$fiber[condition] <- constant*results$fiber[condition]
results$trash[condition] <- constant*results$trash[condition]

# For irrigated simulations, the decline is assumed to be 15%
constant <- (1 + 0.85 + 0.85^2 + 0.85^3 + 0.85^4)/5
condition <- results$irr == "irrigated" 
results$tch[condition] <- constant*results$tch[condition]
results$fiber[condition] <- constant*results$fiber[condition]
results$trash[condition] <- constant*results$trash[condition]

# 28 % May, 44% Aug and 28% Nov. (Marin 2013)
results$weight[results$date == "aug"] <- 0.44
results$weight[results$date != "aug"] <- 0.28

results <- results[,-match('date', colnames(results))]

results <- results %>%
  group_by(year, mod, city, gcm, irr, soil,
           rcp, approach) %>%
  summarise_all(funs(weighted.mean(., weight,
                                    na.rm = TRUE))) %>%
  as.data.frame()

# Percentages of soil
condition <- results$soil == "clayey"

proportion <- 0.672
results$weight[results$city == "jatai" & condition] <- proportion
results$weight[results$city == "jatai" & !condition] <- (1-proportion)

proportion <- 0.298
results$weight[results$city == "piracicaba" & condition] <- proportion
results$weight[results$city == "piracicaba" & !condition] <- (1-proportion)

proportion <- 1
results$weight[results$city == "presidente" & condition] <- proportion
results$weight[results$city == "presidente" & !condition] <- (1-proportion)

results <- results[,-match('soil', colnames(results))]

results <- results %>%
  group_by(year, mod, city, gcm, irr, rcp, approach) %>%
  summarise_all(funs(weighted.mean(.,weight,
                                    na.rm = TRUE))) %>%
  as.data.frame()

# Generation of adaptation scenarios (irrigation)

n <- nrow(results)
results$scen <- NA
results <- rbind(results, results)
results$scen[1:n] <- 0
results$scen[is.na(results$scen)] <- 1

condition1 <- results$irr == "irrigated"
condition2 <- results$scen == 0

# Irrigated and current conditions
proportion <- 0.269
results$weight[results$city == "jatai" & condition1 & condition2] <- proportion
results$weight[results$city == "jatai" & !condition1 & condition2] <- (1-proportion)

proportion <- 2000/49000
results$weight[results$city == "piracicaba" & condition1 & condition2] <- proportion
results$weight[results$city == "piracicaba" & !condition1 & condition2] <- (1-proportion)

proportion <- 1000/5442
results$weight[results$city == "presidente" & condition1 & condition2] <- proportion
results$weight[results$city == "presidente" & !condition1 & condition2] <- (1-proportion)

# Irrigated and in an adaptation scenario
proportion <- 0.60
results$weight[results$city == "jatai" & condition1 & !condition2] <- proportion
results$weight[results$city == "jatai" & !condition1 & !condition2] <- (1-proportion)

proportion <- 0.25
results$weight[results$city == "piracicaba" & condition1 & !condition2] <- proportion
results$weight[results$city == "piracicaba" & !condition1 & !condition2] <- (1-proportion)

proportion <- 0.60
results$weight[results$city == "presidente" & condition1 & !condition2] <- proportion
results$weight[results$city == "presidente" & !condition1 & !condition2] <- (1-proportion)

results <- results[,-match('irr', colnames(results))]

results <- results %>%
  group_by(year, mod, city, gcm, rcp, approach, scen) %>%
  summarise_all(funs(weighted.mean(.,weight,
                                    na.rm = TRUE))) %>%
  as.data.frame()

save(results, file = "../data/outputs/simulResultsSum.RData")
#load("../data/outputs/simulResultsSum.RData")


