# author: Monique Pires Gravina de Oliveira
# date: 2016-10-09

# This code is meant to organize AgMerra data outputs

rm(list = ls())
options(stringsAsFactors = FALSE)

# Load Library ------------------------------------------------------------

library(reshape2)

# WD ----------------------------------------------------------------------

#setwd(dirname(rstudioapi::getActiveDocumentContext()$path))


# Paths -------------------------------------------------------------------
pathCsv <- "../data/weather/agmerra/"

# Organize AgMerra data ---------------------------------------------------

filesComp <- list.files(pathCsv, pattern = ".csv")
files <- unlist(strsplit(filesComp, "[.]"))
files <- files[files != "csv"]

places <- c("pira", "jata", "pres")

# complet <- data.frame(matrix(NA, ncol = 5))
# colnames(complet) <- c("X", "city", "year", "var", "value")
compList <- list()

Ti <- Sys.time()
for (i in 1:length(files)){
  fileName <- paste0(pathCsv, filesComp[i])
  output <- read.csv(fileName)
  
  if (i == 1){
    compList[[i]] <- output
  } else {
    compList[[i]] <- merge(compList[[i-1]], output, all = TRUE)
  }
  
  if (i %% 100 == 0){
    print (i)
  }
  
}
print(Sys.time() - Ti)

complet <- compList[[length(compList)]]
colnames(complet) <- c("day", colnames(complet)[2:5])

# Organize data -----------------------------------------------------------

fullOrg <- dcast(complet, day + year + city ~ var , value.var = "value")
pira <- fullOrg[fullOrg$city == "pira",]
jata <- fullOrg[fullOrg$city == "jata",]
pres <- fullOrg[fullOrg$city == "pres",]

write.csv(pira, file = paste0(pathCsv, "piraMerra.csv"))
write.csv(jata, file = paste0(pathCsv, "jataMerra.csv"))
write.csv(pres, file = paste0(pathCsv, "presMerra.csv"))
