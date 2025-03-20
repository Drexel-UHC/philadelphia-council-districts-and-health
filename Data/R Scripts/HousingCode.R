##Housing Code Violations
library(tidycensus)
library(tigris)
library(sf)
library(mapview)
library(dplyr)
library(readxl)
library(stringr)
library(ggplot2)
library(readr)
library(RColorBrewer)

##Import CSV of Violations
data <- read_csv("C:/Documents/IDEA Fellow/VIOLATIONS.csv")

##Only want Open Violations

Open_cases <- data %>% filter(violationstatus == "OPEN")

#Already has council distict included in dataset
#Need to convert numeric to character for join
Open_cases2 <- Open_cases %>% mutate(council_district = as.character(council_district))

#Dataset too large
violations_per_district <- Open_cases2 %>% 
  group_by(council_district) %>% 
  summarize(total_violations = n(), .groups = "drop") %>%
  filter(council_district != 0 & !is.na(council_district))

# View the cleaned data
#print(violations_per_district)

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
#mapview(total_population_blocks)

#Council District #
Blocks2020_CouncilDistrict2024 <- read_excel(
  "C:/Documents/IDEA Fellow/Crosswalksmap/Blocks2020_CouncilDistrict2024.xlsx")

joined_blocks <-merge(total_population_blocks, Blocks2020_CouncilDistrict2024, 
                      by.x = "GEOID", by.y = "GEOID20", all.x = TRUE, all.y = TRUE)

#Check geometry by district
#mapview(joined_blocks, zcol = "DISTRICT")

##Join Open cases and joined blocks by District

total_join <- joined_blocks %>%
  left_join (violations_per_district, by = c("DISTRICT"="council_district"))


##total_join <- merge(joined_blocks, Open_cases2, TOO LARGE
                  ##  by.x = "DISTRICT", by.y = "council_district", all.x = TRUE, all.y = TRUE)

mapview(total_join, zcol = "total_violations")

district_data <- total_join %>%
  group_by(DISTRICT) %>%
  summarize(
    total_violations = unique(total_violations),  # Take unique value
    geometry = st_union(geometry)  # Dissolve geometries into one per district
  ) %>%
  st_as_sf()  # Ensure it remains an sf object

# Calculate centroids for each district
data4_centroids <- district_data %>%
  st_centroid()

display.brewer.all()

ggplot(data = district_data, aes(fill = total_violations)) + 
  geom_sf() + 
  geom_text(data = data4_centroids, 
            aes(x = st_coordinates(geometry)[,1], 
                y = st_coordinates(geometry)[,2], 
                label = DISTRICT), 
            size = 4, color = "black") + 
  scale_fill_distiller(palette = "YlGnBu", 
                       direction = 1) + 
  labs(title = "             Total Number of Housing Code Violations by 
       Philadelphia City Council District 2019 to July 2024",
       caption = "Data source: Open Data Philly",
       fill = "Total number of code 
          violations") + 
  theme_void() 

#Building footprint dataset, use polygons as points and use as denominator#
#add the year

#Add building footprints dataset

data_total <- read_csv("C:/Documents/IDEA Fellow/LI_BUILDING_FOOTPRINTS.csv")

buildings <- data_total %>% 
  summarize(total_buildings = n_distinct(ADDRESS))

#percentage

pct_data <- district_data %>% 
group_by(DISTRICT) %>% 
  summarize(
    pct_violations = (total_violations/495480)*100  # deno comes from above
  ) %>% 
  st_as_sf() 

#Plot pct
# Calculate centroids for each district
data5_centroids <- pct_data %>%
  st_centroid()


ggplot(data = pct_data, aes(fill = pct_violations)) + 
  geom_sf() + 
  geom_text(data = data5_centroids, 
            aes(x = st_coordinates(geometry)[,1], 
                y = st_coordinates(geometry)[,2], 
                label = DISTRICT), 
            size = 4, color = "black") + 
  scale_fill_distiller(palette = "YlGnBu", 
                       direction = 1) + 
  labs(title = "             Percentage of Housing Code Violations by 
       Philadelphia City Council District 2019 to July 2024",
       caption = "Data source: Open Data Philly",
       fill = "% of Buildings 
with Violations") + 
  theme_void() 


