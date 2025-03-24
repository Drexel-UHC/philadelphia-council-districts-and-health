#Fatal Crashes
#Philly Open Data
#2020 to Present
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

# Import CSV
data <- read_csv("Raw/fatal_crashes.csv")

# Remove rows with missing lng or lat
data <- data %>%
  filter(!is.na(lng) & !is.na(lat))

# Convert to an sf object
data <- data %>%
  st_as_sf(
    coords = c("lng", "lat"),
    crs    = 4326
  )

# Visualize the data
mapview(data)

# Remove outlier (e.g., point in Lake Erie)
data <- data %>%
  filter(objectid != 621544) %>% 
  mutate(count=1) #making a count variable to sum later

#load council districts
load("Clean datasets/CCDistrict_pop.Rdata")

CCDistrict_pop <- CCDistrict_pop %>%
  st_transform(crs = 4326)

st_crs(CCDistrict_pop)
st_crs(data)

#intersect the council districts with the shooting point data, then summarize by district
crashes_by_district <- st_join(data, CCDistrict_pop, join = st_within) %>% 
  group_by(DISTRICT) %>%                                        
  summarize(count_crashes = sum(count)) %>% 
  st_drop_geometry() %>% 
  filter(!is.na(DISTRICT))

#join the shooting data back with the council district geometry

Crashes_CCDistrict<-CCDistrict_pop %>% 
  left_join(crashes_by_district, by="DISTRICT")

###########################################################
#  save clean dataset
########################################################

save(Crashes_CCDistrict, file="clean datasets/Crashes_CCDistrict.RData")

###########################################################
#  map
########################################################


# Calculate centroids for each district
data_centroids <- Crashes_CCDistrict %>%
  st_centroid()

display.brewer.all()

# Plot the result using ggplot2
ggplot(data = Crashes_CCDistrict, aes(fill = count_crashes)) + 
  geom_sf() + 
  geom_text(data = data_centroids, 
            aes(x = st_coordinates(geometry)[,1], 
                y = st_coordinates(geometry)[,2], 
                label = DISTRICT), 
            size = 4, color = "black") + 
  scale_fill_distiller(palette = "PuBu", direction = 1) +  # Keep only this
  labs(title = "Total Number of Fatal Crashes by Philadelphia 
       City Council District 2019 to Present",
       fill = "Number of \nCrashes",
       caption = "Data source: Open Data Philly") + 
  theme_void() 


## OLD CODE:
      # 
      # # Population per Block
      # total_population_blocks <- get_decennial(
      #   geography = "block",
      #   variables = "P1_001N", # Total population
      #   state = "PA",
      #   county = "Philadelphia",
      #   year = 2020,
      #   geometry = TRUE # Add block geometry in this step
      # )
      # 
      # # Council District Data
      # Blocks2020_CouncilDistrict2024 <- read_excel("Raw/Blocks2020_CouncilDistrict2024.xlsx"
      # )
      # 
      # # Join population blocks with council district data
      # joined_blocks <- merge(total_population_blocks, Blocks2020_CouncilDistrict2024, 
      #                        by.x = "GEOID", by.y = "GEOID20", all.x = TRUE, all.y = TRUE)
      # 
      # # Convert to sf object and ensure CRS matches crash data
      # council_districts <- joined_blocks %>%
      #   st_as_sf() %>%
      #   st_transform(crs = 4326)
      # 
      # # Filter out non-polygon geometries (e.g., LINESTRING) from council_districts
      # council_districts <- council_districts %>%
      #   filter(st_is(., "POLYGON") | st_is(., "MULTIPOLYGON"))
      # 
      # # Check geometry types
      # table(st_geometry_type(council_districts))  # Should only show POLYGON or MULTIPOLYGON
      # 
      # # Spatial join: crashes to districts
      # crashes_by_district <- st_join(data, council_districts, join = st_within)
      # 
      # # Count crashes per district
      # crash_counts <- crashes_by_district %>%
      #   filter(!is.na(DISTRICT)) %>%  # Remove rows where DISTRICT is NA
      #   group_by(DISTRICT) %>% 
      #   summarize(crash_count = n(), .groups = 'drop')
      # 
      # # Count crashes per district (without geometry)
      # crash_counts <- crashes_by_district %>%
      #   filter(!is.na(DISTRICT)) %>%  # Remove rows where DISTRICT is NA
      #   group_by(DISTRICT) %>% 
      #   summarize(crash_count = n(), .groups = 'drop') %>%
      #   as.data.frame()  # Convert to a plain data frame (drop geometry)
      # 
      # # Join crash counts back to the council district polygons
      # council_districts_with_counts <- council_districts %>%
      #   left_join(crash_counts, by = "DISTRICT")
      # 
      # # Check the result
      # print(council_districts_with_counts)
      # 
      # # Remove the extra geometry column (geometry.y) and rename geometry.x to geometry
      # council_districts_with_counts <- council_districts_with_counts %>%
      #   select(-geometry.y) %>%  # Drop the multipoint geometry column
      #   rename(geometry = geometry.x)  # Rename geometry.x to geometry
      # 
      # # Check the result
      # #print(council_districts_with_counts)
      # 
      # # Aggregate blocks to council districts
      # council_districts_aggregated <- council_districts_with_counts %>%
      #   group_by(DISTRICT) %>%  # Group by council district
      #   summarize(
      #     crash_count = first(crash_count),  # Take the first crash_count value (since it's the same for all blocks in a district)
      #     SHAPE_Area = sum(SHAPE_Area, na.rm = TRUE)  # Sum area 
      #   )

