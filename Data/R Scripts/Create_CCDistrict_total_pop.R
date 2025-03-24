
#create the population per district file

library(tidyverse)
library(tidycensus)
library(readxl)
library(here)
library(sf)

setwd(here("Data"))

#Population per Block
total_population_blocks <- get_decennial(
  geography = "block",
  variables = "P1_001N", # Total population
  state = "PA",
  county = "Philadelphia",
  year = 2020,
  geometry = TRUE #will add block geometry in this step
)

#Council District #
Blocks2020_CouncilDistrict2024 <- read_excel("Raw/Blocks2020_CouncilDistrict2024.xlsx")

joined_blocks <-merge(total_population_blocks, Blocks2020_CouncilDistrict2024, 
                      by.x = "GEOID", by.y = "GEOID20", all.x = TRUE, all.y = TRUE)

#save the block level dataset:
population_census_blocks<-joined_blocks
save(population_census_blocks, file="clean datasets/population_census_blocks.Rdata")

#aggregate to get district level population
CCDistrict_pop<-joined_blocks %>% 
  group_by(DISTRICT) %>% 
  summarize(CCDistrict_population = sum(value)) %>% 
  ungroup()
  
#save file
save(CCDistrict_pop,file="clean datasets/CCDistrict_pop.Rdata" )


#load("clean datasets/CCDistrict_pop.Rdata" )



