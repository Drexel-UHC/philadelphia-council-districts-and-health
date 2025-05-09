CityDistrictDashboard_UI <- function(id) {
  ns <- NS(id)
  
  div(class = "section",
    h4("How to Use:", class = "mt-4 section-title"),
    p("To explore the data, use the drop-down menu provided below to select the health outcome that interests you. Once selected, the dashboard will display a bar graph comparing all 10 City Council Districts, along with a spatial map that visualizes how this outcome varies across the city."),
    
    fluidRow(
      column(4,
        div(class = "form-group",
          selectInput(ns("healthMetric"), "", 
                    choices = c("percentage_uninsured"))
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

CityDistrictDashboard_Server <- function(id, sf_data) {
  moduleServer(id, function(input, output, session) {
    # Generate the bar chart based on selected health metric
    output$barPlot <- renderPlot({
      req(sf_data)
      # Use the sf_data to create your plot
      barplot(sf_data[[input$healthMetric]], 
              names.arg = sf_data$district,
              main = input$healthMetric)
    })
    
    # Generate the map visualization based on selected health metric  
    output$mapPlot <- renderPlot({
      plot(1:10, 1:10, type = "n")
      text(5, 5, "Map Visualization\nwill appear here")
    })
    
    # Return reactive values if needed
    return(reactive({
      list(
        selectedMetric = input$healthMetric
        # Add more reactive values as needed
      )
    }))
  })
}