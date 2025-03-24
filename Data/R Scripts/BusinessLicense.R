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
library(here)


##Import CSV of All Business Licenses (OPEN DATA PHILLY)
setwd(here("Data"))
data<-arrow::read_parquet("Raw/business_licenses.parquet")


#Remove NA and 0 

##Only want Active Licenses

Active <- data %>% filter(licensestatus == "Active")

#fix the council district variable (there are some entries that are "01" and others that are "1")
Active<- Active %>%  mutate(council_district = case_when(council_district=="00" ~ NA_character_, # not clear what district this was supposed to be so I removed it. There were only 57 observations with "00" - TR
                                                          council_district=="01" ~ "1",
                                                          council_district=="02" ~ "2",
                                                          council_district=="03" ~ "3",
                                                          council_district=="04" ~ "4",
                                                          council_district=="05" ~ "5",
                                                          council_district=="06" ~ "6",
                                                          council_district=="07" ~ "7",
                                                          council_district=="08" ~ "8",
                                                          council_district=="09" ~ "9",
                                                          TRUE~ council_district
                                                          ))

# table(Active$licensetype)
# table(Active$rentalcategory)
# table(Active$council_district, useNA = "always")

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

#Keep rentals only! Map 2
Rental <- Active %>% filter(rental ==1) #Do not need to remove dumpsters


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
load("clean datasets/CCDistrict_pop.RData" )


#Join Companies with District geometry

#all active licenses minus dumpsters and rentals
Active_licenses <- CCDistrict_pop %>%
  left_join (Companies_per_district, by = c("DISTRICT"="council_district")) %>% 
  rename(total_active_licenses_norentals = total_companies)

#all active rental licenses
Active_licenses_rentals <- CCDistrict_pop %>%
  left_join (Companies_per_district2, by = c("DISTRICT"="council_district"))%>% 
  rename(total_active_licenses_rentalsonly = total_companies)

#############################################
#   save dataset
#############################################

save(Active_licenses,file="clean datasets/Active_licenses.RData" ) #all active licenses minus dumpsters and rentals
save(Active_licenses_rentals,file="clean datasets/Active_licenses_rentals.RData" ) #all active rental licenses



##############################
# make maps
##############################

# Calculate centroids for each district for mapping
data4_centroids <- Active_licenses%>%
  st_centroid()

data5_centroids <- Active_licenses_rentals%>%
  st_centroid()

#display.brewer.all()

# Plot the result using ggplot2

##Map 1 -- NO rentals and NO dumpsters
ggplot(data = Active_licenses, aes(fill = total_companies)) + 
  geom_sf() + 
  geom_text(data = data4_centroids, 
            aes(x = st_coordinates(geometry)[,1], 
                y = st_coordinates(geometry)[,2], 
                label = DISTRICT), 
            size = 4, color = "black") + 
  scale_fill_distiller(palette = "YlGnBu", direction = 1) +  # Keep only this
  labs(title = "Businesses in Philadelphia by City Council District,\nNo Rental and No Dumpster License Type, 2020-Oct 2024",
       fill = "Number of\nBusinesses",
       caption = "Data source: Open Data Philly") + 
  theme_void()

# Plot the result using ggplot2
#Map 2 -- rentals only
ggplot(data = Active_licenses_rentals, aes(fill = total_companies)) + 
  geom_sf() + 
  geom_text(data = data4_centroids, 
            aes(x = st_coordinates(geometry)[,1], 
                y = st_coordinates(geometry)[,2], 
                label = DISTRICT), 
            size = 4, color = "black") + 
  scale_fill_distiller(palette = "Spectral", direction = 1) +  # Keep only this
  labs(title = "Businesses in Philadelphia by City Council District, \nOnly Rental License Type, 2020-Oct 2024",
       fill = "Number of\nBusinesses",
       caption = "Data source: Open Data Philly") + 
  theme_void()

