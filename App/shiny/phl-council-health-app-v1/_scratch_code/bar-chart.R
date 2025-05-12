## Dependencies
library(shiny)
library(bslib)
library(waiter)
library(leaflet) 
library(highcharter)
load("data/app_v1.RData")

# Data --------------------------------------------------------------------
input = lst(); input$healthMetric = "pct_violations"
df_data_filtered <- df_data |>
  filter(var_name == input$healthMetric) 
sf_result <- sf_districts |>
  dplyr::left_join(df_data_filtered, by = c("district" = "district")) %>% 
  mutate(district_int = as.integer(district)) %>% 
  arrange(district_int) 


# Base R Plot -------------------------------------------------------------
df_tmp <- df_data_filtered
var_label_tmp <- df_tmp$var_label[1]
barplot(df_tmp$value, 
        names.arg = df_tmp$district,
        main = var_label_tmp,
        xlab = "Council District",
        ylab = var_label_tmp)

# Highcharts -------------------------------------------------------------
sf_data <- sf_result %>% sf::st_drop_geometry()
var_label_tmp <- sf_data$var_label[1]

# Create a data frame for the highcharter bar chart
chart_data <- data.frame(
  district = sf_data$district,
  value = sf_data$value
)

# Create highcharter bar chart
highchart() %>%
  hc_chart(type = "column") %>%
  hc_title(text = var_label_tmp) %>%
  hc_xAxis(
    categories = chart_data$district,
    title = list(text = "Council District")
  ) %>%
  hc_yAxis(
    title = list(text = var_label_tmp),
    min = 0
  ) %>%
  hc_add_series(
    data = chart_data$value,
    name = var_label_tmp,
    colorByPoint = TRUE
  ) %>%
  hc_plotOptions(
    column = list(
      dataLabels = list(
        enabled = TRUE,
        format = "{point.y:.1f}"
      ),
      borderWidth = 0,
      pointPadding = 0.1
    )
  ) %>%
  hc_tooltip(
    headerFormat = '<span style="font-size: 11px">District {point.key}</span><br/>',
    pointFormat = '<span style="color:{point.color}">\u25CF</span> {series.name}: <b>{point.y:.1f}</b><br/>'
  ) %>%
  hc_exporting(
    enabled = TRUE,
    filename = paste0("philly-council-", input$healthMetric)
  ) %>%
  hc_credits(
    enabled = TRUE,
    text = "Source: Philadelphia City Council Districts Dashboard",
    href = "#"
  )
