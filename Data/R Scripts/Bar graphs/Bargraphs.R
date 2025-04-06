
#Bar graphs for Philadelphia CC District data

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
library(tidyr)
library(tidygeocoder)
library(RColorBrewer)
library(patchwork)
library(here)

### Shootings ###

#Open Data Philly
#2015 - Present

setwd(here("Data"))

# Load the saved dataset 
load("clean datasets/Shootings_CCDistrict.RData")

# Create ordered factor so levels go from 1 to 10
Shootings_CCDistrict$DISTRICT <- factor(Shootings_CCDistrict$DISTRICT, 
                                        levels = as.character(1:10))

#plots
fatal <- ggplot(data = Shootings_CCDistrict, aes(x = DISTRICT, y = count_fatal)) +
  geom_bar(stat = "identity", fill = "tomato") +
  labs(title = "Fatal Shootings by City Council District",
       x = "City Council District",
       y = "Number of Fatal Shootings") +
  theme_minimal()

nonfatal <- ggplot(data = Shootings_CCDistrict, aes(x = DISTRICT, y = count_non_fatal)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  labs(title = "Nonfatal Shootings by City Council District",
       x = "City Council District",
       y = "Number of Nonfatal Shootings") +
  theme_minimal()

shootings_plot <- fatal + nonfatal + 
  plot_layout(ncol = 2) + 
  plot_annotation(
    title = "Fatal and NonFatal Shootings by Philadelphia 
City Council District 2015 to Present",
    caption = "Data source: Open Data Philly",
    theme = theme(
      plot.title = element_text(size = 12, hjust = 0.5, margin = margin(b = 10)),
      plot.caption = element_text(size = 8, hjust = 0.5)
    )
  )

print(shootings_plot)


### Insurance ###

load("clean datasets/uninsured_CCdistrict.Rdata")

# Create ordered factor so levels go from 1 to 10
uninsured_CCdistrict$DISTRICT <- factor(uninsured_CCdistrict$DISTRICT, 
                                        levels = as.character(1:10))

ggplot(data = uninsured_CCdistrict, aes(x = DISTRICT, y = percentage_uninsured)) +
  geom_bar(stat = "identity", fill = "orchid") +
  labs(title = "Percentage Uninsured by City Council District",
       x = "City Council District",
       y = "Percentage of Residents Without Health Insurance") +
  theme_minimal()

ggplot(data = uninsured_CCdistrict, aes(x = DISTRICT, y = CD_uninsurance)) +
  geom_bar(stat = "identity", fill = "orchid") +
  labs(title = "Number Uninsured by City Council District",
       x = "City Council District",
       y = "Number of Residents Without Health Insurance") +
  theme_minimal()


## Median Age ##

load("clean datasets/median_age_CCdistrict.Rdata")

# Create ordered factor so levels go from 1 to 10
median_age_CCdistrict$DISTRICT <- factor(median_age_CCdistrict$DISTRICT, 
                                        levels = as.character(1:10))

male <- ggplot(data = median_age_CCdistrict, aes(x = DISTRICT, y = district_median_age_male)) +
  geom_bar(stat = "identity", fill = "blue") +
  labs(title = "Males",
       x = "City Council District",
       y = "Male Median Age") +
  theme_minimal()

female <- ggplot(data = median_age_CCdistrict, aes(x = DISTRICT, y = district_median_age_female)) +
  geom_bar(stat = "identity", fill = "pink") +
  labs(title = "Females",
       x = "City Council District",
       y = "Female Median Age") +
  theme_minimal()

male_female <- ggplot(data = median_age_CCdistrict, aes(x = DISTRICT, y = district_median_age_total)) +
  geom_bar(stat = "identity", fill = "mediumpurple") +
  labs(title = "Total Population",
       x = "City Council District",
       y = "Median Age") +
  theme_minimal()

median_age_plot <- male + female + male_female +
  plot_layout(ncol = 3) + 
  plot_annotation(
    title = "Median Age by Philadelphia City Council District for Males, Females, and Total Population",
    caption = "Data source: ACS 5-year 2022",
    theme = theme(
      plot.title = element_text(size = 12, hjust = 0.5, margin = margin(b = 10)),
      plot.caption = element_text(size = 8, hjust = 0.5)
    )
  )

print(median_age_plot)

### Car Crashes ###

load("clean datasets/Crashes_CCDistrict.Rdata")

# Create ordered factor so levels go from 1 to 10
Crashes_CCDistrict$DISTRICT <- factor(Crashes_CCDistrict$DISTRICT, 
                                        levels = as.character(1:10))

#plot
ggplot(data = Crashes_CCDistrict, aes(x = DISTRICT, y = count_crashes)) +
  geom_bar(stat = "identity", fill = "seagreen") +
  labs(title = "Number of Fatal Car Crashes by Philadelphia City Council District 2019 to Present",
       x = "City Council District",
       y = "Number of Car Crashes",
       caption = 'Data Source: Open Data Philly') +
  theme_minimal()

### Poverty ###

load("clean datasets/poverty_status_CCdistrict.Rdata")

# Create ordered factor so levels go from 1 to 10
poverty_status_CCdistrict$DISTRICT <- factor(poverty_status_CCdistrict$DISTRICT, 
                                      levels = as.character(1:10))

#plots
ggplot(data = poverty_status_CCdistrict, aes(x = DISTRICT, y = CD_pct_poverty)) +
  geom_bar(stat = "identity", fill = "coral") +
  labs(title = "Percentage of Residents below poverty line for the last 12 months
                    by Philadelphia City Council District 2022",
       x = "City Council District",
       y = "Percentage of Residents",
       caption = 'Data Source: ACS 5-year') +
  theme_minimal()

ggplot(data = poverty_status_CCdistrict, aes(x = DISTRICT, y = CD_Poor)) +
  geom_bar(stat = "identity", fill = "coral") +
  labs(title = "Number of Residents below poverty line for the last 12 months
                     by Philadelphia City Council District 2022",
       x = "City Council District",
       y = "Total number of Residents",
       caption = 'Data Source: ACS 5-year') +
  theme_minimal()

### Education ###

load("clean datasets/education_CCdistricts.Rdata")

# Create ordered factor so levels go from 1 to 10
education_CCdistricts$DISTRICT <- factor(education_CCdistricts$DISTRICT, 
                                             levels = as.character(1:10))

#Plots 

#Less than HS
ggplot(data = education_CCdistricts, aes(x = DISTRICT, y = less_than_hs_pct)) +
  geom_bar(stat = "identity", fill = "lightblue") +
  labs(title = "Percentage of Residents over the age of 25 with Less than High School 
                     by Philadelphia City Council District 2022",
       x = "City Council District",
       y = "Percentage of Residents",
       caption = 'Data Source: ACS 5-year') +
  theme_minimal()

ggplot(data = education_CCdistricts, aes(x = DISTRICT, y = less_than_hs)) +
  geom_bar(stat = "identity", fill = "lightblue") +
  labs(title = "Number of Residents over the age of 25 with Less than High School 
                     by Philadelphia City Council District 2022",
       x = "City Council District",
       y = "Number of Residents",
       caption = 'Data Source: ACS 5-year') +
  theme_minimal()

#HS or equivalent
ggplot(data = education_CCdistricts, aes(x = DISTRICT, y = hs_grad_pct)) +
  geom_bar(stat = "identity", fill = "magenta") +
  labs(title = "Percentage of Residents over the age of 25 with a High School Diploma or Equivalent 
                     by Philadelphia City Council District 2022",
       x = "City Council District",
       y = "Percentage of Residents",
       caption = 'Data Source: ACS 5-year') +
  theme_minimal()

ggplot(data = education_CCdistricts, aes(x = DISTRICT, y = hs_grad)) +
  geom_bar(stat = "identity", fill = "magenta") +
  labs(title = "Number of Residents over the age of 25 with a High School Diploma or Equivalent 
                     by Philadelphia City Council District 2022",
       x = "City Council District",
       y = "Percentage of Residents",
       caption = 'Data Source: ACS 5-year') +
  theme_minimal()

#Some College
ggplot(data = education_CCdistricts, aes(x = DISTRICT, y = some_college_pct)) +
  geom_bar(stat = "identity", fill = "orange") +
  labs(title = "Percentage of Residents over the age of 25 with a Some College 
                     by Philadelphia City Council District 2022",
       x = "City Council District",
       y = "Percentage of Residents",
       caption = 'Data Source: ACS 5-year') +
  theme_minimal()

ggplot(data = education_CCdistricts, aes(x = DISTRICT, y = some_college)) +
  geom_bar(stat = "identity", fill = "orange") +
  labs(title = "Number of Residents over the age of 25 with a Some College 
                     by Philadelphia City Council District 2022",
       x = "City Council District",
       y = "Number of Residents",
       caption = 'Data Source: ACS 5-year') +
  theme_minimal()

#College or Higher
ggplot(data = education_CCdistricts, aes(x = DISTRICT, y = college_grad_pct)) +
  geom_bar(stat = "identity", fill = "darkgreen") +
  labs(title = "Percentage of Residents over the age of 25 with a College Degree
                     by Philadelphia City Council District 2022",
       x = "City Council District",
       y = "Percentage of Residents",
       caption = 'Data Source: ACS 5-year') +
  theme_minimal()

ggplot(data = education_CCdistricts, aes(x = DISTRICT, y = college_grad)) +
  geom_bar(stat = "identity", fill = "darkgreen") +
  labs(title = "Number of Residents over the age of 25 with a College Degree
                     by Philadelphia City Council District 2022",
       x = "City Council District",
       y = "Number of Residents",
       caption = 'Data Source: ACS 5-year') +
  theme_minimal()

#Combo Plot for Percentage
less_thanHS_pct <- ggplot(data = education_CCdistricts, aes(x = DISTRICT, y = less_than_hs_pct)) +
  geom_bar(stat = "identity", fill = "lightblue") +
  labs(title = "Less than High School",
       x = "City Council District",
       y = "Percentage of Residents") +
  theme_minimal()

HS_pct <- ggplot(data = education_CCdistricts, aes(x = DISTRICT, y = hs_grad_pct)) +
  geom_bar(stat = "identity", fill = "magenta") +
  labs(title = "High School Diploma",
       x = "City Council District",
       y = "Percentage of Residents") +
  theme_minimal()

some_college_pct <- ggplot(data = education_CCdistricts, aes(x = DISTRICT, y = some_college_pct)) +
  geom_bar(stat = "identity", fill = "orange") +
  labs(title = "Some College",
       x = "City Council District",
       y = "Percentage of Residents") +
  theme_minimal()

college_pct <- ggplot(data = education_CCdistricts, aes(x = DISTRICT, y = college_grad_pct)) +
  geom_bar(stat = "identity", fill = "darkgreen") +
  labs(title = "College Degree",
       x = "City Council District",
       y = "Percentage of Residents") +
  theme_minimal()

combined_plot_pct <- less_thanHS_pct + HS_pct + some_college_pct + college_pct + 
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

print(combined_plot_pct)

#Combo Plot for Number of Residents 
less_thanHS <- ggplot(data = education_CCdistricts, aes(x = DISTRICT, y = less_than_hs)) +
  geom_bar(stat = "identity", fill = "lightblue") +
  labs(title = "Less than High School",
       x = "City Council District",
       y = "Number of Residents") +
  theme_minimal()

HS <- ggplot(data = education_CCdistricts, aes(x = DISTRICT, y = hs_grad)) +
  geom_bar(stat = "identity", fill = "magenta") +
  labs(title = "High School Diploma",
       x = "City Council District",
       y = "Number of Residents") +
  theme_minimal()

some_college <- ggplot(data = education_CCdistricts, aes(x = DISTRICT, y = some_college)) +
  geom_bar(stat = "identity", fill = "orange") +
  labs(title = "Some College",
       x = "City Council District",
       y = "Number of Residents") +
  theme_minimal()

college <- ggplot(data = education_CCdistricts, aes(x = DISTRICT, y = college_grad)) +
  geom_bar(stat = "identity", fill = "darkgreen") +
  labs(title = "College Degree",
       x = "City Council District",
       y = "Number of Residents") +
  theme_minimal()

combined_plot <- less_thanHS + HS + some_college + college + 
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

print(combined_plot)

### Median HH Income ###

load("clean datasets/median_HH_income_CCdistrict.Rdata")

# Create ordered factor so levels go from 1 to 10
median_HH_income_CCdistrict$DISTRICT <- factor(median_HH_income_CCdistrict$DISTRICT, 
                                         levels = as.character(1:10))

#plot
ggplot(data = median_HH_income_CCdistrict, aes(x = DISTRICT, y = medianHH_income_district)) +
  geom_bar(stat = "identity", fill = "seagreen") +
  labs(title = "Median Household Income in the Past 12 months 
       by Philadelphia City Council District 2022",
       x = "City Council District",
       y = "Median HH Income",
       caption = 'Data Source: ACS 5-year') +
  theme_minimal()

### Owner and Renter ###

load("clean datasets/owner_renter_HH_CCdistrict.Rdata")

# Create ordered factor so levels go from 1 to 10
owner_renter_HH_CCdistrict$DISTRICT <- factor(owner_renter_HH_CCdistrict$DISTRICT, 
                                               levels = as.character(1:10))

#plots Renter
ggplot(data = owner_renter_HH_CCdistrict, aes(x = DISTRICT, y = pct_renter)) +
  geom_bar(stat = "identity", fill = "khaki") +
  labs(title = "Percentage of Households that are Renters by Philadelphia City Council District 2022",
       x = "City Council District",
       y = "Percentage of Households",
       caption = 'Data Source: ACS 5-year') +
  theme_minimal()

#plots Owner
ggplot(data = owner_renter_HH_CCdistrict, aes(x = DISTRICT, y = pct_owner)) +
  geom_bar(stat = "identity", fill = "brown") +
  labs(title = "Percentage of Households that are Owners by Philadelphia City Council District 2022",
       x = "City Council District",
       y = "Percentage of Households",
       caption = 'Data Source: ACS 5-year') +
  theme_minimal()

#combo plots

owner_renter_long <- owner_renter_HH_CCdistrict %>%
  gather(key = "Type", value = "Percentage", pct_renter, pct_owner)

# Calculate the percentage labels
owner_renter_long <- owner_renter_long %>%
  mutate(Percentage_label = paste0(round(Percentage, 1), "%"))

#Pie charts might look better per district?

# Create pie charts for each district with percentage labels
ggplot(owner_renter_long, aes(x = "", y = Percentage, fill = Type)) +
  geom_bar(stat = "identity", width = 1, color = "white") +
  coord_polar(theta = "y") +
  facet_wrap(~ DISTRICT, scales = "free_y") +  # Create a pie chart for each district
  labs(title = "Housing Tenure by Philadelphia City Council District (2022)",
       caption = "Data Source: 2022 5-year ACS") +
  theme_void() +  # removes axes
  theme(
    plot.title = element_text(hjust = 0.5),
    legend.title = element_blank()
  ) +
  scale_fill_manual(values = c("khaki", "brown"),
                    labels = c("Renters", "Owners")) +
  geom_text(aes(label = Percentage_label), position = position_stack(vjust = 0.5), color = "white")  # Add percentage labels

#Not quite 100% 

