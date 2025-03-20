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

vars <- load_variables(2022, "acs5")

#Population per Block
total_population_blocks <- get_decennial(
  geography = "block",
  variables = "P1_001N", # Total population
  state = "PA",
  county = "Philadelphia",
  year = 2020,
  geometry = TRUE #will add block geometry in this step
)

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
Poverty_Philly <- Poverty_Philly %>%
  group_by(GEOID) %>%
  summarize(
    total_pop = sum(estimate[variable == "B17001_001"]),
    total_poor = sum(estimate[variable == "B17001_002"])) %>%
  ungroup()

#Council District #
Blocks2020_CouncilDistrict2024 <- read_excel(
  "C:/Documents/IDEA Fellow/Crosswalksmap/Blocks2020_CouncilDistrict2024.xlsx")

joined_blocks <-merge(total_population_blocks, Blocks2020_CouncilDistrict2024, 
                      by.x = "GEOID", by.y = "GEOID20", all.x = TRUE, all.y = TRUE)

total_population_blocks <- joined_blocks %>%
  mutate(GEOIDTRACT = str_sub(GEOID, 1, 11))

#Join them
total_join <- total_population_blocks %>%
  left_join (Poverty_Philly, by = c("GEOIDTRACT"="GEOID"))

#weights? 
data <- total_join %>%
  group_by(GEOIDTRACT) %>%
  mutate(Weight = value/sum(value), #value is pop per block#
         Weight = case_when(is.nan(Weight)~0, TRUE~ Weight)) %>% 
  ungroup()

# Step 2: Summarize the values at the tract level, ensuring no duplication
data <- data %>% 
  group_by(GEOIDTRACT) %>% 
  summarize(
    Weight = first(Weight),  # Use the first value of weight per tract
    tract_poor = sum(total_poor, na.rm = TRUE),  # Sum poor population per tract
    tract_pop = sum(total_pop, na.rm = TRUE),
    DISTRICT = first(DISTRICT)# Sum total population per tract
  ) %>% 
  ungroup()

data2 <- data %>%
  group_by(DISTRICT) %>%
  summarize(
    CD_Poor = sum(tract_poor * Weight, na.rm = TRUE),  # Weighted poor population
    CD_pop = sum(tract_pop * Weight, na.rm = TRUE)     # Weighted total population
  ) %>%
  ungroup() %>%
  mutate(CD_pct = (CD_Poor / CD_pop) * 100)  # Percentage calculation



#Plots
# Calculate centroids
data4_centroids <- data2 %>%
  st_centroid() %>%
  mutate(X = st_coordinates(.)[,1], Y = st_coordinates(.)[,2])

ggplot(data = data2, aes(fill = CD_pct)) + 
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

