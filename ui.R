
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
# 
# http://www.rstudio.com/shiny/
#

library(shiny)
library(rCharts)

shinyUI(
    navbarPage("Storms and Other Severe Weather Events Analysis",
        tabPanel("Visualization",
                sidebarPanel(
                    sliderInput("year", 
                        "Select Year Range:", 
                        min = 1950, 
                        max = 2011, 
                        value = c(1993, 2011)),
                    uiOutput("evtypeControls"),
                    actionButton(inputId = "clear_all", 
                                 label = "Clear selection", 
                                 icon = icon("check-square-o")),
                    actionButton(inputId = "select_all", 
                                 label = "Select all", 
                                 icon = icon("check-square-o"))
                ),
  
                mainPanel(
                    tabsetPanel(
                        
                        # Data by state
                        tabPanel(p(icon("map-marker"), "By State"),
                            h4('Population and Economic impacts by state 
                               for the selected year range', 
                                align = "center"),
                            column(12,
                                plotOutput("populationImpactByState"),
                                plotOutput("economicImpactByState")
                            )

                        ),
                        
                        # Time series data
                        tabPanel(p(icon("line-chart"), "By Year"),
                                 h4('Population Impact by Year', 
                                    align = "center"),
                                 showOutput("populationImpact", "nvd3"),
                                 h4('Economic Impact by Year', 
                                    align = "center"),
                                 showOutput("economicImpact", "nvd3")
                        )
                    )
                )
            
        ),
        
        tabPanel("About",
            mainPanel(
                includeMarkdown("include.md")
            )
        )
    )
)
