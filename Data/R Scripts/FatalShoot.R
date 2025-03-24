#Fatal shootings

#Open Data Philly
#2015 - Present

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
library(RColorBrewer)
library(patchwork)
library(here)

setwd(here("Data"))

# Import CSV
data <- read_csv("Raw/shootings.csv")

# Remove rows with missing lng or lat
data <- data %>%
  filter(!is.na(lng) & !is.na(lat))

# Convert to an sf object
data <- data %>%
  st_as_sf(
    coords = c("lng", "lat"),
    crs    = 4326) %>% 
  mutate(fatal_shooting = case_when(fatal==1 ~ 1, TRUE~0),
         nonfatal_shooting = case_when(fatal==0~ 1, TRUE~0))

# Visualize the data
mapview(data) #I dont see any weird outliers

#load council districts
load("Clean datasets/CCDistrict_pop.Rdata")

CCDistrict_pop <- CCDistrict_pop %>%
  st_transform(crs = 4326)

st_crs(CCDistrict_pop)
st_crs(Fatal)

#intersect the council districts with the shooting point data, then summarize by district
shootings_by_district <- st_join(data, CCDistrict_pop, join = st_within) %>% 
  group_by(DISTRICT) %>%                                        
  summarize(count_fatal = sum(fatal_shooting),
            count_non_fatal = sum(nonfatal_shooting)) %>% 
  st_drop_geometry() %>% 
  filter(!is.na(DISTRICT))

#join the shooting data back with the council district geometry

Shootings_CCDistrict<-CCDistrict_pop %>% 
  left_join(shootings_by_district, by="DISTRICT")


##############################################################
#           save the clean dataset
##############################################################

save(Shootings_CCDistrict, file="clean datasets/Shootings_CCDistrict.Rdata")

# FATAL Calculate centroids for each district
data_centroids <- Shootings_CCDistrict %>%
  st_centroid() %>%
  mutate(x = st_coordinates(.)[,1], 
         y = st_coordinates(.)[,2])

display.brewer.all()

# Plot the result using ggplot2

#FATAL
plot1 <- ggplot(data = Shootings_CCDistrict, aes(fill = count_fatal)) + 
  geom_sf() + 
  geom_text(data = data_centroids, 
            aes(x = x, y = y, label = DISTRICT), 
            size = 4, color = "black") +
  scale_fill_distiller(palette = "PuRd", direction = 1) +
  labs(title = "Fatal",
       fill = "Number of \nShootings") + 
  theme_void() +
  theme(
    plot.title = element_text(size = 11, hjust = 0.5, margin = margin(b = 5)),
    legend.title = element_text(size = 9), 
    legend.text = element_text(size = 7),
    plot.margin = margin(5, 5, 5, 5)
  )

#NONFATAL

plot2 <- ggplot(data = Shootings_CCDistrict, aes(fill = count_non_fatal)) + 
  geom_sf() + 
  geom_text(data = data_centroids, 
            aes(x = x, y = y, label = DISTRICT), 
            size = 4, color = "black") +
  scale_fill_distiller(palette = "BuPu", direction = 1) +
  labs(title = "Nonfatal",
       fill = "Number of \nShootings") + 
  theme_void() +
  theme(
    plot.title = element_text(size = 11, hjust = 0.5, margin = margin(b = 5)),
    legend.title = element_text(size = 9), 
    legend.text = element_text(size = 7),
    plot.margin = margin(5, 5, 5, 5)
  )


# Combine the plots into a grid with a common title and caption
combined_plot <- plot1 + plot2 + 
  plot_layout(ncol = 2) + 
  plot_annotation(
    title = "Fatal and NonFatal Shootings by Philadelphia 
City Council District 2015 to Present",
    caption = "Data source: Open Data Philly",
    theme = theme(
      plot.title = element_text(size = 12, hjust = 0.5, margin = margin(b = 10)),
      plot.caption = element_text(size = 8, hjust = 0.5)
    )
  )

print(combined_plot)

