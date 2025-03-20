##Business Licenses

#Information regarding applications for 
#licenses required by the City to conduct certain 
#business activities. Information includes 
#license application type, applicant, property for which the 
#license would be issued, application date, issue date, renewal date, 
#and expiration date. Data is accurate; however, it may be misinterpreted by an unfamiliar user.

#Licenses are required for individuals and businesses 
#to engage in select commercial activities. For example, vendors and restaurants 
#require a license in order to sell goods.

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

##Import CSV of All Business Licenses (OPEN DATA PHILLY)
data <- read_csv("C:/Documents/IDEA Fellow/business_licenses.csv")


#Remove NA and 0 

##Only want Active Licenses

Active <- data %>% filter(licensestatus == "Active")

table(Active$licensetype)

table(Active$rentalcategory)

table(Active$council_district, useNA = "always")

##Further filter for "Company" only? Remove all "individual"  

##Company <- Active %>% filter(legalentitytype =="Company")

#Active <- Active %>% 
   #mutate(rental = case_when(rentalcategory == "Residential Dwellings"~1,
                             # TRUE~0))

#Make flag for rental
Active <- Active %>% 
  mutate(rental = case_when(licensetype == "Rental"~1,
                            TRUE~0))

#Make flag variable for dumpsters
Active <- Active %>% 
  mutate(dumpster = case_when(
    licensetype == "Dumpster License - Construction" ~ 1,
    licensetype == "Dumpster License - Private Property" ~ 1,
    licensetype == "Dumpster License - Public ROW" ~ 1,
    TRUE ~ 0
  ))
#Remove rentals
NoRental <- Active %>%  filter(rental == 0)
# Remove dumpster-related businesses
NoDumpsters <- NoRental %>% filter(dumpster == 0)

#Keep rentals! Map 2
Rental <- Active %>% filter(rental ==1) #Do not need to remove dumpsters




#Already has council distict included in dataset
#Need to convert numeric to character for join
#Company <- Company %>% mutate(council_district = as.character(council_district))

NoDumpsters <- NoDumpsters %>% mutate(council_district = as.character(council_district))

Rental <- Rental %>% mutate(council_district = as.character(council_district))

#NoResidental <- NoResidental %>% mutate(council_district = as.character(council_district))

#Dataset too large
#Companies_per_district<- Company %>% 
 # group_by(council_district) %>% 
 # summarize(total_companies = n(), .groups = "drop") %>%
 # filter(council_district != 0 & !is.na(council_district))

#Dumpsters removed + individuals in
Companies_per_district<- NoDumpsters %>% 
  group_by(council_district) %>% 
  summarize(total_companies = n(), .groups = "drop") %>%
  filter(council_district != 0 & !is.na(council_district))


Companies_per_district2<- Rental %>% 
  group_by(council_district) %>% 
  summarize(total_companies = n(), .groups = "drop") %>%
  filter(council_district != 0 & !is.na(council_district))


#Bus_per_district<- NoResidental %>% 
  #group_by(council_district) %>% 
 # summarize(total_companies = n(), .groups = "drop") %>%
 # filter(council_district != 0 & !is.na(council_district))

#Add in Crosswalk and Block geometry
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
mapview(total_population_blocks)

#Council District #
Blocks2020_CouncilDistrict2024 <- read_excel(
  "C:/Documents/IDEA Fellow/Crosswalksmap/Blocks2020_CouncilDistrict2024.xlsx")
View(Blocks2020_CouncilDistrict2024)

joined_blocks <-merge(total_population_blocks, Blocks2020_CouncilDistrict2024, 
                      by.x = "GEOID", by.y = "GEOID20", all.x = TRUE, all.y = TRUE)

#Join Companies with District geometry

total_join <- joined_blocks %>%
  left_join (Companies_per_district, by = c("DISTRICT"="council_district"))

total_join2 <- joined_blocks %>%
  left_join (Companies_per_district2, by = c("DISTRICT"="council_district"))

#total_join2 <- joined_blocks %>%
  #left_join (Bus_per_district, by = c("DISTRICT"="council_district"))


mapview(total_join,zcol = "total_companies")

#Clean up geometry
district_data <- total_join %>%
  group_by(DISTRICT) %>%
  summarize(
    total_companies = unique(total_companies),  # Take unique value
    geometry = st_union(geometry)  # Dissolve geometries into one per district
  ) %>%
  st_as_sf()  # Ensure it remains an sf object

#Clean up geometry
district_data2 <- total_join2 %>%
  group_by(DISTRICT) %>%
  summarize(
    total_companies = unique(total_companies),  # Take unique value
    geometry = st_union(geometry)  # Dissolve geometries into one per district
  ) %>%
  st_as_sf()  # Ensure it remains an sf object

#district_data2 <- total_join2 %>%
  #group_by(DISTRICT) %>%
  #summarize(
    #total_companies = unique(total_companies),  # Take unique value
    #geometry = st_union(geometry)  # Dissolve geometries into one per district
 # ) %>%
 # st_as_sf()  # Ensure it remains an sf object

#Plot
#ggplot(data = district_data2, aes(fill = total_companies)) + 
  #geom_sf() + 
  #labs(title = "Total Number of Companies by 
      # Philadelphia City Council District",
      # caption = "Data source: Open Data Philly") + 
  #theme_void() +
# scale_fill_viridis_c()  

#sum(district_data2$total_companies) 

# Calculate centroids for each district
data4_centroids <- district_data%>%
  st_centroid()

# Calculate centroids for each district
data5_centroids <- district_data2%>%
  st_centroid()

display.brewer.all()

# Plot the result using ggplot2
##Map 1 -- NO rentals and NO dumpsters
ggplot(data = district_data, aes(fill = total_companies)) + 
  geom_sf() + 
  geom_text(data = data4_centroids, 
            aes(x = st_coordinates(geometry)[,1], 
                y = st_coordinates(geometry)[,2], 
                label = DISTRICT), 
            size = 4, color = "black") + 
  scale_fill_distiller(palette = "YlGnBu", direction = 1) +  # Keep only this
  labs(title = "     Businesses in Philadelphia by City Council District, 
No Rental and No Dumpster License Type, 2020 to Oct 2024",
       fill = "  Number of
  Businesses",
       caption = "Data source: Open Data Philly") + 
  theme_void()

# Plot the result using ggplot2
#Map 2 -- rentals only
ggplot(data = district_data2, aes(fill = total_companies)) + 
  geom_sf() + 
  geom_text(data = data4_centroids, 
            aes(x = st_coordinates(geometry)[,1], 
                y = st_coordinates(geometry)[,2], 
                label = DISTRICT), 
            size = 4, color = "black") + 
  scale_fill_distiller(palette = "Spectral", direction = 1) +  # Keep only this
  labs(title = "    Businesses in Philadelphia by City Council District, 
Only Rental License Type, 2020 to Oct 2024",
       fill = "  Number of
  Businesses",
       caption = "Data source: Open Data Philly") + 
  theme_void()
