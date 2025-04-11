library(tidyverse)
library(here)
library(sf)

setwd(here('Data'))

# Set the path to your folder containing the .RData files
folder_path <- here("Data/clean datasets")

# List all .RData files in the folder
rdata_files <- list.files(path = folder_path, pattern = "\\.R[Dd]ata$", full.names = TRUE)

# Use purrr::walk to load each .RData file and extract the individual objects
rdata_files %>%
  walk(~ {
    load(.x, envir = .GlobalEnv)  # Load the .RData file into the global environment
    
    # Get the list of objects loaded from the .RData file
    objects_in_rdata <- ls(envir = .GlobalEnv)
    
    # Loop over each object in the .RData file
    walk(objects_in_rdata, ~ {
      # Check if the object is an sf object
      obj <- get(.x, envir = .GlobalEnv)
      
      if (inherits(obj, "sf")) {
        # Remove the geometry (spatial data) from the sf object
        df <- st_drop_geometry(obj)
        
        # Assign the data frame back to the global environment, removing geometry
        assign(.x, df, envir = .GlobalEnv)
      }
    })
  })

## Combine all the files

council_measures<-Active_licenses %>% 
  left_join(Active_licenses_rentals, by=c("DISTRICT","CCDistrict_population")) %>%
  left_join(Crashes_CCDistrict, by=c("DISTRICT","CCDistrict_population"))%>% 
  left_join(education_CCdistricts, by=c("DISTRICT"))%>% 
  left_join(housing_violations_per_CCdistrict, by=c("DISTRICT","CCDistrict_population"))%>% 
  left_join(lack_of_plumb_kitch_CCdistrict, by=c("DISTRICT"))%>% 
  left_join(median_age_CCdistrict, by=c("DISTRICT"))%>% 
  left_join(median_HH_income_CCdistrict, by=c("DISTRICT"))%>% 
  left_join(owner_renter_HH_CCdistrict, by=c("DISTRICT", "total_HH_district"))%>% 
  left_join(poverty_status_CCdistrict, by=c("DISTRICT","CCDistrict_population"="CD_pop"))%>% 
  left_join(race_CCdistricts, by=c("DISTRICT", "CCDistrict_population"="total_pop"))%>% 
  left_join(Shootings_CCDistrict, by=c("DISTRICT","CCDistrict_population"))%>% 
  left_join(uninsured_CCdistrict, by=c("DISTRICT","CCDistrict_population"="CD_pop")) %>% 
  left_join(HVI_CCdistrict, by=c("DISTRICT")) %>% 
  left_join(Tree_canopy_CCdistrict, by=c("DISTRICT"))


#paired down dataset:
council_measures_reduc<-council_measures %>% 
  select(DISTRICT, CCDistrict_population, total_active_licenses_norentals, total_active_licenses_rentalsonly, 
         count_crashes, less_than_hs_pct, hs_grad_pct, some_college_pct, college_grad_pct, pct_violations,
         district_lack_kitch_pct, district_lack_plumb_pct, district_median_age_total, medianHH_income_district, 
         pct_owner, pct_renter, CD_pct_poverty, pct_white, pct_black, pct_native, pct_asian, pct_pi, pct_other, 
         pct_two_more, pct_hispanic, count_fatal, count_non_fatal, percentage_uninsured, CD_tree, weighted_hvi)

load("clean datasets/CCDistrict_pop.RData")

council_measures_reduc_geom<-CCDistrict_pop %>% 
  left_join(council_measures,by=c("DISTRICT","CCDistrict_population"))

#########################################
# save datasets
#########################################
save(council_measures_reduc, file="clean datasets/council_measures_reduc.RData")
save(council_measures_reduc_geom, file="clean datasets/council_measures_reduc_geom.RData")
