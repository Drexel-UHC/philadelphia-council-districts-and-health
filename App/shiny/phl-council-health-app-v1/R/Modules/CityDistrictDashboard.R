CityDistrictDashboard_UI <- function(id, df_metadata) {
  ns <- NS(id)

  # Create choices from metadata if available
  choices <- setNames(
    df_metadata$var_name,
    df_metadata$var_label
  )
 
  div(class = "section",
    h3("How to Use:", class = "mt-4 section-title"),
    p("To explore the data, use the drop-down menu provided below to select the health outcome that interests you. Once selected, the dashboard will display a bar graph comparing all 10 City Council Districts, along with a spatial map that visualizes how this outcome varies across the city."),
    
    fluidRow(
      column(4,
        div(class = "form-group",
          selectInput(ns("healthMetric"), "", 
                    choices = choices)
        )
      ),
      column(8, "")
    ),
    
    fluidRow(
      column(7,
        div(class = "border p-2 bg-light",
          # Replace plotOutput with highchartOutput
          highchartOutput(ns("bar_chart"), height = "400px")
        )
      ),
      column(5,
        div(class = "border p-2 bg-light",
            highchartOutput(ns("output_map"), height = "400px")
        )
      )
    )
  )
}

CityDistrictDashboard_Server <- function(id, df_data, df_metadata, sf_districts) {
  moduleServer(id, function(input, output, session) {
    
    # Data Reactive -----------------------------------------------------------
    # Create a reactive filtered dataset that updates when input changes
    sf_data_filtered <- reactive({
      req(input$healthMetric, df_data, sf_districts)
  
      # Filter data for selected metric
      df_data_filtered <- df_data |>
        filter(var_name == input$healthMetric) %>% 
        left_join(df_metadata)
      print(df_data_filtered)
      shiny::validate(
        need(nrow(df_data_filtered) > 0, "No data available for selected metric")
      )
      # Make sure we're preserving the sf class
      sf_result <- sf_districts |>
        dplyr::left_join(df_data_filtered, by = c("district" = "district")) %>% 
        mutate(district_int = as.integer(district)) %>% 
        arrange(district_int) 

      return(sf_result)
    })
    

    # Bar Chart ---------------------------------------------------------------
    # Generate the bar chart based on selected health metric
    output$bar_chart <- renderHighchart({
      
      # Get filtered data
      dfa <- sf_data_filtered() 
      var_label_tmp <- dfa$var_label[1]

      print("HI2")
      
      # Create highcharter bar chart
      highchart() %>%
        hc_chart(type = "column") %>%
        hc_title(text = var_label_tmp) %>%
        hc_subtitle(text = paste("Source:", dfa$source[1])) %>%
        hc_xAxis(
          categories = dfa$district,
          title = list(text = "Council District")
        ) %>%
        hc_yAxis(
          title = list(text = var_label_tmp),
          min = 0
        ) %>%
        hc_add_series(
          data = dfa$value,
          name = var_label_tmp,
          color = 'grey',
          showInLegend = FALSE  
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
          text = "Urban Health Collaborative, Health of Philadelphia City Council Districts Dashboard, 2025",
          href = "#"
        ) %>%
        hc_add_theme(hc_theme_smpl())
      
    })
    
    # Map ---------------------------------------------------------------
    # Generate the map visualization based on selected health metric  
    output$output_map <- renderHighchart({

      ## Geojson conversion
      sf_result <- sf_data_filtered()
      sf_geojson <- geojsonio::geojson_json(sf_result)
      sf_map_data <- jsonlite::fromJSON(sf_geojson, simplifyVector = FALSE)
    
      ## Data formatting
      map_data_df <- data.frame(
        district = sf_result$district,
        value = sf_result$value,
        var_label = sf_result$var_label[1],
        stringsAsFactor = FALSE
      )

      ## Map
      highchart() %>%
        hc_title(text = "Code Violations by District") %>%
        hc_subtitle(text = paste("Source:", sf_result$source[1])) %>%
        hc_add_series_map(
          map = sf_map_data,
          df = map_data_df,
          name = sf_result$var_label[1],
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
    })
    
  }) 
  
} 
