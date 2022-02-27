# author: Felipe Bocca
# date: 2016-10-15

# This script is meant to: 
# Separate variables and plot trees

rm(list = ls())
options(stringsAsFactors = FALSE)

# Load Library ------------------------------------------------------------

require(rpart)
require(rpart.plot)
library(party)

# WD ----------------------------------------------------------------------

#setwd(dirname(rstudioapi::getActiveDocumentcountext()$path))

# Load files --------------------------------------------------------------

load('../data/dataset/agrResults.RData')
# ext - names of environmental variables
# int - names of variables of internal processes
# highLevel - boundaries conditions for simulations
# results - data.frame with the results
int <- colnames(results)[int]

# vector results2
load('../data/dataset/results2.RData')


#  ------------------------------------------------------------------------

dat <- results; rm(results)
dat$massrel <- results2

         #"cldd", "cldd180", "cldd270", "cldd90", 
         #"dtwt", "dtwt180", "dtwt270", "dtwt90", 
         #"efaa", "efaa180", "efaa270", "efaa90", 
         #"emaa", "emaa180", "emaa270", "emaa90", 
         #"eoaa", "eoaa180", "eoaa270", "eoaa90",
         #"eopa", "eopa180", "eopa270", "eopa90", 
         #"eosa", "eosa180", "eosa270", "eosa90", 
         #"esaa", "esaa180", "esaa270", "esaa90", 
         #"mwtd", "mwtd180", "mwtd270", "mwtd90", 
         #"rofd", "rofd180", "rofd270", "rofd90", 
         #"tdfd", "tdfd180", "tdfd270", "tdfd90", 

par(mfrow=c(1, 2))
hist(dat$difZ, breaks=51)
hist(dat$difPerZ, breaks=51)

old_meta <- c('dif', 'difPer')
# metas <- dat[, old_meta]
# 
# par(mfrow=c(1, 2))
# hist(metas$dif, breaks=51)
# hist(metas$difPer, breaks=51)
# 
dat <- dat[, -match(old_meta, colnames(dat))]
ischar <- sapply(dat, is.character)
dat[ischar] <- lapply(dat[ischar], as.factor)

#cutlabs <- c('lower', 'equal', 'higher')
#dif <- cut(dat$difZ, c(-Inf, -1,1,Inf), labels=cutlabs)
#per <- cut(dat$difPerZ, c(-Inf, -1,1,Inf), labels=cutlabs)

cutlabs <- c('lower', 'equal')
dif <- cut(dat$difZ, c(-Inf, -1, Inf), labels=cutlabs)
per <- cut(dat$difPerZ, c(-Inf, -1, Inf), labels=cutlabs)

ctrl = ctree_control(maxdepth=3, mincriterion=0.99)
dat$DifD <- dif
dat$DifPerD <- per

#tree_extDif <- ctree(difZ~. , data=dat[, c(ext, 'difZ')], control=ctrl)
#tree_extPer <- ctree(difPerZ~. , data=dat[, c(ext, 'difPerZ')], control=ctrl)

# plotExtLowContAllYield

subDat <- dat[dat$difPerZ < -1,]
colnames(subDat)
tree_extDifD <- ctree(DifD ~.,data=subDat[, c(ext, 'DifD')],
                      control=ctrl) 
plot(tree_extDifD)
png(filename ="../figures/plotExtLowContAllYield.png", 
    family = "serif", width = 960, height = 530)
par(cex = 1.4, font = 2)
# mar: c(bottom, left, top, right) The default is c(5, 4, 4, 2) + 0.1.
#par(mar = c(0.5,1,0.1,2))	# taking care of the plot margins
plot(tree_extDifD)
dev.off()

# par(mfrow = c(1,1))
# tree_extDifD <- rpart(DifD ~.,
#                       data=dat[dat$difPerZ < -1, c(ext, 'DifD')],
#                       maxdepth=3) 
# rpart.plot(tree_extDifD, type = 1, extra = 2)

rules <- where(tree_extDifD)
idrules <- rules %in% c(5)

tree <- ctree(DifD~., subDat[idrules, c(int, 'DifD')], 
              control=ctrl)
plot(tree)

png(filename ="../figures/plotnode5.png", 
    family = "serif", width = 960, height = 530)
par(cex = 1.4, font = 2)
# mar: c(bottom, left, top, right) The default is c(5, 4, 4, 2) + 0.1.
#par(mar = c(0.5,1,0.1,2))	# taking care of the plot margins
plot(tree)
dev.off()


#####
rules <- where(tree_extDifD)
idrules <- rules %in% c(14)

tree <- ctree(DifD~., subDat[idrules, c(int, 'DifD')], 
              control=ctrl)

png(filename ="../figures/plotnode14.png", 
    family = "serif", width = 960, height = 530)
par(cex = 1.4, font = 2)
# mar: c(bottom, left, top, right) The default is c(5, 4, 4, 2) + 0.1.
#par(mar = c(0.5,1,0.1,2))	# taking care of the plot margins
plot(tree)
dev.off()


table(per,dif)

# par(mfrow = c(1,1))
# tree_extDifD <- rpart(DifD ~.,
#                       data=subDat[idrule5_12, c(int, 'DifD')],
#                       maxdepth=3)
# rpart.plot(tree_extDifD, type = 1, extra = 2)



tree_intDifPerD <- ctree(DifPerD ~.,
                         data=dat[, c(int, 'massrel', 'DifPerD')],
                         control=ctrl) 
plot(tree_intDifPerD)

tree_intDifPerD <- ctree(DifPerD ~.,
                         data=dat[, c(ext, int, 'DifPerD')],
                         control=ctree_control(maxdepth=5, mincriterion=0.99))

plot(tree_intDifPerD)


#par(mfrow=c(2,1))
#hist(dat$difZ[dat$massrel > 0]) 
#hist(dat$difZ[dat$massrel < 0]) 

geral <- ctree(DifD~.,
               data=dat[, c(int, ext, highLevel[-c(4, 9)], 'DifD')],
               control=ctrl)
plot(geral)



