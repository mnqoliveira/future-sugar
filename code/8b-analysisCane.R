# author: Monique Pires Gravina de Oliveira
# date: 2016-09-07

# Organize the outcomes of sugarcane

rm(list = ls())
gc()
options(stringsAsFactors = FALSE)

# Load Library ------------------------------------------------------------

library("tidyverse")

# Load files --------------------------------------------------------------

load("../data/outputs/resultsPreBaseline.RData")
fullSim <- results

load("../data/outputs/simulResultsSum.RData")


# Eval missing values -----------------------------------------------------
# Eval table of full results (fullSim)
outputs <- c('smfmd_3', 'sufmd_3', "stalk_3", "lddmd_3")
descriptors <- c('mod', 'city', 'var', 'date', 'irr', 'year', 'soil')
scenarios <- c('rcp', 'gcm', 'approach')

fullSim <- fullSim[,c(descriptors, scenarios, outputs)]

renameFrom <- paste(outputs, collapse = "|")
renameTo <- c("tch", "pol", "fiber", "trash")
renamePos <- grep(renameFrom, colnames(fullSim))

colnames(fullSim)[renamePos] <- renameTo

# Limit cultivar only to RB867515
fullSim <- fullSim[fullSim$var == "RB867515", ]
fullSim <- fullSim[,-match('var', colnames(fullSim))]

colnames(fullSim)

# Max sim number
# mod x city x date x irr x year x soil x rcp x gcm x approach
# 2 * 3 * 3 * 2 * 30 * 2 * 4 * 26 * 2 + 2 * 3 * 3 * 2 * 30 * 2 * 1 * 1 * 1
# 451440; 225720 per model

table(fullSim$mod)
# A: 223210; D: 225064
# A: -2510; D: -656

apsim <- fullSim %>%
  filter(mod == "A", irr == "rainfed", soil == "clayey")
table(apsim$date, apsim$year)
colnames(apsim)

# Missing APSIM
missinAps1 <- filter(apsim, gcm == "C", city == "jatai")
char1 <- sapply(missinAps1, is.character)
char1["year"] <- T
missinAps1[char1] <- as.data.frame(lapply(missinAps1[char1], as.factor))
summary(missinAps1)

missinAps2 <- filter(apsim, year == "1980")
table(missinAps2$date, missinAps2$approach)
missinAps2[char1] <- as.data.frame(lapply(missinAps2[char1], as.factor))
summary(missinAps2)

missinAps3 <- filter(apsim, year == "1980")
table(missinAps3$rcp, missinAps3$date)

# Missing DSSAT
dssat <- fullSim %>%
  filter(mod == "D")

sum((table(dssat$rcp, dssat$year) - 1872)[1:4, ])

missSim <- fullSim %>%
  filter(mod == "D", soil == "clayey", irr == "rainfed")

missSim <- filter(missSim, year == "1991", city == "presidente", rcp == "C",
                  gcm == "B")
table(missSim$approach, missSim$gcm)

# Find missing values
missingTCH <- filter(dssat, is.na(tch))

simpMissingTCH <- missingTCH %>%
  filter(soil == "clayey", irr == "rainfed", city == "presidente", 
         year == "1984", rcp == "C", gcm == "B")

simpMissingTCH

table(simpMissingTCH$approach)

# Synthesis ---------------------------------------------------------------

# resultsSum <- results %>%
#   group_by(mod, city, approach, rcp) %>%
#   summarise(meanTCH = mean(tch, na.rm = TRUE), 
#             meanPol = mean(pol, na.rm = TRUE),
#             meanFiber = mean(fiber, na.rm = TRUE), 
#             meanTrash = mean(trash, na.rm = TRUE))

#write.csv(resultsSum, file = '../tables/summaryCane.csv')

resultsSum <- results %>%
  group_by(year, city, gcm, rcp, approach, scen) %>%
  summarise(tch = mean(tch, na.rm = TRUE),
            pol = mean(pol, na.rm = TRUE))

colnames(resultsSum)
colnames(results)

resultsSum$mod <- "mean"

resultsModif <- results %>%
  select(-trash, -fiber, -weight) %>%
  bind_rows(resultsSum) %>%
  mutate(timeFrame = ifelse((rcp == "X"), "Baseline", 
                            ifelse(((rcp == "C") | (rcp == "E")), 
                                   "NT", "MC")
                            )
         ) %>% 
  group_by(year, mod, city, scen) %>%
  mutate(difPol = pol - pol[rcp == "X"],
         difTCH = tch - tch[rcp == "X"])

monique <- "teste"

# Summarizing -------------------------------------------------------------
# Difference from the baseline Near-term and Mid-Century model averages
# per city

