# author: Monique Pires Gravina de Oliveira
# date: 2016-09-03

# This code is meant to read AgMerra Data

rm(list = ls())
options(stringsAsFactors = FALSE)

# Load Library ------------------------------------------------------------

library(ncdf4)
library(lubridate)
library(dplyr)

# WD ----------------------------------------------------------------------

#setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Paths -------------------------------------------------------------------
pathMerra <- "D:/agmip/agMerra"
pathCsv <- "../data/weather/agmerra/"


# Read AgMerra data -------------------------------------------------------
filesComp <- list.files(pathMerra, pattern = ".nc4", full.names = TRUE)
files <- list.files(pathMerra, pattern = ".nc4", full.names = FALSE)
files <- unlist(strsplit(files, "[.]"))
files <- files[files != "nc4"]

places <- c("pira", "jata", "pres")

for (city in places){

  lon <- as.numeric(switch (city,
                            "pira" = "1250", "jata" = "1234", "pres" = "1235"))
  lat <- as.numeric(switch (city,
                            "pira" = "452", "jata" = "432", "pres" = "449"))

  for (i in 1:length(filesComp)){
    result <- as.data.frame(matrix(NA, nrow = 368, ncol = 4))
    colnames(result) <- c("city", "year", "var", "value")
    
    info <- unlist(strsplit(files[i], "_"))
    year <- info[2]
    type <- info[3]
    
    ncin <- nc_open(filesComp[i])
    #print(ncin)
    
    time <- 1
    if (leap_year(as.numeric(year))){
      last <- 366
    } else {
      last <- 365
    }

    time <- as.numeric(time)
    var <- ncvar_get(ncin,type, c(lon, lat, 1), c(1,1,last))
    result$city <- city
    result$year <- year
    result$var <- type
    result$value[1:length(var)] <- var
    
    result <- result[complete.cases(result),]
    write.csv(result, 
              file = paste(pathCsv,city,"-",type,"-",year,".csv",sep=""))
    nc_close(ncin)
  }
}
