#Kitchen and Plumbing maps

#ACS variables

#B25048_001 --> Total Occupied housing units tract
#B25048_003 --> Lacking plumbing occupied housing units tract

#B25052_001 --> Total Occupied housing units tract
#B25052_003 --> Lacking complete kitchen facilities tract

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
library(RColorBrewer)

#Find Variables
vars <- load_variables(2022, "acs5")

#Population per Block (need geometry for crosswalk)
total_population_blocks <- get_decennial(
  geography = "block",
  variables = "P1_001N", # Total population
  state = "PA",
  county = "Philadelphia",
  year = 2020,
  geometry = TRUE #will add block geometry in this step
)

#Facilities (Kitchen + Plumbing) by Tract
facilities <- get_acs(
  geography = "tract",
  variables = c("B25048_001", "B25048_003", "B25052_001", "B25052_003"),
  state = "PA",
  county = "Philadelphia",
  year = 2022,
  survey = "acs5"
)

#change variable names
facilities <- facilities %>%
  group_by(GEOID) %>%
  summarize(
    total_plumb = sum(estimate[variable == "B25048_001"]),
    lack_plumb = sum(estimate[variable == "B25048_003"]),
    total_kitch = sum(estimate[variable =="B25052_001"]),
    lack_kitch = sum(estimate[variable == "B25052_003"])) %>%
  ungroup()

#Council District #Crosswalk
Blocks2020_CouncilDistrict2024 <- read_excel(
  "C:/Documents/IDEA Fellow/Crosswalksmap/Blocks2020_CouncilDistrict2024.xlsx")

joined_blocks <-merge(total_population_blocks, Blocks2020_CouncilDistrict2024, 
                      by.x = "GEOID", by.y = "GEOID20", all.x = TRUE, all.y = TRUE)

#TRACT Need to recreate GEOID minus 4 for the block to join. 

total_population_blocks <- joined_blocks %>%
  mutate(GEOIDTRACT = str_sub(GEOID, 1, 11))

total_join <- total_population_blocks %>%
  left_join (facilities, by = c("GEOIDTRACT"="GEOID"))

#Weight population per block #variable= value
data <- total_join %>%
  group_by(GEOIDTRACT) %>%
  mutate(Weight = value/sum(value), 
         Weight = case_when(is.nan(Weight)~0, TRUE~ Weight),
         totalplumbweight = total_plumb*Weight) %>% #value is pop per block#
  ungroup()

#Create percents
data2 <- data %>%
  group_by(DISTRICT) %>%
  summarize(
    total_plumb2 = sum(total_plumb * Weight, na.rm = TRUE), 
    lack_plumb2 = sum(lack_plumb * Weight, na.rm = TRUE),
    total_kitch2 = sum(total_kitch * Weight, na.rm = TRUE),
    lack_kitch2 = sum(lack_kitch * Weight, na.rm = TRUE)) %>%
  ungroup() %>% 
  mutate(
    lack_plumb_pct = (lack_plumb2/total_plumb2)*100,
    lack_kitch_pct = (lack_kitch2/total_kitch2)*100
  )


#Plots

display.brewer.all()  # Shows all available palettes

# Calculate centroids
data4_centroids <- data2 %>%
  st_centroid() %>%
  mutate(X = st_coordinates(.)[,1], Y = st_coordinates(.)[,2])

# Lack Plumbing
plot1 <- ggplot(data = data2) + 
  geom_sf(aes(fill = lack_plumb_pct)) + 
  geom_text(data = data4_centroids, aes(x = X, y = Y, label = DISTRICT), 
            size = 4, color = "black") + 
  scale_fill_distiller(palette = "PuBu", direction = 1) + 
  labs(title = "Without Complete Plumbing",
       fill = "% Lack Complete 
       Plumbing") + 
  theme_void() +   
  theme(
    plot.title = element_text(size = 10, hjust = 0.5, margin = margin(b = 5)),
    legend.title = element_text(size = 6), 
    legend.text = element_text(size = 7),
    plot.margin = margin(1,1,1,1)
  )

#Lack Kitchen
plot2 <- ggplot(data = data2) + 
  geom_sf(aes(fill = lack_kitch_pct)) + 
  geom_text(data = data4_centroids, aes(x = X, y = Y, label = DISTRICT), 
            size = 4, color = "black") + 
  scale_fill_distiller(palette = "OrRd", direction = 1) + 
  labs(title = "Without Complete Kitchen",
       fill = "% Lack Complete 
        Kitchen") + 
  theme_void() +   
  theme(
    plot.title = element_text(size = 10, hjust = 0.5, margin = margin(b = 5)),
    legend.title = element_text(size = 6), 
    legend.text = element_text(size = 7),
    plot.margin = margin(1,1,1,1)
  )

# Combine Plots
combined_plot <- plot1 + plot2 + 
  plot_layout(ncol = 2) + 
  plot_annotation(
    title = "Occupied Housing Units Lacking Complete Plumbing vs. Complete Kitchen (2022)",
    caption = "Data source: 2022 ACS 5-Year Estimates, US Census Bureau",
    theme = theme(
      plot.title = element_text(size = 12, hjust = 0.5, margin = margin(b = 10)),
      plot.caption = element_text(size = 8, hjust = 0.5)
    )
  )

print(combined_plot)
