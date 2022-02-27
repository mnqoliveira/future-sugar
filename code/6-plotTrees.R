# author: Monique Pires Gravina de Oliveira
# date: 2016-09-07

# This script is meant to: 
# Separate variables and plot trees

rm(list = ls())
gc()
options(stringsAsFactors = FALSE)

# Load Library ------------------------------------------------------------

library(tidyverse)
library(rpart)
library(rpart.plot)
library(party)

# WD ----------------------------------------------------------------------

#setwd(dirname(rstudioapi::getActiveDocumentcountext()$path))

# Load files --------------------------------------------------------------

load("../data/outputs/resultsPosBaselineSplit.RData")


# Choose target attribute -------------------------------------------------
results <- results[results$sucmd_3 != 0,]
results <- results[!is.na(results$sucmd_3),]
results <- results[results$approach != "X",]

# # Sugar Yield
# results$targetSY <- results$sucmd_3 - results$sucmd_3_base
# 
# summary(results$sucmd_3)
# summary(results$targetSY)
# 
# hist(results$sucmd_3)
# hist(results$targetSY)
# 
# # Fresh Mass
# results$targetFM <- results$smfmd_3 - results$smfmd_3_base
# 
# summary(results$smfmd_3)
# summary(results$targetFM)
# 
# hist(results$smfmd_3)
# hist(results$targetFM)
# 
# # Sugar content (SDM)
# results$targetSDM <- results$sudmd_3 - results$sudmd_3_base
# summary(results$sudmd_3)
# summary(results$targetSDM)
# 
# hist(results$sudmd_3)
# hist(results$targetSDM)
# 
# # Dry mass (stalk)
# results$targetDM <- results$smdmd_3 - results$smdmd_3_base
# summary(results$smdmd_3)
# summary(results$targetDM)
# 
# hist(results$smdmd_3)
# hist(results$targetDM)

# Create class ------------------------------------------------------------
# Class: sudmd_3

devBaseline <- results %>%
  group_by(city, gcm, rcp, approach, var, date, soil, irr, mod) %>%
  summarise(periodDev = sd(sudmd_3_base, na.rm = TRUE)) %>%
  as.data.frame()

results <- results[!is.na(results$sudmd_3),]
results$class <- NA

results <- results %>%
  right_join(devBaseline, by = c('city', 'gcm', 'rcp', 'approach', 'var', 
                                 'date', 'irr', 'soil', 'mod')) %>%
  group_by(city, gcm, rcp, approach, var, date, soil, irr, mod) %>%
  mutate(class = ifelse(targetSDM < -periodDev, "lower", "eqHigher")) %>%
  as.data.frame()

table(results$class)

# Remove variables --------------------------------------------------------

exclude <- grep("exp", x = colnames(results))
colnames(results)[exclude]
results <- results[,-exclude]

save(results, file = "../data/outputs/resultsTarget.RData")
#load("../data/outputs/resultsTarget.RData")

# Create levels -----------------------------------------------------------
highLevel <- c("approach", "city", "date", "gcm", "irr", "rcp",
               "soil", "var", "mod")
  
envVar <- c("dayld", "eoaa", "eopa", "esaa", "pred", "srad",
            "swxd", "tmnd", "tmxd")
ext <- grepl(pattern = paste(envVar, collapse = "|"), x = colnames(results))
ext <- colnames(results)[ext]

mechan <- c("badmd", "brdmd", "epaa", "laigd", "lgdmd", "lid",
            "smdmd", "smfmd", "smdmd", "smfmd",
            "sucmd", "sudmd", "tad")

target <- c("sudmd", "sucmd")
mechan <- mechan[!mechan %in% target]

int <- grepl(pattern = paste(mechan, collapse = "|"), x = colnames(results))
int <- colnames(results)[int]

# Plot trees --------------------------------------------------------------

# ctrl = ctree_control(maxdepth=3, mincriterion=0.99)
# tree_extDifD <- ctree(class ~.,
#                       data = results[, c(ext)],
#                       controls = ctrl) 

dat <- results[,c(highLevel, "class")]
m1 <- rpart(class ~ ., data = dat)
png(filename = "../figures/treeHigh.png", 
    height = 900, width = 900)
rpart.plot(m1, extra = 2, type = 1, nn = TRUE)
dev.off()

idHL <- row.names(m1$frame)
results$idHL <- idHL[m1$where]

condition1 <- (results$idHL == "115" | results$idHL == "29" |
                results$idHL == "15")
dat <- results[condition,c(ext, "class")]
m2 <- rpart(class ~ ., data = dat)
png(filename = "../figures/treeExt.png", 
    height = 900, width = 900)
rpart.plot(m2, extra = 2, type = 1, nn = TRUE)
dev.off()

idExt <- row.names(m2$frame)
results$idExt <- NA
results$idExt[condition1] <- idExt[m2$where]

condition2 <- (condition1 &
                 (results$idExt == "13" | results$idExt == "7"))
dat <- results[condition,c(int, "class")]
m3 <- rpart(class ~ ., data = dat)
png(filename = "../figures/treeInt.png", 
    height = 900, width = 900)
rpart.plot(m3, extra = 2, type = 1)
dev.off()

