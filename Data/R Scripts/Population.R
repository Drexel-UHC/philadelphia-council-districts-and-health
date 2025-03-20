library(tidycensus)
library(tigris)
library(sf)
library(mapview)
library(dplyr)
library(readxl)
library(stringr)

vars <- load_variables(2022, "acs5")
View(vars) 

#Population per Block
total_population_blocks <- get_decennial(
  geography = "block",
  variables = "P1_001N", # Total population
  state = "PA",
  county = "Philadelphia",
  year = 2020,
  geometry = TRUE #will add block geometry in this step
)

#Population by Tract
total_population_tract <- get_decennial(
  geography = "tract",
  variables = "P1_001N", # Total population
  state = "PA",
  county = "Philadelphia",
  year = 2020,
)

#Council District #
Blocks2020_CouncilDistrict2024 <- read_excel(
  "C:/Documents/IDEA Fellow/Crosswalksmap/Blocks2020_CouncilDistrict2024.xlsx")
View(Blocks2020_CouncilDistrict2024)

joined_blocks <-merge(total_population_blocks, Blocks2020_CouncilDistrict2024, 
                      by.x = "GEOID", by.y = "GEOID20", all.x = TRUE, all.y = TRUE)

#Check geometry by district
mapview(joined_blocks, zcol = "DISTRICT")

#Need to recreate GEOID minus 4 for the block to join. 
joined_blocks2 <- joined_blocks %>%
  mutate(GEOIDTRACT = str_sub(GEOID, 1, 11))

total_join <- total_population_tract %>%
  left_join (joined_blocks2, by = c("GEOID"="GEOIDTRACT"))

#Weight
data <- total_join %>%
  group_by(GEOID) %>%
  mutate(Weight = value.y/sum(value.y)) %>% #value is pop per block#
  ungroup()

data2 <- data %>%
  group_by(DISTRICT) %>%
  summarize(Totalpop = weighted.mean(value.x, Weight, na.rm = TRUE)) %>% #value.x is pop is  per tract#
  ungroup()




mapview(data2)