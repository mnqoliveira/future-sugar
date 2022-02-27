# author: Monique Pires Gravina de Oliveira
# date: 2016-09-03

# This code is meant to generate .SNX files based on the format of DSSAT .SNX 
# files. The limitation of number of characters do not allow for including
# irrigation with the other combinations. Therefore if a need for irrigation is
# detected, this code must be re-run and all of the files should be replaced by
# the irrigated version.

rm(list = ls())
options(stringsAsFactors = FALSE)

# Load Library ------------------------------------------------------------

library("dplyr")
library("lubridate")
library("stringr")

# WD ----------------------------------------------------------------------

#setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Conditions --------------------------------------------------------------

# Weather
# Previous line
# @L ID_FIELD WSTA....  FLSA  FLOB  FLDT  FLDD  FLDS  FLST
pathWTH <- "../data/weather/wth"
stations <- unique(substring(list.files(pathWTH),1,4))

# Varieties
# Previous line
# @C CR INGENO CNAME
codVariety <- c(" 1 SC BR0002 RB867515-2015",
                " 1 SC BR0003 RB73-454-2011")

# Dates
# Previous line
# @P PDATE EDATE  PPOP  PPOE  PLME  PLDS  PLRS  PLRD  PLDP
plantingDates <- c(" 1 80134 81134   -99   -99     S     R   150",
                   " 1 80226 81226   -99   -99     S     R   150",
                   " 1 80318 81318   -99   -99     S     R   150")
# Previous line
# @H HDATE  HSTG  HCOM HSIZE   HPC  HBPC HNAME
harvestDates <- c(" 1 81135 GS000     H     A   100     0 Sugarcane",
                  " 1 81227 GS000     H     A   100     0 Sugarcane",
                  " 1 81319 GS000     H     A   100     0 Sugarcane")

# Soil
# Previous line
# @L ID_FIELD WSTA....  FLSA  FLOB  FLDT  FLDD  FLDS  FLST SLTX  SLDP  ID_SOIL
codSoils <- c("DR000   -99   -99   -99 -99    450  FS00909002 Dataset Marin 2011",
              "DR000   -99   -99   -99 -99    450  FS00909003 Dataset Marin 2011")
# Previous line
# @C  ICBL  SH2O  SNH4  SNO3
initialCond <- list(c(" 1    20   .36    .2   1.6",
                      " 1    40  .355    .2   1.6",
                      " 1   100  .343    .2   1.6",
                      " 1   450  .335    .2   1.6"),
                    c(" 1    20   .21    .2   1.6",
                      " 1    40   .22    .2   1.6",
                      " 1   100   .21    .2   1.6",
                      " 1   450   .21    .2   1.6"))

# CO2
# Previous line
# @E ODATE EDAY  ERAD  EMAX  EMIN  ERAIN ECO2  EDEW  EWIND ENVNAME  
envModCO2 <- c(" 1 80001 A   0 A   0 S   0 S   0 A 0.0 A  00 A   0 A   0 co2mod",
               " 1 80001 A   0 A   0 S   0 S   0 A 0.0 A  43 A   0 A   0 co2mod",
               " 1 80001 A   0 A   0 S   0 S   0 A 0.0 A  52 A   0 A   0 co2mod",
               " 1 80001 A   0 A   0 S   0 S   0 A 0.0 A 119 A   0 A   0 co2mod",
               " 1 80001 A   0 A   0 S   0 S   0 A 0.0 A 191 A   0 A   0 co2mod")

#380, 423, 432, 499, 571

# Irrigation
# Previous line
# @N MANAGEMENT  PLANT IRRIG FERTI RESID HARVS
irrControl <- c(" 1 MA              R     N     N     N     R", # Not irrigated
                " 1 MA              R     A     N     N     R") # Irrigated

# Not necessary given the example already comes with this line correct.
# # Previous line
# # @N IRRIGATION  IMDEP ITHRL ITHRU IROFF IMETH IRAMT IREFF
# irrVolume <- c(" 1 IR            100    40   100 IB001 IB001    10     1",
#                " 1 IR            100    40   100 IB001 IB001    10     1") 

# Combinations ------------------------------------------------------------

weatherComb <- stations
varComb <- c(1,2)
datesComb <- c(1,2,3)
soilComb <- c(1,2)
CO2Comb <- c(1,2,3,4,5)
irrComb <- c(1,2)

combinations <- expand.grid(weatherComb, varComb, datesComb,soilComb,
                            CO2Comb, irrComb)
combinations[,1] <- as.character(combinations[,1])
colnames(combinations) <- c("weatherC", "varietyC", "datesC", "soilC", "CO2C",
                            "irrigC")

# Delete improper combinations of station and CO2 -------------------------

rcpX <- (substr(combinations$weatherC,3,3) == "X") & combinations$CO2C == 1
rcpC <- (substr(combinations$weatherC,3,3) == "C") & combinations$CO2C == 2
rcpE <- (substr(combinations$weatherC,3,3) == "E") & combinations$CO2C == 3
rcpC2 <- (substr(combinations$weatherC,3,3) == "G") & combinations$CO2C == 4
rcpE2 <- (substr(combinations$weatherC,3,3) == "I") & combinations$CO2C == 5
  
