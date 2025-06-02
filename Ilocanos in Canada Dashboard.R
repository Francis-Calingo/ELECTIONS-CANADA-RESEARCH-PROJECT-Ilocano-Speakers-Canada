##########################
## INSTALL DEPENDENCIES ##
##########################

install.packages(c("DT", "dplyr", "readr"))
install.packages(c("ggplot2", "plotly"))
install.packages("sf")
install.packages("tidyr")
install.packages("ggpmisc")
install.packages(c("shiny", "shinydashboard"))
install.packages("rsconnect")


library(DT)
library(dplyr)
library(readr)
library(ggplot2)
library(plotly)
library(sf)
library(tidyr)
library(ggpmisc)
library(shiny)
library(shinydashboard)
library(rsconnect)


############################################################################################################################
############################################################################################################################

###############################
## IMPORT CSVs AND SHAPEFILE ##
###############################

# Growth of Tagalog-speaking and Ilocano-speaking populations in Canada (2006, 2011, 2016, 2021 Census), 
# nationally, provincially, territorially, and 10 most-populated cities in 2021.
Growth_Data <- readr::read_csv("C:/Users/francali/Downloads/Ilocanos in Canada 2006-2021.csv") 

# Data by Census Metropolitan Areas (CMAs), 2021 Census
CMA_Data <- readr::read_csv("C:/Users/francali/Downloads/Ilocanos in Canada, CMAs.csv")

# Data from Canada's 10 Provinces and 3 Territories, 2021 Census
Province_Data <- readr::read_csv("C:/Users/francali/Downloads/Ilocanos in Canada, Provinces.csv")

# Data from Canada's 343 federal-level electoral boundaries (ridings, 2023 representation order), 2021 Census
Riding_Data <- readr::read_csv("C:/Users/francali/Downloads/Ilocanos in Canada, Ridings.csv")

#Download shapefile of provincial and territorial boundaries from Statistics Canada
my_sf <- read_sf("C:/Users/francali/Downloads/lpr_000b21a_e.shp")
head(my_sf)

############################################################################################################################
############################################################################################################################

##################################
## SKELETON SET-UP OF DASHBOARD ##
##################################

### PANEL 1: PER-CAPITA DATA ###

## Plot 1: Ridings Table (Top 10)

Riding_Table_100K <- Riding_Data[order(-Riding_Data$"Ilocano per 100K"), 
                                 c("Riding (2023 Representation Order)", "Ilocano per 100K")][1:10, ]
Riding_Table_100K

# Convert to a plotly dataframe

Riding_Table_100K[] <- lapply(Riding_Table_100K, function(col) {
  if (is.character(col)) {
    Encoding(col) <- "UTF-8"
    iconv(col, from = "", to = "UTF-8", sub = "")
  } else {
    col
  }
})

Riding_100K <- plot_ly(
  type = "table",
  header = list(
    values = names(Riding_Table_100K),
    align = "left",
    fill = list(color = "lightgrey"),
    font = list(weight = "bold")
  ),
  cells = list(
    values = t(as.matrix(Riding_Table_100K)),
    align = "left"
  )
)

Riding_100K

## Plot 2: CMA Table (Top 10)

CMA_Table_100K <- CMA_Data[order(-CMA_Data$"Ilocano per 100K"), 
                           c("CMA", "Ilocano per 100K")][1:10, ]
CMA_Table_100K

# Convert to a plotly dataframe

CMA_Table_100K[] <- lapply(CMA_Table_100K, function(col) {
  if (is.character(col)) {
    Encoding(col) <- "UTF-8"
    iconv(col, from = "", to = "UTF-8", sub = "")
  } else {
    col
  }
})

CMA_100K <- plot_ly(
  type = "table",
  header = list(
    values = names(CMA_Table_100K),
    align = "left",
    fill = list(color = "lightgrey"),
    font = list(weight = "bold")
  ),
  cells = list(
    values = t(as.matrix(CMA_Table_100K)),
    align = "left"
  )
)


CMA_100K

## Plot 3: Choropleth Map of Provinces and Territories (Ilocanos per 100K)

#Step 1: Merge shapefile with provincial csv file, joined through the names of the provinces and territories
my_sf_merged <- my_sf %>%
  left_join(Province_Data, by = c("PRENAME" = "Province/Territory"))


#Step 2: Map, Ilocanos Per 100K

Map1 <- ggplot(my_sf_merged) +
  geom_sf(
    aes(
      fill = `Ilocano per 100K`
    ),
    color = "white"
  ) +
  scale_fill_distiller(palette = "Blues", direction = 1, name = "Ilocanos per 100K") +
  labs(
    title = "Ilocano Speakers Per 100K (2021)",
    caption = "Source: Statistics Canada"
  ) +
  theme_gray() +
  theme(title = element_text(face = "bold"), legend.position = "bottom")


############################################################################################################################


### PANEL 2: TAGALOG AND ILOCANO COMPARISONS ###

## Plot 1: Distribution by Province, Donut Chart

Distribution_Data <- Province_Data[c("Province/Territory","Population", 
                                     "% Total Ilocano Pop","% Tagalog Pop")]

Distribution_Data

#Step 1: We can make the data more meaningful by grouping them, then sum by group:

Distribution_Data$Region <- c("Atlantic Canada","Atlantic Canada", 
                              "Atlantic Canada","Atlantic Canada",
                              "Quebec","Ontario",
                              "Manitoba","Saskatchewan",
                              "Alberta","BC",
                              "Territories","Territories",
                              "Territories")

Distribution_Data


Distribution_Data_sum <- Distribution_Data[, 2:5] %>%
  group_by(Region) %>%
  summarise(
    total_Ilo = sum(`% Total Ilocano Pop`, na.rm = TRUE),
    total_Tag = sum(`% Tagalog Pop`, na.rm = TRUE)
  )


Distribution_Data_sum

#Step 2: Pivot to long format to make the creation of donut chart less verbose
Distribution_long <- Distribution_Data_sum %>%
  pivot_longer(cols = c(total_Ilo, total_Tag), names_to = "Language", values_to = "Percentage")

#Step 3: Assign inner and outer donuts (inner donut=Ilocano, outer donut=Tagalog)

Distribution_long <- Distribution_long %>%
  mutate(
    ring = ifelse(Language == "total_Ilo", 1, 2)  # 1 = inner, 2 = outer
  )

#Step 4: Separate data for Ilocano and Tagalog rings
ilocano_data <- Distribution_Data_sum %>%
  select(Region, Percentage = total_Ilo) %>%
  mutate(Language = "Ilocano")

tagalog_data <- Distribution_Data_sum %>%
  select(Region, Percentage = total_Tag) %>%
  mutate(Language = "Tagalog")

#Step 5: Plot outer ring (Tagalog)
outer_ring <- plot_ly(tagalog_data,
                      labels = ~Region,
                      values = ~Percentage,
                      type = 'pie',
                      name = "Tagalog",
                      hole = 0.5,
                      sort = FALSE,
                      direction = "clockwise",
                      textinfo = "label+percent",
                      marker = list(line = list(color = '#FFFFFF', width = 1))) %>%
  layout(showlegend = TRUE)

#Step 6: Plot inner ring (Ilocano)
inner_ring <- plot_ly(ilocano_data,
                      labels = ~Region,
                      values = ~Percentage,
                      type = 'pie',
                      name = "Ilocano",
                      hole = 0.3,
                      sort = FALSE,
                      direction = "clockwise",
                      textinfo = "none",
                      marker = list(line = list(color = '#FFFFFF', width = 1)),
                      domain = list(x = c(0.25, 0.75), y = c(0.25, 0.75)))

#Step 7: Combine both rings
Donut_Plot <- subplot(outer_ring, inner_ring, nrows = 1) %>%
  layout(title = list(text = "Ilocano (Inner Ring) vs Tagalog (Outer Ring) Population Share by Region",
                      x = 0.5),
         showlegend = TRUE)

Donut_Plot

