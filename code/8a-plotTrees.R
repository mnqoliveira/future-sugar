# author: Monique Pires Gravina de Oliveira
# date: 2016-09-07

# This script is meant to: 
# Separate variables and plot trees

rm(list = ls())
gc()
options(stringsAsFactors = FALSE)

# Load Library ------------------------------------------------------------

library(rpart)
library(rpart.plot)

# WD ----------------------------------------------------------------------

#setwd(dirname(rstudioapi::getActiveDocumentcountext()$path))

# Load files --------------------------------------------------------------

load("../data/outputs/resultsTarget.RData")

# Create levels -----------------------------------------------------------
highLevel <- c("approach", "city", "date", "gcm", "irr", "rcp",
               "soil", "var", "mod")
  
envVar <- c("dayld", "eoaa", "eopa", "esaa", "pred", "srad",
            "swxd", "tmnd", "tmxd", "irrc")
ext <- grepl(pattern = paste(envVar, collapse = "|"), x = colnames(results))
ext <- colnames(results)[ext]

mechan <- c("badmd", "brdmd", "epaa", "laigd", "lgdmd",
            "tad", "rdmd", "rdpd", "shtd",
            "smdmd", "smfmd",
            "sucmd", "sudmd", "sufmd", 
            "respcf", "wsgd", "wspd", 
            "biomass", "lddmd", "stalk", "cwsi")

mechan <- c("badmd", "brdmd", "epaa", "laigd", "lgdmd",
            "tad", "smdmd", "smfmd",
            "sucmd", "sudmd", "sufmd")

target <- c("sudmd", "sucmd", "sufmd", "base")
mechan <- mechan[!mechan %in% target]

int <- grepl(pattern = paste(mechan, collapse = "|"), x = colnames(results))
int <- colnames(results)[int]

# sort(colnames(results)[(!colnames(results) %in% highLevel) & 
#                          (!colnames(results) %in% ext) & 
#                          (!colnames(results) %in% int) &
#                          (!colnames(results) %in% target)])

# Plot trees --------------------------------------------------------------

# ctrl = ctree_control(maxdepth=3, mincriterion=0.99)
# tree_extDifD <- ctree(class ~.,
#                       data = results[, c(ext)],
#                       controls = ctrl) 

dat <- results[,c(highLevel, "class")]

m1 <- rpart(class ~ ., data = dat)
png(filename = "../figures/treeHigh.png", width = 800, height = 600)
prp(m1,
    family = "serif",
    Margin = 0,
    
    box.palette = "Greens",
    #fallen.leaves = TRUE, #leaves at the bottom
    type = 1, 
    
    extra = 2, #101 = number and % of obs on node
    yesno = 2, # yes/no in every node
    left = FALSE, #yes to the right
    # nn = TRUE,
    # 
    # nn.font = 1,
    # nn.lwd = 0.5,
    # nn.space = 1,
    # nn.yspace = 0.7,
    
        
    branch = 1, # angle of lines. 1 = square.
    branch.type = 0, #width of the branch ~ to % of instances in node
    branch.col = "darkgreen",
    
    varlen = 0, #truncate var nchar to first unique
    faclen = 6, #nchar factors
#    facsep = ";",
#    split.font = 1, #not bold
#    split.fun = fun_split,

    #ni = TRUE,
    # ni.font = 1,
    # ni.lwd = 0.5,
    # ni.space = 1,
    # ni.yspace = 0.7,
      
    
#    digits = 3,
#   
    cex = 1.2,  
    compress = FALSE, #nodes do not have to be aligned
    ycompress = TRUE,
    xcompact = FALSE,
    ycompact = FALSE,
    nspace = 1, #The size of the space between a split and a leaf,
    #relative to the space between leaves.
    space = 0.8,
    yspace= 1,
    ygap = 2
    
    )
dev.off()

idHL <- row.names(m1$frame)
results$idHL <- idHL[m1$where]

condition1 <- (results$idHL == "115" | results$idHL == "29" |
                results$idHL == "15")
dat <- results[condition1,c(ext, "class")]

colnames(dat)

