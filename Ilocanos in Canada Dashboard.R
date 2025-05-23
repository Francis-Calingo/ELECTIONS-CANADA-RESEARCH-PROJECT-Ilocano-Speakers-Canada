
install.packages(c("DT", "dplyr", "readr"))
install.packages(c("ggplot2", "plotly"))

library(DT)
library(dplyr)
library(readr)
library(ggplot2)
library(plotly)


Growth_Data <- readr::read_csv("C:/Users/francali/Downloads/Ilocanos in Canada 2006-2021.csv")
CMA_Data <- readr::read_csv("C:/Users/francali/Downloads/Ilocanos in Canada, CMAs.csv")
City_Data <- readr::read_csv("C:/Users/francali/Downloads/Ilocanos in Canada, Cities.csv")
Province_Data <- readr::read_csv("C:/Users/francali/Downloads/Ilocanos in Canada, Provinces.csv")
Riding_Data <- readr::read_csv("C:/Users/francali/Downloads/Ilocanos in Canada, Ridings.csv")

### PANEL 1: PER-CAPITA DATA

# Plot 1: Ridings Table

Riding_Table <- Riding_Data[order(-Riding_Data$"Ilocano per 100K"), 
                            c("Riding (2023 Representation Order)", "Ilocano per 100K")][1:10, ]
Riding_Table

# Plot 2: CMA Table

CMA_Table <- CMA_Data[order(-CMA_Data$"Ilocano per 100K"), 
                            c("CMA", "Ilocano per 100K")][1:10, ]
CMA_Table

# Plot 3: Choropleth Map of Provinces and Territories

### PANEL 2: TAGALOG AND ILOCANO COMPARISONS

# Plot 1: Distribution by Province, Donut Chart

Distribution_Data <- Province_Data[c("Province/Territory","Population", 
                                     "% Total Ilocano Pop","% Tagalog Pop")]

Distribution_Data

# We can make the data more meaningful by grouping them:

Distribution_Data$Region <- c("Atlantic Canada","Atlantic Canada", 
                                                 "Atlantic Canada","Atlantic Canada",
                                                 "Quebec","Ontario",
                                                 "Manitoba","Saskatchewan",
                                                 "Alberta","BC",
                                                 "Territories","Territories",
                                                 "Territories")

Distribution_Data


Distribution_Data_sum <- Distribution_Data %>%
  group_by(Region) %>%
  summarise(
    total_Ilo = sum("% Total Ilocano Pop", na.rm = TRUE),
    total_Tag = sum("% Tagalog Pop", na.rm = TRUE)
  )

Distribution_Data_sum


#########################################################

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
panel2 <- readr::read_csv("C:/Users/francali/Downloads/Ilocanos by Province&Territory, 2006-2021.csv")

# creating a data frame
panel2.data <- data.frame(
  year = c("2021", "2021", 
           "2016", "2016", 
           "2011","2011",
           "2006","2006"), 
  language = c("Ilocano", "Tagalog", 
               "Ilocano", "Tagalog", 
               "Ilocano","Tagalog",
               "Ilocano","Tagalog"), 
  raw_number = c(33520, 461150, 
               26345, 431380, 
               17915,327445,
               13450,235615), 
  stringsAsFactors = FALSE
)
# print the data frame
print(panel2.data)

# Step 2: Pivot to wide format
wide_data <- panel2.data %>%
  tidyr::pivot_wider(names_from = language, values_from = raw_number) %>%
  arrange(year)

# Step 3: Calculate growth rates
wide_data <- wide_data %>%
  mutate(
    Ilocano_growth = c(NA, diff(Ilocano) / lag(Ilocano)[-1] * 100),
    Tagalog_growth = c(NA, diff(Tagalog) / lag(Tagalog)[-1] * 100)
  )

# Step 4: Plotly chart
plot_ly(wide_data, x = ~year) %>%
  add_lines(y = ~Ilocano, name = "Ilocano Count", line = list(color = 'blue'), yaxis = "y1") %>%
  add_lines(y = ~Tagalog, name = "Tagalog Count", line = list(color = 'red'), yaxis = "y1") %>%
  add_bars(y = ~Ilocano_growth, name = "Ilocano Growth Rate", marker = list(color = 'lightblue'), yaxis = "y2") %>%
  add_bars(y = ~Tagalog_growth, name = "Tagalog Growth Rate", marker = list(color = 'pink'), yaxis = "y2") %>%
  layout(
    title = "Ilocano and Tagalog Language Trends in Canada",
    xaxis = list(title = "Year"),
    yaxis = list(title = "Raw Count", side = "left"),
    yaxis2 = list(title = "Growth Rate (%)", overlaying = "y", side = "right"),
    barmode = "group",
    legend = list(x = 0.1, y = 1.1, orientation = 'h')
  )

panel2

panel3 <- readr::read_csv("")
panel4 <- readr::read_csv("")

############

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
