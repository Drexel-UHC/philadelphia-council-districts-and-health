CityDistrictDashboard_UI <- function(id) {
  ns <- NS(id)
  page_sidebar(
  title = "My dashboard",
  sidebar = "Sidebar",
  "Main content area"
)
}

CityDistrictDashboard_Server <- function(id){
  # moduleServer(id,function(input, output, session) {
  #   output$main_plot <- renderPlot({
  #     print(faithful)
  #     print("HERHERHE")
  #     hist(faithful$eruptions,
  #          probability = TRUE,
  #          breaks = as.numeric(input$n_breaks),
  #          xlab = "Duration (minutes)",
  #          main = "Geyser eruption duration")
      
  #   })
  # })
}