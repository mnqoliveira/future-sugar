# author: Monique Pires Gravina de Oliveira
# date: 2016-09-07

# This script is meant to: 
# Join the different results in one data-frame
# Aggregate variables in pre-defined time periods
# Create dependent variable and other interest variables

rm(list = ls())
options(stringsAsFactors = FALSE)

# Load Library ------------------------------------------------------------

library("stringr")
library("dplyr")

# WD ----------------------------------------------------------------------

#setwd(dirname(rstudioapi::getActiveDocumentcountext()$path))

# Paths -------------------------------------------------------------------

pathResult <- "D:/Documentos/Pesquisa/Projetos/futureSugar/data/apsim-proc/"


# Load column names -------------------------------------------------------
fileHeader <- paste0(pathResult,"header.txt")
headerMatrix <- unlist(read.table(fileHeader, sep = "", header = F))
names(headerMatrix) <- NULL
rm(fileHeader)

info <- c("city", "scenario", "gcm", "method", "cultivar", 
          "date", "soil", "irr", "yearSim")

# Load results ------------------------------------------------------------
fileResults <- paste0(pathResult,"res.txt")
results <- read.csv(fileResults, sep = "", header = FALSE, 
                     row.names = NULL)
colnames(results) <- headerMatrix

fileName <- strsplit(results$name, "/")
n <- length(fileName[[1]])
results$name <- sapply(fileName, function(x) x[n])
rm(fileName)

results$city <- substring(results$name, 1, 1)
results$scenario <- substring(results$name, 2, 2)
results$gcm <- substring(results$name, 3, 3)
results$method <- substring(results$name, 4, 4)
results$cultivar <- substring(results$name, 5, 5)
results$date <- substring(results$name, 6, 6)
results$soil <- substring(results$name, 7, 7)
results$irr <- substring(results$name, 8, 8)
results$yearSim <- substring(results$name, 10, 13)

results <- results[,c(info, headerMatrix)]

results$irrigation[results$irrigation == "?"] <- 0

# Filter results ----------------------------------------------------------

resultsFilt <- results[,c(info, "canefw", "ccs")]
condition <- (resultsFilt$city == "J" &
                resultsFilt$scenario == "0"  &
                resultsFilt$cultivar == 1 &
                resultsFilt$soil == 2 &
                resultsFilt$irr == 1 &
                resultsFilt$date == 2)
sub <- resultsFilt[condition & !duplicated(resultsFilt[,info]),]
hist(sub$ccs)
baselineApsim <- sub
save(baselineApsim, file = "baselineApsim.RData")

boxplot(sub$ccs ~ sub$scenario + sub$method)

dat = results %>% select(city, scenario, gcm, method,
                         cultivar, date, soil, irr, yearSim,
                         canefw, ccs)

dat = dat[!duplicated(dat[,info]),] %>% 
  mutate(date = as.factor(date)) %>% 
  select(-canefw) %>%
  spread(date, ccs)
dat$pond = 0.3*dat[, '1'] + 0.4*dat[, '2'] + 0.3*dat[,'3']


dat = dat %>% unite(comb, method, scenario) %>% 
  group_by(city, comb, irr, yearSim) %>% 
  summarise_if(is.numeric, funs(mean)) %>%
  ungroup() %>% mutate(yearSim = as.numeric(yearSim)) %>% 
                         as.data.frame

ggplot(dat, aes(x=yearSim, y = pond, colour=city)) + geom_line() + 
  facet_wrap(~comb)