#Step 8: Change layout
Donut_Plot <- subplot(outer_ring, inner_ring, nrows = 1) %>%
  layout(
    title = list(
      text = "Ilocano (Inner Ring) vs Tagalog (Outer Ring) Population Share by Region",
      x = 0.5,
      y = 0.95,
      font = list(size = 18, family = "Arial", color = "black")
    ),
    margin = list(t = 150),  # Increase top margin
    showlegend = TRUE
  )

## Plot 2: Choropleth Map, Tagalog-Ilocano Ratio

Map2 <- ggplot(my_sf_merged) +
  geom_sf(
    aes(
      fill = `Ratio, Ilocano-Tagalog`,
    ),
    color = "white"
  ) +
  scale_fill_distiller(palette = "Blues", direction = 1, name = "Ratio, Ilocano-Tagalog") +
  labs(
    title = "Ratio, Ilocano Speakers-Tagalog Speakers",
    caption = "Source: Statistics Canada"
  ) +
  theme_gray() +
  theme(title = element_text(face = "bold"), legend.position = "bottom")

## Plot 3: Ridings Table (Top 10, Minimum Tagalog & Ilocano Population >= 1000)

#Step 1: Check "Ratio, Ilocano-Tagalog" and "Sum (Tagalog + Ilocano)" to see if they are of numeric type
typeof(Riding_Data$`Ratio, Ilocano-Tagalog`)

typeof(Riding_Data$`Sum (Tagalog + Ilocano)`)

#Step 2: Filter for columns of interest and remove "#DIV/0!" from "Ratio, Ilocano-Tagalog", as they 
#represent null values from Excel
Riding_Data_filtered <- Riding_Data[, c("Riding (2023 Representation Order)", 
                                        "Province/Territory", 
                                        "Sum (Tagalog + Ilocano)", 
                                        "Ratio, Ilocano-Tagalog")] %>%
  filter(`Ratio, Ilocano-Tagalog` != "#DIV/0!")

#Step 3: Convert "Ratio, Ilocano-Tagalog" column to numeric type
Riding_Data_filtered$`Ratio, Ilocano-Tagalog` <- as.numeric(gsub(",", "", Riding_Data_filtered$`Ratio, Ilocano-Tagalog`))

#Step 4: Filter for "Sum (Tagalog + Ilocano)" >= 1000
Riding_Data_filtered <- Riding_Data_filtered %>%
  filter(`Sum (Tagalog + Ilocano)` >= 1000)

#Step 5: Order Ratio column in Descending order, then filter for first 10 rows
Riding_Table_Ratio <- Riding_Data_filtered[order(-Riding_Data_filtered$"Ratio, Ilocano-Tagalog"), 
                                           c("Riding (2023 Representation Order)", "Province/Territory", "Ratio, Ilocano-Tagalog")][1:10, ]
Riding_Table_Ratio

# Convert to a plotly dataframe

Riding_Table_Ratio[] <- lapply(Riding_Table_Ratio, function(col) {
  if (is.character(col)) {
    Encoding(col) <- "UTF-8"
    iconv(col, from = "", to = "UTF-8", sub = "")
  } else {
    col
  }
})

Riding_Ratio <- plot_ly(
  type = "table",
  header = list(
    values = names(Riding_Table_Ratio),
    align = "left",
    fill = list(color = "lightgrey"),
    font = list(weight = "bold")
  ),
  cells = list(
    values = t(as.matrix(Riding_Table_Ratio)),
    align = "left"
  )
)

Riding_Ratio


## Plot 4: CMA Table (Top 10, Minimum Tagalog & Ilocano Population >= 1000)

#Similar process as bove. Fortunately, from the CMA csv, "Ratio, Ilocano-Tagalog" and "Sum (Tagalog + Ilocano)" are
#already both of numeric type.

typeof(CMA_Data$`Ratio, Ilocano-Tagalog`)

typeof(CMA_Data$`Sum (Tagalog + Ilocano)`)

CMA_Data_filtered <- CMA_Data[, c("CMA", 
                                  "Provinces/Territories", 
                                  "Sum (Tagalog + Ilocano)", 
                                  "Ratio, Ilocano-Tagalog")]

CMA_Data_filtered <- CMA_Data_filtered %>%
  filter(`Sum (Tagalog + Ilocano)` >= 1000)

CMA_Table_Ratio <- CMA_Data_filtered[order(-CMA_Data_filtered$"Ratio, Ilocano-Tagalog"), 
                                     c("CMA", "Provinces/Territories", "Ratio, Ilocano-Tagalog")][1:10, ]
CMA_Table_Ratio

# Convert to a plotly dataframe

CMA_Table_Ratio[] <- lapply(CMA_Table_Ratio, function(col) {
  if (is.character(col)) {
    Encoding(col) <- "UTF-8"
    iconv(col, from = "", to = "UTF-8", sub = "")
  } else {
    col
  }
})

CMA_Ratio <- plot_ly(
  type = "table",
  header = list(
    values = names(CMA_Table_Ratio),
    align = "left",
    fill = list(color = "lightgrey"),
    font = list(weight = "bold")
  ),
  cells = list(
    values = t(as.matrix(CMA_Table_Ratio)),
    align = "left"
  )
)


CMA_Ratio

############################################################################################################################

### PANEL 3: GROWTH RATES, 2006-2021 ###

## Plot 1: Choropleth Map by Province

#Step 1: Filter for rows where Language = Ilocano and Year=2006 and 2021
num_cols <- sapply(Growth_Data, is.numeric)
growth_row_num <- ((Growth_Data[1, num_cols] - Growth_Data[7, num_cols])/Growth_Data[7, num_cols])*100

#Step 2: Create new row filled with N/A values
growth_row <- Growth_Data[1, ]
growth_row[] <- NA

#Step 3: fill new row with num_cols values. num_cols is a logical variable which determines if a columns is numeric or not,
# which will make growth rate calculations much easier.
growth_row[num_cols] <- growth_row_num

Growth_Data <- rbind(Growth_Data, growth_row)

rownames(Growth_Data)[nrow(Growth_Data)] <- "Ilocano Growth Rate, 2006-2021"

#Step 4: Create new transposed table. The idea is to create a column of province/territory names to go with
#a griwth rate column in order to facilitate data merging with the shapefile.
Growth_Table <- as.data.frame(t(Growth_Data))

Growth_Table_New <- Growth_Table %>%
  slice(4:(n() - 10)) %>%       # drop first 3 and last 10 rows
  select(-(1:8))           # drop columns 1-8

Growth_Table_New$`Province/Territory` <- c("Newfoundland and Labrador","Prince Edward Island", 
                                           "Nova Scotia","New Brunswick",
                                           "Quebec","Ontario",
                                           "Manitoba","Saskatchewan",
                                           "Alberta","British Columbia",
                                           "Yukon","Northwest Territories",
                                           "Nunavut")


Growth_Table_New$`Ilocano Growth Rate, 2006-2021` <- as.numeric(Growth_Table_New$`Ilocano Growth Rate, 2006-2021`)
Growth_Table_New[Growth_Table_New == Inf] <- NA

#Step 5: Merge shapefile with csv file, joined through the names of the provinces and territories
my_sf_merged_2 <- my_sf %>%
  left_join(Growth_Table_New, by = c("PRENAME" = "Province/Territory"))


Map3 <- ggplot(my_sf_merged_2) +
  geom_sf(
    aes(
      fill = `Ilocano Growth Rate, 2006-2021`
    ),
    color = "white"
  ) +
  scale_fill_distiller(palette = "Blues", direction = 1, name = "Ilocano Growth Rate, 2006-2021") +
  labs(
    title = "Ilocano Growth Rate, 2006-2021",
    caption = "Source: Statistics Canada"
  ) +
  theme_gray() +
  theme(title = element_text(face = "bold"), legend.position = "bottom")

#########################################################


## Plots 2-18: Dual Axis Plot for National, Provincial, and City-Level Growth

