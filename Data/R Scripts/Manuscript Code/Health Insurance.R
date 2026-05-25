#Health Insurance

#ACS variables

#B18135_007 -- Estimate!!Total:!!Under 19 years:!!With a disability:!!No health insurance coverage
#B18135_012 -- Estimate!!Total:!!Under 19 years:!!No disability:!!No health insurance coverage

#B18135_018 -- Estimate!!Total:!!19 to 64 years:!!With a disability:!!No health insurance coverage
#B18135_023 -- Estimate!!Total:!!19 to 64 years:!!No disability:!!No health insurance coverage

#B18135_029 -- Estimate!!Total:!!65 years and over:!!With a disability:!!No health insurance coverage
#B18135_034 -- Estimate!!Total:!!65 years and over:!!No disability:!!No health insurance coverage


library(tidycensus)
library(tigris)
library(sf)
library(mapview)
library(dplyr)
library(readxl)
library(stringr)
library(ggplot2)
library(here)
library(writexl)
library(Hmisc)


setwd(here("Data"))

vars <- load_variables(2022, "acs5")

#load the block population
load("clean datasets/population_census_blocks.Rdata") 



#Uninsured by Tract
uninsured_PA <- get_acs(
  geography = "tract",
  variables = c("B18135_012", "B18135_007", "B18135_018","B18135_023",
                "B18135_029", "B18135_034"),# Total uninsured population
  state = "PA",
  county = "Philadelphia",
  year = 2022,
  survey = "acs5")

pop_PA <- get_acs(
  geography = "tract",
  variables = c("B01001_001"),# Total  population
  state = "PA",
  county = "Philadelphia",
  year = 2022,
  survey = "acs5") %>% select(GEOID, estimate) %>% rename(pop = estimate)

#Now add all variables together by census tract
uninsured_PA_total <- uninsured_PA %>% 
  group_by(GEOID) %>% 
  dplyr::summarize(total_uninsured = sum(estimate, na.rm = TRUE)) %>% 
  ungroup() %>% 
  left_join(pop_PA, by='GEOID') %>% 
  mutate(pct_uninsured = total_uninsured/pop)




#Merge Tract insurance pop

#Need to recreate GEOID minus 4 for the block to join. 

total_population_blocks <- population_census_blocks %>%
  mutate(GEOIDTRACT = str_sub(GEOID, 1, 11))

#I need to do a join where the values repeat?

total_join <- total_population_blocks %>%
  left_join (uninsured_PA_total, by = c("GEOIDTRACT"="GEOID"))


#Weight = Blocks / Total block in same tract

data <- total_join %>%
  group_by(GEOIDTRACT) %>%
  mutate(Weight = value/sum(value), 
         Weight = case_when(is.nan(Weight)~0, TRUE~ Weight)) %>% #value is pop per block#
  ungroup() %>% 
  mutate(pct_uninsured = case_when(pop==0 ~ 0,
                                   TRUE~ pct_uninsured*100))




#Council District Insurance value
data2 <- data %>%
  group_by(DISTRICT) %>%
  dplyr::summarize(CD_uninsurance = sum(total_uninsured*Weight, na.rm = TRUE), 
            CD_pop = sum(value, na.rm = TRUE),
            within_sd = round(sqrt(wtd.var(x = pct_uninsured, weights = Weight)),1)) %>% 
  ungroup() %>% 
  mutate(percentage_uninsured = round(((CD_uninsurance/CD_pop)*100),1),
         between_sd = round(sd(percentage_uninsured),1),
         CD_uninsurance = round(CD_uninsurance))


##########################################
#         save clean dataset
##########################################
uninsured_CCdistrict<-data2 %>% 
  select(DISTRICT, CD_uninsurance,CD_pop,percentage_uninsured,within_sd,between_sd)
write_xlsx(uninsured_CCdistrict, "/Users/tr842/Library/CloudStorage/OneDrive-DrexelUniversity/Github_repositories/philadelphia-council-districts-and-health/Data/mansucript/output/uninsured_CCdistrict.xlsx")


##########################################
#         plot 
##########################################


# Calculate centroids for each district
data3_centroids <- data2 %>%
  st_centroid()

## PLOT THE BLOCK LEVEL UNINSURANCE:

p1<-ggplot() +
  geom_sf(data = data, aes(fill = pct_uninsured), color=NA) +  # First layer
  geom_sf(data = data2, fill = NA, color = "white", size = .3) +  # Second layer (outline or overlay)
  scale_fill_viridis_c(option = "mako", na.value = "white",
                       limits = c(0, 25)) +
  theme_void()+ labs(fill='% without medical \ninsurance')


p2<-ggplot() +
  geom_sf(data = data2, aes(fill = percentage_uninsured), color=NA) +  # First layer
  geom_sf(data = data2, fill = NA, color = "black", size = 0.3) +  # Second layer (outline or overlay)
  scale_fill_viridis_c(option = "mako", na.value = "white",
                       limits = c(0, 25) ) +
  theme_void() +
  geom_text(data = data3_centroids, 
            aes(x = st_coordinates(geometry)[,1], 
                y = st_coordinates(geometry)[,2], 
                label = DISTRICT), 
            size = 4, color = "white") + labs(fill='% without medical \ninsurance')


###############################################################################################################
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

p3<-ggplot() +
  geom_sf(data = total_join, aes(fill = CTNLCDTREE), color=NA) +  # First layer
  geom_sf(data = weighted_CD_tree, fill = NA, color = "white", size = 0.3) +  # Second layer (outline or overlay)
  scale_fill_viridis_c(option = "mako", na.value = "grey",
                       limits=c(0,77),direction = -1) +
  theme_void()+ labs(fill='% Tree Canopy Coverage')



p4<-ggplot() +
  geom_sf(data = weighted_CD_tree, aes(fill = CD_tree), color=NA) +  # First layer
  geom_sf(data = weighted_CD_tree, fill = NA, color = "black", size = 0.3) +  # Second layer (outline or overlay)
  scale_fill_viridis_c(option = "mako", na.value = "white",
                       limits = c(0, 77) ,direction = -1) +
  theme_void() +
  geom_text(data = data4_centroids, 
            aes(x = st_coordinates(geometry)[,1], 
                y = st_coordinates(geometry)[,2], 
                label = DISTRICT), 
            size = 4, color = "grey30") + labs(fill='% Tree Canopy Coverage')



library(gridExtra)

p1 <- p1 + ggtitle("a")
p2 <- p2 + ggtitle("b")
p3 <- p3 + ggtitle("c")
p4 <- p4 + ggtitle("d")



# Combine plots
combined <- arrangeGrob(p1, p2, p3, p4, ncol = 2)

# Save as EPS
ggsave("/Users/tr842/Library/CloudStorage/OneDrive-DrexelUniversity/Github_repositories/philadelphia-council-districts-and-health/Data/mansucript/fig_1.eps",
       plot = combined,
       device = "eps",
       width = 10, height = 8)


# grid.arrange(p1, p2, p3, p4,
#              ncol = 2,
#              top = "")
# 
# 
# pdf("/Users/tr842/Library/CloudStorage/OneDrive-DrexelUniversity/Github_repositories/philadelphia-council-districts-and-health/Data/mansucript/fig_1.pdf", 
#     width = 10, height = 8)
# grid.arrange(p1, p2, p3, p4, ncol = 2)
# dev.off()
