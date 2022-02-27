# Future sugar yield | Sugarcane
 
Source code for the analysis of the abstract submitted to BBEST. Abstract in folder 'paper'.

Abstract citation here:
OLIVEIRA, M. P. G. de; BOCCA, F. F. ; RODRIGUES, L. H. A. . Classification trees for delving into sugarcane production in Brazil under climate change. In: BBEST 2017 - Brazilian Bioenergy Science and Technology Conference, 2017, Campos do Jordão, SP. Proceedings of the Brazilian Bioenergy Science and Technology Conference 2017 (BBest2017), 2017. p. 59-60. 

Poster here:
Oliveira, Monique; Rodrigues, Luiz Henrique; Bocca, Felipe Ferreira (2017): Classification trees for delving into sugarcane production in Brazil under climate change. figshare. Poster. https://doi.org/10.6084/m9.figshare.14695527.v2

Parts of this work received contributions from @waroce and from @boccaff.

## Methods
### Variables
As much as possible, the recommended procedures stated by White et al. (2011)[^1], regarding assessments of climate change in agroecosystems, were followed. The variables that were modified in the simulations are summarized in Table 1. 

Table 1. Variables that were changed in the simulations.
| Category          | Configuration                                                                                                                                                                                                                                                                                                 |
|-------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Models            | DSSAT-Canegro   (Inman-Bamber, 1991; Jones et al., 2003; Singels et al., 2008)[^2] [^3] [^4] and   APSIM-Sugar (Keating et al., 1999)[^5]                                                                                                                                                                                       |
| Locations         | Jataí (GO),   Piracicaba (SP) and Presidente Prudente (SP)                                                                                                                                                                                                                                                    |
| Climate scenarios | GCMs: ACCESS1-0,   bcc-csm1-1, BNU-ESM, CanESM2, CCSM4, CESM1-BGC, CSIRO-Mk3-6-0, GFDL-ESM2G,   GFDL-ESM2M, HadGEM2-CC, HadGEM2-ES, inmcm4, IPSL-CM5A-LR, IPSL-CM5A-MR,   MIROC5, MIROC-ESM, MPI-ESM-LR, MPI-ESM-MR, MRI-CGCM3, NorESM1-M, FGOALS-g2,   CMCC-CM, CMCC-CMS, CNRM-CM5, HadGEM2-AO, IPSL-CM5B-LR |
|                   | CMIP5 Representative Concentration Pathways: RCP 4.5 and RCP 8.5                                                                                                                                                                                                                                              |
|                   | Decades: From 2010 to 2039 and from 2040 to 2069.                                                                                                                                                                                                                                                             |
|                   | Generation Methods: Delta and Mean and variability                                                                                                                                                                                                                                                            |
| Soil              | Dataset 2 (Marin et   al., 2011a)[^6]: yellow with predominance of clay, higher water holding capacity,   smaller hydraulic conductivity, runoff potential moderately high, 3% slope   and well drained.                                                                                                          |
|                   | Dataset 3 (Marin et al., 2011a)[^6]: red with predominance of sand, lower   water holding capacity, higher hydraulic conductivity, runoff potential   moderately low, 3% slope and well drained.                                                                                                                  |
| Fertilizers       | Nutrient limitation   was not simulated                                                                                                                                                                                                                                                                       |
| Irrigation        | Rainfed and   irrigated. Irrigation was set to be applied when available soil water -   calculated up to 1 m of depth - was lower than 40%. One rule was included for   no irrigation if it should happen in the last 98 days before harvesting.                                                              |
| Dates             | Planting dates in   May 15th, August 15th and November 15th and one-year cycles.                                                                                                                                                                                                                              |
| Cultivar          | RB867515 (Marin et   al., 2015)[^7]                                                                                                                                                                                                                                                                               |
### Climate data 
Daily maximum and minimum temperature and relative humidity data from 1980 to 2009 were retrieved from AgMerra (Ruane et al., 2015)[^8] for three locations: Piracicaba, where sugarcane has been traditionally grown, and Jatai and Presidente Prudente, both in expansion regions (Caldarelli e Gillio 2018; Spera et al 2017)[^9] [^10]. Climate change scenarios were generated using the AgMIP Climate Scenario Generation Tools with R, made available by the Agricultural Model Intercomparison and Improvement Project (AgMIP) (Ruane et al., 2015)[^8], for the CMIP5 IPCC Scenarios. Both the delta method and the mean and variability method were used with a baseline from 1980 to 2009. No additional downscaling was performed. Carbon dioxide values were defined as 360 ppm for the baseline. Other scenarios follow the values of Table 2.

Table 2. Concentrations of carbon dioxide in the atmosphere used in simulations.
|         | Near-term (2010 to 2039) | Mid-century (2040 to 2069) |
|---------|--------------------------|----------------------------|
| RCP 4.5 | 423 ppm                  | 499 ppm                    |
| RCP 8.5 | 432 ppm                  | 571 ppm                    |

### Simulations
In order to represent, for each location, one condition, we combined the outputs for each type of soil, irrigation scenario and planting dates using an weighted average obtained by the following proportions:
●	The grouping by planting dates followed (Marin 2013)[^11]: the final value accounted for 28 % of the output obtained for the simulations in May, 44% for the simulation in August and 28%, for the simulations in November. Even though sugarcane cycle in the first year may be of 12 or 18 months, only 12 months were simulated, following Marin 2013[^11].
●	The two soil types, representing higher or lower water holding capacity, were combined based on the assumption that the soil proportion in the mill area would follow the proportion in the cities (IBGE, 2006)[^12]. This led to 67.2% of clayey in Jatai, 29.8 % in Piracicaba and 100% in Presidente Prudente. The remainder accounted for sandy soils.
●	As for irrigation, the current situation was represented by 27% of irrigated sugarcane area in Jataí, 4% in Piracicaba and 18% in Presidente Prudente (ANA, 2017)[^13]. 
●	To account for the decline in yield that happens each ratoon, since only planted sugarcane was simulated, biomass outputs were reduced in 20% up to the 5th growth for rainfed areas and 15% for irrigated areas. 
●	We only used the calibration from the RB867515 cultivar (Marin 2015)[^7] because other cultivars had not been calibrated for both DSSAT and APSIM. The last comprehensive survey (IAC, 2017)[^14] pointed this cultivar as the one that is often most planted in all Brazilian states.
 
A few points are worth highlighting. First of all, both DSSAT and APSIM take into account the effects of increased carbon dioxide, as described in Marin 2015[^7]. According to Marin 2015[^7], these are the most widely used models for sugarcane growth. Furthermore, even though Brazilian production is mostly rainfed (Walter et al., 2014)[^15], because we simulated these scenarios for areas known as expansion areas (Scarpare et al., 2016)[^16], the effect on irrigated sugarcane was also evaluated. We modified both codes to set irrigation rules in accordance to our method. Since we were evaluating sugar content and water deficit is important for the storage of sugar content, irrigation closer to harvesting was not allowed. The limit was set to 98 days before harvest. 

Finally, (Marin et al., 2015)[^7] suggest more targeted experiments to understand the physiology Brazilian cultivars so that they can be better represented in sugarcane models for application in Brazil. This is even more relevant given the development of new varieties adapted to new environments. Given these studies have not yet been published, the values used still depend on the authors’ calibration.

## References