#Setup:
#Line plots: Two lines representing raw number of Ilocano and Tagalog Speakers (2006, 2011, 2016, 2021 Censuses)
#Bar plots: Two bars for 2011, 2016, and 2021, representing 5-year growth rate for the Ilocano and Tagalog population.

# CANADA

#Step 1: Adjust year column
Growth_Data$Year <- c("2021", "2021",
                      "2016", "2016",
                      "2011", "2011",
                      "2006", "2006", "N/A")

Growth_Data_TimeSeries <- Growth_Data[-nrow(Growth_Data), ]


#Step 2: Pivot to wide format
wide_data_Canada <- Growth_Data_TimeSeries[, 1:3] %>%
  tidyr::pivot_wider(names_from = Language, values_from = "Canada") %>%
  arrange(Year)

#Step 3: Calculate growth rates
wide_data_Canada <- wide_data_Canada %>%
  mutate(
    Ilocano_growth = c(NA, diff(Ilocano) / lag(Ilocano)[-1] * 100),
    Tagalog_growth = c(NA, diff(Tagalog) / lag(Tagalog)[-1] * 100)
  )


#Step 4: Plot dual axis chart
Growth_Canada <- plot_ly(wide_data_Canada, x = ~Year) %>%
  add_bars(y = ~Ilocano_growth, name = "Ilocano Growth Rate", marker = list(color = '#91bad6'), yaxis = "y1") %>%
  add_bars(y = ~Tagalog_growth, name = "Tagalog Growth Rate", marker = list(color = '#f4b6b6'), yaxis = "y1") %>%
  add_lines(y = ~Ilocano, name = "Ilocano Count", line = list(color = '#1f77b4', width = 3), yaxis = "y2") %>%
  add_lines(y = ~Tagalog, name = "Tagalog Count", line = list(color = '#d62728', width = 3), yaxis = "y2") %>%
  layout(
    title = "Ilocano and Tagalog Language Trends in Canada",
    xaxis = list(title = "Year", type = "category"),
    yaxis = list(title = "Growth Rate (%)", side = "left", showgrid = FALSE),
    yaxis2 = list(title = "Raw Count (10,000)", overlaying = "y", side = "right", showgrid = FALSE),
    barmode = "group",
    legend = list(orientation = 'h', x = 0.1, y = 1.15),
    margin = list(t = 80)
  )

Growth_Canada

#Repeat for 6 most-populated provinces and 10 most-populated cities

# ONTARIO


#Pivot to wide format
wide_data_ON <- Growth_Data_TimeSeries[, c(1, 2, 9)] %>%
  tidyr::pivot_wider(names_from = Language, values_from = "Ontario") %>%
  arrange(Year)

#Calculate growth rates
wide_data_ON <- wide_data_ON %>%
  mutate(
    Ilocano_growth = c(NA, diff(Ilocano) / lag(Ilocano)[-1] * 100),
    Tagalog_growth = c(NA, diff(Tagalog) / lag(Tagalog)[-1] * 100)
  )


#Plot dual axis chart
Growth_ON <- plot_ly(wide_data_ON, x = ~Year) %>%
  add_bars(y = ~Ilocano_growth, name = "Ilocano Growth Rate", marker = list(color = '#91bad6'), yaxis = "y1") %>%
  add_bars(y = ~Tagalog_growth, name = "Tagalog Growth Rate", marker = list(color = '#f4b6b6'), yaxis = "y1") %>%
  add_lines(y = ~Ilocano, name = "Ilocano Count", line = list(color = '#1f77b4', width = 3), yaxis = "y2") %>%
  add_lines(y = ~Tagalog, name = "Tagalog Count", line = list(color = '#d62728', width = 3), yaxis = "y2") %>%
  layout(
    title = "Ilocano and Tagalog Language Trends in Ontario",
    xaxis = list(title = "Year", type = "category"),
    yaxis = list(title = "Growth Rate (%)", side = "left", showgrid = FALSE),
    yaxis2 = list(title = "Raw Count (10,000)", overlaying = "y", side = "right", showgrid = FALSE),
    barmode = "group",
    legend = list(orientation = 'h', x = 0.1, y = 1.15),
    margin = list(t = 80)
  )

Growth_ON

# QUEBEC


#Pivot to wide format
wide_data_QC <- Growth_Data_TimeSeries[, c(1, 2, 8)] %>%
  tidyr::pivot_wider(names_from = Language, values_from = "Quebec") %>%
  arrange(Year)

#Calculate growth rates
wide_data_QC <- wide_data_QC %>%
  mutate(
    Ilocano_growth = c(NA, diff(Ilocano) / lag(Ilocano)[-1] * 100),
    Tagalog_growth = c(NA, diff(Tagalog) / lag(Tagalog)[-1] * 100)
  )


#Plot dual axis chart
Growth_QC <- plot_ly(wide_data_QC, x = ~Year) %>%
  add_bars(y = ~Ilocano_growth, name = "Ilocano Growth Rate", marker = list(color = '#91bad6'), yaxis = "y1") %>%
  add_bars(y = ~Tagalog_growth, name = "Tagalog Growth Rate", marker = list(color = '#f4b6b6'), yaxis = "y1") %>%
  add_lines(y = ~Ilocano, name = "Ilocano Count", line = list(color = '#1f77b4', width = 3), yaxis = "y2") %>%
  add_lines(y = ~Tagalog, name = "Tagalog Count", line = list(color = '#d62728', width = 3), yaxis = "y2") %>%
  layout(
    title = "Ilocano and Tagalog Language Trends in Quebec",
    xaxis = list(title = "Year", type = "category"),
    yaxis = list(title = "Growth Rate (%)", side = "left", showgrid = FALSE),
    yaxis2 = list(title = "Raw Count (10,000)", overlaying = "y", side = "right", showgrid = FALSE),
    barmode = "group",
    legend = list(orientation = 'h', x = 0.1, y = 1.15),
    margin = list(t = 80)
  )

Growth_QC


# BRITISH COLUMBIA

#Pivot to wide format
wide_data_BC <- Growth_Data_TimeSeries[, c(1, 2, 13)] %>%
  tidyr::pivot_wider(names_from = Language, values_from = "British Columbia") %>%
  arrange(Year)

#Calculate growth rates
wide_data_BC <- wide_data_BC %>%
  mutate(
    Ilocano_growth = c(NA, diff(Ilocano) / lag(Ilocano)[-1] * 100),
    Tagalog_growth = c(NA, diff(Tagalog) / lag(Tagalog)[-1] * 100)
  )


#Plot dual axis chart
Growth_BC <- plot_ly(wide_data_BC, x = ~Year) %>%
  add_bars(y = ~Ilocano_growth, name = "Ilocano Growth Rate", marker = list(color = '#91bad6'), yaxis = "y1") %>%
  add_bars(y = ~Tagalog_growth, name = "Tagalog Growth Rate", marker = list(color = '#f4b6b6'), yaxis = "y1") %>%
  add_lines(y = ~Ilocano, name = "Ilocano Count", line = list(color = '#1f77b4', width = 3), yaxis = "y2") %>%
  add_lines(y = ~Tagalog, name = "Tagalog Count", line = list(color = '#d62728', width = 3), yaxis = "y2") %>%
  layout(
    title = "Ilocano and Tagalog Language Trends in British Columbia",
    xaxis = list(title = "Year", type = "category"),
    yaxis = list(title = "Growth Rate (%)", side = "left", showgrid = FALSE),
    yaxis2 = list(title = "Raw Count (10,000)", overlaying = "y", side = "right", showgrid = FALSE),
    barmode = "group",
    legend = list(orientation = 'h', x = 0.1, y = 1.15),
    margin = list(t = 80)
  )

Growth_BC

# ALBERTA

#Pivot to wide format
wide_data_AB <- Growth_Data_TimeSeries[, c(1, 2, 12)] %>%
  tidyr::pivot_wider(names_from = Language, values_from = "Alberta") %>%
  arrange(Year)

