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

#import 2010 to 2020 crosswalk
cross <- read_csv("Raw/IPUMS_2010_2020_Crosswalk.csv")

tree_2019 <- tree_2019 %>%
  mutate(geoid10 = as.character(GEOID10))

cross <- cross %>%
  mutate(tr2010ge = as.character(tr2010ge),
         blk2020ge = as.character(blk2020ge))

#load the block population
load("clean datasets/population_census_blocks.Rdata") 

#Left join to 2010 CT
merge_2010 <- tree_2019 %>%
  left_join(cross, by = c("GEOID10" = "tr2010ge"))

#merge with CD crosswalk
total_join <- population_census_blocks %>%
  left_join (merge_2010, by = c("GEOID" = "blk2020ge"))
  
#Weight with 2010 P_Area value
weighted_CD_tree <- total_join %>% 
  group_by(DISTRICT) %>% 
  summarise(CD_tree = weighted.mean(CTNLCDTREE, parea, na.rm = TRUE)) %>% 
  ungroup()

#################################################################
# save clean dataset
#################################################################

Tree_canopy_CCdistrict<-weighted_CD_tree

save(Tree_canopy_CCdistrict, file="clean datasets/Tree_canopy_CCdistrict.RData")


#################################################################
#Plots
#################################################################

# Calculate centroids for each district
data4_centroids <- weighted_CD_tree %>%
  st_centroid()

#display.brewer.all()


ggplot(data = weighted_CD_tree, aes(fill = CD_tree)) + 
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

#################################################################
#Old Code
#################################################################

#Population per Block
#total_population_blocks <- get_decennial(
#  geography = "block",
#  variables = "P1_001N", # Total population
#  state = "PA",
#  county = "Philadelphia",
#  year = 2020,
#  geometry = TRUE #will add block geometry in this step
#)

#check geometry
#mapview(total_population_blocks)

#Add in the CD crosswalk
#Blocks2020_CouncilDistrict2024 <- read_excel(
#  "C:/Documents/IDEA Fellow/Crosswalksmap/Blocks2020_CouncilDistrict2024.xlsx")

#joined_blocks <-merge(total_population_blocks, Blocks2020_CouncilDistrict2024, 
#                     by.x = "GEOID", by.y = "GEOID20", all.x = TRUE, all.y = TRUE)



#Need to remove Blockgroup from GEOID to join
#tract_join <- joined_blocks %>%
#  mutate(GEOIDTRACT = str_sub(GEOID, 1, 11))

#Attempt join
#total_join <- tract_join %>%
#  left_join (tree_2019, by = c("GEOIDTRACT"="GEOID10"))


#mapview(total_join)

#Need to think about how to show at CD level.
#Currently have % for the tract, so what would be the % for the whole CD
#Area?

#Since shape area is at the block level --> I summed it for each Tract since
#The original tree is by Census tract
#data2 <- total_join %>%
#  group_by(GEOIDTRACT) %>%
#  mutate(Tract_Area = sum(SHAPE_Area), 
#         Tract_Area = case_when(is.nan(Tract_Area)~0, TRUE~ Tract_Area)) %>%
#  mutate(tree = CTNLCDTREE/100)%>%
#  ungroup()

#I took each Tract area, and created a weight for CD
#data3 <- data2 %>%
#  group_by(DISTRICT) %>%
#  mutate(Weight = Tract_Area/sum(Tract_Area),
#         Weight = case_when(is.nan(Weight)~0, TRUE~ Weight)) %>%
#  ungroup()

#I used the weight to take the tree % coverage for each CD
#data4 <- data3 %>% 
#  group_by(DISTRICT) %>%
#  summarize(CD_tree = sum(CTNLCDTREE*Weight, na.rm = TRUE), CD_pop = sum(value, na.rm = TRUE)) %>%
#  ungroup()

#data5 <- data4 %>% 
#  group_by(DISTRICT) %>%
#  summarize(percentage_tree = (CD_tree * 100))
#  ungroup()
#


  
