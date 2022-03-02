# PortfolioProjects

## Covid Data Exploration
### Problem - Ask
Which countries have been most severely affected by COVID-19? And how have vaccinations impacted the effects of COVID-19? 

### Data Source
Data was obtained from https://ourworldindata.org/covid-deaths. The original source is from the COVID-19 Data Repository by the Center for Systems Science and Engineering (CSSE) at Johns Hopkins University. At the time of this project's creation the data ranged from Feb 2020 to Feb 2022.

### Data Preparation
After the data source was verified, I downloaded the full data .csv file. I split the data into 2 sections titled CovidDeaths and CovidVaccinations and removed some of the unneeded columns in order to obtain the data related to our problem. Then, I imported these datasets into SQL where I performed queries for data exploration. After creating several tables based on my queries, I moved these tables back into Excel in order to furthur clean the data (removing NULLS and fixing date formats) and in order to later transfer into Tableau Public.

### Analysis Insights
- The countries with the highest percentages of their population infected with COVID-19 were Faeroe Islands (67.0%), Andorra (49.0%), Denmark (45.9%), and Gibraltar (45.0%).
- The maximum percentage of population infected in the United States was 23.6%.
- The country with the highest death count from COVID-19 was the United States at 941,889. 
- The countries with the highest percentage of cases resulting in death were Yemen (18.1%), Sudan (6.3%), Peru (6.0%), Mexico (5.8%), Syria (5.7%), and Somalia (5.1%).
- At its highest vaccination count, Pitcairn Islands had 100% of its population of 47 vaccinated. 
- The other countries with the highest vaccination counts compared to population were the United Arab Emirates (94.6%), Brunei (91.5%), Portugal (91.5%), and Singapore (89.8%).
- The worldwide average percent of population fully vaccinated is now above 50%, and in the United States 64.4% of the population is fully vaccinated. 
- In early 2021, the number of COVID-19 hospitalizations went down in the United States despite case numbers rising, and this correlates with the introduction of vaccines.

### Recommendations
Data on COVID-19 is always changing and evolving. Newer data may add more context to these problems. However, it is safe to say that vaccines have significantly reduced the amount of COVID-19 related hospitalizations and deaths. Access to proper healthcare is essential: the countries where the highest percentage of cases have resulted in death are countries where access to healthcare is limited. 
