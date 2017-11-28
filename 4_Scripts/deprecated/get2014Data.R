# Read Data from jokecamp's repo

require(dplyr)
require(jsonlite)
require(curl)
games <- fromJSON('https://raw.githubusercontent.com/jokecamp/FootballData/master/openFootballData/games.json'
                  )
# events <- fromJSON('https://raw.githubusercontent.com/jokecamp/FootballData/master/openFootballData/events.json')

# Flatten the nested dataframes. df's get quite wide
games <- flatten(games, recursive = T)

games$date <- as.Date(substr(games$play_at, 1,10))

wc14 <- games %>% 
  filter(event.league_id==1) %>% 
  mutate(result=paste(score1, '-', score2, sep='')
  , year=2014) %>%  
  select(id=id, group_id=group_id, date=date, Round=round.title, teamH=team1.title
         , teamA=team2.title, score1, score2, result
         , score1et, score2et, score1p, score2p, postponed, knockout, winner, winner90)