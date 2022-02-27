# author: Monique Pires Gravina de Oliveira
# date: 2016-09-07

# This script is meant to: 
# Separate variables and plot trees

rm(list = ls())
gc()
options(stringsAsFactors = FALSE)

# Load Library ------------------------------------------------------------

library(rpart)
library(rpart.plot)
library(party)

# WD ----------------------------------------------------------------------

#setwd(dirname(rstudioapi::getActiveDocumentcountext()$path))

# Load files --------------------------------------------------------------

load("../data/outputs/resultsTarget.RData")

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

