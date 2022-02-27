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
pathSim <- "R:/futureSugar/data/simulations"
pathSeasonal <- "D:/Dropbox/Pesquisa/Projetos/futureSugar/data/seasonal"
pathBatch <- paste(pathSim, "/DSSBatch.v46",sep = "")
pathDemo <- paste(pathSim, "/DSSBatchExample.v46",sep = "")

pathSNXDropbox <- "D:/Dropbox/Pesquisa/Projetos/futureSugar/data/seasonal"


# Choose files to run -----------------------------------------------------

# List files from the seasonal folder
xFiles <- substring(list.files(pathSeasonal, "[.]SNX$"),1,8)

allFiles <- 1:length(xFiles)
baseline <- grep("XXQ", xFiles)
notBaseline <- allFiles[!1:length(xFiles) %in% baseline]

# Baseline files should be run first for testing purposes
seqFiles <- c(baseline, notBaseline)
alreadyDone <- list.dirs(path = pathSim, full.names = FALSE, recursive = FALSE)
seqFiles <- xFiles[seqFiles]
seqFiles <- seqFiles[!seqFiles %in% alreadyDone]

first <- 1
last <- 905
seqRun <- c(seqFiles[first:last])
# 1:1000
#xFiles[seqRun]

# Run files ---------------------------------------------------------------

Ti <- Sys.time()
for (sim in seqRun){
  ti <- Sys.time()
  # Read sample file for Batch information
  fileDemo  <- readLines(con = pathDemo)
  
  # Replace the name of the file in the id section
  changeLine <- fileDemo[(grep("! Experiment", x = fileDemo))]
  part1 <- substr(changeLine,1,17)
  part2 <- sim
  part3 <- substr(changeLine,26,nchar(changeLine))
  
  newLine <- paste(part1, part2, part3, sep = "")
  subst  <- gsub(pattern = changeLine,
                 replace = newLine, x = fileDemo)
  
  # Replace the path of the file in the XFile section
  changeLine <- subst[(grep("@FILEX", x = subst))+1]

  part1 <- gsub(pattern = "simulations", replace = "seasonal", x = pathSeasonal)
  part1 <- gsub("/", "\\\\", x = part1)
  part2 <- sim
  part3 <- substr(changeLine,71,nchar(changeLine))
  
  newLine <- paste(part1, "\\", part2,".SNX", part3, sep = "")
  subst  <- gsub(pattern = changeLine,
                 replace = newLine, x = subst, fixed = TRUE)
  
  writeLines(subst, con=pathBatch)
  
  # Create folder to storage the simulation result
  folderName <- paste(pathSim,"/", sim,sep = "")
  dir.create(folderName)
  
  # Run batch
  savePath <- getwd()
  setwd(pathSim)
  system("C://DSSAT46//DSCSM046.EXE N DSSBatch.v46")
  
  # Copy results file to created folder
  filesOUT <- list.files(".", "[.]OUT$", full.names = TRUE)
  folderName <- paste(folderName, "/",sep = "")
  file.copy(filesOUT, folderName)
  setwd(savePath) 
  # Return the path to the original because the only ones that must be changed
  # are specified
  
  #print(Sys.time() - ti)
}
print(Sys.time() - Ti)