#Calculate growth rates
wide_data_AB <- wide_data_AB %>%
  mutate(
    Ilocano_growth = c(NA, diff(Ilocano) / lag(Ilocano)[-1] * 100),
    Tagalog_growth = c(NA, diff(Tagalog) / lag(Tagalog)[-1] * 100)
  )


#Plot dual axis chart
Growth_AB <- plot_ly(wide_data_AB, x = ~Year) %>%
  add_bars(y = ~Ilocano_growth, name = "Ilocano Growth Rate", marker = list(color = '#91bad6'), yaxis = "y1") %>%
  add_bars(y = ~Tagalog_growth, name = "Tagalog Growth Rate", marker = list(color = '#f4b6b6'), yaxis = "y1") %>%
  add_lines(y = ~Ilocano, name = "Ilocano Count", line = list(color = '#1f77b4', width = 3), yaxis = "y2") %>%
  add_lines(y = ~Tagalog, name = "Tagalog Count", line = list(color = '#d62728', width = 3), yaxis = "y2") %>%
  layout(
    title = "Ilocano and Tagalog Language Trends in Alberta",
    xaxis = list(title = "Year", type = "category"),
    yaxis = list(title = "Growth Rate (%)", side = "left", showgrid = FALSE),
    yaxis2 = list(title = "Raw Count (10,000)", overlaying = "y", side = "right", showgrid = FALSE),
    barmode = "group",
    legend = list(orientation = 'h', x = 0.1, y = 1.15),
    margin = list(t = 80)
  )

Growth_AB

# MANITOBA

#Pivot to wide format
wide_data_MB <- Growth_Data_TimeSeries[, c(1, 2, 10)] %>%
  tidyr::pivot_wider(names_from = Language, values_from = "Manitoba") %>%
  arrange(Year)

#Calculate growth rates
wide_data_MB <- wide_data_MB %>%
  mutate(
    Ilocano_growth = c(NA, diff(Ilocano) / lag(Ilocano)[-1] * 100),
    Tagalog_growth = c(NA, diff(Tagalog) / lag(Tagalog)[-1] * 100)
  )


#Plot dual axis chart
Growth_MB <- plot_ly(wide_data_MB, x = ~Year) %>%
  add_bars(y = ~Ilocano_growth, name = "Ilocano Growth Rate", marker = list(color = '#91bad6'), yaxis = "y1") %>%
  add_bars(y = ~Tagalog_growth, name = "Tagalog Growth Rate", marker = list(color = '#f4b6b6'), yaxis = "y1") %>%
  add_lines(y = ~Ilocano, name = "Ilocano Count", line = list(color = '#1f77b4', width = 3), yaxis = "y2") %>%
  add_lines(y = ~Tagalog, name = "Tagalog Count", line = list(color = '#d62728', width = 3), yaxis = "y2") %>%
  layout(
    title = "Ilocano and Tagalog Language Trends in Manitoba",
    xaxis = list(title = "Year", type = "category"),
    yaxis = list(title = "Growth Rate (%)", side = "left", showgrid = FALSE),
    yaxis2 = list(title = "Raw Count (10,000)", overlaying = "y", side = "right", showgrid = FALSE),
    barmode = "group",
    legend = list(orientation = 'h', x = 0.1, y = 1.15),
    margin = list(t = 80)
  )

Growth_MB

# SASKATCHEWAN

#Pivot to wide format
wide_data_SK <- Growth_Data_TimeSeries[, c(1, 2, 11)] %>%
  tidyr::pivot_wider(names_from = Language, values_from = "Saskatchewan") %>%
  arrange(Year)

#Calculate growth rates
wide_data_SK <- wide_data_SK %>%
  mutate(
    Ilocano_growth = c(NA, diff(Ilocano) / lag(Ilocano)[-1] * 100),
    Tagalog_growth = c(NA, diff(Tagalog) / lag(Tagalog)[-1] * 100)
  )


#Plot dual axis chart
Growth_SK <- plot_ly(wide_data_SK, x = ~Year) %>%
  add_bars(y = ~Ilocano_growth, name = "Ilocano Growth Rate", marker = list(color = '#91bad6'), yaxis = "y1") %>%
  add_bars(y = ~Tagalog_growth, name = "Tagalog Growth Rate", marker = list(color = '#f4b6b6'), yaxis = "y1") %>%
  add_lines(y = ~Ilocano, name = "Ilocano Count", line = list(color = '#1f77b4', width = 3), yaxis = "y2") %>%
  add_lines(y = ~Tagalog, name = "Tagalog Count", line = list(color = '#d62728', width = 3), yaxis = "y2") %>%
  layout(
    title = "Ilocano and Tagalog Language Trends in Saskatchewan",
    xaxis = list(title = "Year", type = "category"),
    yaxis = list(title = "Growth Rate (%)", side = "left", showgrid = FALSE),
    yaxis2 = list(title = "Raw Count (10,000)", overlaying = "y", side = "right", showgrid = FALSE),
    barmode = "group",
    legend = list(orientation = 'h', x = 0.1, y = 1.15),
    margin = list(t = 80)
  )

Growth_SK

# TORONTO

#Pivot to wide format
wide_data_Toronto <- Growth_Data_TimeSeries[, c(1, 2, 17)] %>%
  tidyr::pivot_wider(names_from = Language, values_from = "Toronto") %>%
  arrange(Year)

#Calculate growth rates
wide_data_Toronto <- wide_data_Toronto %>%
  mutate(
    Ilocano_growth = c(NA, diff(Ilocano) / lag(Ilocano)[-1] * 100),
    Tagalog_growth = c(NA, diff(Tagalog) / lag(Tagalog)[-1] * 100)
  )


#Plot dual axis chart
Growth_Toronto <- plot_ly(wide_data_Toronto, x = ~Year) %>%
  add_bars(y = ~Ilocano_growth, name = "Ilocano Growth Rate", marker = list(color = '#91bad6'), yaxis = "y1") %>%
  add_bars(y = ~Tagalog_growth, name = "Tagalog Growth Rate", marker = list(color = '#f4b6b6'), yaxis = "y1") %>%
  add_lines(y = ~Ilocano, name = "Ilocano Count", line = list(color = '#1f77b4', width = 3), yaxis = "y2") %>%
  add_lines(y = ~Tagalog, name = "Tagalog Count", line = list(color = '#d62728', width = 3), yaxis = "y2") %>%
  layout(
    title = "Ilocano and Tagalog Language Trends in Toronto",
    xaxis = list(title = "Year", type = "category"),
    yaxis = list(title = "Growth Rate (%)", side = "left", showgrid = FALSE),
    yaxis2 = list(title = "Raw Count (10,000)", overlaying = "y", side = "right", showgrid = FALSE),
    barmode = "group",
    legend = list(orientation = 'h', x = 0.1, y = 1.15),
    margin = list(t = 80)
  )

Growth_Toronto

# MONTREAL

#Pivot to wide format
wide_data_Montreal <- Growth_Data_TimeSeries[, c(1, 2, 18)] %>%
  tidyr::pivot_wider(names_from = Language, values_from = "Montreal") %>%
  arrange(Year)

#Calculate growth rates
wide_data_Montreal <- wide_data_Montreal %>%
  mutate(
    Ilocano_growth = c(NA, diff(Ilocano) / lag(Ilocano)[-1] * 100),
    Tagalog_growth = c(NA, diff(Tagalog) / lag(Tagalog)[-1] * 100)
  )


