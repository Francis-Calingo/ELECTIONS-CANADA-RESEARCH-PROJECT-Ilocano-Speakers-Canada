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

# Define server logic
server <- function(input, output, session) {
  
  output$top10table <- renderDT({
    # Combine selected language + metric to get column name
    lang <- input$language
    metric <- input$metric
    colname <- paste0(lang, metric)  # e.g., IlocanoRate
    
    # Filter and arrange top 10 regions
    top10 <- language_data %>%
      select(Region, !!sym(colname)) %>%
      arrange(desc(!!sym(colname))) %>%
      slice(1:10)
    
    # Render the table
    datatable(top10,
              rownames = FALSE,
              colnames = c("Region", paste(lang, metric)),
              options = list(pageLength = 10, dom = 't'))
  })
}

# Run the app
shinyApp(ui = ui, server = server)

## Panel 1

## Panel 2
tabPanel("Dual-Axis Plots",
         sidebarLayout(
           sidebarPanel(
             selectInput("language2", "Select a language:",
                         choices = c("Ilocano", "Tagalog", "Cebuano")),
             helpText("Shows both rate and count for the selected language by region.")
           ),
           mainPanel(
             plotlyOutput("dualAxisPlot")
           )
         )
)


