##Median Household Income by Council District


#Block Group!

#B19013_001 - Estimate!!Median household income in the past 12 months (in 2022 inflation-adjusted dollars)
#B11001_001 - Estimate!!Total:Household Type (Including Living Alone)


library(tidycensus)
library(tigris)
library(sf)
library(mapview)
library(dplyr)
library(readxl)
library(stringr)
library(ggplot2)
library(matrixStats)
library(patchwork)

vars <- load_variables(2022, "acs5")

#Population and HH per Block (need geometry for crosswalk)
total_population_blocks <- get_decennial(
  geography = "block",
  variables = c("P1_001N", "H1_002N"), # Total population
  state = "PA",
  county = "Philadelphia",
  year = 2020,
  geometry = TRUE #will add block geometry in this step
)

total_population_blocks <- total_population_blocks %>%
  group_by(GEOID) %>%
  summarize(
    pop = sum(value[variable == "P1_001N"]),
    HH = sum(value[variable == "H1_002N"])) %>%
  ungroup()

#medianHH by Block Group
medianHH <- get_acs(
  geography = "block group",
  variables = c("B19013_001", "B11001_001"),# Total HH income and total HH
  state = "PA",
  county = "Philadelphia",
  year = 2022,
  survey = "acs5"
)

#change variable names
medianHH <- medianHH %>%
  group_by(GEOID) %>%
  summarize(
    total_HH = sum(estimate[variable == "B11001_001"]),
    medianHH = sum(estimate[variable == "B19013_001"])) %>%
  ungroup()

#Council District #
Blocks2020_CouncilDistrict2024 <- read_excel(
  "C:/Documents/IDEA Fellow/Crosswalksmap/Blocks2020_CouncilDistrict2024.xlsx")

joined_blocks <-merge(total_population_blocks, Blocks2020_CouncilDistrict2024, 
                      by.x = "GEOID", by.y = "GEOID20", all.x = TRUE, all.y = TRUE)

#Need to recreate GEOID minus 3 for the block group to join. 

total_population_blocks <- joined_blocks %>%
  mutate(GEOIDBG = str_sub(GEOID, 1, 12))

total_join <- total_population_blocks %>%
  left_join (medianHH, by = c("GEOIDBG"="GEOID"))

#weights? Should find number of HH#
data <- total_join %>%
  group_by(GEOIDBG) %>%
  mutate(Weight = HH/sum(HH), 
         Weight = case_when(is.nan(Weight)~0, TRUE~ Weight)) %>% #value is pop per block#
  ungroup()

#District
data2 <- data %>%
  group_by(DISTRICT) %>%
  summarize(
    total_HH_district = sum(total_HH * Weight, na.rm = TRUE),
    medianHH_district = weightedMedian(medianHH, Weight, na.rm = TRUE)) %>% 
  #do I want to use a weighted Median?? -> yes
  ungroup()

#plot
# Calculate centroids
data4_centroids <- data2 %>%
  st_centroid() %>%
  mutate(X = st_coordinates(.)[,1], Y = st_coordinates(.)[,2])

ggplot(data = data2, aes(fill = medianHH_district)) + 
  geom_sf() + 
  geom_text(data = data4_centroids, aes(x = X, y = Y, label = DISTRICT), 
            size = 4, color = "black") + 
  scale_fill_distiller(palette = "BuPu", 
                       direction = 1) + 
  labs(title = 
  "Weighted Median Household income by Philadelphia City
   Council District 2022",
       caption = "Data source: 2022 5-year ACS, US Census Bureau",
       fill = "Median Income") + 
  theme_void() +   
  theme(
    plot.title = element_text(size = 10, hjust = 0.5, margin = margin(b = 5)),
    legend.title = element_text(size = 6), 
    legend.text = element_text(size = 7),
    plot.margin = margin(1,1,1,1)
  )