#Plot dual axis chart
Growth_Montreal <- plot_ly(wide_data_Montreal, x = ~Year) %>%
  add_bars(y = ~Ilocano_growth, name = "Ilocano Growth Rate", marker = list(color = '#91bad6'), yaxis = "y1") %>%
  add_bars(y = ~Tagalog_growth, name = "Tagalog Growth Rate", marker = list(color = '#f4b6b6'), yaxis = "y1") %>%
  add_lines(y = ~Ilocano, name = "Ilocano Count", line = list(color = '#1f77b4', width = 3), yaxis = "y2") %>%
  add_lines(y = ~Tagalog, name = "Tagalog Count", line = list(color = '#d62728', width = 3), yaxis = "y2") %>%
  layout(
    title = "Ilocano and Tagalog Language Trends in Montreal",
    xaxis = list(title = "Year", type = "category"),
    yaxis = list(title = "Growth Rate (%)", side = "left", showgrid = FALSE),
    yaxis2 = list(title = "Raw Count (10,000)", overlaying = "y", side = "right", showgrid = FALSE),
    barmode = "group",
    legend = list(orientation = 'h', x = 0.1, y = 1.15),
    margin = list(t = 80)
  )

Growth_Montreal

# CALGARY

#Pivot to wide format
wide_data_Calgary <- Growth_Data_TimeSeries[, c(1, 2, 19)] %>%
  tidyr::pivot_wider(names_from = Language, values_from = "Calgary") %>%
  arrange(Year)

#Calculate growth rates
wide_data_Calgary <- wide_data_Calgary %>%
  mutate(
    Ilocano_growth = c(NA, diff(Ilocano) / lag(Ilocano)[-1] * 100),
    Tagalog_growth = c(NA, diff(Tagalog) / lag(Tagalog)[-1] * 100)
  )


#Plot dual axis chart
Growth_Calgary <- plot_ly(wide_data_Calgary, x = ~Year) %>%
  add_bars(y = ~Ilocano_growth, name = "Ilocano Growth Rate", marker = list(color = '#91bad6'), yaxis = "y1") %>%
  add_bars(y = ~Tagalog_growth, name = "Tagalog Growth Rate", marker = list(color = '#f4b6b6'), yaxis = "y1") %>%
  add_lines(y = ~Ilocano, name = "Ilocano Count", line = list(color = '#1f77b4', width = 3), yaxis = "y2") %>%
  add_lines(y = ~Tagalog, name = "Tagalog Count", line = list(color = '#d62728', width = 3), yaxis = "y2") %>%
  layout(
    title = "Ilocano and Tagalog Language Trends in Calgary",
    xaxis = list(title = "Year", type = "category"),
    yaxis = list(title = "Growth Rate (%)", side = "left", showgrid = FALSE),
    yaxis2 = list(title = "Raw Count (10,000)", overlaying = "y", side = "right", showgrid = FALSE),
    barmode = "group",
    legend = list(orientation = 'h', x = 0.1, y = 1.15),
    margin = list(t = 80)
  )

Growth_Calgary

# OTTAWA

#Pivot to wide format
wide_data_Ottawa <- Growth_Data_TimeSeries[, c(1, 2, 20)] %>%
  tidyr::pivot_wider(names_from = Language, values_from = "Ottawa") %>%
  arrange(Year)

#Calculate growth rates
wide_data_Ottawa <- wide_data_Ottawa %>%
  mutate(
    Ilocano_growth = c(NA, diff(Ilocano) / lag(Ilocano)[-1] * 100),
    Tagalog_growth = c(NA, diff(Tagalog) / lag(Tagalog)[-1] * 100)
  )


#Plot dual axis chart
Growth_Ottawa <- plot_ly(wide_data_Ottawa, x = ~Year) %>%
  add_bars(y = ~Ilocano_growth, name = "Ilocano Growth Rate", marker = list(color = '#91bad6'), yaxis = "y1") %>%
  add_bars(y = ~Tagalog_growth, name = "Tagalog Growth Rate", marker = list(color = '#f4b6b6'), yaxis = "y1") %>%
  add_lines(y = ~Ilocano, name = "Ilocano Count", line = list(color = '#1f77b4', width = 3), yaxis = "y2") %>%
  add_lines(y = ~Tagalog, name = "Tagalog Count", line = list(color = '#d62728', width = 3), yaxis = "y2") %>%
  layout(
    title = "Ilocano and Tagalog Language Trends in Ottawa",
    xaxis = list(title = "Year", type = "category"),
    yaxis = list(title = "Growth Rate (%)", side = "left", showgrid = FALSE),
    yaxis2 = list(title = "Raw Count (10,000)", overlaying = "y", side = "right", showgrid = FALSE),
    barmode = "group",
    legend = list(orientation = 'h', x = 0.1, y = 1.15),
    margin = list(t = 80)
  )

Growth_Ottawa

# EDMONTON

#Pivot to wide format
wide_data_Edmonton <- Growth_Data_TimeSeries[, c(1, 2, 21)] %>%
  tidyr::pivot_wider(names_from = Language, values_from = "Edmonton") %>%
  arrange(Year)

#Calculate growth rates
wide_data_Edmonton <- wide_data_Edmonton %>%
  mutate(
    Ilocano_growth = c(NA, diff(Ilocano) / lag(Ilocano)[-1] * 100),
    Tagalog_growth = c(NA, diff(Tagalog) / lag(Tagalog)[-1] * 100)
  )


#Plot dual axis chart
Growth_Edmonton <- plot_ly(wide_data_Edmonton, x = ~Year) %>%
  add_bars(y = ~Ilocano_growth, name = "Ilocano Growth Rate", marker = list(color = '#91bad6'), yaxis = "y1") %>%
  add_bars(y = ~Tagalog_growth, name = "Tagalog Growth Rate", marker = list(color = '#f4b6b6'), yaxis = "y1") %>%
  add_lines(y = ~Ilocano, name = "Ilocano Count", line = list(color = '#1f77b4', width = 3), yaxis = "y2") %>%
  add_lines(y = ~Tagalog, name = "Tagalog Count", line = list(color = '#d62728', width = 3), yaxis = "y2") %>%
  layout(
    title = "Ilocano and Tagalog Language Trends in Edmonton",
    xaxis = list(title = "Year", type = "category"),
    yaxis = list(title = "Growth Rate (%)", side = "left", showgrid = FALSE),
    yaxis2 = list(title = "Raw Count (10,000)", overlaying = "y", side = "right", showgrid = FALSE),
    barmode = "group",
    legend = list(orientation = 'h', x = 0.1, y = 1.15),
    margin = list(t = 80)
  )

Growth_Edmonton

# WINNIPEG

#Pivot to wide format
wide_data_Winnipeg <- Growth_Data_TimeSeries[, c(1, 2, 22)] %>%
  tidyr::pivot_wider(names_from = Language, values_from = "Winnipeg") %>%
  arrange(Year)

#Calculate growth rates
wide_data_Winnipeg <- wide_data_Winnipeg %>%
  mutate(
    Ilocano_growth = c(NA, diff(Ilocano) / lag(Ilocano)[-1] * 100),
    Tagalog_growth = c(NA, diff(Tagalog) / lag(Tagalog)[-1] * 100)
  )


#Plot dual axis chart
Growth_Winnipeg <- plot_ly(wide_data_Winnipeg, x = ~Year) %>%
  add_bars(y = ~Ilocano_growth, name = "Ilocano Growth Rate", marker = list(color = '#91bad6'), yaxis = "y1") %>%
  add_bars(y = ~Tagalog_growth, name = "Tagalog Growth Rate", marker = list(color = '#f4b6b6'), yaxis = "y1") %>%
  add_lines(y = ~Ilocano, name = "Ilocano Count", line = list(color = '#1f77b4', width = 3), yaxis = "y2") %>%
  add_lines(y = ~Tagalog, name = "Tagalog Count", line = list(color = '#d62728', width = 3), yaxis = "y2") %>%
  layout(
    title = "Ilocano and Tagalog Language Trends in Winnipeg",
    xaxis = list(title = "Year", type = "category"),
    yaxis = list(title = "Growth Rate (%)", side = "left", showgrid = FALSE),
    yaxis2 = list(title = "Raw Count (10,000)", overlaying = "y", side = "right", showgrid = FALSE),
    barmode = "group",
    legend = list(orientation = 'h', x = 0.1, y = 1.15),
    margin = list(t = 80)
  )

Growth_Winnipeg

