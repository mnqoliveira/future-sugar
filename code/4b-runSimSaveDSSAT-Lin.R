# author: Monique Pires Gravina de Oliveira
# date: 2016-09-03

# This code is meant to create and modify the batch file in order to save each
# simulation in a different folder.
# 
# As long as the files used by DSSAT may be found in the folders where 
# DSSAT is installed, except for the seasonal (so soil, cultivar and weather),
# the batch file may be located in other folder and the outputs will be 
# created in this other folder.
# 
# Batch file for example saved in the data/simulation folder

rm(list = ls())
options(stringsAsFactors = FALSE)

# Load Library ------------------------------------------------------------

library("stringr")

# WD ----------------------------------------------------------------------

#setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Paths -------------------------------------------------------------------
pathOut <- "home/monique/dssatOut/"
pathSeasonal <- "home/monique/DSSAT46/Data/Seasonal/"
pathExe <- "home/monique/DSSAT46/Data/"

# Choose files to run -----------------------------------------------------

# List files from the seasonal folder
xFiles <- substring(list.files(pathSeasonal, "[.]SNX$"),1,8)

allFiles <- 1:length(xFiles)
baseline <- grep("XXQ", xFiles)
notBaseline <- allFiles[!1:length(xFiles) %in% baseline]

# Baseline files should be run first for testing purposes
seqFiles <- c(baseline, notBaseline)
alreadyDone <- list.dirs(path = pathOut, full.names = FALSE, recursive = FALSE)
seqFiles <- xFiles[seqFiles]
seqFiles <- seqFiles[!seqFiles %in% alreadyDone]

n <- 1000
seqRun <- c(seqFiles[1:n])

# Run files ---------------------------------------------------------------

Ti <- Sys.time()
for (sim in seqRun){
  ti <- Sys.time()

  snxFile <- paste0(sim,".SNX")

  # Create folder to storage the simulation result
  folderName <- paste(pathOut,"/", sim,sep = "")
  dir.create(folderName)
  
  # Run DSSAT
  runSNX <- paste0(pathExe,"dscsm046.exe C ",snxFile," 1")
  system(runSNX)
  
  # Copy results file to created folder
  filesOUT <- list.files(pathSeasonal, "[.]OUT$", full.names = TRUE)
  folderName <- paste0(folderName, "/")
  file.copy(filesOUT, folderName)
  #print(Sys.time() - ti)
}
print(Sys.time() - Ti)