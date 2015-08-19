library(shiny)

# Plot 
library(ggplot2)
library(rCharts)
library(ggvis)

# Data
library(data.table)
library(reshape2)
library(dplyr)

# Markdown
library(markdown)

# ggplot maps on shinyapps.io
library(mapproj)
library(maps)

# Load helper functions
source("helpers.R", local = TRUE)


# Load data
states_map <- map_data("state")
dt <- fread('events.csv') %>% mutate(EVTYPE = tolower(EVTYPE))
evtypes <- sort(unique(dt$EVTYPE))


# Shiny server 
shinyServer(function(input, output, session) {
    
    # Define and initialize reactive values
    values <- reactiveValues()
    values$evtypes <- evtypes
    
    # Create event type checkbox
    output$evtypeControls <- renderUI({
        checkboxGroupInput('evtypes', 'Event types', 
                           evtypes, selected=values$evtypes)
    })
    
    # Add observers on clear and select all buttons
    observe({
        if(input$clear_all == 0) return()
        values$evtypes <- c()
    })
    
    observe({
        if(input$select_all == 0) return()
        values$evtypes <- evtypes
    })

    # Preapre datasets
    
    # Prepare dataset for maps
    dt.agg <- reactive({
        aggregate_by_state(dt, input$year[1], input$year[2], input$evtypes)
    })
    
    # Prepare dataset for time series
    dt.agg.year <- reactive({
        aggregate_by_year(dt, input$year[1], input$year[2], input$evtypes)
    })
    
    # Render Plots
    
    # Population impact by state
    output$populationImpactByState <- renderPlot({
        print(plot_impact_by_state (
            dt.agg() %>% mutate(Affected = INJURIES + FATALITIES),
            states_map = states_map, 
            year_min = input$year[1],
            year_max = input$year[2],
            title = "Population Impact %d - %d (number of affected)",
            fill = "Affected"
        ))
    })
    
    # Economic impact by state
    output$economicImpactByState <- renderPlot({
        print(plot_impact_by_state(
            dt.agg() %>% mutate(Damages = PROPDMG + CROPDMG),
            states_map = states_map, 
            year_min = input$year[1],
            year_max = input$year[2],
            title = "Economic Impact %d - %d (Million USD)",
            fill = "Damages"
        ))
    })
    
    # Population impact by year
    output$populationImpact <- renderChart({
        plot_impact_by_year(
            dt = dt.agg.year() %>% select(Year, Injuries, Fatalities),
            dom = "populationImpact",
            yAxisLabel = "Affected",
            desc = TRUE
        )
    })
    
    # Economic impact by state
    output$economicImpact <- renderChart({
        plot_impact_by_year(
            dt = dt.agg.year() %>% select(Year, Crops, Property),
            dom = "economicImpact",
            yAxisLabel = "Total damage (Million USD)"
        )
    })
    
})


