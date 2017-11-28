# Prepare Data for correlations
# Jonas Stillhard
# November 2017

rm(list=ls())

# Read World Cup Data

wc <- readRDS('./1_data/worldcups.RDS')

# Subset to data past 1960 (world bank data only dates back to 1960)

wc1960 <- wc[wc$year>1960,]

require(dplyr)




# Summarised Data ---------------------------------------------------------


wc1960 <- wc1960 %>% 
  mutate(winnerET = 
           case_when(
             winner90==0 & winner==1 & is.na(score1p)    ~1
             , winner90==0 & winner==2 & is.na(score1p)    ~2
             
           ),
         winnerP= 
           case_when(
             winner==1 & !is.na(score1p)  ~ 1
            ,  winner==2 & !is.na(score1p)  ~ 2
           ))


wcSumH <- wc1960%>% 
  group_by(year, teamH) %>% 
  summarize(nWin90=sum(winner90[winner90==1])
            , nWinET=sum(winnerET[winnerET==1])
            , nWinP = sum(winnerP[winnerP==1])
            , nWin=sum(winner[winner==1])
            , nLoss90=sum(winner90[winner90==2])/2
            , nLossET=sum(winner[winner==2 & winner90==0 & is.na(score1p)])/2
            , nLossP = sum(winner[winner==2 & winner90==0 & !is.na(score1p)])/2
            , nLoss =sum(winner[winner==2])/2
            , nGamesP = n()
            , nGoalsFor=sum(score1)
            , nGoalsAg=sum(score2)
            , nGoalsForET=sum(score1et, na.rm=T)
            , nGoalsAgET=sum(score2et, na.rm=T)
            , nGoalsForP=sum(score1p, na.rm=T)
            , nGoalsAgP=sum(score2p, na.rm=T)
            , nLossesKO = sum(winner[knockout %in% c('t') & winner==2]/2)
            , nWinsKO=sum(winner[knockout %in% c('t') & winner==1])) %>% 
  mutate(team=teamH, nDraws=nGamesP-(nWin+nLoss), nGamesKO=nLossesKO+nWinsKO)

wcSumA <- wc1960%>% 
  group_by(year, teamA) %>% 
  summarize(nWin90=sum(winner90[winner90==2])/2
            , nWinET=sum(winnerET[winnerET==2])/2
            , nWinP = sum(winnerP[winnerP==2])/2
            , nWin=sum(winner[winner==2])/2
            , nLoss90=sum(winner90[winner90==1])
            , nLossET=sum(winner[winner==1 & winner90==0 & is.na(score1p)])
            , nLossP = sum(winner[winner==1 & winner90==0 & !is.na(score1p)])
            , nLoss =sum(winner[winner==1])
            , nGamesP = n()
            , nGoalsFor=sum(score2, na.rm=T)
            , nGoalsAg=sum(score1, na.rm=T)
            , nGoalsForET=sum(score2et, na.rm=T)
            , nGoalsAgET=sum(score1et, na.rm=T)
            , nGoalsForP=sum(score2p, na.rm=T)
            , nGoalsAgP=sum(score1p, na.rm=T)
            , nLossesKO = sum(winner[knockout %in% c('t') & winner==1])
            , nWinsKO=sum(winner[knockout %in% c('t') & winner==2])/2)  %>% 
  mutate(team=teamA, nDraws=nGamesP-(nWin+nLoss), nGamesKO=nLossesKO+nWinsKO)

wcSum <- rbind(wcSumA, wcSumH)

wcSum <- wcSum %>%  
  group_by(year, team) %>% 
  summarize(nGamesP=sum(nGamesP)
            , nWin=sum(nWin)
            , nDraws=sum(nDraws)
            , nLoss=sum(nLoss)
            , nGamesKO=sum(nGamesKO)
            , nWinsKO=sum(nWinsKO)
            , nLossKO=sum(nLossesKO)
            , nWin90=sum(nWin90)
            , nWinET=sum(nWinET)
            , nWinP=sum(nWinP)
            , nLoss90=sum(nLoss90)
            , nLossET=sum(nLossET)
            , nLossP=sum(nLossP)
            , nGoalsFor=sum(nGoalsFor, na.rm=T)
            , nGoalsAg=sum(nGoalsAg, na.rm=T)
            , nGoalsForET=sum(nGoalsForET, na.rm=T)
            , nGoalsAgET=sum(nGoalsAgET, na.rm=T)
            , nGoalsForP=sum(nGoalsForP, na.rm=T)
            , nGoalsAgP=sum(nGoalsAgP, na.rm=T)
  )


# All Games ---------------------------------------------------------------

# Create a dataset where every Game appears twice so the columns can be easily analyzed

wcA <- wc

wcA$teamH <- wc$teamA
wcA$teamA <- wc$teamH
wcA$team1_id <- wc$team2_id
wcA$team2_id <- wc$team1_id
wcA$score1 <- wc$score2
wcA$score2 <- wc$score1
wcA$score1et <- wc$score2et
wcA$score2et <- wc$score1et
wcA$score1p <- wc$score2p
wcA$score2p <- wc$score1p


wcA <- wcA %>% 
  mutate(winner90=case_when(
    winner90==1   ~ 2
    , winner90==2   ~ 1
  )
  , winner=case_when(
    winner==1 ~ 2
    , winner==2 ~ 1
  )
  , result=paste(score1, score2, sep='-'))


wcDoubledUp <- rbind(wc, wcA)


# Save Data -------------------------------------------------------------

saveRDS(wcDoubledUp, './1_data/WorldCupDoubledUp.RDS')
saveRDS(wcSum, './1_data/WorldCupSummary.RDS')

