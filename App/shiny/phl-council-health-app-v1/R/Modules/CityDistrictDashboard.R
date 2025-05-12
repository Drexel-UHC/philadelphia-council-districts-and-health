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
      column(6,
        div(class = "border p-2 bg-light",
          # Replace plotOutput with highchartOutput
          highchartOutput(ns("bar_chart"), height = "300px")
        )
      ),
      column(6,
        div(class = "border p-2 bg-light",
          leafletOutput(ns("output_map"), height = "300px") 
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
      validate(
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
      dfa <- sf_data_filtered() %>% sf::st_drop_geometry()
      var_label_tmp <- dfa$var_label[1]
      source_tmp = dfa$source[1]
      
      # Create highcharter bar chart
      highchart() %>%
        hc_chart(type = "column") %>%
        hc_title(text = var_label_tmp) %>%
        hc_subtitle(text = glue::glue("Source: {source_tmp}")) %>%
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
    output$output_map <- renderLeaflet({
      sf_data <- sf_data_filtered()
      var_label_tmp <- sf_data$var_label[1]

      # Create a color palette based on the variable
      pal <- colorNumeric(
        palette = "viridis",
        domain = sf_data$value
      )

      # Create the leaflet map - using value instead of input$select_variable
      sf_data %>% 
        leaflet() %>%
        addTiles() %>%
        addPolygons(
          fillColor = ~pal(value), 
          weight = 1, 
          opacity = 1,
          color = "white",
          dashArray = "3",
          fillOpacity = 0.7,
          # Add these lines for hover functionality
          highlightOptions = highlightOptions(
            weight = 3,
            color = "#666",
            fillOpacity = 0.9,
            bringToFront = TRUE
          ),
          # Create labels from your data
          label = ~lapply(paste0(
            "District: ", district, "<br>",
            var_label, ": ", formatC(value, big.mark = ",")
          ), HTML),
          labelOptions = labelOptions(
            style = list("font-weight" = "normal", padding = "3px 8px"),
            textsize = "15px",
            direction = "auto"
          )
        ) %>% 
        # Add a legend
        addLegend(
          position = "bottomright",
          pal = pal,
          values = ~value,
          title = sf_data$var_label[1],
          opacity = 0.7)
    })
  }) # Add this closing curly brace for moduleServer
} # This is the closing curly brace for the CityDistrictDashboard_Server function