OldFaithful_UI <- function(id) {
  ns <- NS(id)
  sidebarLayout(
    sidebarPanel(selectInput(inputId = ns("n_breaks"),
                             label = "Number of bins in histogram (approximate):",
                             choices = c(10, 20, 35, 50),
                             selected = 20) ),
    mainPanel(
      plotOutput(outputId = ns("main_plot"), height = "300px")
    )
  )
}

OldFaithful_Server <- function(id){
  moduleServer(id,function(input, output, session) {
    output$main_plot <- renderPlot({
      print(faithful)
      print("HERHERHE")
      hist(faithful$eruptions,
           probability = TRUE,
           breaks = as.numeric(input$n_breaks),
           xlab = "Duration (minutes)",
           main = "Geyser eruption duration")
      
    })
  })
}