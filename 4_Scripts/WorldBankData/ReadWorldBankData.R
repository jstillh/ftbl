# Read WorldBankData
# Jonas Stillhard, November 2017

# This script reads data from the world bank API. For more information on 
# the calls etc, see
# https://datahelpdesk.worldbank.org/knowledgebase/articles/898581-api-basic-call-structure
# The Script follows 
# https://www.r-bloggers.com/accessing-apis-from-r-and-a-little-r-programming/
# with some minor modifications.

require(dplyr)
require(jsonlite)
require(curl)
require(httr)

rm(list=ls())


rawjson <- fromJSON('http://api.worldbank.org/v2/datacatalog?format=json&per_page=10000000')


u# Get WorldBank Country Codes ---------------------------------------------

url <- 'http://api.worldbank.org'
path <- 'v2/countries?per_page=10000&format=json'

raw <- GET(url=url, path=path)

names(raw)

raw$status_code
# status code 200 tells us that the connection is ok
# See https://en.wikipedia.org/wiki/List_of_HTTP_status_codes
# for meaning of status codes

raw.content <- rawToChar(raw$content)
head(raw.content)
countries <- fromJSON(raw.content)
countries <-  countries[[2]]

countries <- flatten(countries, recursive=T)

rm(raw.content, raw, url, path)


# Less Coding: 

rawjson <- fromJSON('http://api.worldbank.org/v2/countries?format=json&per_page=10000000')
rawjson <- rawjson [[2]]
countries <- flatten(countries)
rm(rawjson)

saveRDS(countries, './1_data/worldBank/countrieCodesWB.RDS')

# Check topics ----------------------------------------------------

rawjson <- fromJSON('http://api.worldbank.org/v2/topics?format=json&per_page=1000000')
topics <- as.data.frame(rawjson[2])
u
# Check data for topics
rawjson <- fromJSON('http://api.worldbank.org/v2/indicators?format=json&per_page=1000000')
indicators <- as.data.frame(rawjson[2])


# Read Population 
rawjson <-fromJSON('http://api.worldbank.org/v2/countries/all/indicators/SP.POP.TOTL?format=json&per_page=20000')
population <- as.data.frame(rawjson[2])
saveRDS(population, './1_data/worldBank/populationCountries.RDS')

# Number of teacher
rawjson <-fromJSON('http://api.worldbank.org/v2/countries/all/indicators/UIS.T.2?format=json&per_page=20000')
noTeachers <- as.data.frame(rawjson[2])
saveRDS(noTeachers, './1_data/worldBank/noTeachers.RDS')

