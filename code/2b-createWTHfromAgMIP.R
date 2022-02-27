# author: Monique Pires Gravina de Oliveira
# date: 2016-08-28

# Code meant to generate .WTH files from the outputs from the AgMIP tool for
# generating scenarios.

rm(list = ls())
options(stringsAsFactors = FALSE)

# Load Library ------------------------------------------------------------

library(dplyr)
library(lubridate)
library(stringr)

# WD ----------------------------------------------------------------------

#setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Number of days - breaks -------------------------------------------------
# Create a vector that indicates year ends lines in the complete file.
# Every year starts in 1980 and ends in 2010, so that the sequence has to
# accumulate the number of days in each year

years <- c(seq(80,99),seq(0,9),10)
nDays <- leap_year(years)
nDays <- 365 + nDays
totalDays <- rep(0,length(nDays))

totalDays[1] <- nDays[1]
for (i in 2:length(nDays)){
  totalDays[i] <- totalDays[i-1] + nDays[i]
}

# Read and save files -----------------------------------------------------

# Saves the pathes in which the .AgMIP files are saved and the path to which
# the .WTH files will be saved.
path <- "../data/weather/agmip"
pathWTH <- "../data/weather/wth"
pathDSSAT <- "C:/DSSAT46/Weather/"
filesAgMIP <- list.files(path)

