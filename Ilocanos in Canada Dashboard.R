install.packages(c("DT", "dplyr", "readr"))
install.packages(c("ggplot2", "plotly"))
install.packages("sf")


library(DT)
library(dplyr)
library(readr)
library(ggplot2)
library(plotly)
library(sf)



Growth_Data <- readr::read_csv("C:/Users/francali/Downloads/Ilocanos in Canada 2006-2021.csv")
CMA_Data <- readr::read_csv("C:/Users/francali/Downloads/Ilocanos in Canada, CMAs.csv")
City_Data <- readr::read_csv("C:/Users/francali/Downloads/Ilocanos in Canada, Cities.csv")
Province_Data <- readr::read_csv("C:/Users/francali/Downloads/Ilocanos in Canada, Provinces.csv")
Riding_Data <- readr::read_csv("C:/Users/francali/Downloads/Ilocanos in Canada, Ridings.csv")

#Download shapefile of provincial and territorial boundaries
my_sf <- read_sf("C:/Users/francali/Downloads/lpr_000b21a_e.shp")

head(my_sf)

### PANEL 1: PER-CAPITA DATA ###

## Plot 1: Ridings Table (Top 10)

Riding_Table_100K <- Riding_Data[order(-Riding_Data$"Ilocano per 100K"), 
                                 c("Riding (2023 Representation Order)", "Ilocano per 100K")][1:10, ]
Riding_Table_100K

## Plot 2: CMA Table (Top 10)

CMA_Table_100K <- CMA_Data[order(-CMA_Data$"Ilocano per 100K"), 
                           c("CMA", "Ilocano per 100K")][1:10, ]
CMA_Table_100K

## Plot 3: Choropleth Map of Provinces and Territories

#Merge shapefile with csv file, joined through the names of the provinces and territories
my_sf_merged <- my_sf %>%
  left_join(Province_Data, by = c("PRENAME" = "Province/Territory"))

#Map, Ilocanos Per 100K

Map1 <- ggplot(my_sf_merged) +
  geom_sf(aes(fill = `Ilocano per 100K`), color='gray',data=my_sf_merged) +
  geom_sf(fill='transparent', color='white', data=my_sf_merged) +
  scale_fill_distiller(palette = "Blues", direction = 1, name = "Ilocanos per 100K") +
  labs(title='Ilocano Speakers Per 100K (2021)',
       caption=c('Source: Statistics Canada')) +
  theme_gray() +
  theme(title=element_text(face='bold'), legend.position='bottom')
Map1

### PANEL 2: TAGALOG AND ILOCANO COMPARISONS ###

## Plot 1: Distribution by Province, Donut Chart

Distribution_Data <- Province_Data[c("Province/Territory","Population", 
                                     "% Total Ilocano Pop","% Tagalog Pop")]

Distribution_Data

# Step 1 We can make the data more meaningful by grouping them:

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

# Step 2: Pivot to long format
Distribution_long <- Distribution_Data_sum %>%
  pivot_longer(cols = c(total_Ilo, total_Tag), names_to = "Language", values_to = "Percentage")

# Step 3: Assign inner and outer donuts

Distribution_long <- Distribution_long %>%
mutate(
  ring = ifelse(Language == "total_Ilo", 1, 2)  # 1 = inner, 2 = outer
)

# Step 4: Create donut chart
ggplot(Distribution_long, aes(x = ring, y = Percentage, fill = Region)) +
  geom_col(color = "white", width = 1) +
  coord_polar(theta = "y") +
  xlim(0, 5) +  # Space for two rings
  scale_fill_viridis_d(option = "D") + 
  theme_void() +
  theme(
    legend.title = element_text(size = 10, face = "bold"),
    legend.text = element_text(size = 9),
    plot.title = element_text(hjust = 0.5, face = "bold", size = 14)
  ) +
  labs(
    title = "Ilocano (Inner Ring) vs Tagalog (Outer Ring) Population Share by Region",
    fill = "Region"
  )


