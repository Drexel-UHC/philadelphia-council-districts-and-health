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
  IntroductionModule_UI("Introduction"),
  
  # Dashboard section - now more integrated into the document flow
  CityDistrictDashboard_UI("Dashboard", df_metadata),

  # Outro section with acknowledgements
  OutroModule_UI("Outro"),

  # Document-like footer
  div(class = "section small text-muted",
    includeHTML("HTML/Footer.html")
  )
)

server <- function(input, output, session) {
  ## Loader code: Server (start)
  Sys.sleep(0.5) # do something that takes time
  library(dplyr)
  load("data/app_v1.RData")
  geojson_districts = readRDS("data/json_districts.rds")
  waiter_hide()
  ## Loader code: Server (end)

  # Initialize the dashboard module
  IntroductionModule_Server("Introduction")

  # Reuse the dashboard module functionality but adapt to the single page layout
  CityDistrictDashboard_Server("Dashboard", df_data, df_metadata, sf_districts, geojson_districts)
  
  OutroModule_Server("Outro")
}

shinyApp(ui, server)