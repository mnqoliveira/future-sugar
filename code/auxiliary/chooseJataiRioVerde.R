# Script to compare average weather in Jataí and in Rio Verde.
rm(list = ls())

#setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
#?make_datetime

# Libraries ---------------------------------------------------------------


# Check averages ----------------------------------------------------------

load(file = "save_evtng.RData")

setwd("../data/weather/")
folders <- list.dirs(".")
pos <- match(".", folders)
folders <- folders[-pos]

jat <- grep("jatai",folders)
rv <- grep("rioverde",folders)

dfAvgJatai <- data.frame(matrix(nrow = 7, ncol = 12))
row.names(dfAvgJatai) <- c("tmaxmax", "tmaxmin", "tminmax", "tminmin",
                   "sradmax", "sradmin", "pptsum")

dfAvgRV <- data.frame(matrix(nrow = 7, ncol = 12))
row.names(dfAvgRV) <- c("tmaxmax", "tmaxmin", "tminmax", "tminmin",
                           "sradmax", "sradmin", "pptsum")

dfAvgPira <- data.frame(matrix(nrow = 7, ncol = 12))
row.names(dfAvgPira) <- c("tmaxmax", "tmaxmin", "tminmax", "tminmin",
                        "sradmax", "sradmin", "pptsum")

k <- 0

for (j in 1:length(folders)){
  for (i in 1:nrow(dfAvgRV)){
    k <- k + 1
    
    if(j == jat){
      dfAvgJatai[i,] <- colMeans(save_evtng[[k]][,2:13])
    } else if(j == rv){
      dfAvgRV[i,] <- colMeans(save_evtng[[k]][,2:13])
    } else {
      dfAvgPira[i,] <- colMeans(save_evtng[[k]][,2:13])
    }
  }
}

round(dfAvgRV,2) - round(dfAvgJatai,2)
round(dfAvgRV,2) - round(dfAvgPira,2)
round(dfAvgJatai,2)- round(dfAvgPira,2)

round(dfAvgRV,2)
round(dfAvgJatai,2)
round(dfAvgPira,2)
