# Create a LookupTable for matching World Bank and Football Data

rm(list=ls())

codesWB <- readRDS('./1_data/worldBank/countryCodesWB.RDS')
teams <- readRDS('./1_data/teams.RDS')

teams$WBName <- teams$team

# Correct flawn country names
teams$WBName[teams$team_id==2] <- c('Egypt, Arab Rep.')
teams$WBName[teams$team_id %in% c(170, 173, 171, 172)] <- c('United Kingdom')
teams$WBName[teams$team_id==74] <- 'Korea, Rep.'
teams$WBName[teams$team_id==178] <- 'Iran, Islamic Rep.'
teams$WBName[teams$team_id==156] <- 'Russian Federation'
teams$WBName[teams$team_id==17] <- "Cote d'Ivoire"
teams$WBName[teams$team_id==139] <- 'Slovak Republic'
teams$WBName[teams$team_id==162] <- 'Bosnia and Herzegovina'
teams$idWB <- codesWB$id[match(teams$WBName, codesWB$name)]


teams$idWB <- codesWB$id[match(teams$WBName, codesWB$name)]
teams$idWB[teams$team_id==73] <- 'PRK'
teams[is.na(teams$idWB),]

saveRDS(teams, './1_data/teams.RDS')
