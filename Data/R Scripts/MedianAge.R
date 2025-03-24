#Age

#B01002: Median Age : Block Group

#B01002_001 : Total Median Age by Sex
#B01002_002 : Male Median Age by Sex
#B01002_003 : Female Median Age by Sex

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
library(here)

setwd(here('Data'))


#load the Population per Block dataset
load("clean datasets/population_census_blocks.Rdata") 


#medianAge by Block Group
medianAge <- get_acs(
  geography = "block group",
  variables = c("B01002_001", "B01002_002", "B01002_003"),#Total, Male, Female
  state = "PA",
  county = "Philadelphia",
  year = 2022,
  survey = "acs5"
)

#change variable names and make a wide dataset
medianAge_wide <- medianAge %>%
  group_by(GEOID) %>%
  summarize(
    median_age_total = sum(estimate[variable == "B01002_001"]),
    median_age_male = sum(estimate[variable == "B01002_002"]),
    median_age_female = sum(estimate[variable =="B01002_003"])) %>%
  ungroup()


#Need to recreate GEOID minus 3 for the block group to join. 
total_population_blocks <- population_census_blocks %>%
  mutate(GEOIDBG = str_sub(GEOID, 1, 12))

total_join <- total_population_blocks %>%
  left_join (medianAge_wide, by = c("GEOIDBG"="GEOID"))

#weights? Should find number of Age#
data <- total_join %>%
  group_by(GEOIDBG) %>%
  mutate(Weight = value/sum(value), 
         Weight = case_when(is.nan(Weight)~0, TRUE~ Weight)) %>% #value is pop per block#
  ungroup()

#District
data2 <- data %>%
  group_by(DISTRICT) %>%
  summarize(
    district_median_age_total = weightedMedian(median_age_total, Weight, na.rm = TRUE),
    district_median_age_male = weightedMedian(median_age_male, Weight, na.rm = TRUE),
    district_median_age_female = weightedMedian(median_age_female, Weight, na.rm = TRUE)) %>% 
  ungroup()

##################################################
# save datset
##################################################
median_age_CCdistrict<-data2

save(median_age_CCdistrict, file="clean datasets/median_age_CCdistrict.Rdata" )

##################################################
# plotting
##################################################
# Calculate centroids for each district
data4_centroids <- data2 %>%
  st_centroid()

#plot
#ggplot(data = data2, aes(fill = medianAge_district)) + 
 # geom_sf() + 
  #scale_fill_distiller(palette = "BuPu", 
                       # direction = 1) + 
  #labs(title = 
       #  "Weighted Median Age by Philadelphia City
          #    Council District 2022 (Male and Female)",
     #  caption = "Data source: 2022 1-year ACS, US Census Bureau",
     #  fill = "ACS estimate") + 
 # theme_void()

#Male
#ggplot(data = data2, aes(fill = medianAge_district_male)) + 
  #geom_sf() + 
 # scale_fill_distiller(palette = "Blues", 
                       #direction = 1) + 
 # labs(title = 
       #  "Weighted Median Age by Philadelphia City
         #     Council District 2022 (Male Only)",
     #  caption = "Data source: 2022 1-year ACS, US Census Bureau",
      # fill = "Median Age") + 
  #theme_void()

#Female
#ggplot(data = data2, aes(fill = medianAge_district_female)) + 
  #geom_sf() + 
  #scale_fill_distiller(palette = "Reds", 
                    #   direction = 1) + 
  #labs(title = 
         #"Weighted Median Age by Philadelphia City
             # Council District 2022 (Female Only)",
    #   caption = "Data source: 2022 1-year ACS, US Census Bureau",
    #   fill = "Median Age") + 
 # theme_void()

# Plot for Male and Female combined
plot1 <- ggplot(data = data2, aes(fill = district_median_age_total)) + 
  geom_sf() + 
  geom_text(data = data4_centroids, 
            aes(x = st_coordinates(geometry)[,1], 
                y = st_coordinates(geometry)[,2], 
                label = DISTRICT), 
            size = 4, color = "black") + 
  scale_fill_distiller(palette = "BuPu", direction = 1) + 
  labs(title = "Male and Female",
       fill = "Median Age") + 
  theme_void() +   theme(
    plot.title = element_text(size = 10, hjust = 0.5, margin = margin(b = 5)),
    legend.title = element_text(size = 6), 
    legend.text = element_text(size = 7),
    plot.margin = margin(1,1,1,1)
  )

# Plot for Male only
plot2 <- ggplot(data = data2, aes(fill = district_median_age_male)) + 
  geom_sf() + 
  geom_text(data = data4_centroids, 
            aes(x = st_coordinates(geometry)[,1], 
                y = st_coordinates(geometry)[,2], 
                label = DISTRICT), 
            size = 4, color = "black") + 
  scale_fill_distiller(palette = "Blues", direction = 1) + 
  labs(title = "Male Only",
       fill = "Median Age") + 
  theme_void() +
  theme(
    plot.title = element_text(size = 10, hjust = 0.5, margin = margin(b = 5)),
    legend.title = element_text(size = 6), 
    legend.text = element_text(size = 7),
    plot.margin = margin(1,1,1,1)
  )

# Plot for Female only
plot3 <- ggplot(data = data2, aes(fill = district_median_age_female)) + 
  geom_sf() + 
  geom_text(data = data4_centroids, 
            aes(x = st_coordinates(geometry)[,1], 
                y = st_coordinates(geometry)[,2], 
                label = DISTRICT), 
            size = 4, color = "black") + 
  scale_fill_distiller(palette = "Reds", direction = 1) + 
  labs(title = "Female Only",
       fill = "Median Age") + 
  theme_void() +
  theme(
    plot.title = element_text(size = 10, hjust = 0.5, margin = margin(b = 5)),
    legend.title = element_text(size = 6), 
    legend.text = element_text(size = 7),
    plot.margin = margin(1,1,1,1)
  )

# Combine the three plots side by side using plot_layout
combined_plot <- plot2 + plot1 + plot3  + 
  plot_layout(ncol = 3) + 
  plot_annotation(
    title = "Weighted Median Age by Philadelphia City Council District 2022",
    caption = "Data source: 2022 5-year ACS, US Census Bureau",
    theme = theme(
      plot.title = element_text(size = 12, hjust = 0.5, margin = margin(b = 10)),
      plot.caption = element_text(size = 8, hjust = 0.5)
    )
  )

# Display the combined plot
combined_plot
