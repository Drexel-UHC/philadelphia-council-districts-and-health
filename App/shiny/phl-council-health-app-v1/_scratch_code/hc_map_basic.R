## Dependencies
library(shiny)
library(bslib)
library(waiter)
library(leaflet) 
library(highcharter)
library(sf)


 
# Reprex (hc_add_series_map) ------------------------------------------------------------------
# https://jkunst.com/highcharter/reference/hc_add_series_map.html

library("dplyr")

data("USArrests", package = "datasets")
data("usgeojson")

USArrests <- mutate(USArrests, state = rownames(USArrests)) %>% as_tibble()

head(usgeojson); USArrests; str(usgeojson, max.level = 3)

highchart() %>%
  hc_title(text = "Violent Crime Rates by US State") %>%
  hc_subtitle(text = "Source: USArrests data") %>%
  hc_add_series_map(usgeojson, USArrests,
                    name = "Murder arrests (per 100,000)",
                    value = "Murder", joinBy = c("woename", "state"),
                    dataLabels = list(
                      enabled = TRUE,
                      format = "{point.properties.postalcode}"
                    )
  ) %>%
  hc_colorAxis(stops = color_stops()) %>%
  hc_legend(valueDecimals = 0, valueSuffix = "%") %>%
  hc_mapNavigation(enabled = TRUE)
  

# Sf object --------------------------------------------------------------------
load("data/app_v1.RData")
input = lst(); input$healthMetric = "pct_violations"
df_data_filtered <- df_data |>
  filter(var_name == input$healthMetric)  %>% 
  left_join(df_metadata)
sf_result <- sf_districts |>
  dplyr::left_join(df_data_filtered, by = c("district" = "district")) %>% 
  mutate(district_int = as.integer(district)) %>% 
  arrange(district_int) 

# Replicate with sf  ------------------------------------------------------------------

## Geojson
library(geojsonio)
library(jsonlite)
geojson_districts


# Create a properly formatted data frame matching the GeoJSON structure
map_data_df <- data.frame(
  district = df_data_filtered$district,
  value = df_data_filtered$value,
  var_label = df_data_filtered$var_label[1],
  stringsAsFactor = FALSE
)

# Create the map with proper joinBy fields
source_tmp = sf_result$source[1]
var_label_tmp = sf_result$var_label[1]
highchart() %>%
  hc_title(text = "Code Violations by District") %>%
  hc_subtitle(text = paste("Source:", source_tmp)) %>%
  hc_add_series_map(
    map = json_districts, 
    df = map_data_df,
    name = var_label_tmp,
    value = "value", 
    joinBy = c("district", "district"),  # Join using the district field on both sides
    dataLabels = list(
      enabled = TRUE,
      format = "{point.district}"  # Display district number as label
    ),
    tooltip = list(
      # headerFormat = '<span style="font-size:14px"><b>{series.name}</b></span><br/>',
      pointFormat = '<span style="font-size:13px"><b>District {point.district}</b>: {point.value:.1f}%</span>'
    )
  ) %>%
   hc_colorAxis(
     min = min(map_data_df$value),
     max = max(map_data_df$value),
     stops = list(
       list(0, "#EFEFFF"),  # Light color for low values
       list(0.5, "#4444BB"), 
       list(1, "#000066")   # Dark color for high values
     )
   ) %>%
  hc_legend(valueDecimals = 1, valueSuffix = "%") %>%
  hc_mapNavigation(enabled = TRUE)

