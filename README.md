# ELECTIONS CANADA RESEARCH PROJECT: Ilocano Language Community in Canada Dashboard

# Table of Contents
* [Project Background](#project-background)
* [Data Structure and Initial Checks](#data-structure-and-initial-checks)
* [Executive Summary](#executive-summary)
* [Insights Deep Dive](#insights-deep-dive)
* [Recommendations](#recommendations)
* [Assumptions and Caveats](#assumptions-and-caveats)
* [Credits and Acknowledgements](#credits-and-acknowledgements)

---

# Project Background

Ilocanos constitute the third-largest ethnolinguistic group in the Philippines (source: 2020 Census of Population and Housing, Philippines), but the second-largest Philippine-based language community in Canada (behind Tagalog). As per the 2021 Canadian Census, an estimated 33,520 people identified Ilocano as their mother tongue, while 461,150 people identified Tagalog as their mother tongue. Cebuano was the third-largest Philippine-based language community in Canada (18,945). From a [previous project](https://github.com/Francis-Calingo/ELECTIONS-CANADA-RESEARCH-PROJECT-Filipino-Canadian-Demographic-Report/) that I did, also for Elections Canada, it was determined that Ilocano was the most-spoken secondary Philippine-based language (i.e., not Tagalog) in the majority of the then-338 federal ridings of Canada (since redistributed to 343 ridings in 2023):

<img src="https://github.com/Francis-Calingo/ELECTIONS-CANADA-RESEARCH-PROJECT-Ilocano-Speakers-Canada/blob/main/Figures/Overview/Figure0.1.jpg"/>

Ascertaining settlement patterns with regards to the Ilocano-speaking community will be very useful for Elections Canada in helping better understand the community itself and how their demographics play a role in their interactions with Canadian democracy. The fact that Ilocano is not a very commonly used language in digital environment, alongside the fact that Tagalog and English are the predominantly used languages int the Filipino Canadian community makes ascertaining settlement patterns and drawing actionable insights from that more difficult that the demographic research project executed for the general Filipino Canadian community. Therefore, unique methods will be employed to account for those considerations.

Insights and recommendations are provided on the following key areas:

- **Per-Capita Analysis** 
- **Categorical Data Analysis (Tagalog vs. Ilocano)** 
- **Time-Series Growth Analysis** 
- **Linear Regression Modelling (Ilocano vs. Other Language Communities)** 

**FINAL DELIVERABLE:** A dashboard visualization of the demographics of Ilocanos in Canada using R Shiny.

<img src="https://github.com/Francis-Calingo/ELECTIONS-CANADA-RESEARCH-PROJECT-Ilocano-Speakers-Canada/blob/main/GIFs/Panel1.gif"/>

<img src="https://github.com/Francis-Calingo/ELECTIONS-CANADA-RESEARCH-PROJECT-Ilocano-Speakers-Canada/blob/main/GIFs/Panel2.gif"/>

<img src="https://github.com/Francis-Calingo/ELECTIONS-CANADA-RESEARCH-PROJECT-Ilocano-Speakers-Canada/blob/main/GIFs/Panel3.gif"/>

<img src="https://github.com/Francis-Calingo/ELECTIONS-CANADA-RESEARCH-PROJECT-Ilocano-Speakers-Canada/blob/main/GIFs/Panel4.gif"/>

> GIFs made courtesy of ShareX app, version 17.1


The CSV files used for this project can be found in the next section. The following links are Statistics Canada sources where the data from the CSV files were extracted from:
* <a href="https://www12.statcan.gc.ca/census-recensement/2021/dp-pd/prof/index.cfm?Lang=E">Census Profile, 2021 Census of Population</a> 
* <a href="https://www12.statcan.gc.ca/census-recensement/2016/dp-pd/prof/index.cfm?Lang=E">Census Profile, 2016 Census of Population</a>
* <a href="https://www12.statcan.gc.ca/census-recensement/2011/dp-pd/prof/index.cfm?Lang=E">Census Profile, 2011 Census of Population</a>
* <a href="https://www12.statcan.gc.ca/census-recensement/2006/dp-pd/index-eng.cfm">Census Profile, 2006 Census of Population</a>
* <a href="https://www12.statcan.gc.ca/census-recensement/2021/geo/sip-pis/boundary-limites/index2021-eng.cfm?year=21">2021 Census – Boundary files</a> 

The following is the R Script used for the quantitative analysis portion of the reporting: [Link to see script](https://raw.githubusercontent.com/Francis-Calingo/ELECTIONS-CANADA-RESEARCH-PROJECT-Ilocano-Speakers-Canada/main/Ilocanos%20in%20Canada%20Dashboard.R)
* <b>IDEs Used:</b> RStudio
* <b>R Version:</b> 4.4.1
* <b>Libraries:</b> DT, dplyr, readr, ggplot2, plotly, sf, tidyr, ggpmisc, shiny, shinydashboard

If you'd like to fork or run this locally:

```bash
git clone https://github.com/Francis-Calingo/ELECTIONS-CANADA-RESEARCH-PROJECT-Ilocano-Speakers-Canada.git
cd ELECTIONS-CANADA-RESEARCH-PROJECT-Ilocano-Speakers-Canada
```

[<b>Back to Table of Contents</b>](#table-of-contents)

---

# Data Structure and Initial Checks

The following is the data structure for the csv files used for this project:

| Data Content  | Number of Entries (Records x Field) | Number of Records  | Number of Fields | Download File Link |
| ------------- | ------------- | ------------- | ------------- | ------------- |
| Ilocano Speakers in Canada, 13 Provinces and Territories, 10 Largest Cities (2006-2021 Censuses)  | **208**  | 8  | 26 | [Download]()  |
| Ilocano and Tagalog Speakers, Census Metropolitan Areas (CMAs), 2021  | **369**  | 41  | 9  | [Download]() |
| Ilocano and Tagalog Speakers, 13 Provinces and Territories, 2021  | **130**  | 13 | 10  | [Download]() |
| Riding Data (2023 Representation Order), Ilocano, Tagalog, Other Languages  | **7546**  | 343 | 22  | [Download]()  |
| **TOTAL** | **8253**  | 405  | 67  | N/A  |

The following is the repo structure:

```

├── Figures          <- Figures used for the README, organized by sections
│   ├── Data Structure                  
│       ├── Figure0.2.png
│   ├── Overview
│       ├── Figure0.1.jpg
│   ├── Panel 1 Pics                
│       ├── Figure 3.1.1.png
│       ├── Figure 3.1.2.png
│       ├── Figure 3.1.3.png
│   ├── Panel 2 Pics             
│       ├── Figure 3.2.1.png
│       ├── Figure 3.2.2.png
│       ├── Figure 3.2.3.png
│       ├── Figure 3.2.4.png
│   ├── Panel 3 Pics    
│       ├── Figure 3.3.1.png
│       ├── Figure 3.3.2.png
│       ├── Figure 3.3.3.png
│       ├── Figure 3.3.4.png
│       ├── Figure 3.3.5.png
│       ├── Figure 3.3.6.png
│       ├── Figure 3.3.7.png
│       ├── Figure 3.3.8.png
│       ├── Figure 3.3.9.png
│       ├── Figure 3.3.10.png
│       ├── Figure 3.3.11.png
│       ├── Figure 3.3.12.png
│       ├── Figure 3.3.13.png
│       ├── Figure 3.3.14.png
│       ├── Figure 3.3.15.png
│       ├── Figure 3.3.16.png
│       ├── Figure 3.3.17.png
│       ├── Figure 3.3.18.png
│   ├── Panel 4 Pics
│       ├── Figure 3.4.1.png
│       ├── Figure 3.4.2.png
│       ├── Figure 3.4.3.png
│       ├── Figure 3.4.4.png
│       ├── Figure 3.4.5.png
│       ├── Figure 3.4.6.png
│       ├── Figure 3.4.7.png
│
│
├── GIFs          <- Folder hosting 4 GIF files, each corresponding to each panel of the dashboard
│   ├── Panel1.gif
│   ├── Panel2.gif
│   ├── Panel3.gif
│   ├── Panel4.gif
│
│
├── ilocano-dashboard          <- Folder meant to mimic the folder structure of files used to run the dashboard locally in a local machine (if you want to run as a browser app hosted on shinyapps.io, they should ALL be in the same folder)
│   ├── data          <- CSV files needed    
│       ├── Ilocanos_in_Canada_2006-2021.csv
│       ├── Ilocanos_in_Canada_CMAs.csv
│       ├── Ilocanos_in_Canada_Provinces.csv
│       ├── Ilocanos_in_Canada_Ridings.csv
│   ├── shapefile      <- all files extracted frown the zipfile downloaded from the 2021 Census Boundary file (province and territories). EXCEPTION: .shp file, as it is too big of a file to upload on GitHub (Do NOT download these files directly from here, there are here only to demonstrate the local machine file structure)
│       ├── lpr_000b21a_e.dbf
│       ├── lpr_000b21a_e.prj
│       ├── lpr_000b21a_e.shx
│       ├── lpr_000b21a_e.xml
│   ├── app.R              <- main R script (It can be any name, but if you intend to run as a browswer app, and not just locally, it MUST be named app.R)
│   ├── deploy.R            <- R script to deploy app as browser app (not needed if you're only running it locally). WARNING: Sometimes, app.R can run locally but may run into issues being deployed as a browser app if the app.R file is too big.
│
│
├── .gitattributes                     <- used to force GitHub to recognize certain languages (in this case, Markdown)
│
│
├── LICENSE.txt    <- repo license.
│
│
├── README.md      <- repo REAME.
```

Note: This is what the file structure for the zipfile files should look like in the local machine, **with the .shp file.** Remember to **NOT download the files from this repo, but the zipfile should be downloaded from the 2021 Census Boundary webpage.**
<img src="https://github.com/Francis-Calingo/ELECTIONS-CANADA-RESEARCH-PROJECT-Ilocano-Speakers-Canada/blob/main/Figures/Data%20Structure/Figure0.2.png"/>

[<b>Back to Table of Contents</b>](#table-of-contents)

---

# Executive Summary

### Overview of Findings

An interesting finding was that Ilocano settlement in Montreal (specifically the Mount Royal riding) is more prominent than they in Winnipeg, the city with the highest per-capita Filipino population in Canada. It was also observed that the Ilocano-speaking communities in most major cities were growing at a much faster rate that the Tagalog-speaking communities (although it is unlikely that they will overtake Tagalog speaker in terms of raw numbers). Alberta, Saskatchewan, and the Northwest Territories have the potential to be an important hub for the Ilocano community in Canada (due to a high growth rate in Saskatchewan's case, and a high per-capita Ilocano population in Alberta and the Northwest Territories' case).

[<b>Back to Table of Contents</b>](#table-of-contents)

---

# Insights Deep Dive
### Per-Capita Analysis:

* **The 10 ridings with the highest per-capita Ilocano population were unsurprisingly all from major cities (Toronto, Montreal, Calgary, Winnipeg, Vancouver) with a few interesting insights.** North York ridings (ridings from Toronto's northern suburb) represented a plurality on the list (York Centre, Eglinton--Lawrence, Humber River--Black Creek). Interestingly, Mount Royal (a Montreal-area riding) had the second-highest per-capita Ilocano population in all of Canada despite the fact that Greater Montreal has a comparitively lower Filipino population that most other major metropolitan areas in the country. Conversely, Winnipeg North only had the 9th-highest per-capita Ilocano population despite having the highest per-capita Filipino population in Canada, suggesting that Ilocanos are either less likely to settle there or less likely to identify "Ilocano" as their mother tongue.
  
* **Smaller Census Metropolitan Areas (CMAs) are better represented in the list of the 10 CMAs with the highest per-capita Ilocano population, with Red Deer taking the top spot at 352.029 per 100,000 people.** Other smaller CMAs on the list include Regina, Saskatoon, and Victoria. The fact that Montreal nor Winnipeg did not appear on the list suggests that the relatively high Ilocano concentration that we saw from the Mount Royal riding does not extend to the whole Montreal area, while the relatively low concentration of Ilocanos in the Winnipeg North riding in comparions to the general Filipino Canadian population appears to be a shared trait for the Winnipeg area.
  
* **Alberta (174.540 per 100,000), the Northwest Territories (158.266 per 100,000), and British Columbia (126.478) lead the country in Ilocanos per-capita.** Manitoba ranked 5th (112.878 per 100,000) while Quebec ranked 9th (24.995 per 100,000) reflecting the fact that Ilocanos are comparatively less concentrated in Manitoba like its capital Winnipeg (but still at a high level due to the higher proportions of Filipinos settling in Winnipeg and Manitoba) while they are even less concentrated in Quebec (suggesting that Ilocanos in Quebec are only concentrated in a select few areas in the Montreal area).

<details><summary><b>Table of Top 10 Ridings</b></summary> 
  <img src="https://github.com/Francis-Calingo/ELECTIONS-CANADA-RESEARCH-PROJECT-Ilocano-Speakers-Canada/blob/main/Figures/Panel%201%20Pics/Figure%203.1.1.png"/>
</details>

<details><summary><b>Table of Top 10 CMAs</b></summary> 
    <img src="https://github.com/Francis-Calingo/ELECTIONS-CANADA-RESEARCH-PROJECT-Ilocano-Speakers-Canada/blob/main/Figures/Panel%201%20Pics/Figure%203.1.2.png"/>
</details>

<details><summary><b>Choropleth Map of Per-Capita Ilocano Population</b></summary> 
    <img src="https://github.com/Francis-Calingo/ELECTIONS-CANADA-RESEARCH-PROJECT-Ilocano-Speakers-Canada/blob/main/Figures/Panel%201%20Pics/Figure%203.1.3.png"/>
</details>

[Visualization specific to category 1]


### Categorical Data Analysis (Tagalog vs. Ilocano):

* **For the most part, the settlement distribution for both Canada's Tagalog-speaking community and the Ilocano-speaking community are near-identical, with a notable difference for Manitoba and Quebec.** Unsurprisingly, Ilocanos and Tagalog speakers in Ontario, the most populous province in Canada, make up the plurality of their respective groups. However, the proportion os Ilocanos living in Quebec in comparison to the national Ilocano-speaking population is much higher than the proportion of Tagalog-speakers living in Quebec in comparison to the national Tagalog-speaking population. The reverse is true for Manitoba.
  
* **Despite the Ilocano community in Quebec being comparatively low in population when measured against other provinces and territories, Quebec not only leads the country in terms of the ratio between Ilocano speakers and Tagalog speakers (0.120), but is the only province where the ratio exceed 0.100.** Knowing that the Filipino community in Quebec is both compartively low in comparison to other provinces and territories, and is highly concentrated in a few areas of the Montreal region, it can be argued that the Ilocano community in Quebec is therefore less heterogenous and less spread out than Ilocano communities in other places in Canada. Also of note is the fact that Manitoba only ranked 10th (0.030), corrobating an earlier hypothesis that Ilocanos are less likely to settle in that province or less likely to identify Ilocano as their mother tongue. 
  
* **In terms of ridings (minimum combined Tagalog and Ilocano population 1000), Toronto ridings dominate the top 10, while 3 Montreal-area ridings made this list (the only riding from the list outside of Quebec and Ontario is North Vancouver—Capilano, which was actually second on the list).** The fact that three Montreal-area ridings were on the list while not a single riding from Winnipeg (nor from Manitoba in general) further corrobates the current conclusion that the Ilocano language has much more influence on the Filipino community in Montreal than in Winnipeg.
  
* **In terms of CMAs (minimum combined Tagalog and Ilocano population 1000), Montreal takes the top spot, while the rest of the top 10 is a mix of larger CMAs (e.g., Toronto, Calgary, Vancouver) and smaller CMAs (e.g., Barrie, London, Red Deer).** Just like with the ridings table, the absence of Winnipeg and presence of Montreal further corrobates the current conclusion that the Ilocano language has much more influence on the Filipino community in Montreal than in Winnipeg. Furthermore, the appearance of smaller CMAs suggests hidden language community patterns within the Filipino community amongst those CMAs.

<details><summary><b>Donut Plot of Settlement Distribution</b></summary> 
    <img src="https://github.com/Francis-Calingo/ELECTIONS-CANADA-RESEARCH-PROJECT-Ilocano-Speakers-Canada/blob/main/Figures/Panel%202%20Pics/Figure%203.2.1.png"/>
</details>

<details><summary><b>Choropleth Map of Ilocano-Tagalog Ratio</b></summary> 
  <img src="https://github.com/Francis-Calingo/ELECTIONS-CANADA-RESEARCH-PROJECT-Ilocano-Speakers-Canada/blob/main/Figures/Panel%202%20Pics/Figure%203.2.2.png"/>
</details>

<details><summary><b>Table of Top 10 Ridings</b></summary> 
  <img src="https://github.com/Francis-Calingo/ELECTIONS-CANADA-RESEARCH-PROJECT-Ilocano-Speakers-Canada/blob/main/Figures/Panel%202%20Pics/Figure%203.2.3.png"/>
</details>

<details><summary><b>Table of Top 10 CMAs</b></summary> 
  <img src="https://github.com/Francis-Calingo/ELECTIONS-CANADA-RESEARCH-PROJECT-Ilocano-Speakers-Canada/blob/main/Figures/Panel%202%20Pics/Figure%203.2.4.png"/>
</details>


### Time-Series Growth Analysis:

* **In general, the Ilocano language community is outpacing the Tagalog language community in terms of census-by-census growth, although  in terms of raw numbers, they are not expected to overtake the Tagalog language community any time soon.** 
  
* **Specific cities.** More detail about the supporting analysis about this insight, including time frames, quantitative values, and observations about trends.
  
* **Specific cities.** More detail about the supporting analysis about this insight, including time frames, quantitative values, and observations about trends.
  
* **Saskatchewan, Nova Scotia, and the Northwest Territories  currently lead the country in terms of the Ilocano population growth rate (2006-2021).**

<details><summary><b>Choropleth Map of Ilocano Growth Rate</b></summary> 
    <img src="https://github.com/Francis-Calingo/ELECTIONS-CANADA-RESEARCH-PROJECT-Ilocano-Speakers-Canada/blob/main/Figures/Panel%203%20Pics/Figure%203.3.1.png"/>
</details>

<details><summary><b>Ilocano vs. Tagalog Growth, Canada</b></summary> 
  <img src="https://github.com/Francis-Calingo/ELECTIONS-CANADA-RESEARCH-PROJECT-Ilocano-Speakers-Canada/blob/main/Figures/Panel%203%20Pics/Figure%203.3.2.png"/>
</details>

<details><summary><b>Ilocano vs. Tagalog Growth, Provinces with > 1 Million People</b></summary> 
  <img src="https://github.com/Francis-Calingo/ELECTIONS-CANADA-RESEARCH-PROJECT-Ilocano-Speakers-Canada/blob/main/Figures/Panel%203%20Pics/Figure%203.3.3.png"/>

  <img src="https://github.com/Francis-Calingo/ELECTIONS-CANADA-RESEARCH-PROJECT-Ilocano-Speakers-Canada/blob/main/Figures/Panel%203%20Pics/Figure%203.3.4.png"/>

  <img src="https://github.com/Francis-Calingo/ELECTIONS-CANADA-RESEARCH-PROJECT-Ilocano-Speakers-Canada/blob/main/Figures/Panel%203%20Pics/Figure%203.3.5.png"/>

  <img src="https://github.com/Francis-Calingo/ELECTIONS-CANADA-RESEARCH-PROJECT-Ilocano-Speakers-Canada/blob/main/Figures/Panel%203%20Pics/Figure%203.3.6.png"/>

  <img src="https://github.com/Francis-Calingo/ELECTIONS-CANADA-RESEARCH-PROJECT-Ilocano-Speakers-Canada/blob/main/Figures/Panel%203%20Pics/Figure%203.3.7.png"/>

  <img src="https://github.com/Francis-Calingo/ELECTIONS-CANADA-RESEARCH-PROJECT-Ilocano-Speakers-Canada/blob/main/Figures/Panel%203%20Pics/Figure%203.3.8.png"/>
</details>

<details><summary><b>Ilocano vs. Tagalog Growth, 10 Most Populous Cities</b></summary> 
  <img src="https://github.com/Francis-Calingo/ELECTIONS-CANADA-RESEARCH-PROJECT-Ilocano-Speakers-Canada/blob/main/Figures/Panel%203%20Pics/Figure%203.3.9.png"/>

  <img src="https://github.com/Francis-Calingo/ELECTIONS-CANADA-RESEARCH-PROJECT-Ilocano-Speakers-Canada/blob/main/Figures/Panel%203%20Pics/Figure%203.3.10.png"/>

  <img src="https://github.com/Francis-Calingo/ELECTIONS-CANADA-RESEARCH-PROJECT-Ilocano-Speakers-Canada/blob/main/Figures/Panel%203%20Pics/Figure%203.3.11.png"/>

  <img src="https://github.com/Francis-Calingo/ELECTIONS-CANADA-RESEARCH-PROJECT-Ilocano-Speakers-Canada/blob/main/Figures/Panel%203%20Pics/Figure%203.3.12.png"/>

  <img src="https://github.com/Francis-Calingo/ELECTIONS-CANADA-RESEARCH-PROJECT-Ilocano-Speakers-Canada/blob/main/Figures/Panel%203%20Pics/Figure%203.3.13.png"/>

  <img src="https://github.com/Francis-Calingo/ELECTIONS-CANADA-RESEARCH-PROJECT-Ilocano-Speakers-Canada/blob/main/Figures/Panel%203%20Pics/Figure%203.3.14.png"/>

  <img src="https://github.com/Francis-Calingo/ELECTIONS-CANADA-RESEARCH-PROJECT-Ilocano-Speakers-Canada/blob/main/Figures/Panel%203%20Pics/Figure%203.3.15.png"/>

  <img src="https://github.com/Francis-Calingo/ELECTIONS-CANADA-RESEARCH-PROJECT-Ilocano-Speakers-Canada/blob/main/Figures/Panel%203%20Pics/Figure%203.3.16.png"/>

  <img src="https://github.com/Francis-Calingo/ELECTIONS-CANADA-RESEARCH-PROJECT-Ilocano-Speakers-Canada/blob/main/Figures/Panel%203%20Pics/Figure%203.3.17.png"/>

  <img src="https://github.com/Francis-Calingo/ELECTIONS-CANADA-RESEARCH-PROJECT-Ilocano-Speakers-Canada/blob/main/Figures/Panel%203%20Pics/Figure%203.3.18.png"/>
</details>

### Linear Regression Modelling (Ilocano vs. Other Language Communities):

* **There is a strong positive correlation between the density of Ilocano speakers and the density of Tagalog speakers.** In other words, Ilocano settlement generally do not deviate from the larger Tagalog settlement patterns, as seen by some outliers in the regression plot, as well as previous examples of certain ridings and CMAs.
  
* **Cebuano and Ilocano density, when not accounting for the presence of the Tagalog language, are positively correlated, but only modestly.** More detail about the supporting analysis about this insight, including time frames, quantitative values, and observations about trends.
  
* **With the top 5 non-official languages (Mandarin, .** More detail about the supporting analysis about this insight, including time frames, quantitative values, and observations about trends.

<details><summary><b>Regression vs. Tagalog</b></summary> 
  <img src="https://github.com/Francis-Calingo/ELECTIONS-CANADA-RESEARCH-PROJECT-Ilocano-Speakers-Canada/blob/main/Figures/Panel%204%20Pics/Figure%203.4.1.png"/>
</details>

<details><summary><b>Partial Regression vs. Cebuano (Controlling for Tagalog)</b></summary> 
  <img src="https://github.com/Francis-Calingo/ELECTIONS-CANADA-RESEARCH-PROJECT-Ilocano-Speakers-Canada/blob/main/Figures/Panel%204%20Pics/Figure%203.4.2.png"/>
</details>

<details><summary><b>Partial Regression vs. Top 5 Non-Official Languages (Controlling for Tagalog) </b></summary> 
  <img src="https://github.com/Francis-Calingo/ELECTIONS-CANADA-RESEARCH-PROJECT-Ilocano-Speakers-Canada/blob/main/Figures/Panel%204%20Pics/Figure%203.4.3.png"/>

  <img src="https://github.com/Francis-Calingo/ELECTIONS-CANADA-RESEARCH-PROJECT-Ilocano-Speakers-Canada/blob/main/Figures/Panel%204%20Pics/Figure%203.4.4.png"/>

  <img src="https://github.com/Francis-Calingo/ELECTIONS-CANADA-RESEARCH-PROJECT-Ilocano-Speakers-Canada/blob/main/Figures/Panel%204%20Pics/Figure%203.4.5.png"/>

  <img src="https://github.com/Francis-Calingo/ELECTIONS-CANADA-RESEARCH-PROJECT-Ilocano-Speakers-Canada/blob/main/Figures/Panel%204%20Pics/Figure%203.4.6.png"/>

  <img src="https://github.com/Francis-Calingo/ELECTIONS-CANADA-RESEARCH-PROJECT-Ilocano-Speakers-Canada/blob/main/Figures/Panel%204%20Pics/Figure%203.4.7.png"/>
</details>


[<b>Back to Table of Contents</b>](#table-of-contents)

---

# Recommendations:

Based on the insights and findings above, we would recommend the [stakeholder team] to consider the following: 

* Mount Royal and Red Deer per-capita. **Monitor Recommendation or general guidance based on this observation.**
  
* 3 Montreal ridings comparatively more Ilocano than Tagalog. 6 from Toronto, multiple CMAs. **Recommendation or general guidance based on this observation.**
  
* Growing faster than Tagalog. **Partner with community orgs. Recommendation or general guidance based on this observation.**
  
* Residuals. **Recommendation or general guidance based on this observation.**

[<b>Back to Table of Contents</b>](#table-of-contents)

---

# Assumptions and Caveats:

Throughout the analysis, multiple assumptions were made to manage challenges with the data. These assumptions and caveats are noted below:

* Census population counts for the redistributed electoral ridings were not available on Statistics Canada's 2021 Census Profile, but they were acquired from the Electoral Boundaries Commission's website (https://redecoupage-redistribution-2022.ca/com/index_e.aspx).
  
* While the "mother tongue" definition was used for this research, it is important to note that it is not the only type of census data regarding language use. Other categories such as "Knowledge of Languages" and "Language Spoken Most Often at Home" emphasize the complex nature of language use, and it would therefore be useful to have follow-up research comparing how language communities fare in terms of data discrepancies between those categories.
  
* Specific granular data on Philippine-based languages were not available in the 2001 Census, therefore, it can be assumed that they are not available before the 2006 Census (hence why the time-series visualizations only start from 2006).

* Boundary files for the updated ridings are currently not available as of June 2025, hence why choropleth maps were of provincial and territorial levels only.

* The regression analyses only measured Ilocano against the top 5 non-official languages communities (i.e., neither English nor French) as well as Tagalog and Cenuano (the most and third-most spoken Philippine-based languages in Canada). This does not mean that there could be valuable insights to be gained from measuring it against other languages, even if their communities are low in numbers (e.g., other Austronesian languages, other Asian languages, other language communities who generally do not settle in francophone regions in large numbers).

[<b>Back to Table of Contents</b>](#table-of-contents)

---

# Credits and Acknowledgements

Chang, Winston, et al. Shinydashboard: Create Dashboards with “Shiny.” 0.7.3, 21 Apr. 2025. R-Packages, https://cran.r-project.org/web/packages/shinydashboard/index.html.

“Shiny - Welcome to Shiny.” Shiny, https://shiny.posit.co/r/getstarted/shiny-basics/lesson1/.

Sievert, Carson, et al. Plotly: Create Interactive Web Graphics via “Plotly.Js.” 4.10.4, 13 Jan. 2024. R-Packages, https://cran.r-project.org/web/packages/plotly/index.html.

[<b>Back to Table of Contents</b>](#table-of-contents)
