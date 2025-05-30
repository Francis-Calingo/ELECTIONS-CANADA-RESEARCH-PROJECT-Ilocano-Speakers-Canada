# ELECTIONS-CANADA-RESEARCH-PROJECT-Ilocano-Speakers-Canada

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

<img src="https://github.com/Francis-Calingo/ELECTIONS-CANADA-RESEARCH-PROJECT-Ilocano-Speakers-Canada/blob/main/Figures/Figure0.1.jpg"/>

Ascertaining settlement patterns with regards to the Ilocano-speaking community will be very useful for Elections Canada in helping better understand the community itself and how their demographics play a role in their interactions with Canadian democracy. The fact that Ilocano is not a very commonly used language in digital environment, alongside the fact that Tagalog and English are the predominantly used languages int the Filipino Canadian community makes ascertaining settlement patterns and drawing actionable insights from that more difficult that the demographic research project executed for the general Filipino Canadian community. Therefore, unique methods will be employed to account for those considerations.

Insights and recommendations are provided on the following key areas:

- **Per-Capita Analysis** 
- **Categorical Data Analysis (Tagalog vs. Ilocano)** 
- **Time-Series Growth Analysis** 
- **Linear Regression Modelling (Ilocano vs. Other Language Communities)** 

**FINAL DELIVERABLE:** A dashboard visualization of the demographics of Ilocanos in Canada using R Shiny.

The SQL queries used to inspect and clean the data for this analysis can be found here [link].

Targed SQL queries regarding various business questions can be found here [link].

An interactive Tableau dashboard used to report and explore sales trends can be found here [link].

