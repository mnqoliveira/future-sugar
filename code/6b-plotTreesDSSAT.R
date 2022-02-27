# author: Monique Pires Gravina de Oliveira
# date: 2016-09-07

# This script is meant to: 
# Separate variables and plot trees

rm(list = ls())
options(stringsAsFactors = FALSE)

# Load Library ------------------------------------------------------------

library(rpart)
library(rpart.plot)
library(party)

# WD ----------------------------------------------------------------------

#setwd(dirname(rstudioapi::getActiveDocumentcountext()$path))

# Load files --------------------------------------------------------------

load("../data/dssat-proc/dssatResults.RData")

# # Create class ------------------------------------------------------------
# Dif from baseline (class)
results$long <- paste(results$city, results$var, results$date,
                      results$soil, results$year, sep = "_")

results$long2 <- paste(results$city, results$var, results$plant,
                      results$soil, sep = "_")


baseline <- results[results$approach == "Baseline",]
 
# Strict absolute diference from baseline (sugar yield)
ti <- Sys.time()
i <- 1
for (i in 1:nrow(results)){
  condition <- baseline$long %in% results$long[i]
  if (sum(condition) == 1){
    results$dif[i] <- (results$sucmd4[i] - baseline$sucmd4[condition])/
      baseline$sucmd4[condition]
  } else {
    results$dif[i] <- NA
  }
}
print(Sys.time() - ti)
summary(results$dif)

# results$class[results$dif < 0] <- "lower"
# results$class[results$dif >= 0] <- "eqLarger"

# Difference from baseline regarding sugarcontent
ti <- Sys.time()
for (i in 1:nrow(results)){
  condition <- baseline$long %in% results$long[i]
  if (sum(condition) == 1){
    results$difPer[i] <- (results$sudmd4[i] - baseline$sudmd4[condition])/
      baseline$sudmd4[condition]
  } else {
    results$difPer[i] <- NA
  }
}
print(Sys.time() - ti)
summary(results$difPerf)

# results$classPer[results$difPer < 0] <- "lower"
# results$classPer[results$difPer >= 0] <- "eqLarger"

# Absolute diference from baseline (z-scored)
baselineMean <- aggregate(baseline$sucmd4,
                          by = list(long2 = baseline$long2),
                          FUN = mean)

baselineSd <- aggregate(baseline$sucmd4,
                          by = list(long2 = baseline$long2),
                          FUN = sd)

ti <- Sys.time()
i <- 1
for (i in 1:nrow(results)){
  basMean <- baselineMean[baselineMean$long2 %in% results$long2[i],"x"]
  basSd <- baselineSd[baselineSd$long2 %in% results$long2[i],"x"]

  results$difZ[i] <- (results$sucmd4[i] - basMean)/basSd
}
print(Sys.time() - ti)
summary(results$difZ)

# # results$classZ[results$difZ < 0] <- "lower"
# # results$classZ[results$difZ >= 0] <- "eqLarger"

# Difference from baseline regarding sugarcontent (z-scored)
baselineMean <- aggregate(baseline$sudmd4,
                          by = list(long2 = baseline$long2),
                          FUN = mean)
baselineSd <- aggregate(baseline$sudmd4,
                        by = list(long2 = baseline$long2),
                        FUN = sd)

baseline$mean <- baselineMean$x
baseline$sd <- baselineSd$x

ti <- Sys.time()
for (i in 1:nrow(results)){
  basMean <- baselineMean[baselineMean$long2 %in% results$long2[i],"x"]
  basSd <- baselineSd[baselineSd$long2 %in% results$long2[i],"x"]

  results$difPerZ[i] <- (results$sudmd4[i] - basMean)/basSd
}
print(Sys.time() - ti)
summary(dat$difPerZ)

#Difference from baseline regarding freshmass (z-scored)
baselineMean <- aggregate(baseline$smdmd4,
                          by = list(long2 = baseline$long2),
                          FUN = mean)
baselineSd <- aggregate(baseline$smdmd4,
                        by = list(long2 = baseline$long2),
                        FUN = sd)

baseline$mean <- baselineMean$x
baseline$sd <- baselineSd$x

ti <- Sys.time()
for (i in 1:nrow(results)){
  basMean <- baselineMean[baselineMean$long2 %in% results$long2[i],"x"]
  basSd <- baselineSd[baselineSd$long2 %in% results$long2[i],"x"]

  results$difDMZ[i] <- (results$smdmd4[i] - basMean)/basSd
}
print(Sys.time() - ti)

results2 <- results$difDMZ
save(results2, file = "../data/dataset/results2.RData")

# Remove variables --------------------------------------------------------

exclude <- grep("sucmd|suid|sudmd|sufmd|long", x = colnames(results))
colnames(results)[exclude]
results <- results[,-exclude]