combinations <- combinations[rcpX | rcpC | rcpE | rcpC2 | rcpE2,]
row.names(combinations) <- NULL

rm(rcpX, rcpC, rcpE, rcpC2, rcpE2)

# Creating files ----------------------------------------------------------

#for (i in 13280:13281){
ti <- Sys.time()
for (i in 1:nrow(combinations)){
  # For cleaneness of the script, 
  # isolate for each combination the respective variables
  weather <- combinations$weatherC[i]
  variety <- codVariety[combinations$varietyC[i]]
  plantDate <- plantingDates[combinations$datesC[i]]
  harvDate <- harvestDates[combinations$datesC[i]]
  inCond <- unlist(initialCond[combinations$soilC[[i]]])
  soil <- codSoils[combinations$soilC[i]]
  CO2 <- envModCO2[combinations$CO2C[i]]
  irrCon <- irrControl[combinations$irrigC[i]]
  #irrVol <- irrVolume[combinations$irrigC[i]]

  # Read sample file 
  fileDemo  <- readLines("../data/seasonal/example/TSTS8001.SNX")
  
  # Replace identification
  scenario <- paste(combinations$weatherC[i], 
                    combinations$varietyC[i], 
                    combinations$datesC[i], 
                    combinations$soilC[i],
                    #combinations$CO2C[i],
                    combinations$irrigC[i], 
                    sep = "")
   
  changeLine <- fileDemo[(grep("*EXP.DETAILS:", x = fileDemo))]
  part1 <- substr(changeLine,2,14)
  part2 <- weather
  part3 <- substr(changeLine,19,25)
  part4 <- scenario
  
  newLine <- paste(part1, part2, part3, part4, sep="")
  subst  <- gsub(pattern = changeLine,
                 replacement = newLine, x = fileDemo)
  
  # Replace station and soil
  changeLine <- subst[(grep("@L ID_FIELD WSTA....  FLSA", x = subst)+1)]
  part1 <- substr(changeLine,1,12)
  part2 <- weather
  part3 <- substr(changeLine,17,33)
  part4 <- soil
  
  newLine <- paste(part1, part2, part3, part4, sep="")
  subst  <- gsub(pattern = changeLine,
                   replacement = newLine, x = subst)
  
  # Replace cultivar
  changeLine <- subst[(grep("@C CR INGENO CNAME", x = subst)+1)]
  
  newLine <-  variety
  subst  <- gsub(pattern = changeLine,
                       replacement = newLine, x = subst)
  
  # Replace planting date
  changeLine <- subst[(grep("@P PDATE EDATE  PPOP  PPOE  ", x = subst)+1)]
  part1 <- plantDate
  part2 <- substr(changeLine,45,nchar(changeLine))

  newLine <- paste(part1, part2, sep="")
  subst  <- gsub(pattern = changeLine,
                   replacement = newLine, x = subst)
  
  # Replace harvesting date
  changeLine <- subst[(grep("@H HDATE  HSTG  HCOM HSIZE", x = subst)+1)]
  newLine <- harvDate
  
  subst  <- gsub(pattern = changeLine,
                 replacement = newLine, x = subst)
  
  # Replace soil initial conditions
  # Since the two soils were characterized in the same depths, the number of 
  # layers is included in the code for the initial conditions to be
  # specifically replaced.

  changeLine <- subst[(grep("@C  ICBL  SH2O  SNH4  SNO3", x = subst)+1)]
  newLine <- inCond[1]
  subst  <- gsub(pattern = changeLine,
                   replacement = newLine, x = subst)

  changeLine <- subst[(grep("@C  ICBL  SH2O  SNH4  SNO3", x = subst)+2)]
  newLine <- inCond[2]
  subst  <- gsub(pattern = changeLine,
                 replacement = newLine, x = subst)
  
  changeLine <- subst[(grep("@C  ICBL  SH2O  SNH4  SNO3", x = subst)+3)]
  newLine <- inCond[3]
  subst  <- gsub(pattern = changeLine,
                 replacement = newLine, x = subst)
  
  changeLine <- subst[(grep("@C  ICBL  SH2O  SNH4  SNO3", x = subst)+4)]
  newLine <- inCond[4]
  subst  <- gsub(pattern = changeLine,
                 replacement = newLine, x = subst)
  
  # Replace CO2 situation
  changeLine <- subst[(grep("@E ODATE EDAY  ERAD  EMAX", x = subst)+1)]
  newLine <- CO2
  subst  <- gsub(pattern = changeLine,
                 replacement = newLine, x = subst)
  
  # # Modify irrigation
  changeLine <- subst[(grep("@N MANAGEMENT  PLANT IRRIG FERTI RESID HARVS",
                            x = subst)+1)]
  newLine <- irrCon
  subst  <- gsub(pattern = changeLine,
                 replacement = newLine, x = subst)

  # changeLine <- subst[(grep("@N IRRIGATION  IMDEP ITHRL ITHRU ", x = subst)+1)]
  # newLine <- irrVol
  # subst  <- gsub(pattern = changeLine,
  #                replacement = newLine, x = subst)
  
  # After modifying the file in every possible condition, re-write
  fileName <- paste("../data/seasonal/",scenario, 
                    ".SNX", sep = "")
  
  writeLines(subst, con=fileName)
  
}

Sys.time() - ti