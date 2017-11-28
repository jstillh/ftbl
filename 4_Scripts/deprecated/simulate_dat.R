# Read Data

rm(list=ls())

dat32 <- readRDS('./1_data/worldcups.RDS')
teams <- readRDS('./1_data/events_teams.RDS')

d32nko <- dat32 %>% 
  filter(year>=1994 & knockout=='f' & !is.na(score1))

# Create a vector of continents

for (i in unique(teams$continentname)){
  t <- teams[teams$continentname %in% i,]
  assign(i, c(unique(t$team)))
}
rm(t, i)


# Functions ---------------------------------------------------------------
# b <- dat32 %>% filter(year==1994)
# include no other varibles than score
pred <- function(df, score1, score2, ptsdiff, ptsscr, ptswin, outdf){
  output <- data.frame()

  b <- df
  diffpred <- ifelse(b$score1-b$score2==score1-score2, ptsdiff, 0)
  scrpred <- ifelse(b$score1==score1 & b$score2==score2, ptsscr, 0)
  winpred <- ifelse(score1-score2>0 & b$winner==1, ptswin,
                    ifelse(score1-score2<0&b$winner==2, 1
                           , ifelse(score1-score2==0& b$winner==0, 1, 0)))
  sum <- sum(diffpred, scrpred, winpred)
  rb <- c(score1, score2, ptsdiff, ptsscr, ptswin, unique(b$year), sum)
  output <- rbind(output, rb)
}


pred.ctr <- function(df, score1, score2, ptsdiff, ptsscr, ptswin){
  output <- data.frame()
  b <- df
  b$score1 <- ifelse(b$teamH %in% ctr, 0, b$score1)
  b$score2 <- ifelse(b$teamA %in% ctr, 0, b$score1)
  b$winner <- ifelse((b$teamA %in% ctr & b$teamH %in% ctr), 0, 
                  ifelse((b$teamH %in% ctr & !b$teamA %in% ctr), 2,
                         ifelse((b$teamA %in% ctr & !b$teamH %in% ctr), 1, b$winner)))
                  
  diffpred <- ifelse(b$score1-b$score2==score1-score2, ptsdiff, 0)
  scrpred <- ifelse(b$score1==score1 & b$score2==score2, ptsscr, 0)
  winpred <- ifelse(score1-score2>0 & b$winner==1, ptswin,
                    ifelse(score1-score2<0&b$winner==2, 1
                           , ifelse(score1-score2==0& b$winner==0, 1, 0)))
  sum <- sum(diffpred, scrpred, winpred)
  rb <- c(score1, score2, ptsdiff, ptsscr, ptswin, unique(b$year), sum)
  output <- rbind(output, rb)
}


# Explore -----------------------------------------------------------------

b <- dat32
r <- expand.grid(0:10, 0:10)

res <- data.frame()

for(i in 1:nrow(r)){
  for (j in unique(dat32$year)){
    b <- dat32[dat32$year==j, ]
    out <- pred(b, r$Var1[i], r$Var2[i], 2, 5, 1)
    colnames(out) <- c('score1', 'score2', 'ptsdiff', 'ptsscr', 'ptswin', 'year', 'sum')
    res <- rbind(res, out)
    rm(out)
    
  }
}
res$sum <- as.integer(as.character(res$sum))
max(res$sum)

ctr <- c(get('Asia & Australia'), get('Middle East'), get('Central America'), Africa, Caribbean, get('Middle East'))
gr <- expand.grid(0:10, 0:10)
res.ctr <- data.frame()

for(i in 1:nrow(gr)){
  for( j in unique(dat32$year)){
    b <- dat32[dat32$year==j,]
    out <- pred.ctr(b, gr$Var1[i], gr$Var2[i], 2, 5, 1)
    colnames(out) <- c('score1', 'score2', 'ptsdiff', 'ptsscr', 'ptswin', 'year', 'sum')
    res.ctr <- rbind(res.ctr, out)
    rm(out)

    }
}
    

res.ctr$sum <- as.integer(as.character(res.ctr$sum))
max(res.ctr$sum)

res.ctr <- res.ctr %>% mutate(results=paste(score1, score2, sep='-'))
res.ctr$results <- as.factor(res.ctr$results)
res.ctr.sum <- res.ctr %>% 
           group_by(as.factor(results)) %>% 
           summarise(sum=sum(sum))

res <- res %>% mutate(results=paste(score1, score2, sep='-'))
res$results <- as.factor(res$results)
res.sum <- res %>% 
  group_by(as.factor(results)) %>% 
  summarise(sum=sum(sum))

# b <- dat32[dat32$year==1998,]
# m <- pred.ctr(b, 1,0, 2, 5, 1)

# res <- data.frame()
# for (i in 0:10){
#   for (j in 0:10){
#   out <- pred(b, i, j, 2,5,1)
#   colnames(out) <- c('score1', 'score2', 'ptsdiff', 'ptsscr', 'ptswin', 'year', 'sum')
#   
#   }
#   res <- rbind(res, out)
#   rm(out)
# }
# 
# View(res)
# for (i in 1:10){
#   out <- pred(b, i, 1, )
# }

