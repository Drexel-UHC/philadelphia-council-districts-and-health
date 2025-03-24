#Race variables -- All Block Group

#B02001_001 Total pop
#B03002_003 White Not hispanic or Latino
#B02001_003 Black
#B02001_004 American Indian/Alaska Native
#B02001_005 Asian
#B02001_006 Native Hawaiian/Pacific Islander
#B02001_007 Some other race
#B02001_008 Two or more races

#B03001_001 Total pop
#B03002_012 Hispanic/Latino
#B03002_002 Not Hispanic or Latino


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
library(tidyr)
library(here)

setwd(here("Data"))

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

#Race by Block Group
race <- get_acs(
  geography = "block group",
  variables = c("B02001_001", #Total
                "B03002_003", #White
                "B02001_003", #Black
                "B02001_004", #American Indian
                "B02001_005", #Asian
                "B02001_006", #Native Hawaiian/PI
                "B02001_007", #Other
                "B02001_008", #2 or more
                # "B03001_001", #Total His (Amber: this does not work becuase it is by tract and not block group -TR)
                "B03002_012", #Hispanic
                "B03002_002"), #Not Hispanic
  state = "PA",
  county = "Philadelphia",
  year = 2022,
  survey = "acs5"
)

#change variable names
race_wide <- race %>%
  group_by(GEOID) %>%
  summarize(
    total_race = sum(estimate[variable == "B02001_001"]),
    white = sum(estimate[variable == "B03002_003"]),
    black = sum(estimate[variable == "B02001_003"]),
    native = sum(estimate[variable == "B02001_004"]),
    asian = sum(estimate[variable == "B02001_005"]),
    pi = sum(estimate[variable == "B02001_006"]),
    other = sum(estimate[variable == "B02001_007"]),
    two_more = sum(estimate[variable == "B02001_008"]),
    # total_hispanic = sum(estimate[variable == "B03001_001"]), #not working, but total matches total race (because the variable is at the tract level-TR)
    hispanic = sum(estimate[variable == "B03002_012"]),
    not_hispanic = sum(estimate[variable == "B03002_002"]))%>%
  ungroup() %>% 
  mutate(asian_pi = asian+pi)

#Council District #
Blocks2020_CouncilDistrict2024 <- read_excel("Raw/Blocks2020_CouncilDistrict2024.xlsx")
# View(Blocks2020_CouncilDistrict2024)

joined_blocks <-merge(total_population_blocks, Blocks2020_CouncilDistrict2024, 
                      by.x = "GEOID", by.y = "GEOID20", all.x = TRUE, all.y = TRUE)

#Need to recreate GEOID minus 3 for the block group to join. 
joined_blocks2 <- joined_blocks %>%
  mutate(GEOIDBG = str_sub(GEOID, 1, 12))

total_join <- joined_blocks2 %>%
  left_join (race_wide, by = c("GEOIDBG"="GEOID"))

#weights
data <- total_join %>%
  group_by(GEOIDBG) %>%
  mutate(Weight = value/sum(value), #Value is Block population
         Weight = case_when(is.nan(Weight)~0, TRUE~ Weight)) %>% 
  ungroup()

# Extract Census Tract ID from Block Group GEOID
data <- data %>%
  mutate(GEOIDTRACT = str_sub(GEOIDBG, 1, 11))  # First 11 digits = tract

# Aggregate block group data to CD
data_cd <- data %>%
  group_by(DISTRICT) %>%
  summarize(
    total_pop = sum(value, na.rm=TRUE),
    white = sum(white * Weight, na.rm = TRUE),
    black = sum(black * Weight, na.rm = TRUE),
    native = sum(native * Weight, na.rm = TRUE),
    asian = sum(asian * Weight, na.rm = TRUE),
    pi = sum(pi * Weight, na.rm = TRUE),
    other = sum(other * Weight, na.rm = TRUE),
    asian_pi = sum(asian_pi*Weight,na.rm=TRUE),
    two_more = sum(two_more * Weight, na.rm = TRUE),
    hispanic = sum(hispanic * Weight, na.rm = TRUE),
    not_hispanic = sum(not_hispanic * Weight, na.rm = TRUE)) %>% 
  ungroup() %>% 
  mutate(     pct_white = ((white / total_pop)*100),
              pct_black = ((black / total_pop)*100),
              pct_native = ((native / total_pop)*100),
              pct_asian = ((asian / total_pop)*100),
              pct_pi = ((pi / total_pop)*100),
              pct_asian_pi = ((asian_pi/total_pop)*100),
              pct_other = ((other/ total_pop)*100),
              pct_two_more = ((two_more / total_pop)*100),
              pct_hispanic = ((hispanic / total_pop)*100),
              pct_not_hispanic = ((not_hispanic / total_pop)*100))


#######################################
# save file
#######################################

race_CCdistricts<-data_cd

save(race_CCdistricts, file="clean datasets/race_CCdistricts.RData" )


#######################################
#Plot
#######################################

library(RColorBrewer)
display.brewer.all()  # Shows all available palettes

# Plot for White
plot <- ggplot(data = data_cd, aes(fill = pct_white)) + 
  geom_sf() + 
  scale_fill_distiller(palette = "Blues", direction = 1) + 
  labs(title = "Non-Hispanic White", 
       fill = "% NH White") + 
  theme_void() +
  theme(
    plot.title = element_text(size = 8.5, hjust = 0.5, margin = margin(b = 5)),
    legend.title = element_text(size = 6), 
    legend.text = element_text(size = 7),
    plot.margin = margin(5, 5, 5, 5)
  )