resultsFilt <- resultsModif %>%
  mutate(scenario = paste0(approach, rcp)) %>%
  filter(scenario %in% c("XX", "AC", "FE", "AG", "FI")) %>%
  mutate(scenario = ifelse((scenario == "XX"), "Baseline", 
                           ifelse(((scenario == "AC") | (scenario == "AG")), 
                                  "Less severe", "More severe")
  )
  )  %>%
  filter(scen == 0 & mod == "mean" & rcp != "X")

condition <- sapply(FUN = is.character, resultsFilt)
resultsFilt[,condition] <- lapply(FUN = as.factor, 
                                     X = resultsFilt[,condition])

summary(resultsFilt)

resultsFilt$timeFrame <- factor(resultsFilt$timeFrame,
                      levels = c("Baseline", "NT", "MC"),
                      labels = c("Baseline", "Near-term", "Mid-century") )

resultsFilt$city <- factor(resultsFilt$city,
                      levels = c("piracicaba", "jatai", "presidente"),
                      labels = c("Piracicaba", "Jatai", "Presidente Prudente"))

comb <- expand.grid(unique(resultsFilt$city),
                    unique(resultsFilt$timeFrame),
                    unique(resultsFilt$scenario),
                    unique(resultsFilt$mod))

colnames(comb) <- c("city", "timeFrame", "scenario", "mod")

for(i in 1:nrow(comb)){
  cond1 <- resultsFilt$city == comb$city[i]
  cond2 <- resultsFilt$timeFrame == comb$timeFrame[i]
  cond3 <- resultsFilt$scenario == comb$scenario[i]
  cond4 <- resultsFilt$mod == comb$mod[i]
  
  condition <- cond1 & cond2 & cond3 & cond4
  
  comb$meanDifPol[i] <- mean(resultsFilt$difPol[condition], na.rm = TRUE)
  comb$sdDifPol[i] <- sd(resultsFilt$difPol[condition], na.rm = TRUE)
  
  comb$meanDifTCH[i] <- mean(resultsFilt$difTCH[condition], na.rm = TRUE)
  comb$sdDifTCH[i] <- sd(resultsFilt$difTCH[condition], na.rm = TRUE)
  
}

comb
write.csv(comb, file = "../tables/summaryDifs.csv")
# png(filename = "../figures/outputs/difPol.png",
#     height = 600, width = 700)
# ggplot(data = resultsFilt) +
#   geom_boxplot(mapping = aes(x = scenario, y = difPol)) +
#   facet_grid(city ~ timeFrame) +
#   labs(x = "Scenario", y = "Sugar content [%]") +
#   geom_hline(aes(yintercept = 0)) +
#   theme_light()
# dev.off()
# 
# png(filename = "../figures/outputs/difTCH.png", 
#     height = 600, width = 700)
# ggplot(data = resultsFilt) + 
#   geom_boxplot(mapping = aes(x = scenario, y = difTCH)) + 
#   facet_grid(city ~ timeFrame) +
#   labs(x = "Scenario", y = "TCH [Mg ha-1]") + 
#   geom_hline(aes(yintercept = 0)) +
#   theme_light()
# dev.off()
# 
# # Explicitly showing model differences for sucrose estimates
# resultsFilt <- resultsModif %>%
#   filter(scen == 0 & mod != "mean" & rcp != "X")
# 
# condition <- sapply(FUN = is.character, resultsFilt)
# resultsFilt[,condition] <- lapply(FUN = as.factor, 
#                                   X = resultsFilt[,condition])
# 
# summary(resultsFilt)
# 
# head(resultsFilt)
# resultsFilt$mod <- factor(resultsFilt$mod,
#                           levels = c("A", "D"),
#                           labels = c("Apsim-Sugar", "DSSAT-Canegro") )
# 
# resultsFilt$timeFrame <- factor(resultsFilt$timeFrame,
#                           levels = c("NT", "MC"),
#                           labels = c("Near-term", "Mid-century") )
# 
# resultsFilt$city <- factor(resultsFilt$city,
#                            levels = c("piracicaba", "jatai", "presidente"),
#                            labels = c("Piracicaba", "Jatai", "Presidente Prudente"))
# 
# png(filename = "../figures/outputs/modelsSugar.png", 
#     height = 600, width = 700)
# ggplot(data = resultsFilt) + 
#   geom_boxplot(mapping = aes(x = timeFrame, y = difPol)) + 
#   facet_grid(city ~ mod) +
#   labs(x = "Timeframe", y = "Sugar content [%]") + 
#   #coord_cartesian(ylim = c(-4, 4))  + 
#   geom_hline(aes(yintercept = 0)) +
#   theme_light()
# dev.off()
