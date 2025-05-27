##########################
## INSTALL DEPENDENCIES ##
##########################

install.packages(c("DT", "dplyr", "readr"))
install.packages(c("ggplot2", "plotly"))
install.packages("sf")
install.packages("tidyr")
install.packages("ggpmisc")


library(DT)
library(dplyr)
library(readr)
library(ggplot2)
library(plotly)
library(sf)
library(tidyr)
library(ggpmisc)

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

# Data from Canada's 10 Largest Cities, 2021 Census
City_Data <- readr::read_csv("C:/Users/francali/Downloads/Ilocanos in Canada, Cities.csv")

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

## Plot 2: CMA Table (Top 10)

CMA_Table_100K <- CMA_Data[order(-CMA_Data$"Ilocano per 100K"), 
                           c("CMA", "Ilocano per 100K")][1:10, ]
CMA_Table_100K

## Plot 3: Choropleth Map of Provinces and Territories (Ilocanos per 100K)

#Step 1: Merge shapefile with provincial csv file, joined through the names of the provinces and territories
my_sf_merged <- my_sf %>%
  left_join(Province_Data, by = c("PRENAME" = "Province/Territory"))

#Step 2: Map, Ilocanos Per 100K

Map1 <- ggplot(my_sf_merged) +
  geom_sf(aes(fill = `Ilocano per 100K`), color='gray',data=my_sf_merged) +
  geom_sf(fill='transparent', color='white', data=my_sf_merged) +
  scale_fill_distiller(palette = "Blues", direction = 1, name = "Ilocanos per 100K") +
  labs(title='Ilocano Speakers Per 100K (2021)',
       caption=c('Source: Statistics Canada')) +
  theme_gray() +
  theme(title=element_text(face='bold'), legend.position='bottom')
Map1

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

#Step 4: Create donut chart
Donut_Plot <- ggplot(Distribution_long, aes(x = ring, y = Percentage, fill = Region)) +
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

Donut_Plot 


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
  geom_sf(aes(fill = `Ilocano Growth Rate, 2006-2021`), color='gray',data=my_sf_merged_2) +
  geom_sf(fill='transparent', color='white', data=my_sf_merged_2) +
  scale_fill_distiller(palette = "Blues", direction = 1, name = "Growth Rate of Ilocano Population, 2006-2021",
na.value = "lightgray")+
  labs(title='Growth Rate of Ilocano Speakers in Canada, 2006-2021',
       caption=c('Source: Statistics Canada')) +
  theme_gray() +
  theme(title=element_text(face='bold'), legend.position='bottom')
Map3

#########################################################


## Plots 2-18: Dual Axis Plot for National, Provincial, and City-Level Growth

#Setup:
#Line plots: Two lines representing raw number of Ilocano and Tagalog Speakers (2006, 2011, 2016, 2021 Censuses)
#Bar plots: Two bars for 2011, 2016, and 2021, representing 5-year growth rate for the Ilocano and Tagalog population.

# National-level

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
    yaxis = list(title = "Raw Count", side = "left", showgrid = FALSE),
    yaxis2 = list(title = "Growth Rate (%)", overlaying = "y", side = "right", showgrid = FALSE),
    barmode = "group",
    legend = list(orientation = 'h', x = 0.1, y = 1.15),
    margin = list(t = 80)
  )

#Repeat for 6 most-populated provinces and 10 most-populated cities



############################################################################################################################

### PANEL 4: RIDING-LEVEL REGRESSION ANALYSIS: ILOCANO VS. OTHER LANGUAGE COMMUNITIES

## Plot 1: Versus Tagalog

# model1 is not necessary for the visualization, but is helpful for future statistical analyses.
model1 <- lm(`Ilocano per 100K` ~ `Tagalog per 100K`, data = Riding_Data)

#Visualization
LM1 <- ggplot(Riding_Data, aes(x = `Tagalog per 100K`, y = `Ilocano per 100K`)) +
  geom_point(color = "#1f77b4", alpha = 0.7, size = 3) +  # scatter points
  geom_smooth(method = "lm", se = TRUE, color = "#ff7f0e", linewidth = 1.5) +  # regression line
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

LM1

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

partial_df <- data.frame(
  Ilocano_resid = resid_y,
  Cebuano_resid = resid_x
)

LM2 <-  ggplot(partial_df, aes(x = Cebuano_resid, y = Ilocano_resid)) +
  geom_point(color = "#0072B2", size = 2.5, alpha = 0.7) +
  geom_smooth(method = "lm", se = TRUE, color = "#D55E00", linetype = "solid") +
  labs(
    title = "Partial Regression Plot for CebuanoRate",
    x = "CebuanoRate Residuals (controlling for TagalogRate)",
    y = "IlocanoRate Residuals (controlling for TagalogRate)"
  ) +
  theme_minimal(base_size = 14)

LM2


## Plots 3-7: Versus Mandarin, Punjabi, Cantonese, Spanish, Arabic

# The 5 aforementioned languages are the most spoken non-official languages (i.e., not English nor French)
#in Canada based on mother tongue.
# Similar to the previous plot, these residual plots will visualize any potential interactions between ridings with higher
#per-capita populations of Ilocano speakers and speakers of each of the 5 languages.
#Just like with the previous plot, TagalogRate has been added to each model for the exact same reason.

# Partial regression plot for Mandarin Rate, controlling for TagalogRate

model3 <- lm(`Ilocano per 100K` ~ `Tagalog per 100K` + `Mandarin per 100K`, data = Riding_Data)