# Plot for Black
plot2 <- ggplot(data = data_cd, aes(fill = pct_black)) + 
  geom_sf() + 
  scale_fill_distiller(palette = "Reds", direction = 1) + 
  labs(title = "Black", 
       fill = "% Black") + 
  theme_void() +
  theme(
    plot.title = element_text(size = 8.5, hjust = 0.5, margin = margin(b = 5)),
    legend.title = element_text(size = 6), 
    legend.text = element_text(size = 7),
    plot.margin = margin(5, 5, 5, 5)
  )

# Plot for Native American / Alaska Native
plot3 <- ggplot(data = data_cd, aes(fill = pct_native)) + 
  geom_sf() + 
  scale_fill_distiller(palette = "BuPu", direction = 1) + 
  labs(title = "American Indian and Alaska Native", 
       fill = "% American Indian and \nAlaska Native") + 
  theme_void() +
  theme(
    plot.title = element_text(size = 8.5, hjust = 0.5, margin = margin(b = 5)),
    legend.title = element_text(size = 6), 
    legend.text = element_text(size = 7),
    plot.margin = margin(5, 5, 5, 5)
  )

# Plot for Asian
plot4 <- ggplot(data = data_cd, aes(fill = pct_asian)) + 
  geom_sf() + 
  scale_fill_distiller(palette = "YlGn", direction = 1) + 
  labs(title = "Asian", 
       fill = "% Asian") + 
  theme_void() +
  theme(
    plot.title = element_text(size = 8.5, hjust = 0.5, margin = margin(b = 5)),
    legend.title = element_text(size = 6), 
    legend.text = element_text(size = 7),
    plot.margin = margin(5, 5, 5, 5)
  )

# Plot for PI (Pacific Islander/Native Hawaiian)
plot5 <- ggplot(data = data_cd, aes(fill = pct_pi)) + 
  geom_sf() + 
  scale_fill_distiller(palette = "OrRd", direction = 1) + 
  labs(title = "Pacific Islander/Native Hawaiian", 
       fill = "% Pacific 
Islander/Native Hawaiian") + 
  theme_void() +
  theme(
    plot.title = element_text(size = 8.5, hjust = 0.5, margin = margin(b = 5)),
    legend.title = element_text(size = 6), 
    legend.text = element_text(size = 7),
    plot.margin = margin(5, 5, 5, 5)
  )

# Plot for Other
plot6 <- ggplot(data = data_cd, aes(fill = pct_other)) + 
  geom_sf() + 
  scale_fill_distiller(palette = "PuRd", direction = 1) + 
  labs(title = "Other Race", 
       fill = "% Other") + 
  theme_void() +
  theme(
    plot.title = element_text(size = 8.5, hjust = 0.5, margin = margin(b = 5)),
    legend.title = element_text(size = 6), 
    legend.text = element_text(size = 7),
    plot.margin = margin(5, 5, 5, 5)
  )

# Plot for 2 or more races
plot7 <- ggplot(data = data_cd, aes(fill = pct_two_more)) + 
  geom_sf() + 
  scale_fill_distiller(palette = "BuGn", direction = 1) + 
  labs(title = "Two or More Races", 
       fill = "% Two or More") + 
  theme_void() +
  theme(
    plot.title = element_text(size = 8.5, hjust = 0.5, margin = margin(b = 5)),
    legend.title = element_text(size = 6), 
    legend.text = element_text(size = 7),
    plot.margin = margin(5, 5, 5, 5)
  )

# Plot for Hispanic
plot8 <- ggplot(data = data_cd, aes(fill = pct_hispanic)) + 
  geom_sf() + 
  scale_fill_distiller(palette = "Greys", direction = 1) + 
  labs(title = "Hispanic/Latino", 
       fill = "% Hispanic/Latino") + 
  theme_void() +
  theme(
    plot.title = element_text(size = 8.5, hjust = 0.5, margin = margin(b = 5)),
    legend.title = element_text(size = 6), 
    legend.text = element_text(size = 7),
    plot.margin = margin(5, 5, 5, 5)
  )

# Plot for Not Hispanic
plot9 <- ggplot(data = data_cd, aes(fill = pct_not_hispanic)) + 
  geom_sf() + 
  scale_fill_distiller(palette = "Greys", direction = 1) + 
  labs(title = "Not Hispanic/Latino", 
       fill = "% Not Hispanic/Latino") + 
  theme_void() +
  theme(
    plot.title = element_text(size = 8.5, hjust = 0.5, margin = margin(b = 5)),
    legend.title = element_text(size = 6), 
    legend.text = element_text(size = 7),
    plot.margin = margin(5, 5, 5, 5)
  )
# Combine the plots into a grid with a common title and caption
combined_plot <- plot + plot2 + plot3 + plot4 + plot5 + plot6 + plot7 + plot8 + plot9 +
  plot_layout(ncol = 3) + 
  plot_annotation(
    title = "Percentage by Race by Philadelphia City Council District 2022",
    caption = "Data source: 2022 5-year ACS, US Census Bureau",
    theme = theme(
      plot.title = element_text(size = 12, hjust = 0.5, margin = margin(b = 10)),
      plot.caption = element_text(size = 8, hjust = 0.5)
    )
  )

# Print the combined plot with the title
print(combined_plot)