# MISSISSAUGA

#Pivot to wide format
wide_data_Mississauga <- Growth_Data_TimeSeries[, c(1, 2, 23)] %>%
  tidyr::pivot_wider(names_from = Language, values_from = "Mississauga") %>%
  arrange(Year)

#Calculate growth rates
wide_data_Mississauga <- wide_data_Mississauga %>%
  mutate(
    Ilocano_growth = c(NA, diff(Ilocano) / lag(Ilocano)[-1] * 100),
    Tagalog_growth = c(NA, diff(Tagalog) / lag(Tagalog)[-1] * 100)
  )


#Plot dual axis chart
Growth_Mississauga <- plot_ly(wide_data_Mississauga, x = ~Year) %>%
  add_bars(y = ~Ilocano_growth, name = "Ilocano Growth Rate", marker = list(color = '#91bad6'), yaxis = "y1") %>%
  add_bars(y = ~Tagalog_growth, name = "Tagalog Growth Rate", marker = list(color = '#f4b6b6'), yaxis = "y1") %>%
  add_lines(y = ~Ilocano, name = "Ilocano Count", line = list(color = '#1f77b4', width = 3), yaxis = "y2") %>%
  add_lines(y = ~Tagalog, name = "Tagalog Count", line = list(color = '#d62728', width = 3), yaxis = "y2") %>%
  layout(
    title = "Ilocano and Tagalog Language Trends in Mississauga",
    xaxis = list(title = "Year", type = "category"),
    yaxis = list(title = "Growth Rate (%)", side = "left", showgrid = FALSE),
    yaxis2 = list(title = "Raw Count (10,000)", overlaying = "y", side = "right", showgrid = FALSE),
    barmode = "group",
    legend = list(orientation = 'h', x = 0.1, y = 1.15),
    margin = list(t = 80)
  )

Growth_Mississauga

# VANCOUVER

#Pivot to wide format
wide_data_Vancouver <- Growth_Data_TimeSeries[, c(1, 2, 24)] %>%
  tidyr::pivot_wider(names_from = Language, values_from = "Vancouver") %>%
  arrange(Year)

#Calculate growth rates
wide_data_Vancouver <- wide_data_Vancouver %>%
  mutate(
    Ilocano_growth = c(NA, diff(Ilocano) / lag(Ilocano)[-1] * 100),
    Tagalog_growth = c(NA, diff(Tagalog) / lag(Tagalog)[-1] * 100)
  )


#Plot dual axis chart
Growth_Vancouver <- plot_ly(wide_data_Vancouver, x = ~Year) %>%
  add_bars(y = ~Ilocano_growth, name = "Ilocano Growth Rate", marker = list(color = '#91bad6'), yaxis = "y1") %>%
  add_bars(y = ~Tagalog_growth, name = "Tagalog Growth Rate", marker = list(color = '#f4b6b6'), yaxis = "y1") %>%
  add_lines(y = ~Ilocano, name = "Ilocano Count", line = list(color = '#1f77b4', width = 3), yaxis = "y2") %>%
  add_lines(y = ~Tagalog, name = "Tagalog Count", line = list(color = '#d62728', width = 3), yaxis = "y2") %>%
  layout(
    title = "Ilocano and Tagalog Language Trends in Vancouver",
    xaxis = list(title = "Year", type = "category"),
    yaxis = list(title = "Growth Rate (%)", side = "left", showgrid = FALSE),
    yaxis2 = list(title = "Raw Count (10,000)", overlaying = "y", side = "right", showgrid = FALSE),
    barmode = "group",
    legend = list(orientation = 'h', x = 0.1, y = 1.15),
    margin = list(t = 80)
  )

Growth_Vancouver

# BRAMPTON

#Pivot to wide format
wide_data_Brampton <- Growth_Data_TimeSeries[, c(1, 2, 25)] %>%
  tidyr::pivot_wider(names_from = Language, values_from = "Brampton") %>%
  arrange(Year)

#Calculate growth rates
wide_data_Brampton <- wide_data_Brampton %>%
  mutate(
    Ilocano_growth = c(NA, diff(Ilocano) / lag(Ilocano)[-1] * 100),
    Tagalog_growth = c(NA, diff(Tagalog) / lag(Tagalog)[-1] * 100)
  )


#Plot dual axis chart
Growth_Brampton <- plot_ly(wide_data_Brampton, x = ~Year) %>%
  add_bars(y = ~Ilocano_growth, name = "Ilocano Growth Rate", marker = list(color = '#91bad6'), yaxis = "y1") %>%
  add_bars(y = ~Tagalog_growth, name = "Tagalog Growth Rate", marker = list(color = '#f4b6b6'), yaxis = "y1") %>%
  add_lines(y = ~Ilocano, name = "Ilocano Count", line = list(color = '#1f77b4', width = 3), yaxis = "y2") %>%
  add_lines(y = ~Tagalog, name = "Tagalog Count", line = list(color = '#d62728', width = 3), yaxis = "y2") %>%
  layout(
    title = "Ilocano and Tagalog Language Trends in Brampton",
    xaxis = list(title = "Year", type = "category"),
    yaxis = list(title = "Growth Rate (%)", side = "left", showgrid = FALSE),
    yaxis2 = list(title = "Raw Count (10,000)", overlaying = "y", side = "right", showgrid = FALSE),
    barmode = "group",
    legend = list(orientation = 'h', x = 0.1, y = 1.15),
    margin = list(t = 80)
  )

Growth_Brampton

# HAMILTON

#Pivot to wide format
wide_data_Hamilton <- Growth_Data_TimeSeries[, c(1, 2, 26)] %>%
  tidyr::pivot_wider(names_from = Language, values_from = "Hamilton") %>%
  arrange(Year)

#Calculate growth rates
wide_data_Hamilton <- wide_data_Hamilton %>%
  mutate(
    Ilocano_growth = c(NA, diff(Ilocano) / lag(Ilocano)[-1] * 100),
    Tagalog_growth = c(NA, diff(Tagalog) / lag(Tagalog)[-1] * 100)
  )


#Plot dual axis chart
Growth_Hamilton <- plot_ly(wide_data_Hamilton, x = ~Year) %>%
  add_bars(y = ~Ilocano_growth, name = "Ilocano Growth Rate", marker = list(color = '#91bad6'), yaxis = "y1") %>%
  add_bars(y = ~Tagalog_growth, name = "Tagalog Growth Rate", marker = list(color = '#f4b6b6'), yaxis = "y1") %>%
  add_lines(y = ~Ilocano, name = "Ilocano Count", line = list(color = '#1f77b4', width = 3), yaxis = "y2") %>%
  add_lines(y = ~Tagalog, name = "Tagalog Count", line = list(color = '#d62728', width = 3), yaxis = "y2") %>%
  layout(
    title = "Ilocano and Tagalog Language Trends in Hamilton",
    xaxis = list(title = "Year", type = "category"),
    yaxis = list(title = "Growth Rate (%)", side = "left", showgrid = FALSE),
    yaxis2 = list(title = "Raw Count (10,000)", overlaying = "y", side = "right", showgrid = FALSE),
    barmode = "group",
    legend = list(orientation = 'h', x = 0.1, y = 1.15),
    margin = list(t = 80)
  )

Growth_Hamilton

############################################################################################################################

### PANEL 4: RIDING-LEVEL REGRESSION ANALYSIS: ILOCANO VS. OTHER LANGUAGE COMMUNITIES

## Plot 1: Versus Tagalog

# model1 is not necessary for the visualization, but is helpful for future statistical analyses.
model1 <- lm(`Ilocano per 100K` ~ `Tagalog per 100K`, data = Riding_Data)

