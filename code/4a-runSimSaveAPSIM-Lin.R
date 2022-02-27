# author: Monique Pires Gravina de Oliveira
# date: 2017-03-18

# This code is meant to load simulation .apsim files and run them, saving the
# .out files in another folder.

rm(list = ls())
options(stringsAsFactors = FALSE)

# Load Library ------------------------------------------------------------

#install.packages("apsimr")
library("stringr")
library("apsimr")

# WD ----------------------------------------------------------------------

#setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Paths -------------------------------------------------------------------
# .EXE path in your machine
pathApsim <- "home/monique/apsim_build/trunk/Model/Apsim.exe"

# .apsim files path
pathSim <- "home/monique/apsim_build/data/apsim/"

# .out files path
pathOut <- "home/monique/apsim_build/data/apsim-out/"

# .RData with complete .out list
pathData <- "home/monique/apsim_build/data/apsim/"

# Choose files to run -----------------------------------------------------

# List files from the apsim folder
filesAPSIM <- list.files(pathSim, pattern = ".apsim")
simFiles <- substring(filesAPSIM,1,13)

allFiles <- 1:length(simFiles)
baseline <- grep("0QX", simFiles)
notBaseline <- allFiles[!1:length(simFiles) %in% baseline]

# Baseline files should be run first for testing purposes
seqFiles <- c(baseline, notBaseline)
seqFiles <- simFiles[seqFiles]

n <- 6259
seqRun <- seqFiles[1:n]

rm(allFiles, baseline,
   filesAPSIM, notBaseline,
   simFiles, seqFiles)

# Run files ---------------------------------------------------------------
Ti <- Sys.time()
i <- 1
sim <- seqRun[1]
for (sim in seqRun) {
  
  if ((i %% 50) == 1) {
    
    ti <- Sys.time()
    
  }
  
  # File to run
  runSim <- paste0(sim,".apsim")
  
  # Run exe
  savePath <- getwd()
  setwd(pathSim)
  apsim(exe = pathApsim, wd = pathSim, files = runSim)
  
  # Personalize paths
  # city <- substring(runSim, 1, 1)
  # if (city == "J"){
  #   pathOutMod <- paste0(pathOut, "jata/")
  #   pathSimMod <- paste0(pathSim, "done/jata/")
  # } else if (city == "P"){
  #   pathOutMod <- paste0(pathOut, "pira/")
  #   pathSimMod <- paste0(pathSim, "done/pira/")
  # } else {
  #   pathOutMod <- paste0(pathOut, "resi/")
  #   pathSimMod <- paste0(pathSim, "done/resi/")
  # }
  
  pathOutMod <- pathOut
  
  # Copy results file to created folder and rename them
  filesOUT <- list.files(".", "[.]out$", full.names = TRUE)
  file.copy(filesOUT, pathOutMod)

  filesSUM <- list.files(".", "[.]sum$", full.names = TRUE)
  file.copy(filesSUM, pathOutMod)
  
  setwd(pathOutMod)
  newName <- paste0(sim, ".out")
  file.rename(from = filesOUT, to = newName)
  newName <- paste0(sim, ".sum")
  filesSUM <- file.rename(from = filesSUM, to = newName)
  rm(filesSUM, filesOUT, newName, pathOutMod)
  
  # Move sim file to "done" folder
  setwd(pathSim)
  runSimMov <- paste0(pathSim, runSim)
  file.copy(runSimMov, pathSimMod)
  file.remove(runSimMov)
  rm(runSimMov, pathSimMod)
  
  setwd(savePath) 
  # Return the path to the original because the only ones that must be changed
  # are specified
  
  i <- i + 1
  
  if ((i %% 50) == 0) {
    
    #gc(verbose = TRUE)
    print(i)
    print(Sys.time() - ti)
  }
  
}
Tf <- Sys.time()
print(Tf - Ti)