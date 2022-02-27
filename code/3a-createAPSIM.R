# author: Monique Pires Gravina de Oliveira
# date: 2017-05-01

# This code is meant to generate .APSIM files based on the format of APSIM 
# .APSIM files. The limitation of number of characters do not allow for 
# including irrigation with the other combinations. Therefore if a need 
# for irrigation is detected, this code must be re-run and all 
# of the files should be replaced by the irrigated version.

rm(list = ls())
options(stringsAsFactors = FALSE)

# Load Library ------------------------------------------------------------

library("XML")

# WD ----------------------------------------------------------------------

#setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Paths -------------------------------------------------------------------
# Path of the example used to write the apsim files.
pathExample <- "../data/apsim/example/"
fileExample <- "../data/apsim/example/exampleSim.apsim"
fileExampleIr <- "../data/apsim/example/exampleSimIr.apsim"

#Path to save the created files
#pathApsim <- "D:/Documentos/Pesquisa/Projetos/futureSugar/data/apsim/"
pathApsim <- "../data/apsim/"

#Paths that are written into the file
pathMET <- "D:/Dropbox/Pesquisa/Projetos/futureSugar/data/weather/met/"
#pathSugar <- "D:/Dropbox/Pesquisa/Projetos/futureSugar/data/cultivar/Sugar.xml"
pathSugar <- "%apsim%/data/cultivar/Sugar.xml"

# pathMET <- "D:/monique/Dropbox/Pesquisa/Projetos/futureSugar/data/weather/met/"
# pathSugar <- "D:/monique/Dropbox/Pesquisa/Projetos/futureSugar/data/cultivar/Sugar.xml"

fileSoils <- "../data/soil/marinSoils.soils"

# Soil toolbox ------------------------------------------------------------
# Load soil toolbox as a xml file
soils <- xmlParse(fileSoils, useInternalNodes = TRUE)
soils <- getNodeSet(soils, "//Soil")
names(soils) <- c(xmlAttrs(soils[[1]])["name"], xmlAttrs(soils[[2]])["name"])

# Conditions --------------------------------------------------------------

# Weather
# Each metfile refers to one condition
metFiles <- list.files(pathMET, "*.met", full.names = FALSE)
stations <- paste(substr(list.files(pathMET),1,8))

pathMET <- "%apsim%/data/met"

# Varieties
codVariety <- c("rb867515", "rb72454")

# Dates
plantingDates <- c("15-may", "15-aug", "15-nov")

# Soil
codSoils <- c("Clayey", "Sandy")

# CO2
# Previous line
# @E ODATE EDAY  ERAD  EMAX  EMIN  ERAIN ECO2  EDEW  EWIND ENVNAME  
envModCO2 <- c(380, 423, 432, 499, 571)

# Irrigation
# Different base files for irrigated or not

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

rcpX <- (substr(combinations$weatherC,5,5) == "0") & combinations$CO2C == 1
rcpC <- (substr(combinations$weatherC,5,5) == "C") & combinations$CO2C == 2
rcpE <- (substr(combinations$weatherC,5,5) == "E") & combinations$CO2C == 3
rcpC2 <- (substr(combinations$weatherC,5,5) == "G") & combinations$CO2C == 4
rcpE2 <- (substr(combinations$weatherC,5,5) == "I") & combinations$CO2C == 5

combinations <- combinations[rcpX | rcpC | rcpE | rcpC2 | rcpE2,]
row.names(combinations) <- NULL

rm(rcpX, rcpC, rcpE, rcpC2, rcpE2)

# Creating files ----------------------------------------------------------
i <- 1050
for (i in 1:2) {
ti <- Sys.time()
#for (i in 1:nrow(combinations)) {
  # For cleaneness of the script, 
  # isolate for each combination the respective variables
  weather <- combinations$weatherC[i]
  variety <- codVariety[combinations$varietyC[i]]
  plantDate <- plantingDates[combinations$datesC[i]]
  
  soil <- codSoils[combinations$soilC[i]]
  CO2 <- envModCO2[combinations$CO2C[i]]
  
  if (combinations$irrigC[i] == 1){
    fileExample <- fileExample
  } else {
    fileExample <- fileExampleIr
  }

  # Read sample file 
  fileDemo <-  xmlParse(fileExample, useInternalNodes = TRUE)
  
  # Define path for additional CVs
  # Node #2 contains sugar file filename
  nodesCrop <- getNodeSet(fileDemo, "//filename")
  xmlValue(nodesCrop[[2]]) <- pathSugar
  rm(nodesCrop)
  
  # Replace the met file path
  # Node #1 contains metfile filename
  nodesMet <- getNodeSet(fileDemo, "//filename")
  newMetNode <- paste0(pathMET,"/",weather,".met")
  xmlValue(nodesMet[[1]]) <- newMetNode
  rm(nodesMet, newMetNode)
  
  # Replace the soil
  nodesSoil <- getNodeSet(fileDemo, "//Soil")
  newSoilNode <- soils[[soil]]
  
  replaceNodes(nodesSoil[[1]], newSoilNode)
  rm(nodesSoil, newSoilNode)
  
  # Changing planting date
  nodesPlantingDate <- getNodeSet(fileDemo, "//planting_day")
  newDateNode <- plantDate
  xmlValue(nodesPlantingDate[[1]]) <- newDateNode
  rm(newDateNode, nodesPlantingDate)
  
  # Change cultivar
  nodesVariety <- getNodeSet(fileDemo, "//variety")
  newVarNode <- variety
  xmlValue(nodesVariety[[1]]) <- newVarNode
  rm(newVarNode, nodesVariety)
  
  # Change CO2
  nodesCO2 <- getNodeSet(fileDemo, "//CO2")
  newCO2Node <- CO2
  xmlValue(nodesCO2[[1]]) <- newCO2Node
  rm(newCO2Node, nodesCO2)
  
  year <- 1980
  for (year in 1980:2009) {
    # Loop through all the 30 years
    nodesStDate <- getNodeSet(fileDemo, "//start_date")
    newStDateNode <- paste0("01/01/",year)
    xmlValue(nodesStDate[[1]]) <- newStDateNode
    rm(newStDateNode, nodesStDate)
    
    nodesEnDate <- getNodeSet(fileDemo, "//end_date")
    newEnDateNode <- paste0("31/12/",(year + 1))
    xmlValue(nodesEnDate[[1]]) <- newEnDateNode
    rm(newEnDateNode, nodesEnDate)
    
    # Change the name of the file
    nodesOut <- getNodeSet(fileDemo, "//filename")
    newName <- paste0(substring(weather,1,1),substring(weather,5,6),
                      substring(weather,8,8), combinations$varietyC[i],
                      combinations$datesC[i], combinations$soilC[i],
                      combinations$irrigC[i], "_", year)
    
    # Node #3 contains output filename
    xmlValue(nodesOut[[3]]) <- paste0(newName, ".out")
    
    saveXML(fileDemo, 
            file = paste0(pathApsim, newName, ".apsim"), 
            indent = TRUE)
     
  }

}

Sys.time() - ti