# Create levels -----------------------------------------------------------
highLevel <- c("city", "method", "cenario", "gcm", "var", "plant", "soil",
               "co2", "year")
envVar <- c("sraa", "tmaxa", "tmina", "prec",
            "pred", "dayld", "twld", "srad", "pard", "cldd", "tmxd", "tmnd",
            "tavd", "tdyd", "tdwd", "tgad", "tgrd", "wdsd", "soil",
            "eoaa", "eopa", "eosa", "esaa", "efaa", "emaa", "eoac",
            "esac", "efac", "emac", "swtd", "swxd", "rofc", "drnc",
            "prec", "irrc", "dtwt", "mwtd", "tdfd", "tdfc", "rofd")
ext <- grepl(pattern = paste(envVar, collapse = "|"), x = colnames(results))
ext <- colnames(results)[ext]

mechan <- c("tsd", "gtsd", "laigd", "lgdmd", "smfmd", "smdmd",
            "rdmd", "badmd", "tad", "lsd", "lddmd", "laitd",
            "wspd", "wsgd", "eosa", "rtld", "lid", "slad", "pgrd", "brdmd",
            "ldgfd", "ttebc", "ttspc", "ttlec", "cwsi", "respcf",
            "etaa", "epaa", "etac", "epac")
int <- grepl(pattern = paste(mechan, collapse = "|"), x = colnames(results))
int <- colnames(results)[int]

save(results, highLevel, ext, int,
     file = "../data/dataset/agrResults.RData")


# Load --------------------------------------------------------------------

load(file = "../data/dataset/agrResults.RData")

# # Remove Baseline ---------------------------------------------------------
# 
results <- results[results$method != "Baseline",]
# 
# # Divide dataset ----------------------------------------------------------
# 
# # Delta
# dfDelta <- results[results$method != "MeanVar",]
# 
# # MAV
# dfMav <- results[results$method != "Delta",]
# 
# # Plot trees --------------------------------------------------------------
# 
# tst <- results[,-match(c("dif", "class", "difPer"), colnames(results))]
# #tst <- tst[,-match(int, colnames(tst))]
# 
# #tst <- tst[,-match(highLevel, colnames(tst))]
# 
# ti <- Sys.time()
# m1 <- rpart(classPer ~ ., data = tst)
# Sys.time() - ti
# 
# rpart.plot(m1,type = 3, extra = 1)
# save(m1, file = "../data/dataset/m1.RData")
# 
# #  ------------------------------------------------------------------------
# 
# tst <- dfDelta[,-match(c("dif", "class", "difPer"), colnames(dfDelta))]
# #tst <- tst[,-match(int, colnames(tst))]
# 
# #tst <- tst[,-match(highLevel, colnames(tst))]
# 
# ti <- Sys.time()
# m2 <- rpart(classPer ~ ., data = tst)
# Sys.time() - ti
# 
# rpart.plot(m2,type = 4, extra = 1)
# save(m2, file = "../data/dataset/m2.RData")
# 
# #  ------------------------------------------------------------------------
# 
# tst <- dfMav[,-match(c("dif", "class", "difPer"), colnames(dfMav))]
# #tst <- tst[,-match(int, colnames(tst))]
# 
# #tst <- tst[,-match(highLevel, colnames(tst))]
# 
# ti <- Sys.time()
# m3 <- rpart(classPer ~ ., data = tst)
# Sys.time() - ti
# 
# rpart.plot(m3,type = 3, extra = 1)
# save(m3, file = "../data/dataset/m3.RData")
# 
# # Ext ---------------------------------------------------------------------
# ext <- c(ext,"classPer")
# int <- c(int, "classPer")
# highLevel <- c(highLevel, "classPer")
# 
# tst <- results[,match(ext, colnames(results))]
# 
# ti <- Sys.time()
# m4 <- rpart(classPer ~ ., data = tst)
# Sys.time() - ti
# 
# rpart.plot(m4,type = 3, extra = 1)
# save(m4, file = "../data/dataset/m4.RData")
# 
# # Int ---------------------------------------------------------------------
# tst <- results[,match(int, colnames(results))]
# 
# ti <- Sys.time()
# m5 <- rpart(classPer ~ ., data = tst)
# Sys.time() - ti
# 
# rpart.plot(m5,type = 3, extra = 1)
# save(m5, file = "../data/dataset/m5.RData")
# 
# # High --------------------------------------------------------------------
# tst <- results[,match(highLevel, colnames(results))]
# 
# ti <- Sys.time()
# m6 <- rpart(classPer ~ ., data = tst)
# Sys.time() - ti
# 
# rpart.plot(m6,type = 3, extra = 2)