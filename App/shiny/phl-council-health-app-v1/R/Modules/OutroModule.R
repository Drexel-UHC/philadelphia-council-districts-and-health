OutroModule_UI <- function(id) {
  ns <- NS(id)
  
  tagList(
    # Acknowledgements section
    div(class = "section",
      h3("Acknowledgements", class = "section-title"),
      p(class = "lead", "This dashboard was developed through collaborative effort and supported by the IDEA Fellowship.")
    ),
    
    # Authors and sponsor section
    div(class = "section",
      h4("Authors", class = "subsection-title"),
      p("Amber Bolli, Tamara Rushovich, Ran Li, Stephanie Hernandez, Alina Schnake-Mahl"),
      
      h4("Sponsor", class = "subsection-title"),
      p("IDEA Fellowship")
    ),
    
    # Links to related work section
    div(class = "section",
      h4("Links to Related Work", class = "subsection-title"),
      tags$ul(
        tags$li(a("NYU Congressional Dashboard", href = "#", target = "_blank")),
        tags$li("Congressional District Journal Articles"),
        tags$li("Chicago Health Atlas")
      )
    ),
    
    # Citation section
    div(class = "section",
        h4("Citation", class = "subsection-title"),
        div(
          class = "code-block",
          tags$code("Urban Health Collaborative, Health of Philadelphia City Council Districts Dashboard, 2025")
        )
    ),
    
    # Contact section
    div(class = "section",
      h4("Contact Us", class = "subsection-title"),
      p("Please reach out to ", tags$b("XXXXX"), " with any questions.")
    )
  )
}

OutroModule_Server <- function(id) {
  moduleServer(id, function(input, output, session) {
    # No server-side logic needed for this module
  })
}