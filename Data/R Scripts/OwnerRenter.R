#Housing: Owned vs. Renter

#ACS variables 

#B25003_001 --> Estimate!!Total: block group
#B25003_002 --> Estimate!!Total:!!Owner occupied block group
#B25003_003 --> Estimate!!Total:!!Renter occupied block group 

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
library(here)

setwd(here('Data'))


#Find Variables
vars <- load_variables(2020, "pl")
#look up tidycensus

#H1_002N #Total occupied


#Population per Block and households per block (need geometry for crosswalk)
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

#Occupany by Block Group
Occupany <- get_acs(
  geography = "block group",
  variables = c("B25003_001", "B25003_002", "B25003_003"),#Total, owner, renter
  state = "PA",
  county = "Philadelphia",
  year = 2022,
  survey = "acs5"
)

#change variable names
Occupany_wide <- Occupany %>%
  group_by(GEOID) %>%
  summarize(
    total_HH = sum(estimate[variable == "B25003_001"]),
    owner = sum(estimate[variable == "B25003_002"]),
    renter = sum(estimate[variable =="B25003_003"])) %>%
  ungroup()

#Council District #Crosswalk
Blocks2020_CouncilDistrict2024 <- read_excel("Raw/Blocks2020_CouncilDistrict2024.xlsx")

joined_blocks <-merge(total_population_blocks, Blocks2020_CouncilDistrict2024, 
                      by.x = "GEOID", by.y = "GEOID20", all.x = TRUE, all.y = TRUE)

#Need to recreate GEOID minus 3 for the block group to join. 

total_population_blocks <- joined_blocks %>%
  mutate(GEOIDBG = str_sub(GEOID, 1, 12))

total_join <- total_population_blocks %>%
  left_join (Occupany_wide, by = c("GEOIDBG"="GEOID"))


#Weight HH per block #variable= value (creating the weights based on the number of households in a census block)
data <- total_join %>%
  group_by(GEOIDBG) %>%
  mutate(Weight = HH/sum(HH), 
         Weight = case_when(is.nan(Weight)~0, TRUE~ Weight)) %>% 
  ungroup()


# Aggregate data at the Council District level
data2 <- data %>%
  group_by(DISTRICT) %>%
  summarize(
    total_HH_district = sum(HH, na.rm = TRUE),
    total_owner_district = sum(owner * Weight, na.rm = TRUE),
    total_renter_district = sum(renter * Weight, na.rm = TRUE) 
  ) %>% 
  ungroup() %>% 
  mutate(
    pct_owner = (total_owner_district / total_HH_district) * 100, 
    pct_renter = (total_renter_district / total_HH_district) * 100
  )


#################################################################
# save clean dataset
#################################################################

owner_renter_HH_CCdistrict<-data2

save(owner_renter_HH_CCdistrict, file="clean datasets/owner_renter_HH_CCdistrict.RData")



#################################################################
#Plots
#################################################################
display.brewer.all()  # Shows all available palettes

# Calculate centroids
data4_centroids <- data2 %>%
  st_centroid() %>%
  mutate(X = st_coordinates(.)[,1], Y = st_coordinates(.)[,2])

# Owner Occupied Map
plot1 <- ggplot(data = data2) + 
  geom_sf(aes(fill = pct_owner)) + 
  geom_text(data = data4_centroids, aes(x = X, y = Y, label = DISTRICT), 
            size = 4, color = "black") + 
  scale_fill_distiller(palette = "PuBuGn", direction = 1) + 
  labs(title = "Owner Occupied",
       fill = "% Owner") + 
  theme_void() +   
  theme(
    plot.title = element_text(size = 10, hjust = 0.5, margin = margin(b = 5)),
    legend.title = element_text(size = 6), 
    legend.text = element_text(size = 7),
    plot.margin = margin(1,1,1,1)
  )

# Renter Occupied Map
plot2 <- ggplot(data = data2) + 
  geom_sf(aes(fill = pct_renter)) + 
  geom_text(data = data4_centroids, aes(x = X, y = Y, label = DISTRICT), 
            size = 4, color = "black") + 
  scale_fill_distiller(palette = "PuBuGn", direction = 1) + 
  labs(title = "Renter Occupied",
       fill = "% Renter") + 
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
    title = "Owner vs. Renter Occupied by Philadelphia City Council District (2022)",
    caption = "Data source: 2022 ACS 5-Year Estimates, US Census Bureau",
    theme = theme(
      plot.title = element_text(size = 12, hjust = 0.5, margin = margin(b = 10)),
      plot.caption = element_text(size = 8, hjust = 0.5)
    )
  )

print(combined_plot)
