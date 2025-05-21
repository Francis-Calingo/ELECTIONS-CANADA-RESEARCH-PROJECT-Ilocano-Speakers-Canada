install.packages("shiny")
install.packages(c("DT", "dplyr", "readr"))
install.packages(c("leaflet", "sf", "tmap"))  # geospatial tools, rgdal retired
install.packages(c("ggplot2", "plotly"))



library(shiny)

library(DT)
library(dplyr)
library(readr)

library(leaflet)
library(sf)
library(tmap)
# library(rgdal)

library(ggplot2)
library(plotly)

panel1 <- readr::read_csv("")
panel2 <- readr::read_csv("")
panel3 <- readr::read_csv("")
panel4 <- readr::read_csv("")

# Define UI
ui <- navbarPage("Ilocano Speakers in Canada",
                 
                 # First Panel: Top 10 Tables
                 tabPanel("Top 10 Tables",
                          sidebarLayout(
                            sidebarPanel(
                              selectInput("language", "Select a language:",
                                          choices = c("Ilocano", "Tagalog", "Cebuano")),
                              selectInput("metric", "Select a metric:",
                                          choices = c("Count", "Rate")),
                              helpText("Displays the top 10 regions by selected language and metric.")
                            ),
                            mainPanel(
                              DTOutput("top10table")
                            )
                          )
                 )
                 
                 # You can add more tabPanels here later:
                 # tabPanel("Choropleth Maps", ...)
                 # tabPanel("Regression Analysis", ...)
)

# First Panel: Top 10 Tables (single dropdown version)
tabPanel("Top 10 Tables",
         sidebarLayout(
           sidebarPanel(
             selectInput("tableChoice", "Select a table to view:",
                         choices = c("Raw Number", "Per-Capita", "Ilocano-Tagalog Ratio")),
             helpText("Displays the top 10 regions for the selected language.")
           ),
           mainPanel(
             DTOutput("top10table")
           )
         )
)

server <- function(input, output, session) {
  output$top10table <- renderDT({
    # Map the dropdown choices to column names in your CSV
    column_map <- list(
      "Raw Number" = "Col1",
      "Per-Capita" = "Col2",
      "Ilocano-Tagalog Ratio" = "Col3"
    )
    
    selected_column <- column_map[[input$tableChoice]]
    
    # Filter TagalogCount > 1000 and select top 10 rows (assuming already sorted)
    top10 <- language_data %>%
      filter(TagalogCount > 1000) %>%
      select(Region, !!sym(selected_column)) %>%
      slice_head(n = 10)
    
    datatable(top10,
              rownames = FALSE,
              colnames = c("Region", gsub("Ilocano", "Ilocano ", selected_column)),
              options = list(pageLength = 10, dom = 't'))
  })
}

# Run the app
shinyApp(ui = ui, server = server)

## Panel 1

## Panel 2
