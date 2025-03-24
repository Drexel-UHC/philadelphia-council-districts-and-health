library(tidycensus)
library(tigris)
library(sf)
library(mapview)
library(dplyr)
library(readxl)
library(stringr)
library(ggplot2)
library(readr)
library(patchwork)
library(RColorBrewer)
library(here)


setwd(here("Data"))


#Load Crosswalk
load("clean datasets/population_census_blocks.Rdata")

#Load ACS education data
#vars <- load_variables(2022, "acs5")

Education <- get_acs(
  geography = "block group",
  variables = c("B15003_001", "B15003_002", "B15003_003", "B15003_004", "B15003_005",
                "B15003_006", "B15003_007", "B15003_008", "B15003_009", "B15003_010",
                "B15003_011", "B15003_012", "B15003_013", "B15003_014", "B15003_015",
                "B15003_016", "B15003_017", "B15003_018", "B15003_019", "B15003_020",
                "B15003_021", "B15003_022", "B15003_023", "B15003_024", "B15003_025"),
  year = 2022,
  state = "PA",
  county = "Philadelphia",
  geometry = FALSE # This means no spatial geometry will be included
)
#VARIABLES
#"B15003_001" = total pop over 25, 
#"B15003_002" = No schooling
#"B15003_003" = Nursery School 
#"B15003_004"= Kindergarten
#"B15003_005" = 1st
#"B15003_006" = 2nd, 
#"B15003_007" = 3rd 
#"B15003_008" = 4th, 
#"B15003_009" = 5th, 
#"B15003_010" = 6th
#"B15003_011" = 7th 
#"B15003_012"= 8th 
#"B15003_013" 9th 
#"B15003_014"= 10th 
#"B15003_015" = 11th
#"B15003_016" = 12th no diploma 
#"B15003_017" HS grad, 
#"B15003_018" = GED or equivalent 
#"B15003_019" = some college less than 1 yr
#"B15003_020"= some college 1 yr or more no degree
#"B15003_021"= Associates 
#"B15003_022"= Bachelors 
#"B15003_023"= Masters 
#"B15003_024"= Professional school 
#"B15003_025" = Doctorate

#Create categories "less than hs" "HS" "Some college" "College Grad"

# Reformat into categories
Education_Categories <- Education %>%
  group_by(GEOID) %>%
  summarize(
    total_pop_over25 = sum(estimate[variable == "B15003_001"]),
    
    # Less than High School (No Schooling to 12th Grade, No Diploma)
    less_than_hs = sum(estimate[variable %in% c("B15003_002", "B15003_003", "B15003_004",
                                                "B15003_005", "B15003_006", "B15003_007",
                                                "B15003_008", "B15003_009", "B15003_010",
                                                "B15003_011", "B15003_012", "B15003_013",
                                                "B15003_014", "B15003_015", "B15003_016")]),
    
    # High School Graduate (Includes HS Diploma and GED)
    hs_grad = sum(estimate[variable %in% c("B15003_017", "B15003_018")]),
    
    # Some College (No Degree or Associate's)
    some_college = sum(estimate[variable %in% c("B15003_019", "B15003_020", "B15003_021")]),
    
    # College Graduate (Bachelor's Degree or Higher)
    college_grad = sum(estimate[variable %in% c("B15003_022", "B15003_023", "B15003_024", "B15003_025")])
  ) %>%
  mutate(
    less_than_hs_pct = less_than_hs / total_pop_over25 * 100,
    hs_grad_pct = hs_grad / total_pop_over25 * 100,
    some_college_pct = some_college / total_pop_over25 * 100,
    college_grad_pct = college_grad / total_pop_over25 * 100
  ) %>%
  ungroup()

#Need to recreate GEOID minus 3 for the block group to join. 

total_population_blocks <- population_census_blocks %>%
  mutate(GEOID_blockgroup = str_sub(GEOID, 1, 12))

#I need to do a join where the values repeat?

total_join <- total_population_blocks %>%
  left_join (Education_Categories, by = c("GEOID_blockgroup"="GEOID"))

data <- total_join %>%
  group_by(GEOID_blockgroup) %>%
  mutate(Weight = value/sum(value), 
         Weight = case_when(is.nan(Weight)~0, TRUE~ Weight)) %>% #value is pop per block, this is to remove the NANs that resulted from dividing 0 by a zero population blockgroup
  ungroup()

education_CCdistricts <- data %>%
  group_by(DISTRICT) %>%
  summarize(
    total_pop_over25 = sum((total_pop_over25 * Weight), na.rm = TRUE),  # Define total_pop first
    less_than_hs = sum((less_than_hs * Weight), na.rm = TRUE),
    hs_grad = sum((hs_grad * Weight), na.rm = TRUE),
    some_college = sum((some_college * Weight), na.rm = TRUE),
    college_grad = sum((college_grad * Weight), na.rm = TRUE)
  ) %>%
  ungroup() %>% 