#Visualization
LM1 <- ggplot(Riding_Data, aes(x = `Tagalog per 100K`, y = `Ilocano per 100K`)) +
  geom_point(aes(text = paste("Tagalog: ", `Tagalog per 100K`,
                              "<br>Ilocano: ", `Ilocano per 100K`)),
             color = "#1f77b4", alpha = 0.7, size = 3) +
  geom_smooth(method = "lm", se = TRUE, color = "#ff7f0e", linewidth = 1.5) +
  stat_poly_eq(
    aes(label = paste(..eq.label.., ..rr.label.., sep = "~~~")),
    formula = y ~ x, parse = TRUE, label.x = "left", label.y = "top"
  ) +
  labs(
    title = "Linear Regression, Ilocanos vs. Tagalog per Capita",
    x = "Tagalog Speakers per 100K",
    y = "Ilocano Speakers per 100K"
  ) +
  theme_minimal(base_size = 14)

LM1 <- ggplotly(LM1, tooltip = "text")

## Plot 2: Versus Cebuano

#Cebuano is the third most-spoken Philippine-based language in Canada
#This residual plot will visualize any potential interactions between ridings with higher
#per-capita populations of Ilocano and Cebuano speakers.
#Since Tagalog is a dominant language amongst the Filipino community, it has been added in this
#model to control for its potentially disproportionate effects on the relationships.

# Partial regression plot for CebuanoRate, controlling for TagalogRate

model2 <- lm(`Ilocano per 100K` ~ `Tagalog per 100K` + `Cebuano per 100K`, data = Riding_Data)

resid_y <- resid(lm(`Ilocano per 100K` ~ `Tagalog per 100K`, data = Riding_Data))
resid_x <- resid(lm(`Cebuano per 100K` ~ `Tagalog per 100K`, data = Riding_Data))

partial_df <- data.frame(Ilocano_resid = resid_y, Cebuano_resid = resid_x)

LM2 <- ggplot(partial_df, aes(
  x = Cebuano_resid,
  y = Ilocano_resid
)) +
  geom_point(aes(
    text = paste0(
      "Cebuano resid: ", round(Cebuano_resid, 2), "\n",
      "Ilocano resid: ", round(Ilocano_resid, 2)
    )
  ), color = "#0072B2", size = 2.5, alpha = 0.7) +
  geom_smooth(method = "lm", se = TRUE, color = "#D55E00") +
  labs(
    title = "Partial Regression Plot for Cebuano Rate",
    x = "Cebuano Rate Residuals (controlling for Tagalog Rate)",
    y = "Ilocano Rate Residuals (controlling for Tagalog Rate)"
  ) +
  theme_minimal(base_size = 14)

LM2 <- ggplotly(LM2, tooltip = "text")


## Plots 3-7: Versus Mandarin, Punjabi, Cantonese, Spanish, Arabic

# The 5 aforementioned languages are the most spoken non-official languages (i.e., not English nor French)
#in Canada based on mother tongue.
# Similar to the previous plot, these residual plots will visualize any potential interactions between ridings with higher
#per-capita populations of Ilocano speakers and speakers of each of the 5 languages.
#Just like with the previous plot, TagalogRate has been added to each model for the exact same reason.

# Partial regression plot for Mandarin Rate, controlling for TagalogRate

model3 <- lm(`Ilocano per 100K` ~ `Tagalog per 100K` + `Mandarin per 100K`, data = Riding_Data)

resid_x <- resid(lm(`Mandarin per 100K` ~ `Tagalog per 100K`, data = Riding_Data))
partial_df <- data.frame(Ilocano_resid = resid_y, Mandarin_resid = resid_x)

LM3 <- ggplot(partial_df, aes(
  x = Mandarin_resid,
  y = Ilocano_resid
)) +
  geom_point(aes(
    text = paste0(
      "Mandarin resid: ", round(Mandarin_resid, 2), "\n",
      "Ilocano resid: ", round(Ilocano_resid, 2)
    )
  ), color = "#0072B2", size = 2.5, alpha = 0.7) +
  geom_smooth(method = "lm", se = TRUE, color = "#D55E00") +
  labs(
    title = "Partial Regression Plot for Mandarin Rate",
    x = "Mandarin Rate Residuals (controlling for Tagalog Rate)",
    y = "Ilocano Rate Residuals (controlling for Tagalog Rate)"
  ) +
  theme_minimal(base_size = 14)

LM3 <- ggplotly(LM3, tooltip = "text")


# Partial regression plot for Punjabi Rate, controlling for TagalogRate

model4 <- lm(`Ilocano per 100K` ~ `Tagalog per 100K` + `Punjabi per 100K`, data = Riding_Data)

resid_x <- resid(lm(`Punjabi per 100K` ~ `Tagalog per 100K`, data = Riding_Data))
partial_df <- data.frame(Ilocano_resid = resid_y, Punjabi_resid = resid_x)

LM4 <- ggplot(partial_df, aes(
  x = Punjabi_resid,
  y = Ilocano_resid
)) +
  geom_point(aes(
    text = paste0(
      "Punjabi resid: ", round(Punjabi_resid, 2), "\n",
      "Ilocano resid: ", round(Ilocano_resid, 2)
    )
  ), color = "#0072B2", size = 2.5, alpha = 0.7) +
  geom_smooth(method = "lm", se = TRUE, color = "#D55E00") +
  labs(
    title = "Partial Regression Plot for Punjabi Rate",
    x = "Punjabi Rate Residuals (controlling for Tagalog Rate)",
    y = "Ilocano Rate Residuals (controlling for Tagalog Rate)"
  ) +
  theme_minimal(base_size = 14)

LM4 <- ggplotly(LM4, tooltip = "text")

# Partial regression plot for Cantonese Rate, controlling for TagalogRate

model5 <- lm(`Ilocano per 100K` ~ `Tagalog per 100K` + `Cantonese per 100K`, data = Riding_Data)

resid_x <- resid(lm(`Cantonese per 100K` ~ `Tagalog per 100K`, data = Riding_Data))
partial_df <- data.frame(Ilocano_resid = resid_y, Cantonese_resid = resid_x)

LM5 <- ggplot(partial_df, aes(
  x = Cantonese_resid,
  y = Ilocano_resid
)) +
  geom_point(aes(
    text = paste0(
      "Cantonese resid: ", round(Cantonese_resid, 2), "\n",
      "Ilocano resid: ", round(Ilocano_resid, 2)
    )
  ), color = "#0072B2", size = 2.5, alpha = 0.7) +
  geom_smooth(method = "lm", se = TRUE, color = "#D55E00") +
  labs(
    title = "Partial Regression Plot for Cantonese Rate",
    x = "Cantonese Rate Residuals (controlling for Tagalog Rate)",
    y = "Ilocano Rate Residuals (controlling for Tagalog Rate)"
  ) +
  theme_minimal(base_size = 14)

LM5 <- ggplotly(LM5, tooltip = "text")

# Partial regression plot for Spanish Rate, controlling for TagalogRate

model6 <- lm(`Ilocano per 100K` ~ `Tagalog per 100K` + `Spanish per 100K`, data = Riding_Data)

resid_x <- resid(lm(`Spanish per 100K` ~ `Tagalog per 100K`, data = Riding_Data))
partial_df <- data.frame(Ilocano_resid = resid_y, Spanish_resid = resid_x)

LM6 <- ggplot(partial_df, aes(
  x = Spanish_resid,
  y = Ilocano_resid
)) +
  geom_point(aes(
    text = paste0(
      "Spanish resid: ", round(Spanish_resid, 2), "\n",
      "Ilocano resid: ", round(Ilocano_resid, 2)
    )
  ), color = "#0072B2", size = 2.5, alpha = 0.7) +
  geom_smooth(method = "lm", se = TRUE, color = "#D55E00") +
  labs(
    title = "Partial Regression Plot for Spanish Rate",
    x = "Spanish Rate Residuals (controlling for Tagalog Rate)",
    y = "Ilocano Rate Residuals (controlling for Tagalog Rate)"
  ) +
  theme_minimal(base_size = 14)

LM6 <- ggplotly(LM6, tooltip = "text")

# Partial regression plot for Arabic Rate, controlling for TagalogRate

