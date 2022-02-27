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

# Load files --------------------------------------------------------------

load("../data/outputs/resultsPosBaselineSplit.RData")

## Tree analysis -----------------------------------------------------------
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

outputs <- c('smfmd_3', 'sufmd_3')
descriptors <- c('mod', 'city', 'var', 'date', 'irr', 'year', 'soil')
scenarios <- c('rcp', 'gcm', 'approach')

results <- results[,c(descriptors, scenarios, outputs)]
save(results, file = "../data/outputs/simulResultsSum.RData")