TI <- Sys.time()
completeFile <- filesAgMIP[3]
for (completeFile in filesAgMIP){
  ti <- Sys.time()
  # IDs taken from the .AGMIP file names to create the .WTH file names
  city <- substr(completeFile,1,1)
  method <- substr(completeFile,8,8)
  scenRCP <- substr(completeFile,5,5)
  scenGCM <- substr(completeFile,6,6)
  
  # Change to suit the accepted format of .WTH names
  if (scenRCP == 0){
    scenRCP <- "X"
  }
  
  inputFile <- paste(path,"/",completeFile,sep="")
    
  # Read .AgMIP files as table to ignore date columns
  datAgMIP <- readLines(con = inputFile)
  datAgMIP <- datAgMIP[6:length(datAgMIP)]
  
  # Read header and include the expected column titles.
  # Reload header for every file read.
  weatherYear <- readLines(con = inputFile,n = 4)
  
  # Edit the value from AMP. It came from the AgMIP file in which it is 
  # half the value used by DSSAT, according to Ruane et al (2013).
  # To do so, read the line as numeric, identify the number that belongs to the
  # AMP position and replace that number with its double.
  lineAmp <- weatherYear[4]
  ampNum <- as.numeric(unlist(str_extract_all(lineAmp, "[\\.0-9e-]+")))
  ampNum <- ampNum[5]
  ampNumDoub <- ampNum * 2.0
  
  if (nchar(as.character(ampNum)) == 1){
    ampNum <- paste0(" ", ampNum, ".0 ")
    ampNumDoub <- paste0(" ", ampNumDoub, ".0 ")
  } 
  
  if (nchar(as.character(ampNumDoub)) == 1){
    ampNum <- paste0(" ", ampNum, " ")
    ampNumDoub <- paste0(" ", ampNumDoub, ".0 ")
  } else if (nchar(as.character(ampNumDoub)) == 3){
    ampNum <- paste0(" ", ampNum, " ")
    ampNumDoub <- paste0(" ", ampNumDoub, " ")
  }

  findAmp <- unlist(str_locate_all(lineAmp, ampNum))
  part1 <- substr(lineAmp,1,(findAmp[1]-1))
  part2 <- ampNumDoub
  part3 <- substr(lineAmp,(findAmp[2]+1),nchar(lineAmp))

  newLine <- paste0(part1, part2, part3)
  weatherYear  <- gsub(pattern = lineAmp,
                 replacement = newLine, x = weatherYear)
  
  # Include column names
  weatherYear <- append(weatherYear,
                        paste("@DATE  SRAD  TMAX  TMIN  RAIN",
                              "  DEWP  WIND   PAR  EVAP  RHUM",sep=""))
  
  for (i in 1:length(datAgMIP)){

    year <- substring(datAgMIP[i],3,4) #Used in the file name
    
    if (!i %in% totalDays){
    # If the line is not the last one, the information required is just
    # appended in the file.
    # Substring may be used because the positions in .WTH files are fixed.
      lineFile <- paste(substring(datAgMIP[i],3,7), 
                        substring(datAgMIP[i],22,45),
                        sep = "")
      
      weatherYear <- append(weatherYear,lineFile)
    }else{
    # If it is the last line, the information is appended and the file is
    # saved.
      lineFile <- paste(substring(datAgMIP[i],3,7), 
                        substring(datAgMIP[i],22,45),
                        sep = "")
      
      weatherYear <- append(weatherYear,lineFile)
      
      # # If the GCM scenario code is a number, it is replaced by a letter..
      # if (!scenGCM %in% LETTERS){
      #   
      #   codeScenGCM <- LETTERS[as.numeric(scenGCM)+1]
      #   station <- paste(city,method,scenRCP,codeScenGCM,sep="")
      #   wthName <- paste(station,year,
      #                    "01.WTH",sep="")
      # 
      #   # Before saving, rename the station because it has been simply 
      #   # copied from the original station instead of personalized.
      #   weatherYear[4] <- gsub(substring(weatherYear[4],3,6),
      #                          station,
      #                          weatherYear[4])
      #   
      #   writeLines(weatherYear, 
      #              con = paste(pathWTH,"/",wthName,sep=""))
      #   
      # } else {
        # If it is a letter, it is normally saved in the expected folder
        station <- paste(city,method,scenRCP,scenGCM, sep="")
        wthName <- paste(station,year,
                         "01.WTH",sep="")
        
        # Before saving, rename the station because it has been simply 
        # copied from the original station instead of personalized.
        weatherYear[4] <- gsub(substring(weatherYear[4],3,6),
                               station,
                               weatherYear[4])
        
        writeLines(weatherYear, 
             con = paste(pathWTH,"/",wthName,sep=""))
        
      #}
      
      # After saving, the header must be restarted for the file referring to
      # the new year.
      weatherYear <- readLines(con = inputFile,n = 4)
      lineAmp <- weatherYear[4]
      ampNum <- as.numeric(unlist(str_extract_all(lineAmp, "[\\.0-9e-]+")))
      ampNum <- ampNum[5]
      ampNumDoub <- ampNum * 2.0

      if (nchar(as.character(ampNum)) == 1){
        ampNum <- paste0(" ", ampNum, ".0 ")
        ampNumDoub <- paste0(" ", ampNumDoub, ".0 ")
      } 
      
      if (nchar(as.character(ampNumDoub)) == 1){
        ampNum <- paste0(" ", ampNum, " ")
        ampNumDoub <- paste0(" ", ampNumDoub, ".0 ")
      } else if (nchar(as.character(ampNumDoub)) == 3){
        ampNum <- paste0(" ", ampNum, " ")
        ampNumDoub <- paste0(" ", ampNumDoub, " ")
      }
      
      findAmp <- unlist(str_locate_all(lineAmp, ampNum))
      part1 <- substr(lineAmp,1,(findAmp[1]-1))
      part2 <- ampNumDoub
      part3 <- substr(lineAmp,(findAmp[2]+1),nchar(lineAmp))
      
      newLine <- paste0(part1, part2, part3)
      weatherYear  <- gsub(pattern = lineAmp,
                           replacement = newLine, x = weatherYear)
      weatherYear <- append(weatherYear,
                            paste("@DATE  SRAD  TMAX  TMIN  RAIN",
                                  "  DEWP  WIND   PAR  EVAP  RHUM",sep=""))

    }
  }
  print (paste(completeFile, (Sys.time() - ti), sep = "_"))
}
print (Sys.time() - TI)

# Copy files to the weather folder where DSSAT is installed
filesWTH <- list.files(pathWTH, "[.]WTH$", full.names = TRUE)
file.copy(filesWTH, pathDSSAT)
