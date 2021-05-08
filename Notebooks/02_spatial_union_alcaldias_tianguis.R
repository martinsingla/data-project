##
rm(list= ls())
library(tidyverse)
library(sf)
library(leaflet)

dat<- read.csv("random/tianguis_df.csv")
dat <- dat %>% st_as_sf(coords= c("lng", "lat"), crs= 4326)

cols <- st_read("random/coloniascdmx/coloniascdmx.shp")
cols <- cols %>% st_set_crs(4326)
cols <- cols %>% 
  group_by(alcaldia) %>% 
  summarise()

leaflet() %>% 
  addTiles() %>% 
  addCircles(data= dat) %>% 
  addPolygons(data= cols, color = "red", fill = NA)


int <- st_intersects(cols, dat)
cols$tianguis_count <- lengths(int)


cols$tianguis_tot_ratings <- NA
cols$tianguis_avg_ratings <- NA
for (i in 1:length(int)){
  a <- int[i][[1]]
  b <- dat[a,]
  cols$tianguis_tot_ratings[i] <- sum(b$Users_ratings_total)
  cols$tianguis_avg_ratings[i] <- round(mean(b$Users_ratings_total),1)
}

cols$tianguis_avg_ratings[is.na(cols$tianguis_avg_ratings)] <- 0

st_write(cols, "random/alcaldias_con_tianguis.geojson", driver= "geoJSON")
