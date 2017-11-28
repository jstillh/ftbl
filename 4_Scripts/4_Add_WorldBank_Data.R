# Match World Bank Data to Football Dataset

rm(list=ls())
require(dplyr)



# Read Datasets -----------------------------------------------------------

# Read summarised WorldCupData
wcSumAll <- readRDS('./1_data/WorldCupSummaryAll.RDS')

# Read World Bank Data set on World Development indicators
wdiftbl <- readRDS('./1_data/wdi.RDS')

# The datasturcture of data downloaded from https://data.worldbank.org/ 
# is as follows: 
# Country.Name - Countryname, does not match to team name in football data
# country.Code - Code with 3 characters. Matches the wbId in football data
# Indicator.name - description of the indicator, see below for an example
# Indicator.Code - Code for indicators, used above
# X1960:X2017 - Data for each year indicated in the column name.
# table(unique(wdiftbl$Indicator.Name))

# Create a functionp of the following chunk!
# Subset to death rates
deathRate <- wdiftbl[wdiftbl$Indicator.Code=='SP.DYN.CDRT.IN',]
# Create a dataframe in longformat to work with
deathRate <- deathRate %>%  select(Country.Code, X1960:X2016)
cnames <- colnames(deathRate)
colnames(deathRate) <-c('CountryCode', (substr(cnames[2:length(cnames)], 2,6)))
deathRate <-  setNames(data.frame(t(deathRate[,-1])), deathRate[,1])
# Subset to years of WC 
deathRate <- deathRate[row.names(deathRate) %in% c(unique(wcSumAll$year)),]

# Remove all Na's in CountryCodes 
# All countries that are not part of the World Bank dataset 
# (e.g., Soviet Union, Zaire) are removed
wcSumAll <- wcSumAll[!is.na(wcSumAll$codeWB),]


# Create a df with WB data and World Cups ---------------------------------

wcSumWB <- data.frame()
# Create a dataframe with a row for every observation
for (i in unique(wcSumAll$codeWB)){
  wcdata <- wcSumAll[ wcSumAll$codeWB==i,]
  wcdata <- arrange(wcdata, year)
  wbdata <- deathRate[colnames(deathRate)==i]
  colnames(wbdata) <- c('deathRate')
  wcdata <- cbind(wcdata, wbdata)
  wcSumWB <- rbind(wcSumWB, wcdata)
  rm(wcdata)
}