resid_y <- resid(lm(`Ilocano per 100K` ~ `Tagalog per 100K`, data = Riding_Data))
resid_x <- resid(lm(`Mandarin per 100K` ~ `Tagalog per 100K`, data = Riding_Data))

partial_df <- data.frame(
  Ilocano_resid = resid_y,
  Mandarin_resid = resid_x
)

LM3 <-  ggplot(partial_df, aes(x = Mandarin_resid, y = Ilocano_resid)) +
  geom_point(color = "#0072B2", size = 2.5, alpha = 0.7) +
  geom_smooth(method = "lm", se = TRUE, color = "#D55E00", linetype = "solid") +
  labs(
    title = "Partial Regression Plot for CebuanoRate",
    x = "MandarinRate Residuals (controlling for TagalogRate)",
    y = "IlocanoRate Residuals (controlling for TagalogRate)"
  ) +
  theme_minimal(base_size = 14)

LM3

lm(`Ilocano per 100K` ~ `Tagalog per 100K` + `Punjabi per 100K`, data = Riding_Data)

# Partial regression plot for Punjabi Rate, controlling for TagalogRate

model4 <- lm(`Ilocano per 100K` ~ `Tagalog per 100K` + `Punjabi per 100K`, data = Riding_Data)


resid_y <- resid(lm(`Ilocano per 100K` ~ `Tagalog per 100K`, data = Riding_Data))
resid_x <- resid(lm(`Punjabi per 100K` ~ `Tagalog per 100K`, data = Riding_Data))

partial_df <- data.frame(
  Ilocano_resid = resid_y,
  Punjabi_resid = resid_x
)

LM4 <-  ggplot(partial_df, aes(x = Punjabi_resid, y = Ilocano_resid)) +
  geom_point(color = "#0072B2", size = 2.5, alpha = 0.7) +
  geom_smooth(method = "lm", se = TRUE, color = "#D55E00", linetype = "solid") +
  labs(
    title = "Partial Regression Plot for CebuanoRate",
    x = "PunjabiRate Residuals (controlling for TagalogRate)",
    y = "IlocanoRate Residuals (controlling for TagalogRate)"
  ) +
  theme_minimal(base_size = 14)

LM4

# Partial regression plot for Cantonese Rate, controlling for TagalogRate

model5 <- lm(`Ilocano per 100K` ~ `Tagalog per 100K` + `Cantonese per 100K`, data = Riding_Data)


resid_y <- resid(lm(`Ilocano per 100K` ~ `Tagalog per 100K`, data = Riding_Data))
resid_x <- resid(lm(`Cantonese per 100K` ~ `Tagalog per 100K`, data = Riding_Data))

partial_df <- data.frame(
  Ilocano_resid = resid_y,
  Cantonese_resid = resid_x
)

LM5 <-  ggplot(partial_df, aes(x = Cantonese_resid, y = Ilocano_resid)) +
  geom_point(color = "#0072B2", size = 2.5, alpha = 0.7) +
  geom_smooth(method = "lm", se = TRUE, color = "#D55E00", linetype = "solid") +
  labs(
    title = "Partial Regression Plot for CebuanoRate",
    x = "CantoneseRate Residuals (controlling for TagalogRate)",
    y = "IlocanoRate Residuals (controlling for TagalogRate)"
  ) +
  theme_minimal(base_size = 14)

LM5

# Partial regression plot for Spanish Rate, controlling for TagalogRate

model6 <- lm(`Ilocano per 100K` ~ `Tagalog per 100K` + `Spanish per 100K`, data = Riding_Data)


resid_y <- resid(lm(`Ilocano per 100K` ~ `Tagalog per 100K`, data = Riding_Data))
resid_x <- resid(lm(`Spanish per 100K` ~ `Tagalog per 100K`, data = Riding_Data))

partial_df <- data.frame(
  Ilocano_resid = resid_y,
  Spanish_resid = resid_x
)

LM6 <-  ggplot(partial_df, aes(x = Spanish_resid, y = Ilocano_resid)) +
  geom_point(color = "#0072B2", size = 2.5, alpha = 0.7) +
  geom_smooth(method = "lm", se = TRUE, color = "#D55E00", linetype = "solid") +
  labs(
    title = "Partial Regression Plot for CebuanoRate",
    x = "SpanishRate Residuals (controlling for TagalogRate)",
    y = "IlocanoRate Residuals (controlling for TagalogRate)"
  ) +
  theme_minimal(base_size = 14)

LM6

# Partial regression plot for Arabic Rate, controlling for TagalogRate

model7 <- lm(`Ilocano per 100K` ~ `Tagalog per 100K` + `Arabic per 100K`, data = Riding_Data)


resid_y <- resid(lm(`Ilocano per 100K` ~ `Tagalog per 100K`, data = Riding_Data))
resid_x <- resid(lm(`Arabic per 100K` ~ `Tagalog per 100K`, data = Riding_Data))

partial_df <- data.frame(
  Ilocano_resid = resid_y,
  Arabic_resid = resid_x
)

LM7 <-  ggplot(partial_df, aes(x = Arabic_resid, y = Ilocano_resid)) +
  geom_point(color = "#0072B2", size = 2.5, alpha = 0.7) +
  geom_smooth(method = "lm", se = TRUE, color = "#D55E00", linetype = "solid") +
  labs(
    title = "Partial Regression Plot for CebuanoRate",
    x = "ArabicRate Residuals (controlling for TagalogRate)",
    y = "IlocanoRate Residuals (controlling for TagalogRate)"
  ) +
  theme_minimal(base_size = 14)

LM7



############################################################################################################################
############################################################################################################################

#################################
## SHINY DASHBOARD DEPLOYMENT ##
#################################

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
