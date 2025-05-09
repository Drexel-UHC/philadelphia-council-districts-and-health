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
          plotOutput(ns("barPlot"), height = "300px")
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

CityDistrictDashboard_Server <- function(id, df_data, sf_districts) {
  moduleServer(id, function(input, output, session) {
    
    # Create a reactive filtered dataset that updates when input changes
    sf_data_filtered <- reactive({

      req(input$healthMetric, df_data, sf_districts)
  
      # Filter data for selected metric
      df_data_filtered <- df_data |>
        filter(var_name == input$healthMetric)
      validate(
        need(nrow(df_data_filtered) > 0, "No data available for selected metric")
      )
    
      # Make sure we're preserving the sf class
      sf_result <- sf_districts |>
        dplyr::left_join(df_data_filtered, by = c("district" = "district")) 

      return(sf_result)
    })
    
   
    # Generate the bar chart based on selected health metric
    output$barPlot <- renderPlot({
      # Get filtered data
      df_tmp <- sf_data_filtered()
      var_label_tmp <- df_tmp$var_label[1]
      
      # Create bar plot
      barplot(df_tmp$value, 
              names.arg = df_tmp$district,
              main = var_label_tmp,
              xlab = "Council District",
              ylab = var_label_tmp)
    })
    
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