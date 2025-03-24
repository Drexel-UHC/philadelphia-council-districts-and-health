#Poverty Level

#B17001_002 #Estimate!!Total:!!Income in the past 12 months below poverty level:
#B17001_001 #Estimate: Total

#Tract ACS 2022

library(tidycensus)
library(tigris)
library(sf)
library(mapview)
library(dplyr)
library(readxl)
library(stringr)
library(ggplot2)
library(patchwork)
library(here)

setwd(here("Data"))

vars <- load_variables(2022, "acs5")

#load block population data
load("clean datasets/population_census_blocks.Rdata") 

#import poverty data from the census ACS
#Total Poverty by Tract
Poverty_Philly <- get_acs(
  geography = "tract",
  variables = c("B17001_002", "B17001_001"),# Total poverty population
  state = "PA",
  county = "Philadelphia",
  year = 2022,
  survey = "acs5"
)

#change variable names
Poverty_Philly_wide <- Poverty_Philly %>%
  group_by(GEOID) %>%
  summarize(
    total_pop = sum(estimate[variable == "B17001_001"]),
    total_poor = sum(estimate[variable == "B17001_002"])) %>%
  ungroup()

#Council District #
total_population_blocks <- population_census_blocks %>%
  mutate(GEOIDTRACT = str_sub(GEOID, 1, 11))

#Join poverty and block data
total_join <- total_population_blocks %>%
  left_join (Poverty_Philly_wide, by = c("GEOIDTRACT"="GEOID"))

#weights 
data <- total_join %>%
  group_by(GEOIDTRACT) %>%
  mutate(Weight = value/sum(value), #value is pop per block and sum(value) is the population of the census tract#
         Weight = case_when(is.nan(Weight)~0, TRUE~ Weight)) %>% 
  ungroup()

# Step 2: Summarize the values at the tract level, ensuring no duplication

data2 <- data %>%
  group_by(DISTRICT) %>%
  summarize(
    CD_Poor = sum(total_poor * Weight, na.rm = TRUE),  # Weighted poor population
    CD_pop = sum(value, na.rm = TRUE)     # Using the district population as the denominator 
  ) %>%
  ungroup() %>%
  mutate(CD_pct_poverty = (CD_Poor / CD_pop) * 100)  # Percentage calculation

#####################################################
# save clean dataset
############################################
poverty_status_CCdistrict<-data2

save(poverty_status_CCdistrict, file="clean datasets/poverty_status_CCdistrict.Rdata")


#Plots
# Calculate centroids
data4_centroids <- data2 %>%
  st_centroid() %>%
  mutate(X = st_coordinates(.)[,1], Y = st_coordinates(.)[,2])

ggplot(data = data2, aes(fill = CD_pct_poverty)) + 
  geom_sf() + 
  geom_text(data = data4_centroids, aes(x = X, y = Y, label = DISTRICT), 
                        size = 4, color = "black") + 
  scale_fill_distiller(palette = "PuBu", 
                       direction = 1) + 
  labs(title = 
         "Percent in Poverty by Philadelphia City
              Council District 2022",
       caption = "Data source: 2022 1-year ACS, US Census Bureau",
       fill = "ACS estimate") + 
  theme_void()+   
  theme(
    plot.title = element_text(size = 10, hjust = 0.5, margin = margin(b = 5)),
    legend.title = element_text(size = 6), 
    legend.text = element_text(size = 7),
    plot.margin = margin(1,1,1,1)
  )

ggplot(data = data2, aes(fill = CD_Poor)) + 
  geom_sf() + 
  geom_text(data = data4_centroids, aes(x = X, y = Y, label = DISTRICT), 
            size = 4, color = "black") + 
  scale_fill_distiller(palette = "PuBu", 
                       direction = 1) + 
  labs(title = 
         "Total in Poverty by Philadelphia City
              Council District 2022",
       caption = "Data source: 2022 1-year ACS, US Census Bureau",
       fill = "ACS estimate") + 
  theme_void()+   
  theme(
    plot.title = element_text(size = 10, hjust = 0.5, margin = margin(b = 5)),
    legend.title = element_text(size = 6), 
    legend.text = element_text(size = 7),
    plot.margin = margin(1,1,1,1)
  )

