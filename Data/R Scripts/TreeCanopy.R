# same issue as HVI - the tree canopy cover dataset uses 2010 census blocks
#we need to make a crosswalk between 2010 census tracts and 2020 census blocks


#Tree Canopy Cover UHC --2019

library(tidycensus)
library(tigris)
library(sf)
library(mapview)
library(dplyr)
library(readxl)
library(stringr)
library(ggplot2)
library(readr)
library(tidyverse)
library(tidygeocoder)
library(here)

setwd(here("Data"))

#Import CSV

data <- read_csv("Raw/Tree Canopy Cover UHC.csv")

#Filter just for 2019 (most recent)

tree_2019 <- data %>% filter(YEAR == "2019")

#Population per Block
total_population_blocks <- get_decennial(
  geography = "block",
  variables = "P1_001N", # Total population
  state = "PA",
  county = "Philadelphia",
  year = 2020,
  geometry = TRUE #will add block geometry in this step
)
#check geometry
mapview(total_population_blocks)

#Add in the crosswalk
Blocks2020_CouncilDistrict2024 <- read_excel(
  "C:/Documents/IDEA Fellow/Crosswalksmap/Blocks2020_CouncilDistrict2024.xlsx")

joined_blocks <-merge(total_population_blocks, Blocks2020_CouncilDistrict2024, 
                      by.x = "GEOID", by.y = "GEOID20", all.x = TRUE, all.y = TRUE)



#Need to remove Blockgroup from GEOID to join
tract_join <- joined_blocks %>%
  mutate(GEOIDTRACT = str_sub(GEOID, 1, 11))

#Attempt join
total_join <- tract_join %>%
  left_join (tree_2019, by = c("GEOIDTRACT"="GEOID10"))

#lots of missing values = I could remove them, but I'll leave it for now

#mapview(total_join)

#Need to think about how to show at CD level.
#Currently have % for the tract, so what would be the % for the whole CD
#Area?

#Since shape area is at the block level --> I summed it for each Tract since
#The original tree is by Census tract
data2 <- total_join %>%
  group_by(GEOIDTRACT) %>%
  mutate(Tract_Area = sum(SHAPE_Area), 
         Tract_Area = case_when(is.nan(Tract_Area)~0, TRUE~ Tract_Area)) %>%
  mutate(tree = CTNLCDTREE/100)%>%
  ungroup()

#I took each Tract area, and created a weight for CD
data3 <- data2 %>%
  group_by(DISTRICT) %>%
  mutate(Weight = Tract_Area/sum(Tract_Area),
         Weight = case_when(is.nan(Weight)~0, TRUE~ Weight)) %>%
  ungroup()

#I used the weight to take the tree % coverage for each CD
data4 <- data3 %>% 
  group_by(DISTRICT) %>%
  summarize(CD_tree = sum(CTNLCDTREE*Weight, na.rm = TRUE), CD_pop = sum(value, na.rm = TRUE)) %>%
  ungroup()

#data5 <- data4 %>% 
#  group_by(DISTRICT) %>%
#  summarize(percentage_tree = (CD_tree * 100))
#  ungroup()
#

# Calculate centroids for each district
data4_centroids <- data4 %>%
  st_centroid()

display.brewer.all()


ggplot(data = data4, aes(fill = CD_tree)) + 
  geom_sf() + 
  geom_text(data = data4_centroids, 
            aes(x = st_coordinates(geometry)[,1], 
                y = st_coordinates(geometry)[,2], 
                label = DISTRICT), 
            size = 4, color = "black") + 
  scale_fill_distiller(palette = "YlGn", 
                       direction = 1) + 
  labs(title = "Tree Canopy Cover by Philadelphia 
       City Council District 2019",
       caption = "Data source: Drexel Urban Health Collaborative (UHC)",
       fill = "% Tree Canopy 
       Cover") +
  theme_void()
  
