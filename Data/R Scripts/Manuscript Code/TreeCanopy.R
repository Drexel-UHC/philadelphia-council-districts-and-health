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
library(Hmisc)

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
  summarise(CD_tree = weighted.mean(CTNLCDTREE, parea, na.rm = TRUE),
            within_sdw = round(sqrt(wtd.var(x = CTNLCDTREE, weights = parea)),1)) %>% 
  ungroup() %>% 
  mutate(between_sd = round(sd(CD_tree),1),
         CD_tree = round(CD_tree,1))
         


#################################################################
# save clean dataset
#################################################################

Tree_canopy_CCdistrict<-weighted_CD_tree

write_xlsx(Tree_canopy_CCdistrict, "/Users/tr842/Library/CloudStorage/OneDrive-DrexelUniversity/Github_repositories/philadelphia-council-districts-and-health/Data/mansucript/output/Tree_canopy_CCdistrict.xlsx")



#################################################################
#Plots
#################################################################

# Calculate centroids for each district
data4_centroids <- weighted_CD_tree %>%
  st_centroid()

#display.brewer.all()


## PLOT THE BLOCK LEVEL UNINSURANCE:

ggplot() +
  geom_sf(data = total_join, aes(fill = CTNLCDTREE), color=NA) +  # First layer
  geom_sf(data = weighted_CD_tree, fill = NA, color = "white", size = 3) +  # Second layer (outline or overlay)
  scale_fill_viridis_c(option = "mako", na.value = "grey",
                       limits=c(0,77),direction = -1) +
  theme_void()


ggplot() +
  geom_sf(data = weighted_CD_tree, aes(fill = CD_tree), color=NA) +  # First layer
  geom_sf(data = weighted_CD_tree, fill = NA, color = "black", size = 0.3) +  # Second layer (outline or overlay)
  scale_fill_viridis_c(option = "mako", na.value = "white",
                       limits = c(0, 77) ,direction = -1) +
  theme_void() +
  geom_text(data = data4_centroids, 
            aes(x = st_coordinates(geometry)[,1], 
                y = st_coordinates(geometry)[,2], 
                label = DISTRICT), 
            size = 4, color = "grey30") 







\