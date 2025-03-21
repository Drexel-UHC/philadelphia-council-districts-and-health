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
library(arrow)
library(tidyverse)
library(here)

setwd(here("Data"))

##Import CSV of Violations
# data <- read_csv("C:/Documents/IDEA Fellow/VIOLATIONS.csv")
data<-arrow::read_parquet("Raw/violations.parquet")


##subset to Open Violations
Open_cases <- data %>% filter(violationstatus == "OPEN")

#Already has council district included in dataset
#Need to convert numeric to character for join
Open_cases2 <- Open_cases %>% mutate(council_district = as.character(council_district))

#subset the dataset and summarize number of violations per districts
violations_per_district <- Open_cases2 %>% 
  group_by(council_district) %>% 
  summarize(total_violations = n(), .groups = "drop") %>%
  filter(council_district != 0 & !is.na(council_district))

# View the cleaned data
#print(violations_per_district)

#get the decennial census population per Census Block
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
# Blocks2020_CouncilDistrict2024 <- read_excel("C:/Documents/IDEA Fellow/Crosswalksmap/Blocks2020_CouncilDistrict2024.xlsx")

Blocks2020_CouncilDistrict2024 <- read_excel("Raw/Blocks2020_CouncilDistrict2024.xlsx")

joined_blocks <-merge(total_population_blocks, Blocks2020_CouncilDistrict2024, 
                      by.x = "GEOID", by.y = "GEOID20", all.x = TRUE, all.y = TRUE)

#Check geometry by district
#mapview(joined_blocks, zcol = "DISTRICT")

##Join Open cases and joined blocks by District

total_join <- joined_blocks %>%
  left_join (violations_per_district, by = c("DISTRICT"="council_district"))

# mapview(total_join, zcol = "total_violations")

district_data <- total_join %>%
  group_by(DISTRICT) %>%
  summarize(
    total_violations = unique(total_violations),  # Take unique value
    geometry = st_union(geometry)  # Dissolve geometries into one per district
  ) %>%
  ungroup() %>% 
  st_as_sf()  # Ensure it remains an sf object


#Building footprint dataset, use polygons as points and use as denominator
# We are using the number of violations per parcel as the numerator (from the violations dataset) and the number 
#of parcels per district as the denominator (because parcel seems to be the unique ID for both datasets)


#Add building footprints dataset

building_footprints <- read_csv("Raw/LI_BUILDING_FOOTPRINTS.csv")
building_footprints_shape <- read_sf('Raw/LI_BUILDING_FOOTPRINTS/LI_BUILDING_FOOTPRINTS.shp')

#fixing invalid districts
sum(!st_is_valid(building_footprints_shape))
building_footprints_shape <- st_make_valid(building_footprints_shape)

#group by parcel id
building_counts <- building_footprints_shape %>%  #using the parcel ID number to get the denominator of parcels as that is a unique identifier across both datasets
  select(PARCEL_ID_) %>% 
  group_by(PARCEL_ID_) %>%  
  summarise(building_count = n(), geometry = st_geometry(geometry[1])) %>%
  st_as_sf()

#get council district for each parcel
building_counts <- st_transform(building_counts, st_crs(district_data))
buildings_with_districts <- st_join(building_counts, district_data, left = TRUE)

parcel_totals_in_district <- buildings_with_districts %>%
  st_drop_geometry()%>% 
  group_by(DISTRICT) %>%  # Replace with the actual district ID column
  summarise(parcel_count = n())

#add percentages

housing_violations_per_CCdistrict <- district_data %>% 
  left_join(parcel_totals_in_district, by="DISTRICT") %>% 
  mutate(
    pct_violations = (total_violations/parcel_count*100 ) # denominator comes from above
  ) %>% 
  st_as_sf() 

#remove geometry to save as csv:
housing_violations_per_CCdistrict<-housing_violations_per_CCdistrict %>%   st_drop_geometry()

#############################################
#     save the cleaned district data        #
#############################################
#DISTRICT = city council district
#total_violations = the count of parcel violations per city council district. (parcel is a unique ID for building code violations)
#parcel_count = the count of parcels per city council district. 

#building footprint data from Open Data Philly is "current" downloaded in March 2025
#violation data from Open Data Philly is from 2020 - present and was downloaded on XX-XX-2025

write.csv(housing_violations_per_CCdistrict,"clean datasets/housing_violations_per_CCdistrict.csv" )





#PLOTTING
# Calculate centroids for each district (so that the labels will be in the center of the district when mapped)
data4_centroids <- housing_violations_per_CCdistrict %>%
  st_centroid()

# plot counts
# display.brewer.all()

ggplot(data = housing_violations_per_CCdistrict, aes(fill = total_violations)) + 
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



#Plot pct

ggplot(data = housing_violations_per_CCdistrict, aes(fill = pct_violations)) + 
  geom_sf() + 
  geom_text(data = data4_centroids, 
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