## Plot 2: Choropleth Map, Tagalog-Ilocano Ratio

Map2 <- ggplot(my_sf_merged) +
  geom_sf(aes(fill = `Ratio, Ilocano-Tagalog`), color='gray',data=my_sf_merged) +
  geom_sf(fill='transparent', color='white', data=my_sf_merged) +
  scale_fill_distiller(palette = "Blues", direction = 1, name = "Ratio, Ilocano Speakers to Tagalog Speakers") +
  labs(title='Ratio Between Ilocano and Tagalog Speakers (2021)',
       caption=c('Source: Statistics Canada')) +
  theme_gray() +
  theme(title=element_text(face='bold'), legend.position='bottom')
Map2


## Plot 3: Ridings Table (Top 10, Minimum Tagalog & Ilocano Population >= 1000)

Riding_Data$`Ratio, Ilocano-Tagalog` <- as.numeric(gsub(",", "", Riding_Data$`Ratio, Ilocano-Tagalog`))

Riding_Table_Ratio <- Riding_Data[
  Riding_Data$`Sum (Tagalog + Ilocano)` >= 1000, 
][order(-Riding_Data$`Ratio, Ilocano-Tagalog`), 
  c("Riding (2023 Representation Order)", "Ratio, Ilocano-Tagalog")][1:10, ]
Riding_Table_Ratio

# Filter rows with at least 1000 people speaking Tagalog + Ilocano
filtered1 <- Riding_Data[Riding_Data$`Sum (Tagalog + Ilocano)` >= 1000, ]

# Order by Ratio (descending) and select top 10
Riding_Table_Ratio <- filtered1[
  order(-filtered1$`Ratio, Ilocano-Tagalog`), 
  c("Riding (2023 Representation Order)", "Ratio, Ilocano-Tagalog")
][1:10, ]

# View result
Riding_Table_Ratio

## Plot 4: CMA Table (Top 10, Minimum Tagalog & Ilocano Population >= 1000)

CMA_Table_Ratio <- CMA_Data[
  CMA_Data$"Sum (Tagalog + Ilocano)" >= 1000, 
][order(-CMA_Data$"Ratio, Ilocano-Tagalog"), 
  c("CMA", "Ratio, Ilocano-Tagalog")][1:10, ]
CMA_Table_Ratio

#########################################################

### PANEL 3: GROWTH RATES, 2006-2021 ###

## Plot 1: Choropleth Map by Province

num_cols <- sapply(Growth_Data, is.numeric)
growth_row_num <- ((Growth_Data[1, num_cols] - Growth_Data[7, num_cols])/Growth_Data[7, num_cols])*100

growth_row <- Growth_Data[1, ]
growth_row[] <- NA

growth_row[num_cols] <- growth_row_num

Growth_Data <- rbind(Growth_Data, growth_row)

rownames(Growth_Data)[nrow(Growth_Data)] <- "Ilocano Growth Rate, 2006-2021"


Growth_Table <- as.data.frame(t(Growth_Data))

Growth_Table_New <- Growth_Table %>%
  slice(4:(n() - 10)) %>%       # drop first 3 and last 10 rows
  select(-(1:8)) %>%            # drop columns 1-8

Growth_Table_New$`Province/Territory` <- c("Newfoundland and Labrador","Prince Edward Island", 
                                                                       "Nova Scotia","New Brunswick",
                                                                       "Quebec","Ontario",
                                                                       "Manitoba","Saskatchewan",
                                                                       "Alberta","British Columbia",
                                                                       "Yukon","Northwest Territories",
                                                                       "Nunavut")


Growth_Table_New$`Ilocano Growth Rate, 2006-2021` <- as.numeric(Growth_Table_New$`Ilocano Growth Rate, 2006-2021`)
Growth_Table_New[Growth_Table_New == Inf] <- NA

#Merge shapefile with csv file, joined through the names of the provinces and territories
my_sf_merged_2 <- my_sf %>%
  left_join(Growth_Table_New, by = c("PRENAME" = "Province/Territory"))


