CityDistrictDashboard_UI <- function(id, df_metadata) {
  ns <- NS(id)

  # Create choices from metadata if available
  choices <- setNames(
    df_metadata$var_name,
    df_metadata$var_label
  )
 
  div(class = "section",
    h3("How to Use:", class = "mt-4 section-title"),
    p("To explore the data, use the drop-down menu provided below to select the health outcome that interests you. Once selected, the dashboard will display a bar graph comparing all 10 City Council Districts, along with a spatial map that visualizes how this outcome varies across the city."),
    
    fluidRow(
      column(5,
        div(class = "form-group",
          selectInput(ns("healthMetric"), "", 
                    choices = choices)
        )
      ),
      column(7, "" )
    ),
    
    fluidRow(
      column(7, 
        div(class = "border p-2 bg-light",
          highchartOutput(ns("bar_chart"), height = "400px")
        )
      ),
      column(5, # ""
        div(class = "border p-2 bg-light",
            highchartOutput(ns("output_map"), height = "400px")
        )
      )
    )
  )
}

CityDistrictDashboard_Server <- function(id, df_data, geojson_districts) {
  moduleServer(id, function(input, output, session) {
    
    
    # Reactives Data  -----------------------------------------------------------
    ## Data  -----------------------------------------------------------
    # Create a reactive filtered dataset that updates when input changes
    df_data_filtered <- reactive({
      req(input$healthMetric, df_data) # input = lst();input$healthMetric = "total_active_licenses_norentals"
  
      # Filter data for selected metric
      df_data_filtered <- df_data |>
        filter(var_name == input$healthMetric) %>% 
        arrange(desc(value))  
      shiny::validate(
        need(nrow(df_data_filtered) > 0, "No data available for selected metric")
      ) 
      return(df_data_filtered)
    })

    ## Hovered District  -----------------------------------------------------------
    hovered_district <- reactiveVal(NULL)
    

    # Bar Chart ---------------------------------------------------------------
    # Generate the bar chart based on selected health metric
    output$bar_chart <- renderHighchart({
      
      # Get filtered data
      df_data_filtered <- df_data_filtered() 
      var_label_tmp <- df_data_filtered$var_label[1]
      var_name <- df_data_filtered$var_name[1]
      city_avg_tmp <- df_data_filtered$city_avg[1]
      source_year_tmp = df_data_filtered$source_year[1]

      # Check if this is the weighted HVI variable
      if (var_name == "weighted_hvi") {
        # Return a simple message chart for HVI
        return(
          highchart() %>%
            hc_title(text = var_label_tmp) %>%
            hc_subtitle(text = "Heat Vulnerability Index is shown on map") %>%
            hc_add_theme(hc_theme_smpl())
        )
      }

      # Create highcharter bar chart WITH city average line and custom formatted values
      highchart() %>%
        hc_chart(type = "column") %>%
        hc_title(text = var_label_tmp) %>%
        hc_subtitle(text =  unique(df_data_filtered$var_def)) %>%
        hc_xAxis(
          categories = df_data_filtered$district,
          title = list(text = "Council District")
        ) %>%
        hc_yAxis(
          title = list(text = unique(df_data_filtered$ylabs)),
          min = 0,
          plotLines = list(
            list(
              value = city_avg_tmp,
              color = "#707070",
              dashStyle = "shortdash",
              width = 2,
              label = list(
                text = paste("City Average:", round(city_avg_tmp, 1)),
                align = "right",
                style = list(color = "#707070")
              ),
              zIndex = 5
            )
          )
        ) %>%
        hc_add_series(
          data = lapply(1:nrow(df_data_filtered), function(i) {
            list(
              y = df_data_filtered$value[i],            # Original value for chart
              valueFormatted = df_data_filtered$value_clean[i], # Formatted value for display
              district = df_data_filtered$district[i],
              color = "grey",  # Default color
              id = df_data_filtered$district[i]  # Use district as point ID for easier reference
            )
          }),
          name = var_label_tmp,
          showInLegend = FALSE
        ) %>%
        hc_plotOptions(
          column = list(
            dataLabels = list(
              enabled = TRUE,
              format = "{point.valueFormatted}"  # Use formatted value in data labels
            ),
            borderWidth = 0,
            pointPadding = 0.1
          )
        ) %>%
        hc_tooltip(
          headerFormat = paste0(""),
          pointFormat = '<span style="color:{point.color}">\u25CF</span> <b>District {point.district}:</b> {point.valueFormatted}<br/>'
        ) %>%
        hc_exporting(
          enabled = TRUE,
          filename = paste0("philly-council-chart-", input$healthMetric)
        ) %>%
        hc_credits(
          enabled = TRUE,
          text = unique(df_data_filtered$source_year)
        ) %>%
        hc_add_theme(hc_theme_smpl())
    })

    # Observer to update bar chart colors when district is hovered
    observeEvent(input$hoveredDistrict, {
      # Get the bar chart proxy
      chart_proxy <- highchartProxy(session$ns("bar_chart"))
      
      # Get the filtered data
      df <- df_data_filtered()
      
      if (!is.null(input$hoveredDistrict)) {
        # Get the district being hovered
        hovered_district_id <- input$hoveredDistrict$district
        
        # Prepare the updated points with the right colors
        updated_points <- lapply(1:nrow(df), function(i) {
          district <- df$district[i]
          # Use RED for the hovered district, grey for others
          color <- ifelse(district == hovered_district_id, "#6666FF", "#CCCCCC")
          
          list(
            y = df$value[i],
            district = district,
            color = color,
            id = district
          )
        })
      } else {
        # Reset ALL colors to grey when nothing is hovered
        updated_points <- lapply(1:nrow(df), function(i) {
          list(
            y = df$value[i],
            district = df$district[i],
            color = "#CCCCCC",  # Default grey
            id = df$district[i]
          )
        })
      }
      
      # Force a complete update of the series with the updated points
      # This approach ensures the color changes are applied consistently
      chart_proxy %>%
        hcpxy_update(
          series = list(
            list(
              data = updated_points
            )
          )
        )
    }, ignoreNULL = FALSE)  # Critical: Process NULL values too
    
    # Map ---------------------------------------------------------------
    # Generate the map visualization based on selected health metric  
    output$output_map <- renderHighchart({
      # Get filtered data
      df_data_filtered <- df_data_filtered() 
      var_label_tmp <- df_data_filtered$var_label[1]
      var_name <- df_data_filtered$var_name[1]
      
      ## Map
      map_chart = highchart() %>%
        hc_title(text = var_label_tmp) %>%
        hc_subtitle(text = unique(df_data_filtered$var_def)) %>%
        hc_add_series_map(
          map = geojson_districts,
          df = df_data_filtered,
          name = var_label_tmp,
          value = "value",
          joinBy = c("district", "district"),
          dataLabels = list(
            enabled = TRUE,
            format = "{point.district}"
          ),
          tooltip = list(
            useHTML = TRUE,
            headerFormat = '',
            pointFormat = '<span style="font-size:13px"><b>District {point.district}</b>: {point.value_clean}</span>'
          ),
          # Add event handlers for hover
          point = list(
            events = list(
              # When hovering over a district, update the reactive value
              mouseOver = JS(paste0("function() {
                Shiny.setInputValue('", session$ns("hoveredDistrict"), "', {
                  district: this.district,
                  value: this.value
                });
              }")),
              # When moving out of a district, clear the value
              mouseOut = JS(paste0("function() {
                Shiny.setInputValue('", session$ns("hoveredDistrict"), "', null, {priority: 'event'});
              }"))
            )
          )
        ) %>% 
        hc_legend(
          title = list(text = unique(df_data_filtered$ylabs)),
          valueDecimals = 1, 
          valueSuffix = "%"
        )
      
      # Only add special legend formatting for weighted_hvi
      if (var_name == "weighted_hvi") {
        map_chart = map_chart %>%
          hc_colorAxis(
            min = min(df_data_filtered$value),
            max = max(df_data_filtered$value),
            stops = list(
              list(0, "#EFEFFF"),
              list(0.5, "#4444BB"),
              list(1, "#000066")
            ),
            # Apply the labels directly in colorAxis instead of legend
            labels = list(
              formatter = JS("function() {
                if (this.value === this.axis.min) {
                  return 'Low';
                } else if (this.value === this.axis.max) {
                  return 'High';
                } else {
                  return '';  // Hide other labels
                }
              }"),
              style = list(
                fontSize = "12px",  # Increase font size slightly
                textOverflow = "none"  # Prevent text truncation
              ),
              useHTML = TRUE  # Allow HTML in labels for better control
            )
          ) 
      } else {
        # Regular legend for other variables
        map_chart <- map_chart %>% 
          hc_colorAxis(
          min = min(df_data_filtered$value),
          max = max(df_data_filtered$value),
          stops = list(
            list(0, "#EFEFFF"),
            list(0.5, "#4444BB"),
            list(1, "#000066")
          )) %>% 
          hc_legend(
            title = list(text = unique(df_data_filtered$ylabs)),
            valueDecimals = 1, 
            valueSuffix = "%"
          )
      }
      
      # Add the remaining common elements
      map_chart %>%
        hc_credits(enabled = TRUE, text = unique(df_data_filtered$source_year)) %>%
        hc_mapNavigation(enabled = TRUE) %>%
        hc_add_theme(hc_theme_smpl())
    })
    

    # Observer ----------------------------------------------------------------
    # Observer to update the reactive value when hovering
    observeEvent(input$hoveredDistrict, {
      # Only update when it's actually changing
      isolate({
        if(!identical(hovered_district(), input$hoveredDistrict)) {
          hovered_district(input$hoveredDistrict)
        }
      })
    }, ignoreNULL = FALSE)  # Important: Process NULL values too
    
    
    # Observer downstream ----------------------------------------------------------------
    # Render the hovered district information
    output$hover_info <- renderUI({
      district_data <- hovered_district()
      if (is.null(district_data)) {
        return(p("None"))
      } else {
        return(p(district_data$district))
      }
    })
    
  }) 
  
}