mutate(
  less_than_hs_pct = (less_than_hs / total_pop_over25) * 100,
  hs_grad_pct = (hs_grad / total_pop_over25) * 100,
  some_college_pct = (some_college / total_pop_over25) * 100,
  college_grad_pct = (college_grad / total_pop_over25) * 100
)

###################################################### 
# save clean dataset
###################################################### 
save(education_CCdistricts, file="clean datasets/education_CCdistricts.RData" )



###################################################### 
# making maps
###################################################### 

# Calculate centroids for each district
data4_centroids <- education_CCdistricts %>%
  st_centroid()

#Plots

display.brewer.all()  # Shows all available palettes

plot1 <- ggplot(data = education_CCdistricts, aes(fill = less_than_hs_pct)) + 
  geom_sf() + 
  geom_text(data = data4_centroids, 
            aes(x = st_coordinates(geometry)[,1], 
                y = st_coordinates(geometry)[,2], 
                label = DISTRICT), 
            size = 4, color = "black") + 
  scale_fill_distiller(palette = "BuPu", 
                       direction = 1) + 
  labs(title = "Less than High School",
       fill = "% of Residents") + 
  theme_void() +
  theme(
    plot.title = element_text(size = 8.5, hjust = 0.5, margin = margin(b = 5)),
    legend.title = element_text(size = 6), 
    legend.text = element_text(size = 7),
    plot.margin = margin(5, 5, 5, 5)
  )


plot2 <- ggplot(data = education_CCdistricts, aes(fill = hs_grad_pct)) + 
  geom_sf() + 
  geom_text(data = data4_centroids, 
            aes(x = st_coordinates(geometry)[,1], 
                y = st_coordinates(geometry)[,2], 
                label = DISTRICT), 
            size = 4, color = "black") + 
  scale_fill_distiller(palette = "PuRd", 
                       direction = 1) + 
  labs(title = "High School Graduate",
       fill = "% of Residents") + 
  theme_void() +
  theme(
    plot.title = element_text(size = 8.5, hjust = 0.5, margin = margin(b = 5)),
    legend.title = element_text(size = 6), 
    legend.text = element_text(size = 7),
    plot.margin = margin(5, 5, 5, 5)
  )


plot3 <- ggplot(data = education_CCdistricts, aes(fill = some_college_pct)) + 
  geom_sf() + 
  geom_text(data = data4_centroids, 
            aes(x = st_coordinates(geometry)[,1], 
                y = st_coordinates(geometry)[,2], 
                label = DISTRICT), 
            size = 4, color = "black") + 
  scale_fill_distiller(palette = "OrRd", 
                       direction = 1) + 
  labs(title = "Some College",
       fill = "% of Residents") + 
  theme_void() +
  theme(
    plot.title = element_text(size = 8.5, hjust = 0.5, margin = margin(b = 5)),
    legend.title = element_text(size = 6), 
    legend.text = element_text(size = 7),
    plot.margin = margin(5, 5, 5, 5)
  )


plot4 <- ggplot(data = education_CCdistricts, aes(fill = college_grad_pct)) + 
  geom_sf() + 
  geom_text(data = data4_centroids, 
            aes(x = st_coordinates(geometry)[,1], 
                y = st_coordinates(geometry)[,2], 
                label = DISTRICT), 
            size = 4, color = "black") + 
  scale_fill_distiller(palette = "YlGn", #need to change palette
                       direction = 1) + 
  labs(title = "College Degree",
       fill = "% of Residents") + 
  theme_void() +
  theme(
    plot.title = element_text(size = 8.5, hjust = 0.5, margin = margin(b = 5)),
    legend.title = element_text(size = 6), 
    legend.text = element_text(size = 7),
    plot.margin = margin(5, 5, 5, 5)
  )



#Would like to find a way to better graph all 4 of these graphs together. 

# Combine the plots into a grid with a common title and caption
combined_plot <- plot1 + plot2 + plot3 + plot4 + 
  plot_layout(ncol = 2) + 
  plot_annotation(
    title = "Educational Attainment for Ages 25 and Older 
    by Philadelphia City Council District 2022",
    caption = "Data source: 2022 5-year ACS, US Census Bureau",
    theme = theme(
      plot.title = element_text(size = 12, hjust = 0.5, margin = margin(b = 10)),
      plot.caption = element_text(size = 8, hjust = 0.5)
    )
  )

# Print the combined plot with the title
print(combined_plot)











