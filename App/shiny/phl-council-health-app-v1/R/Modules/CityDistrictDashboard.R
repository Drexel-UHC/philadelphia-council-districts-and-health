CityDistrictDashboard_UI <- function(id) {
  ns <- NS(id)
  
  div(class = "section",
    h2("Health Indicators", class = "section-title"),
    
    fluidRow(
      column(4,
        div(class = "form-group",
          selectInput(ns("healthMetric"), "Select Health Indicator:", 
                    choices = c("Percentage of Residence Uninsured"))
        )
      ),
      column(8, "")
    ),
    
    fluidRow(
      column(6,
        h4("Bar plot of Percent without Health Insurance by District", class = "text-center mb-3"),
        div(class = "border p-2 bg-light",
          plotOutput(ns("barPlot"), height = "300px")
        )
      ),
      column(6,
        h4("Geographic Distribution", class = "text-center mb-3"),
        div(class = "border p-2 bg-light",
          plotOutput(ns("mapPlot"), height = "300px")
        )
      )
    )
  )
}

CityDistrictDashboard_Server <- function(id) {
  moduleServer(id, function(input, output, session) {
    # Generate the bar chart based on selected health metric
    output$barPlot <- renderPlot({
      barplot(1:10, main = input$healthMetric)
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