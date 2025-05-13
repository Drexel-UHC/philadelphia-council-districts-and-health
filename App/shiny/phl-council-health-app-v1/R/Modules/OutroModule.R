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
        tags$li(a("Congressional District Health Dashboard", href = "https:/www.congressionaldistricthealthdashboard.org", target = "_blank")),
        tags$li(a("Rushovich T, Nethery RC, White A, Krieger N. Gerrymandering and the Packing and Cracking of Medical Uninsurance Rates in the United States. J Public Health Manag Pract. 2024", href = "https://pubmed.ncbi.nlm.nih.gov/39190647/", target = "_blank")),
        tags$li(a("Schnake-Mahl A, Anfuso G, Goldstein ND, et al. Measuring variation in infant mortality and deaths of despair by US congressional district in Pennsylvania: a methodological case study. Am J Epidemiol. 2024", href = "https://pubmed.ncbi.nlm.nih.gov/38412272/", target = "_blank")),
        tags$li(a("Schnake-Mahl A, Anfuso G, Bilal U, et al. Court-mandated redistricting and disparities in infant mortality and deaths of despair. BMC Public Health. 2025", href = "https://pmc.ncbi.nlm.nih.gov/articles/PMC11921522/", target = "_blank")),
        tags$li(a("Schnake-Mahl A, Anfuso G, Hernandez SM, Bilal U. Geospatial Data Aggregation Methods for Novel Geographies: Validating Congressional District Life Expectancy Estimates. Epidemiology. 2025", href = "https://pubmed.ncbi.nlm.nih.gov/39329432/", target = "_blank")),
        tags$li(a("Spoer BR, Chen AS, Lampe TM, et al. Validation of a geospatial aggregation method for congressional districts and other US administrative geographies. SSM Popul Health. 2023", href = "https://pmc.ncbi.nlm.nih.gov/articles/PMC10498302/", target = "_blank"))
      )
    ),
    
    # Citation section
    div(class = "section",
        h4("Citation", class = "subsection-title"),
        div(
          class = "code-block",
          tags$code(HTML("Urban Health Collaborative, <em>Health of Philadelphia City Council Districts Dashboard</em>, 2025"))
        )
    ),
    
    # Contact section
    div(class = "section",
      h4("Contact Us", class = "subsection-title"),
      p("Please reach out to ", a(href = "mailto:UHC@drexel.edu", "UHC@drexel.edu"), " with any questions.")
    )
  )
}

OutroModule_Server <- function(id) {
  moduleServer(id, function(input, output, session) {
    # No server-side logic needed for this module
  })
}