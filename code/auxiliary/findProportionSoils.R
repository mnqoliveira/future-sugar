# Set configurations ------------------------------------------------------
rm(list = ls())
options(stringsAsFactors = FALSE)
Sys.setenv(LANG = "En")

# libraries ---------------------------------------------------------------
# # Used for the maps part
# library(RCurl)
# library(RJSONIO)
# library(plyr)

# Used for coordinates conversion
library(sp)
library(rgdal)

library(tidyverse)

# Path files --------------------------------------------------------------
pathMetadataMaps <- ("../data/soil/")
pathCoords <- ("../data/coords/")

# Files -------------------------------------------------------------------
maps <- list.files(path = pathMetadataMaps, pattern = "map", 
                   full.names = TRUE)
coordsCities <- list.files(path = pathCoords, full.names = TRUE)

# Find nearest points to each city ----------------------------------------
map <- read.csv(maps[3])
head(map,1)
map <- map[,c("ID_PONTO", "TEXTURA", "POINT_X", "POINT_Y")]
colnames(map) <- c("id", "texture", "long", "lat")

# Conversion of coordinates
coords <- data.frame(ID = map$id,
                     X = as.numeric(map$lon), 
                     Y = as.numeric(map$lat))
coordinates(coords) <- c("X", "Y")
proj4string(coords) <- CRS("+proj=longlat +datum=WGS84")
res <- spTransform(coords, CRS("+proj=utm +zone=22 ellps=WGS84"))

map$latUTM <- res@coords[,2]
map$longUTM <- res@coords[,1]

coords <- read.table(coordsCities[3])
coords

latCity <- as.numeric(coords$V2[3])
longCity <- as.numeric(coords$V2[4])

coords <- data.frame(ID = "presidente", X = longCity, Y = latCity)
coordinates(coords) <- c("X", "Y")
proj4string(coords) <- CRS("+proj=longlat +datum=WGS84")
res <- spTransform(coords, CRS("+proj=utm +zone=22 ellps=WGS84"))

latCityUTM <- res@coords[,2]
longCityUTM <- res@coords[,1]

city <- as.matrix(cbind(longCityUTM, latCityUTM))
points <- as.matrix(map[,c("longUTM", "latUTM")])

map$dist <- spDistsN1(pts = points, pt = city)
points <- map[order(map$dist),]
pointsSel <- points[map$dist < 50000,]
table(pointsSel$texture)

#write.csv(subRotas, paste0(caminhoDados, "coordEscolas.csv"))