[click me to download](https://github.com/Francis-Calingo/CATEGORICAL-SOCIOECONOMIC-DATA-ANALYSIS-OF-CANADIAN-REGIONS/raw/refs/heads/main/Census_Division_Stats_-_Sheet1.csv)

[<b>Back to Table of Contents</b>](#table-of-contents)

---

# Data Structure and Initial Checks


https://raw.githubusercontent.com/Francis-Calingo/Visualizing-Migration-in-Canada/main/CSVs%20for%20Time-Series%20Analysis/Non-Permanent%20Migration.csv

| Data Content  | Number of Entries (Records x Field) | Number of Records  | Number of Fields | Download File Link |
| ------------- | ------------- | ------------- | ------------- | ------------- |
| Ilocano Speakers in Canada, 13 Provinces and Territories, 10 Largest Cities (2006-2021 Censuses)  | **208**  | 8  | 26 | [Download]()  |
| Ilocano and Tagalog Speakers, Census Metropolitan Areas (CMAs), 2021  | **369**  | 41  | 9  | [Download]() |
| Ilocano and Tagalog Speakers, 10 Most Populated Cities (and Most Populated Provincial and Territorial Cities), 2021 | **136**  |  17 | 8 | [Download]() |
| Ilocano and Tagalog Speakers, 13 Provinces and Territories, 2021  | **130**  | 13 | 10  | [Download]() |
| Riding Data (2023 Representation Order), Ilocano, Tagalog, Other Languages  | **7546**  | 343 | 22  | [Download]()  |
| **TOTAL** | **8389**  | 422  | 75  | N/A  |

[Entity Relationship Diagram here]

If you'd like to fork or run this locally:

```bash
git clone https://github.com/Francis-Calingo/ELECTIONS-CANADA-RESEARCH-PROJECT-Ilocano-Speakers-Canada.git
cd ELECTIONS-CANADA-RESEARCH-PROJECT-Ilocano-Speakers-Canada
```

[<b>Back to Table of Contents</b>](#table-of-contents)

---

# Executive Summary

### Overview of Findings

An interesting finding was that Ilocanos were more concentrated in Montreal (specifically the Mount Royal riding) than they are in Winnipeg, the city with the highest per-capita Filipino population in Canada. It was also observed that the Ilocano-speaking communities in most major cities were growing at a much faster rate that the Tagalog-speaking communities (although it is unlikely that they will overtake Tagalog speaker in terms of raw numbers). Alberta, Saskatchewan, and the Northwest Territories have the potential to be an important hub for the Ilocano community in Canada (due to a high growth rate in Saskatchewan's case, and a high per-capita Ilocano population in Alberta and the Northwest Territories' case).

[Visualization, including a graph of overall trends or snapshot of a dashboard]

[<b>Back to Table of Contents</b>](#table-of-contents)

---

# Insights Deep Dive
### Per-Capita Analysis:

* **Riding.** More detail about the supporting analysis about this insight, including time frames, quantitative values, and observations about trends.
  
* **CMA.** More detail about the supporting analysis about this insight, including time frames, quantitative values, and observations about trends.
  
* **Choropleth Map.** More detail about the supporting analysis about this insight, including time frames, quantitative values, and observations about trends.
  
* **Main insight 4.** More detail about the supporting analysis about this insight, including time frames, quantitative values, and observations about trends.

[Visualization specific to category 1]


### Categorical Data Analysis (Tagalog vs. Ilocano):

* **Donut plot proportion.** More detail about the supporting analysis about this insight, including time frames, quantitative values, and observations about trends.
  
* **Choropleth map ratio.** More detail about the supporting analysis about this insight, including time frames, quantitative values, and observations about trends.
  
* **Riding ratio.** More detail about the supporting analysis about this insight, including time frames, quantitative values, and observations about trends.
  
* **CMA ratio.** More detail about the supporting analysis about this insight, including time frames, quantitative values, and observations about trends.

[Visualization specific to category 2]


### Time-Series Growth Analysis:

* **Generally outpacing.** More detail about the supporting analysis about this insight, including time frames, quantitative values, and observations about trends.
  
* **Specific cities.** More detail about the supporting analysis about this insight, including time frames, quantitative values, and observations about trends.
  
* **Specific cities.** More detail about the supporting analysis about this insight, including time frames, quantitative values, and observations about trends.
  
* **Saskatchewan, NWT, Nova Scotia.** More detail about the supporting analysis about this insight, including time frames, quantitative values, and observations about trends.

[Visualization specific to category 3]


### Linear Regression Modelling (Ilocano vs. Other Language Communities):

* **Tagalog.** More detail about the supporting analysis about this insight, including time frames, quantitative values, and observations about trends.
  
* **Cebuano.** More detail about the supporting analysis about this insight, including time frames, quantitative values, and observations about trends.
  
* **Other languages 1.** More detail about the supporting analysis about this insight, including time frames, quantitative values, and observations about trends.
  
* **Other languages 2.** More detail about the supporting analysis about this insight, including time frames, quantitative values, and observations about trends.

[Visualization specific to category 4]

[<b>Back to Table of Contents</b>](#table-of-contents)

---

# Recommendations:

Based on the insights and findings above, we would recommend the [stakeholder team] to consider the following: 

* Specific observation that is related to a recommended action. **Recommendation or general guidance based on this observation.**
  
* Specific observation that is related to a recommended action. **Recommendation or general guidance based on this observation.**
  
* Specific observation that is related to a recommended action. **Recommendation or general guidance based on this observation.**
  
* Specific observation that is related to a recommended action. **Recommendation or general guidance based on this observation.**
  
* Specific observation that is related to a recommended action. **Recommendation or general guidance based on this observation.**

[<b>Back to Table of Contents</b>](#table-of-contents)

---

# Assumptions and Caveats:

Throughout the analysis, multiple assumptions were made to manage challenges with the data. These assumptions and caveats are noted below:

* Because data was not completely available for the newest electoral boundaries (i.e., 2023 represenation order), the last iteration of the boundaries (i.e., 2013 representation order) had to be used for calculations such as per-capita calculations.
  
* Assumption 1 (ex: data for December 2021 was missing - this was imputed using a combination of historical trends and December 2020 data)
  
* Assumption 1 (ex: because 3% of the refund date column contained non-sensical dates, these were excluded from the analysis)

[<b>Back to Table of Contents</b>](#table-of-contents)

---

# Credits and Acknowledgements
