CityDistrictDashboard_UI <- function(id, df_metadata) {
  ns <- NS(id)

  # Create choices from metadata if available
  choices <- setNames(
    df_metadata$var_name,
    df_metadata$var_label
  )
 
  

  div(class = "section",
    h4("How to Use:", class = "mt-4 section-title"),
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
          plotOutput(ns("mapPlot"), height = "300px")
        )
      )
    )
  )
}

CityDistrictDashboard_Server <- function(id, df_data, sf_districts) {
  moduleServer(id, function(input, output, session) {
    
    # Create a reactive filtered dataset that updates when input changes
    filtered_data <- reactive({
      req(input$healthMetric, df_data)
      
      # Filter data for selected metric
      df_data_filtered <- df_data |>
        filter(var_name == input$healthMetric)
      
      # Handle case where filtering returns no rows
      validate(
        need(nrow(df_data_filtered) > 0, "No data available for selected metric")
      )
      
      return(df_data_filtered)
    })
    
    # Get joined spatial data reactively
    spatial_data <- reactive({
      req(filtered_data(), sf_districts)
      
      sf_districts |>
        left_join(filtered_data(), by = c("district" = "district"))
    })
    
    # Generate the bar chart based on selected health metric
    output$barPlot <- renderPlot({
      # Get filtered data
      df_tmp <- filtered_data()
      var_label_tmp <- df_tmp$var_label[1]
      
      # Create bar plot
      barplot(df_tmp$value, 
              names.arg = df_tmp$district,
              main = var_label_tmp,
              xlab = "Council District",
              ylab = var_label_tmp)
    })
    
    # Generate the map visualization based on selected health metric  
    output$mapPlot <- renderPlot({ 
      plot(1:10, 1:10, type = "n") 
    })
    
    # Return reactive values if needed
    return(reactive({
      list(
        selectedMetric = input$healthMetric,
        filteredData = filtered_data()
      )
    }))
  })
}