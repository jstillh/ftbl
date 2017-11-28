# Data Exploration


rm(list=ls())
dat <- readRDS('./1_data/worldcups.RDS')
teams <- readRDS('./1_data/teams.RDS')

require(dplyr)

# teams %>% group_by(event_id) %>% summarize(n=n())
# # 24 Teams since 1982, 32 since 1998

# Subset to non-knockout games starting with France 1998
d32nko <- dat %>% 
  filter(year>=1998 & knockout=='f' & !is.na(score1))

table(d32nko$result)
table(d32nko$winner)

d32nko <- d32nko %>% 
  mutate(winnerTeam=ifelse(winner==1, teamH, ifelse(winner==2, teamA, 'Draw'))
         , looserTeam=ifelse(winner==1, teamA, ifelse(winner==2, teamH, 'Draw'))
         , draw1 =ifelse(winner==0, teamH, NA)
         , draw2 = ifelse(winner==0, teamA, NA))


wins <- d32nko %>% 
  group_by(winnerTeam) %>% 
  summarize(wins=n())

losses <- d32nko %>% 
  group_by(looserTeam) %>% 
  summarize(losses=n())

draw1 <- d32nko %>%
  group_by(draw1) %>% 
  summarize(draws=n()) %>% 
  mutate(drawTeam=draw1) %>% 
  ungroup() %>% 
  select(drawTeam, draws)

draw2 <- d32nko %>%
  group_by(draw2) %>% 
  summarize(draws=n()) %>%
  mutate(drawTeam=draw2) %>% 
  ungroup() %>% 
  select(drawTeam, draws)

draws <- rbind(draw1, draw2)

draws <-   draws %>%  
  group_by(drawTeam) %>% 
  summarize(draws=sum(draws))

teamperf <- teams

teamperf$losses <- losses$losses[match(teamperf$team, losses$looserTeam)]
teamperf$wins <- wins$wins[match(teamperf$team, wins$winnerTeam)]
teamperf$draws <- draws$draws[match(teamperf$team, draws$drawTeam)]

rm(draws, draw1, draw2, losses, wins)

teamperf$wins[is.na(teamperf$wins)] <- 0
teamperf$losses[is.na(teamperf$losses)] <- 0
teamperf$draws[is.na(teamperf$draws)] <- 0

teamperf$gamesPlayed <- rowSums(teamperf[6:8], na.rm=T)

teamperf$winperc <- teamperf$wins/teamperf$gamesPlayed

table(teamperf$gamesPlayed)

pdf('./tex/winpercentage.pdf', width=12, height=9)
boxplot(winperc~continentname, data=teamperf, notch=F)
dev.off()

teamperf$l <- substr(teamperf$looserTeam, 1,1)

for(i in LETTERS){
teamperf$abc <- ifelse(teamperf$l %in% c(i), 'abc', 'other')

boxplot(winperc~abc, data=teamperf, main=i)}


View(teamperf)

saveRDS(d32nko, './3_Output/d32nko.RDS')
