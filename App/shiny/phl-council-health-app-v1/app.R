{
  ## Dependencies
  library(shiny)
  library(bslib)
  library(waiter)
  library(highcharter)

  ## Load Modules
  source("R/Modules/IntroductionModule.R")
  source("R/Modules/CityDistrictDashboard.R")
  source("R/Modules/OutroModule.R")
  load("data/app_v1.RData")

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

  ## UI Setup 
  useWaiter(),
  waiterShowOnLoad(html = loading_screen, color = 'white'),
  tags$head(includeCSS("CSS/Header.css")),
  tags$head(includeCSS("CSS/NavbarPage.css")),
  tags$head(includeCSS("CSS/Home.css")),
  tags$head(includeHTML("HTML/FontAwesomeLoader.html")),

  # Header
  includeHTML("HTML/Header.html"),
  
  # Modules
  IntroductionModule_UI("Introduction"),
  CityDistrictDashboard_UI("Dashboard", df_metadata),
  OutroModule_UI("Outro"),

  # Footer
  div(class = "section small text-muted",
    includeHTML("HTML/Footer.html")
  )
)

server <- function(input, output, session) {
  
  ## Loader code: Setup Server 
  library(dplyr)
  load("data/app_v1.RData")
  waiter_hide()

  # Modules
  IntroductionModule_Server("Introduction")
  CityDistrictDashboard_Server("Dashboard", df_data, geojson_districts)
  OutroModule_Server("Outro")
  
}

shinyApp(ui, server)