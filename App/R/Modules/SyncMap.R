SyncMap_UI <- function(id) {
  ns <- NS(id)
  sidebarLayout(
    sidebarPanel(
      width = 3,
      selectInput(ns("var1"),
                  label = "Select Variable 1",
                  choices = unique(shinyUHC::tidy_indicators_philly$indicator_label)),
      hr(),
      selectInput(ns("var2"),
                  label = "Select Variable 2",
                  choices = unique(shinyUHC::tidy_indicators_philly$indicator_label))
    ),
    mainPanel(
      width = 9,
      tabsetPanel(
        tabPanel("Map", uiOutput(ns("sync_map")) )
      )
    )
  )
}

SyncMap_Server <- function(id){
  moduleServer(id,function(input, output, session) {

    ### Data
    sfObject = reactive({
      ## Get Variable 1 data
      df_var1 = shinyUHC::tidy_indicators_philly %>%
        filter(indicator_label == input$var1) %>%
        select(zcta,var1_value = value, var1_tooltip = tooltip)

      ## Get Variable 2 data
      df_var2 = shinyUHC::tidy_indicators_philly %>%
        filter(indicator_label == input$var2) %>%
        select(zcta,var2_value = value, var2_tooltip = tooltip)

      ## Return ZCTA boundaries merged with data
      sfObject = shinyUHC::sf_zcta_philly %>%
        left_join(df_var1) %>%
        left_join(df_var2)
      sfObject
    })


    ### Sync Map
    output$sync_map = renderUI({output$sync_map = renderUI({

      ## Funciton to make map from selected variable
      makeMap = function(variable_selected){
        ## Pull Data
        data_tmp = shinyUHC::tidy_indicators_philly %>%
          filter(indicator_label == variable_selected) %>%
          select(zcta,  value,  tooltip)
        ## Merge with boudaries
        sf_tmp = shinyUHC::sf_zcta_philly %>% left_join(data_tmp)
        ## Generate pallete function
        pallete_tmp <-  colorNumeric("plasma", data_tmp$value)
        ## Generate leaflet map
        map =  sf_tmp %>%
          leaflet(options = leafletOptions(zoomControl = FALSE)) %>%
          addProviderTiles("Esri.WorldGrayCanvas") %>%
          addPolygons(weight = 1, color = "#777777",
                      fillColor = ~pallete_tmp(value), fillOpacity = 0.9,
                      label = ~tooltip %>% map(~HTML(.x))) %>%
          addLegend(position = "bottomright",
                    title = variable_selected,
                    opacity = 0.9,
                    pal = pallete_tmp, values = ~value)
        return(map)
      }

      ## Make maps
      var1_map = makeMap(input$var1)
      var2_map = makeMap(input$var2)

      ## Compose sync-map
      leafsync::sync(var1_map,var2_map)

    })})
  })
}
