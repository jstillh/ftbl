# Read Fifa world Cup Data

# Jonas Stillhard, October 2017
# Updated November 2017, implemented importing of 2014 WC data.


# Read Data ---------------------------------------------------------------

require(RSQLite)

rm(list=ls())

sqlite <- dbDriver('SQLite')
conn <- dbConnect(sqlite, './1_data/worldcup.db')
dbListTables(conn)

rs <- dbSendQuery(conn, "SELECT * from rounds")
rounds <- dbFetch(rs)

rs <- dbSendQuery(conn, "SELECT * from games")
games <- dbFetch(res = rs)

rs <- dbSendQuery(conn, "SELECT * from countries")
countries <- dbFetch(res = rs)

rs <- dbSendQuery(conn, 'SELECT * from teams')
teams <- dbFetch(res=rs)

rs <- dbSendQuery(conn, 'SELECT * from events')
events <- dbFetch(rs)

rs <- dbSendQuery(conn, 'SELECT * from events_teams')
events_teams <- dbFetch(rs)

rs <- dbSendQuery(conn, 'SELECT * from Continents')
continents <- dbFetch(rs)

games$teamH <- teams$title[match(games$team1_id, teams$id)]
games$teamA <- teams$title[match(games$team2_id, teams$id)]
games$Round <- rounds$title[match(games$round_id, rounds$id)]

events_teams$team <- teams$title[match(events_teams$team_id, teams$id)]
events_teams$country <- teams$country_id[match(events_teams$team_id, teams$id)]
events_teams$continent <- countries$continent_id[match(events_teams$country, countries$id)]
events_teams$continentname <- continents$name[match(events_teams$continent, continents$id)]

dbDisconnect(conn)

# Clean ws
rm(events, continents, teams, conn, rs, sqlite, countries, rounds)

detach(package:RSQLite, unload=T)

# Create Data -------------------------------------------------------------

# The dataset contains all games for worldcups from 1930 to 2010. 
# 2014 is not yet implemented. 

require(dplyr)

games$date <- substr(games$play_at, 1, 10)
games$date <- as.Date(games$date, '%Y-%m-%d')
games$result <- paste(games$score1, games$score2, sep='-')
games$year <- substr(games$play_at, 1, 4)

str(games)

dat <- games %>%  
  select(id, group_id, date, Round, teamH, team1_id
         , result, teamA, team2_id, score1, score2
         , score1et, score2et, score1p, score2p
         , postponed, knockout, winner, winner90, year)

table(dat$year)

dat <- dat %>%  filter(year<2014)


# Add data from WC 2014 ---------------------------------------------------

# Read Data from jokecamp's repo

require(dplyr)
require(jsonlite)
require(curl)
games <- fromJSON('https://raw.githubusercontent.com/jokecamp/FootballData/master/openFootballData/games.json'
)


# Flatten the nested dataframes. df's get quite wide
games <- flatten(games, recursive = T)

games$date <- as.Date(substr(games$play_at, 1,10))
# games$team1.title[games$team1.id==17] <- 'Côte d'Ivoire''

wc14 <- games %>% 
  filter(event.league_id==1) %>% 
  mutate(result=paste(score1, '-', score2, sep='')
         , year=2014) %>%  
  select(id=id, group_id=group_id, date=date, Round=round.title, teamH=team1.title, team1_id
         , result, teamA=team2.title, team2_id, score1, score2
         , score1et, score2et, score1p, score2p, postponed, knockout, winner
         , winner90, year)

# correct Côte d'Ivoire for wc14

wc14$teamH[wc14$team1_id==17] <- "Côte d'Ivoire"
wc14$teamA[wc14$team2_id==17] <- "Côte d'Ivoire"

wc14teams <- unique(wc14$teamH)
wc14teams <- events_teams[events_teams$team %in% wc14teams,]

dat <- rbind(dat, wc14)

table(dat$year)

dat$knockout <- ifelse(!is.na(dat$group_id), 'f', 't')


teamsUnique <- events_teams %>% 
  select(team, team_id, country, continent, continentname)

teamsUnique <- unique(teamsUnique)

saveRDS(dat, './1_data/worldcups.RDS')
saveRDS(events_teams, './1_data/events_teams.RDS')
saveRDS(teamsUnique, './1_data/teams.RDS')


rm(games, events_teams)






