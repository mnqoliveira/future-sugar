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

ext <- c("dayld", "dayld180", "dayld270", "dayld90", 
         "pard", "pard180", "pard270", "pard90",
         "pred", "pred180", "pred270", "pred90", 
         "soil", 
         "sraa", "sraa180", "sraa270", "sraa90", 
         "srad", "srad180", "srad270", "srad90", 
         "swtd", "swtd180", "swtd270", "swtd90", 
         "swxd", "swxd180", "swxd270", "swxd90", 
         "tavd", "tavd180", "tavd270", "tavd90", 
         "tdwd", "tdwd180", "tdwd270", "tdwd90", 
         "tdyd", "tdyd180", "tdyd270", "tdyd90", 
         "tgad", "tgad180", "tgad270", "tgad90", 
         "tgrd", "tgrd180", "tgrd270", "tgrd90", 
         "tmaxa", "tmaxa180", "tmaxa270", "tmaxa90", 
         "tmina", "tmina180", "tmina270", "tmina90", 
         "tmnd", "tmnd180", "tmnd270", "tmnd90", 
         "tmxd", "tmxd180", "tmxd270", "tmxd90", 
         "twld", "twld180", "twld270", "twld90", 
         "wdsd", "wdsd180", "wdsd270", "wdsd90")

int <- c("badmd", "badmd180", "badmd270", "badmd90", 
         "brdmd", "brdmd180", "brdmd270", "brdmd90", 
         "cwsi", "cwsi180", "cwsi270", "cwsi90",
         "epaa", "epaa180", "epaa270", "epaa90",
         "etaa", "etaa180","etaa270", "etaa90", 
         "laigd", "laigd180", "laigd270", "laigd90", 
         "laitd", "laitd180", "laitd270", "laitd90", 
         "lddmd", "lddmd180", "lddmd270", "lddmd90",
         "ldgfd", "ldgfd180", "ldgfd270", "ldgfd90", 
         "lgdmd", "lgdmd180", "lgdmd270", "lgdmd90", 
         "lid", "lid180", "lid270", "lid90",
         "lsd", "lsd180", "lsd270", "lsd90", 
         "pgrd", "pgrd180", "pgrd270", "pgrd90", 
         "rdmd", "rdmd180", "rdmd270", "rdmd90",
         "respcf", "respcf180", "respcf270", "respcf90", 
         "rtld", "rtld180", "rtld270", "rtld90", 
         "slad", "slad180", "slad270", "slad90",
         "smdmd", "smdmd180", "smdmd270", "smdmd90", 
         "smfmd", "smfmd180", "smfmd270", "smfmd90", 
         "tad", "tad180", "tad270", "tad90",
         "tsd", "tsd180", "tsd270", "tsd90", 
         "wsgd", "wsgd180", "wsgd270", "wsgd90", 
         "wspd", "wspd180", "wspd270", "wspd90")

par(mfrow=c(1, 2))
hist(dat$difZ, breaks=51)
hist(dat$difPerZ, breaks=51)

old_meta <- c('dif', 'class', 'difPer', 'classPer')
metas <- dat[, old_meta]

par(mfrow=c(1, 2))
hist(metas$dif, breaks=51)
hist(metas$difPer, breaks=51)

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
tree_extDifD <- ctree(class ~.,
                      data = results[, c(ext, 'sudmd')],
                      controls = ctrl) 

tree_extDifPerD <- ctree(DifPerD ~.,
                         data=dat[dat$difZ < -1, c(ext, 'DifPerD')],
                         control=ctrl) 
plot(tree_extDifPerD)

#tri  <- rpart(DifD~., data=dat[dat$difPerZ < -1, c(ext, 'DifD')],
              #maxdepth=3, cp=0.001)
#rpart.plot(tri, extra=1, type=2)


#tree_intDifD <- ctree(DifD ~.,
                      #data=dat[, c(int, 'DifD')],
                      #control=ctrl) 
#plot(tree_intDifD)

tree_intDifPerD <- ctree(DifPerD ~.,
                         data=dat[, c(int, 'massrel', 'DifPerD')],
                         control=ctrl) 
plot(tree_intDifPerD)

tree_intDifPerD <- ctree(DifPerD ~.,
                         data=dat[, c(ext, int, 'DifPerD')],
                         control=ctree_control(maxdepth=5, mincriterion=0.99))

plot(tree_intDifPerD)

rule45 <- where(tree_extDifPerD)
idrule45 <- rule45 %in% c(5, 8, 12, 14, 15)
tree11 <- ctree(DifPerD~., dat[idrule45, c(int, 'DifPerD')], control=ctrl)
plot(tree11)

#par(mfrow=c(2,1))
#hist(dat$difZ[dat$massrel > 0]) 
#hist(dat$difZ[dat$massrel < 0]) 

geral <- ctree(DifD~.,
               data=dat[, c(int, ext, highLevel[-c(4, 9)], 'DifD')],
               control=ctrl)
plot(geral)



