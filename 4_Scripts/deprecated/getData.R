# Read Fifa world Cup Data

# Jonas Stillhard, October 2017


# Read Data ---------------------------------------------------------------

require(RSQLite)

rm(list=ls())

setwd('C:/Users/Jonas/Desktop/FootballData/1_data')
sqlite <- dbDriver('SQLite')
conn <- dbConnect(sqlite, 'worldcup.db')
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

rm(events, continents, teams, conn, rs, sqlite, countries, rounds)

dbDisconnect()

detach(package:RSQLite, unload=T)

# Create Data -------------------------------------------------------------

require(dplyr)

games$date <- substr(games$play_at, 1, 10)
games$date <- as.Date(games$date, '%Y-%m-%d')
games$result <- paste(games$score1, games$score2, sep='-')
games$year <- substr(games$play_at, 1, 4)

dat <- games %>%  
  select(id, group_id, date, Round, teamH, result, teamA,  home, score1, score2, score1et, score2et, score1p, score2p, postponed, knockout, winner, winner90, year)
head(dat)