##Would like to look at different years##

      # #Rates per 100,000
      # 
      # nonfatal_rate <- nonfatal_council_districts_aggregated %>%
      #   group_by(DISTRICT) %>%  # Group by council district
      #   summarize(
      #     nonfatal_per_100000 = (shoot_count/total_pop)*100000
      #   )
      # 
      # fatal_rate <- council_districts_aggregated %>%
      #   group_by(DISTRICT) %>%  # Group by council district
      #   summarize(
      #     fatal_per_100000 = (shoot_count/total_pop)*100000
      #   )



## OLD CODE:

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
# Blocks2020_CouncilDistrict2024 <- read_excel("Raw/Blocks2020_CouncilDistrict2024.xlsx")
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
# # Spatial join: fatal to districts
# fatalshoot_by_district <- st_join(Fatal, council_districts, join = st_within)
# 
# #Spatial Join: Non_fatal to districts
# nonfatal_by_district <- st_join(Non_fatal, council_districts, join = st_within)
# 
# # Count fatal shootings per district
# #fatalshoot_counts <- fatalshoot_by_district %>%
#  # filter(!is.na(DISTRICT)) %>%  # Remove rows where DISTRICT is NA
#  # group_by(DISTRICT) %>% 
#  # summarize(shoot_count = n(), .groups = 'drop')
# 
# # Fatal Count per district (without geometry)
# fatalshoot_counts <- fatalshoot_by_district %>%
#   filter(!is.na(DISTRICT)) %>%  # Remove rows where DISTRICT is NA
#   group_by(DISTRICT) %>% 
#   summarize(shoot_count = n(), .groups = 'drop') %>%
#   as.data.frame()  # Convert to a plain data frame (drop geometry)
# 
# # Nonfatal per district (without geometry)
# nonfatal_counts <- nonfatal_by_district %>%
#   filter(!is.na(DISTRICT)) %>%  # Remove rows where DISTRICT is NA
#   group_by(DISTRICT) %>% 
#   summarize(shoot_count = n(), .groups = 'drop') %>%
#   as.data.frame()  # Convert to a plain data frame (drop geometry)
# 
# # Join fatal counts back to the council district polygons
# council_districts_with_counts <- council_districts %>%
#   left_join(fatalshoot_counts, by = "DISTRICT")
# 
# # Join nonfatal counts back to the council district polygons
# nonfatal_council_districts_with_counts <- council_districts %>%
#   left_join(nonfatal_counts, by = "DISTRICT")
# 
# # Check the result
# print(council_districts_with_counts)
# 
# # FATAL Remove the extra geometry column (geometry.y) and rename geometry.x to geometry
# council_districts_with_counts <- council_districts_with_counts %>%
#   select(-geometry.y) %>%  # Drop the multipoint geometry column
#   rename(geometry = geometry.x)  # Rename geometry.x to geometry
# 
# # NONFATAL Remove the extra geometry column (geometry.y) and rename geometry.x to geometry
# non_fatal_council_districts_with_counts <- nonfatal_council_districts_with_counts %>%
#   select(-geometry.y) %>%  # Drop the multipoint geometry column
#   rename(geometry = geometry.x)  # Rename geometry.x to geometry
# 
# # FATAL Aggregate blocks to council districts
# council_districts_aggregated <- council_districts_with_counts %>%
#   group_by(DISTRICT) %>%  # Group by council district
#   summarize(
#     shoot_count = first(shoot_count),  # Take the first crash_count value (since it's the same for all blocks in a district)
#     SHAPE_Area = sum(SHAPE_Area, na.rm = TRUE),
#     total_pop = sum(value)# Sum area 
#   )
# 
# # NONFATAL Aggregate blocks to council districts
# nonfatal_council_districts_aggregated <- nonfatal_council_districts_with_counts %>%
#   group_by(DISTRICT) %>%  # Group by council district
#   summarize(
#     shoot_count = first(shoot_count),  # Take the first crash_count value (since it's the same for all blocks in a district)
#     SHAPE_Area = sum(SHAPE_Area, na.rm = TRUE),
#     total_pop = sum(value)# Sum area 
#   )

# Check the result
print(council_districts_aggregated)