colnames(dat) <- gsub(pattern = "3", replacement = "4", x = colnames(dat))
colnames(dat) <- gsub(pattern = "2", replacement = "3", x = colnames(dat))
colnames(dat) <- gsub(pattern = "1", replacement = "2", x = colnames(dat))
colnames(dat) <- gsub(pattern = "0", replacement = "1", x = colnames(dat))

colnames(dat) <- gsub(pattern = "tmxd", replacement = "tMax", x = colnames(dat))
colnames(dat) <- gsub(pattern = "tmnd", replacement = "tMin", x = colnames(dat))
colnames(dat) <- gsub(pattern = "esaa", replacement = "soilEv", x = colnames(dat))
colnames(dat) <- gsub(pattern = "srad", replacement = "sRad", x = colnames(dat))

m2 <- rpart(class ~ ., data = dat)
png(filename = "../figures/treeExt.png", height = 600, width = 700)
prp(m2,
    family = "serif",
    Margin = 0,
    
    box.palette = "Greens",
    type = 1, 
    
    extra = 2, #101 = number and % of obs on node
    yesno = 2, # yes/no in every node
    left = FALSE, #yes to the right
    nn = TRUE,

    branch = 1, # angle of lines. 1 = square.
    branch.type = 0, #width of the branch ~ to % of instances in node
    branch.col = "darkgreen",
    
    varlen = 0, #truncate var nchar to first unique
    faclen = 6, #nchar factors

    cex = 1.2,  
    compress = FALSE, #nodes do not have to be aligned
    ycompress = TRUE,
    xcompact = FALSE,
    ycompact = FALSE,
    nspace = 1, #The size of the space between a split and a leaf,
    #relative to the space between leaves.
    space = 0.8,
    yspace= 1,
    ygap = 2
    
)
dev.off()

idExt <- row.names(m2$frame)
results$idExt <- NA
results$idExt[condition1] <- idExt[m2$where]

condition2 <- condition1

# condition2 <- (condition1 &
#                  (results$idExt == "13" | results$idExt == "7" |
#                     results$idExt == "25" | results$idExt == "11"))
dat <- results[condition2,c(int, "class")]

colnames(dat)

colnames(dat) <- gsub(pattern = "3", replacement = "4", x = colnames(dat))
colnames(dat) <- gsub(pattern = "2", replacement = "3", x = colnames(dat))
colnames(dat) <- gsub(pattern = "1", replacement = "2", x = colnames(dat))
colnames(dat) <- gsub(pattern = "0", replacement = "1", x = colnames(dat))

colnames(dat) <- gsub(pattern = "epaa", replacement = "plantTransp", x = colnames(dat))
colnames(dat) <- gsub(pattern = "laigd", replacement = "LAI", x = colnames(dat))
colnames(dat) <- gsub(pattern = "brdmd", replacement = "dailyBiomInc", x = colnames(dat))
colnames(dat) <- gsub(pattern = "tad", replacement = "tiller", x = colnames(dat))

m3 <- rpart(class ~ ., data = dat, cp = 0.01)
rpart.plot(m3, extra = 2, type = 1, nn = TRUE)

png(filename = "../figures/treeInt.png", height = 600, width = 700)
prp(m3,
    family = "serif",
    Margin = 0.1,
    
    box.palette = "Greens",
    type = 1, 
    
    extra = 2, #101 = number and % of obs on node
    yesno = 2, # yes/no in every node
    left = FALSE, #yes to the right
    #nn = TRUE,
    
    branch = 1, # angle of lines. 1 = square.
    branch.type = 0, #width of the branch ~ to % of instances in node
    branch.col = "darkgreen",
    
    varlen = 0, #truncate var nchar to first unique
    faclen = 6, #nchar factors
    
    cex = 1.2,  
    compress = TRUE, #nodes do not have to be aligned
    ycompress = FALSE,
    xcompact = FALSE,
    ycompact = FALSE,
    nspace = 1, #The size of the space between a split and a leaf,
    #relative to the space between leaves.
    space = 0.8,
    yspace= 1,
    ygap = 2
    
)
dev.off()

