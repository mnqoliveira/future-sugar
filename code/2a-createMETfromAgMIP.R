# author: Monique Pires Gravina de Oliveira
# author: Thiago da Silva Siqueira

# Code meant to generate .MET files from the outputs from the AgMIP tool for
# generating scenarios.

rm(list = ls())
options(stringsAsFactors = FALSE)

# Load Library ------------------------------------------------------------

library(stringr)
library(tidyr)
library(lubridate)

# Determine paths ---------------------------------------------------------

pathAgmip <- "../data/weather/agmip/"
pathMet <- "../data/weather/met/"

# Read AgMIP --------------------------------------------------------------

filesAgmip <- list.files(pathAgmip, pattern = ".AgMIP")

instance <- filesAgmip[2]
for (instance in filesAgmip){
  
  # Information to be included in the header may be extracted from the header
  # of the .AgMIP file
  stationInfo <- readLines(con = paste0(pathAgmip,instance),n = 4)
  stationInfo <- stationInfo[4]
  
  city <- substring(stationInfo,3,6)
  lat <- substring(stationInfo,9,15)
  long <- substring(stationInfo,18,24)
  tav <- substring(stationInfo,33,36)
  amp <- substring(stationInfo,40,42)
  
  scenario <- substring(instance,8,8)

  # Load weather info
  weatherData <- NULL
  weatherData <- readLines(paste0(pathAgmip,instance,sep = ""))
  weatherData <- weatherData[6:length(weatherData)]
  
  # Create column names and units rows based on the method of scenario
  # generation - delta method did not provide missing value codes for the
  # last columns
  if (scenario == "A") {
    namesData <- paste("yearDay", "year", "month", "dom", "radn", "maxt",
                       "mint", "rain")
    unitsData <- paste("()","()", "()", "()" , "(MJ/m2/d)", "(oC)",
                       "(oC)","(mm)")
  } else {
    namesData <- paste("yearDay", "year", "month", "dom", "radn", "maxt",
                       "mint", "rain", "wind", "dewp", "vprs", "rhum")
    unitsData <- paste("()","()", "()", "()" , "(MJ/m2/d)", "(oC)",
                       "(oC)","(mm)","(m/s)","()", "()", "(%)")
  }
  
  # Create header line
  site <- paste("Site", "=", city)
  lat <- paste("Latitude", "=", lat)
  long <- paste("Longitude", "=", long)
  tav <- paste("tav", "=", tav)
  amp <- paste("amp", "=", amp)
  
  # Join all info in one variable
  output <- c(site, lat, long, tav, amp, namesData,
              unitsData, weatherData)
  outputName <- substring(instance, 1, 8)
  
  # Write the output separating it with spaces
  writeLines(output, paste0(pathMet, outputName, ".met"))
  
  
}