Map3 <- ggplot(my_sf_merged_2) +
  geom_sf(aes(fill = `Ilocano Growth Rate, 2006-2021`), color='gray',data=my_sf_merged_2) +
  geom_sf(fill='transparent', color='white', data=my_sf_merged_2) +
  scale_fill_distiller(palette = "Blues", direction = 1, name = "Growth Rate of Ilocano Population, 2006-2021",
na.value = "lightgray")+
  labs(title='Growth Rate of Ilocano Speakers in Canada, 2006-2021',
       caption=c('Source: Statistics Canada')) +
  theme_gray() +
  theme(title=element_text(face='bold'), legend.position='bottom')
Map3

## Plots 2-18: Dual Axis Plot for National, Provincial, and City-Level Growth

Growth_Data$Year <- c("2021", "2021",
                       "2016", "2016",
                       "2011", "2011",
                       "2006", "2006", "N/A")

Growth_Data_TimeSeries <- Growth_Data[-nrow(Growth_Data), ]


# Step 2: Pivot to wide format
wide_data_Canada <- Growth_Data_TimeSeries[, 1:3] %>%
  tidyr::pivot_wider(names_from = Language, values_from = "Canada") %>%
  arrange(Year)

# Step 3: Calculate growth rates
wide_data_Canada <- wide_data_Canada %>%
  mutate(
    Ilocano_growth = c(NA, diff(Ilocano) / lag(Ilocano)[-1] * 100),
    Tagalog_growth = c(NA, diff(Tagalog) / lag(Tagalog)[-1] * 100)
  )


plot_ly(wide_data_Canada, x = ~Year) %>%
  add_bars(y = ~Ilocano_growth, name = "Ilocano Growth Rate", marker = list(color = '#91bad6'), yaxis = "y1") %>%
  add_bars(y = ~Tagalog_growth, name = "Tagalog Growth Rate", marker = list(color = '#f4b6b6'), yaxis = "y1") %>%
  add_lines(y = ~Ilocano, name = "Ilocano Count", line = list(color = '#1f77b4', width = 3), yaxis = "y2") %>%
  add_lines(y = ~Tagalog, name = "Tagalog Count", line = list(color = '#d62728', width = 3), yaxis = "y2") %>%
  layout(
    title = "Ilocano and Tagalog Language Trends in Canada",
    xaxis = list(title = "Year", type = "category"),
    yaxis = list(title = "Raw Count", side = "left", showgrid = FALSE),
    yaxis2 = list(title = "Growth Rate (%)", overlaying = "y", side = "right", showgrid = FALSE),
    barmode = "group",
    legend = list(orientation = 'h', x = 0.1, y = 1.15),
    margin = list(t = 80)
  )

### PANEL 4: RIDING-LEVEL REGRESSION ANALYSIS: ILOCANO VS. OTHER LANGUAGE COMMUNITIES

## Plot 1: Versus Tagalog

lm(`Ilocano per 100K` ~ `Tagalog per 100K`, data = Riding_Data)

# https://plotly.com/r/ml-regression/

## Plot 2: Versus Cebuano

lm(`Ilocano per 100K` ~ `Tagalog per 100K` + `Cebuano per 100K`, data = Riding_Data)

## Plots 3-7: Versus Mandarin, Punjabi, Cantonese, Spanish, Arabic

lm(`Ilocano per 100K` ~ `Tagalog per 100K` + `Mandarin per 100K`, data = Riding_Data)

lm(`Ilocano per 100K` ~ `Tagalog per 100K` + `Punjabi per 100K`, data = Riding_Data)

lm(`Ilocano per 100K` ~ `Tagalog per 100K` + `Spanish per 100K`, data = Riding_Data)

lm(`Ilocano per 100K` ~ `Tagalog per 100K` + `Spanish per 100K`, data = Riding_Data)

lm(`Ilocano per 100K` ~ `Tagalog per 100K` + `Arabic per 100K`, data = Riding_Data)






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
