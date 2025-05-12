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

##Find City-wide Averages: Education, Plumb/Kitch, Owner/Renter, MedianAge, HHincome, Poverty, Race
#Uninsured, 

City_average <- council_measures %>% 
  summarise(
    city_totalpop = sum(CCDistrict_population),
    city_totalpop25 = sum(total_pop_over25),
    city_less_than_hs = sum(less_than_hs),
    city_hs_grad = sum(hs_grad),
    city_some_college = sum(some_college),
    city_college_grad = sum(college_grad),
    city_total_violations = sum(total_violations),
    city_parcel_count = sum(parcel_count),
    city_total_housing_units = sum(district_total_housingunits),
    city_lack_plumb = sum(district_lack_plumbing),
    city_lack_kitch = sum(district_lack_kitchen),
    city_medianage = mean(district_median_age_total),
    city_medianage_female = mean(district_median_age_female),
    city_medianage_male = mean(district_median_age_male),
    city_medianHHincome = mean(medianHH_income_district),
    city_HH_total = sum(total_HH_district),
    city_owner = sum(total_owner_district),
    city_renter = sum(total_renter_district),
    city_poor = sum(CD_Poor),
    city_white = sum(white),
    city_black = sum(black),
    city_native = sum(native),
    city_asian = sum(asian),
    city_pi = sum(pi),
    city_other = sum(other),
    city_asian_pi = sum(asian_pi),
    city_two_more = sum(two_more),
    city_hispanic = sum(hispanic),
    city_not_hispanic = sum(not_hispanic)
  ) %>% 
  mutate(
    city_less_than_hs_pct = city_less_than_hs/city_totalpop25 * 100,
    city_hs_grad_pct = city_hs_grad / city_totalpop25 * 100,
    city_some_college_pct = city_some_college / city_totalpop25 * 100,
    city_college_grad_pct = city_college_grad / city_totalpop25 * 100,
    city_total_violations_pct = city_total_violations / city_parcel_count * 100, 
    city_lack_plumb_pct = city_lack_plumb / city_total_housing_units * 100, 
    city_lack_kitch_pct = city_lack_kitch / city_total_housing_units * 100, 
    city_owner_pct = city_owner / city_HH_total * 100, 
    city_renter_pct = city_renter / city_HH_total * 100, 
    city_poor_pct = city_poor / city_totalpop * 100, 
    city_white_pct = city_white / city_totalpop * 100,
    city_black_pct = city_black / city_totalpop * 100,
    city_native_pct = city_native / city_totalpop * 100,
    city_asian_pct = city_asian / city_totalpop * 100,
    city_asian_pi_pct = city_asian_pi / city_totalpop * 100,
    city_pi_pct = city_pi / city_totalpop * 100,
    city_other_pct = city_other / city_totalpop * 100,
    city_two_more_pct = city_two_more / city_totalpop * 100,
    city_hispanic_pct = city_hispanic / city_totalpop * 100,
    city_not_hispanic_pct = city_not_hispanic / city_totalpop * 100
  )


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
save(City_average, file = "clean datasets/City_average.RData")

#########################################
# bargraphs for city wide
#########################################


