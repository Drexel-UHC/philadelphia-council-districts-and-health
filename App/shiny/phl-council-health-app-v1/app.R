{
  ## Dependencies
  library(shiny)
  library(bslib)
  library(waiter)

  ## Load Modules
  source("R/Modules/CityDistrictDashboard.R")

  ## Loader code: Global Scope
  loading_screen = div(
    tags$img(
      src = "logo.png",
      height = 175 
    ),
    div(
      style = "padding-top: 50px;",
      spin_loader()) )

  # Create a theme object with custom colors - more subdued for document-like feel
  app_theme <- bs_theme(
    version = 5, 
    bootswatch = "flatly",
    # More document-like colors
    primary = "#2c3e50",
    secondary = "#95a5a6",
    success = "#18bc9c"
  )
  
  # Add custom CSS rules correctly - as a single string
  app_theme <- bs_add_rules(
    app_theme,
    "
    .section { margin-top: 2rem; margin-bottom: 2rem; }
    .section-title { border-bottom: 1px solid #eee; padding-bottom: 0.5rem; margin-bottom: 1.5rem; }
    body { max-width: 1200px; margin: 0 auto; padding: 20px; }
    /* Fix for waiter overlay */
    .waiter-overlay {
      max-width: 1200px !important;
      left: 50% !important;
      transform: translateX(-50%) !important;
    }
    "
  )
}

ui <- page_fluid(
  theme = app_theme,

  ## Loader code: UI (start)
  useWaiter(),
  waiterShowOnLoad(html = loading_screen, color = 'white'),
  ## Loader code: UI (end)
  
  tags$head(includeCSS("CSS/Header.css")),
  tags$head(includeCSS("CSS/NavbarPage.css")),
  tags$head(includeCSS("CSS/Home.css")),
  tags$head(includeHTML("HTML/FontAwesomeLoader.html")),

  # Simple header without navigation
  includeHTML("HTML/Header.html"),
  
  # Title and intro - Quarto-like document header
  div(class = "section",
    h1("Health of Philadelphia City Council Districts", class = "section-title"),
    p(class = "lead", "This dashboard leverages publicly available data from the US Census Bureau and Open Data Philly to examine important public health indicators for Philadelphia's 10 City Council Districts. The project aims to offer actionable knowledge that empowers city leaders and communities to address health inequities in their communities.")
  ),
  
  # Introduction section
  div(class = "section",
    h2("Introduction", class = "section-title"),
    p("Philadelphia has faced differences in health outcomes across neighborhoods – differences that reflect broader disparities in income, opportunity, and access to essential resources. These are not just statistics on a page - they are the city's residents, and they are shaped by where people live and the conditions of their community."),
    
    p("This project takes a closer look at those conditions by analyzing publicly available data and mapping key health indicators and social determinants of health across all 10 Philadelphia City Council Districts. By doing this, we aim to provide a clearer picture of how geography and disparities in health interact to shape the health of Philadelphians."),
    
    p("Our goal is to equip all 17 Philadelphia City Council members and the public with actionable, district-level insights that can guide and empower more equitable policy and investment into our city. By connecting this data to City Council Districts, we hope this project continues to grow and support effective policy solutions that can promote equality and better health for all Philadelphians.")
  ),
  
  # Interactive elements section
  div(class = "section",
    h2("Find your City Council District:", class = "section-title"),
    actionButton("findDistrict", "Find Your District", class = "btn-primary"),
    
    h2("How to Use:", class = "mt-4 section-title"),
    p("To explore the data, use the drop-down menu provided below to select the health outcome that interests you. Once selected, the dashboard will display a bar graph comparing all 10 City Council Districts, along with a spatial map that visualizes how this outcome varies across the city.")
  ),
  
  # Dashboard section - now more integrated into the document flow
  div(class = "section",
    h2("Health Indicators", class = "section-title"),
    
    fluidRow(
      column(4,
        div(class = "form-group",
          selectInput("healthMetric", "Select Health Indicator:", 
                    choices = c("Percentage of Residence Uninsured"))
        )
      ),
      column(8, "")
    ),
    
    fluidRow(
      column(6,
        h4("Bar plot of Percent without Health Insurance by District", class = "text-center mb-3"),
        div(class = "border p-2 bg-light",
          plotOutput("barPlot", height = "300px")
        )
      ),
      column(6,
        h4("Geographic Distribution", class = "text-center mb-3"),
        div(class = "border p-2 bg-light",
          plotOutput("mapPlot", height = "300px")
        )
      )
    )
  ),
  
  # Document-like footer
  hr(),
  div(class = "section small text-muted",
    includeHTML("HTML/Footer.html")
  )
)

server <- function(input, output, session) {
  ## Loader code: Server (start)
  Sys.sleep(1) # do something that takes time
  library(dplyr)
  library(leaflet) 
  load("data/app_v0.1.Rdata")
  waiter_hide()
  ## Loader code: Server (end)

  # Reuse the dashboard module functionality but adapt to the single page layout
  dashboardData <- CityDistrictDashboard_Server('Dashboard')
  
  # Example placeholder outputs - replace with actual plotting logic from your module
  output$barPlot <- renderPlot({
    # Generate the bar chart based on selected health metric
    barplot(1:10, main = input$healthMetric)
  })
  
  output$mapPlot <- renderPlot({
    # Generate the map visualization based on selected health metric
    plot(1:10, 1:10, type = "n")
    text(5, 5, "Map Visualization\nwill appear here")
  })
  
  # Find district functionality
  observeEvent(input$findDistrict, {
    showModal(modalDialog(
      title = "Find Your District",
      "District lookup feature would be implemented here",
      easyClose = TRUE
    ))
  })
}

shinyApp(ui, server)