model7 <- lm(`Ilocano per 100K` ~ `Tagalog per 100K` + `Arabic per 100K`, data = Riding_Data)

resid_x <- resid(lm(`Arabic per 100K` ~ `Tagalog per 100K`, data = Riding_Data))
partial_df <- data.frame(Ilocano_resid = resid_y, Arabic_resid = resid_x)

LM7 <- ggplot(partial_df, aes(
  x = Arabic_resid,
  y = Ilocano_resid
)) +
  geom_point(aes(
    text = paste0(
      "Arabic resid: ", round(Arabic_resid, 2), "\n",
      "Ilocano resid: ", round(Ilocano_resid, 2)
    )
  ), color = "#0072B2", size = 2.5, alpha = 0.7) +
  geom_smooth(method = "lm", se = TRUE, color = "#D55E00") +
  labs(
    title = "Partial Regression Plot for Arabic Rate",
    x = "Arabic Rate Residuals (controlling for Tagalog Rate)",
    y = "Ilocano Rate Residuals (controlling for Tagalog Rate)"
  ) +
  theme_minimal(base_size = 14)

LM7 <- ggplotly(LM7, tooltip = "text")

############################################################################################################################
############################################################################################################################

#################################
## SHINY DASHBOARD DEPLOYMENT ##
#################################

### PANEL SET-UP ###

plot_list1 <- list("Top 10 Ridings" = Riding_100K, "Top 10 CMAs" = CMA_100K, "Choropleth Map-Ilocanos Per 100K" = Map1)
plot_list2 <- list("Ilocano vs. Tagalog Distribution" = Donut_Plot , "Choropleth Map-Ilocano-Tagalog Ratio" = Map2, 
                   "Top 10 Ridings, Ilocano-Tagalog Ratio (>=1000 Tagalog & Ilocanos)" = Riding_Ratio,
                   "Top 10 CMAs, Ilocano-Tagalog Ratio (>=1000 Tagalog & Ilocanos)" = CMA_Ratio)
plot_list3 <- list("Choropleth Map-Ilocano Growth Rate, 2006-2021" = Map3, "Tagalog and Ilocano Growth Trend-Canada" = Growth_Canada,
                   "Tagalog and Ilocano Growth Trend-Ontario" = Growth_ON,"Tagalog and Ilocano Growth Trend-Quebec" = Growth_QC,
                   "Tagalog and Ilocano Growth Trend-British Columbia" = Growth_BC,"Tagalog and Ilocano Growth Trend-Alberta" = Growth_AB,
                   "Tagalog and Ilocano Growth Trend-Manitoba" = Growth_MB,"Tagalog and Ilocano Growth Trend-Saskatchewan" = Growth_SK,
                   "Tagalog and Ilocano Growth Trend-Toronto" = Growth_Toronto,"Tagalog and Ilocano Growth Trend-Montreal" = Growth_Montreal,
                   "Tagalog and Ilocano Growth Trend-Calgary" = Growth_Calgary,"Tagalog and Ilocano Growth Trend-Ottawa" = Growth_Ottawa,
                   "Tagalog and Ilocano Growth Trend-Edmonton" = Growth_Edmonton,"Tagalog and Ilocano Growth Trend-Winnipeg" = Growth_Winnipeg,
                   "Tagalog and Ilocano Growth Trend-Mississauga" = Growth_Mississauga,"Tagalog and Ilocano Growth Trend-Vancouver" = Growth_Vancouver,
                   "Tagalog and Ilocano Growth Trend-Brampton" = Growth_Brampton,"Tagalog and Ilocano Growth Trend-Hamilton" = Growth_Hamilton)
plot_list4 <- list("Regression Model-Ilocano vs. Tagalog" = LM1, "Regression Model-Ilocano vs. Cebuano" = LM2,
                   "Regression Model-Ilocano vs. Mandarin" = LM3, "Regression Model-Ilocano vs. Punjabi" = LM4,
                   "Regression Model-Ilocano vs. Cantonese" = LM5, "Regression Model-Ilocano vs. Spanish" = LM6,
                   "Regression Model-Ilocano vs. Arabic" = LM7)

#=== UI ===

ui <- dashboardPage(
  dashboardHeader(title = "Ilocanos in Canada Dashboard"),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Per-Capita Visualizations", tabName = "panel1"),
      menuItem("Tagalog vs. Ilocano Comparisons", tabName = "panel2"),
      menuItem("Growth Visualizations", tabName = "panel3"),
      menuItem("Linear Regression Comparison", tabName = "panel4")
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "panel1",
              fluidRow(
                box(
                  title = "Select a Plot",
                  width = 12,
                  fill = TRUE,
                  selectInput("plot_choice1", "Choose Plot:", choices = names(plot_list1)),
                  uiOutput("panel1_plot_ui")
                )
              )
      ),
      tabItem(tabName = "panel2",
              fluidRow(
                box(
                  title = "Select a Plot",
                  width = 12,
                  fill = TRUE,
                  selectInput("plot_choice2", "Choose Plot:", choices = names(plot_list2)),
                  uiOutput("panel2_plot_ui")
                )
              )
      ),
      tabItem(tabName = "panel3",
              fluidRow(
                box(
                  title = "Select a Plot",
                  width = 12,
                  fill = TRUE,
                  selectInput("plot_choice3", "Choose Plot:", choices = names(plot_list3)),
                  uiOutput("panel3_plot_ui")
                )
              )
      ),
      tabItem(tabName = "panel4",
              fluidRow(
                box(
                  title = "Select a Plot",
                  width = 12,
                  fill = TRUE,
                  selectInput("plot_choice4", "Choose Plot:", choices = names(plot_list4)),
                  uiOutput("panel4_plot_ui")
                )
              )
      )
    )
  )
)

# === Server ===

server <- function(input, output, session) {
  
  # Panel 1
  observe({
    plot <- plot_list1[[input$plot_choice1]]
    if (inherits(plot, "ggplot")) {
      output$panel1_plot_ui <- renderUI({
        plotOutput("ggplot_output1", height = "600px", width = "100%")
      })
      output$ggplot_output1 <- renderPlot({ plot })
    } else {
      output$panel1_plot_ui <- renderUI({
        plotlyOutput("plotly_output1", height = "600px", width = "100%")
      })
      output$plotly_output1 <- renderPlotly({ plot })
    }
  })
  
  # Panel 2
  observe({
    plot <- plot_list2[[input$plot_choice2]]
    if (inherits(plot, "ggplot")) {
      output$panel2_plot_ui <- renderUI({
        plotOutput("ggplot_output2", height = "600px", width = "100%")
      })
      output$ggplot_output2 <- renderPlot({ plot })
    } else {
      output$panel2_plot_ui <- renderUI({
        plotlyOutput("plotly_output2", height = "600px", width = "100%")
      })
      output$plotly_output2 <- renderPlotly({ plot })
    }
  })
  
  # Panel 3
  observe({
    plot <- plot_list3[[input$plot_choice3]]
    if (inherits(plot, "ggplot")) {
      output$panel3_plot_ui <- renderUI({
        plotOutput("ggplot_output3", height = "600px", width = "100%")
      })
      output$ggplot_output3 <- renderPlot({ plot })
    } else {
      output$panel3_plot_ui <- renderUI({
        plotlyOutput("plotly_output3", height = "600px", width = "100%")
      })
      output$plotly_output3 <- renderPlotly({ plot })
    }
  })
  
  # Panel 4
  observe({
    plot <- plot_list4[[input$plot_choice4]]
    if (inherits(plot, "ggplot")) {
      output$panel4_plot_ui <- renderUI({
        plotOutput("ggplot_output4", height = "600px", width = "100%")
      })
      output$ggplot_output4 <- renderPlot({ plot })
    } else {
      output$panel4_plot_ui <- renderUI({
        plotlyOutput("plotly_output4", height = "600px", width = "100%")
      })
      output$plotly_output4 <- renderPlotly({ plot })
    }
  })
  
}

shinyApp(ui = ui, server = server)
