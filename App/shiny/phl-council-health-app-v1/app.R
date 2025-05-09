{
  ## Dependencies
  library(shiny)
  library(bslib)
  library(dplyr)
  library(waiter)
  library(leaflet)
  library(sf)
  library(leafsync)
  # library(shinyUHC)
  library(purrr)

  ## Load Modules
  source("R/Modules/OldFaithful.R")
  # source("R/Modules/SyncMap.R")

  ## Loader code: Global Scope
  loading_screen = div(
    tags$img(
      src = "logo.png",
      height = 175
    ),
    div(
      style = "padding-top: 50px;",
      spin_loader()) )
}

ui <- fluidPage(
  ## Loader code: UI (start)
  useWaiter(),
  waiterShowOnLoad(html = loading_screen,
                   color = 'white'),
  ## Loader code: UI (end)
  tags$head(includeCSS("CSS/Header.css")),
  tags$head(includeCSS("CSS/NavbarPage.css")),
  tags$head(includeCSS("CSS/Home.css")),
  tags$head(includeHTML("HTML/FontAwesomeLoader.html")),
  includeHTML("HTML/Header.html"),
  navbarPage( id = 'navbar',
              title = "Title",
              tabPanel("Home",includeHTML("HTML/Home.html")),
              tabPanel("Figure1",OldFaithful_UI("Figure1"))#,
              # tabPanel("Sync Map",SyncMap_UI("SyncMap"))
  ),
  includeHTML("HTML/Footer.html")
)

server <- function(input, output, session) {

  ## Loader code: Server (start)
  Sys.sleep(1) # do something that takes time
  waiter_hide()
  ## Loader code: Server (end)


  ## Module 1: ggplot
  OldFaithful_Server("Figure1")

  ## Module 2: Sync Map
  # SyncMap_Server('SyncMap')
}

shinyApp(ui, server)
