#Health Insurance

#ACS variables

#B18135_007 -- Estimate!!Total:!!Under 19 years:!!With a disability:!!No health insurance coverage
#B18135_012 -- Estimate!!Total:!!Under 19 years:!!No disability:!!No health insurance coverage

#B18135_018 -- Estimate!!Total:!!19 to 64 years:!!With a disability:!!No health insurance coverage
#B18135_023 -- Estimate!!Total:!!19 to 64 years:!!No disability:!!No health insurance coverage

#B18135_029 -- Estimate!!Total:!!65 years and over:!!With a disability:!!No health insurance coverage
#B18135_034 -- Estimate!!Total:!!65 years and over:!!No disability:!!No health insurance coverage


library(tidycensus)
library(tigris)
library(sf)
library(mapview)
library(dplyr)
library(readxl)
library(stringr)
library(ggplot2)
library(here)

setwd(here("Data"))

vars <- load_variables(2022, "acs5")

#load the block population
load("clean datasets/population_census_blocks.Rdata") 


#Uninsured by Tract
uninsured_PA <- get_acs(
  geography = "tract",
  variables = c("B18135_012", "B18135_007", "B18135_018","B18135_023",
                "B18135_029", "B18135_034"),# Total uninsured population
  state = "PA",
  county = "Philadelphia",
  year = 2022,
  survey = "acs5")

#Now add all variables together by census tract
uninsured_PA_total <- uninsured_PA %>% 
  group_by(GEOID) %>% 
  summarize(total_uninsured = sum(estimate, na.rm = TRUE)) %>% 
  ungroup()


#Merge Tract insurance pop

#Need to recreate GEOID minus 4 for the block to join. 

total_population_blocks <- population_census_blocks %>%
  mutate(GEOIDTRACT = str_sub(GEOID, 1, 11))

#I need to do a join where the values repeat?

total_join <- total_population_blocks %>%
  left_join (uninsured_PA_total, by = c("GEOIDTRACT"="GEOID"))


#Weight = Blocks / Total block in same tract

data <- total_join %>%
  group_by(GEOIDTRACT) %>%
  mutate(Weight = value/sum(value), 
         Weight = case_when(is.nan(Weight)~0, TRUE~ Weight)) %>% #value is pop per block#
  ungroup()


#Council District Insurance value
data2 <- data %>%
  group_by(DISTRICT) %>%
  summarize(CD_uninsurance = sum(total_uninsured*Weight, na.rm = TRUE), 
            CD_pop = sum(value, na.rm = TRUE)) %>%  
  ungroup() %>% 
  mutate(percentage_uninsured = ((CD_uninsurance/CD_pop)*100))


##########################################
#         save clean dataset
##########################################
uninsured_CCdistrict<-data2
save(uninsured_CCdistrict, file="clean datasets/uninsured_CCdistrict.RData")


##########################################
#         plot 
##########################################
#Plot total number

ggplot(data = data2, aes(fill = CD_uninsurance)) + 
  geom_sf() + 
  scale_fill_distiller(palette = "RdPu", 
                       direction = 1) + 
  labs(title = "Total Number Uninsured by Philadelphia City Council District",
       caption = "Data source: 2022 1-year ACS, US Census Bureau",
       fill = "ACS estimate") + 
  theme_void()

# Calculate centroids for each district
data3_centroids <- data2 %>%
  st_centroid()

# Plot with district numbers centered
ggplot(data = data2, aes(fill = percentage_uninsured)) + 
  geom_sf() + 
  geom_text(data = data3_centroids, 
            aes(x = st_coordinates(geometry)[,1], 
                y = st_coordinates(geometry)[,2], 
                label = DISTRICT), 
            size = 4, color = "black") + 
  scale_fill_distiller(palette = "RdPu", direction = 1) + 
  labs(title = "     Percentage of Residents Uninsured by
       Philadelphia City Council District 2022",
       caption = "Data source: 2022 5-year ACS, US Census Bureau",
       fill = "% of Residents") + 
  theme_void()



