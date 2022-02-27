# author: Monique Pires Gravina de Oliveira
# date: 2016-09-03

# This code is meant to figure out what is wrong with the Piracicaba climate

rm(list = ls())
options(stringsAsFactors = FALSE)

# Load Library ------------------------------------------------------------

library(ncdf4)

# WD ----------------------------------------------------------------------

#setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Identify the cases in which simulations do not run ----------------------

pathSim <- "R:/futureSugar/data/simulations"
setwd(pathSim)

interrupSim  <- readLines(list.files(".", "[.]txt$", full.names = TRUE))
table(interrupSim)

# Try and fix the mistakes in the datasets using AgMerra for the baseline
pathMerra <- "D:/agmip/agMerra"
setwd(pathMerra)
filesComp <- list.files(pathMerra)
files <- unlist(strsplit(filesComp, "[.]"))
files <- files[files != "nc4"]

result <- as.data.frame(matrix(nrow = 1, ncol = 4))

for (dataset in files){
  
  ncname <- dataset
  ncfname <- paste(ncname,".nc4", sep="")
  
  info <- unlist(strsplit(dataset, "_"))
  year <- info[2]
  type <- info[3]
  
  ncin <- nc_open(ncfname)
  print(ncin)
  
  #lon <- ncvar_get(ncin,"longitude")
  #lat <- ncvar_get(ncin,"latitude")
  #time <- ncvar_get(ncin,"time")
  
  lon <- 1250
  lat <- 452
  
  time <- switch(year, "2010" = "96", "2007" = "204", "1993" = "351",
                 "1995" = "37", "1989" = "268", "2000" = "241")
  time <- as.numeric(time)
  var <- ncvar_get(ncin,type, c(lon, lat, time), c(1,1,1))
  
  result <- rbind(result, c(type, year, time, round(var,2)))
  
  nc_close(ncin)
}

result
write.csv(result, file = "correctionsPira.csv")
# Identify why mean and var do not run ------------------------------------
# Might be caused by the mistakes above

