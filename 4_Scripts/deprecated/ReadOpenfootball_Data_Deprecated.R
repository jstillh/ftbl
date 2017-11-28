# Football Data Sets
# Jonas Stillhard
# October 2017


# Get Data from Github (Openfootball) -------------------------------------

rm(list=ls())

require(RCurl)
require(data.table)
require(dplyr)
# require(tidyr)

# Functions ---------------------------------------------------------------

r <- dat[1,]

clean <- function(r){
  t <- strsplit(r, split = ' ')[[1]]
  t <- t[t!=""]
  country_check <- which(grepl("-", t))
  if (country_check > 5) {
    t <- c(t[1:3], paste(t[4:(country_check-1)], collapse = " "), t[country_check:length(t)])
  }
  country_check <- which(grepl("@", t))
  if (country_check > 7) {
    t <- c(t[1:5], paste(t[6:(country_check-1)], collapse = " "), paste(t[(country_check+1):length(t)], collapse = " "))
  } else {
    t <- c(t[1:(country_check-1)], paste(t[(country_check+1):length(t)], collapse = " "))
  }
  data.frame(t(t))
}

# Italia Novanta ---------------------------------------------------------------

 
wc1990 <- read.csv(text=getURL('https://raw.githubusercontent.com/openfootball/world-cup/master/1990--italy/cup.txt')
                   , row.names=NULL, skip=9)
wc1990$all <- paste(wc1990$row.names, wc1990$Group.A., sep=' ')
wc1990 <- wc1990[- grep("Group", wc1990$all),]
wc1990 <- wc1990 %>% 
  select(all)

wc90 <- do.call(rbind.data.frame, apply(wc1990, 1, clean))

head(wc90)

wc90 <- wc90 %>% 
  mutate(Round='First', Year=1990) %>% 
  select(Round, Game=X1, Day=X2, Month=X3, Year, Home=X4, FinalScore=X5, Away=X6, Stadium=X7)
head(wc90)
rm(wc1990)


# Final Round

dat <- read.csv(text=getURL('https://raw.githubusercontent.com/openfootball/world-cup/master/1990--italy/cup_finals.txt')
                                , row.names=NULL, skip=0)
dat$all <- paste(dat[,1], dat[,2], sep=' ')
# require(stringr)
dat <- dat %>% 
  select(all) %>% 
  filter(grepl('\\(', all))%>% 
  filter(!grepl('\\#', all))

wc90 <- do.call(rbind.data.frame, apply(dat, 1, clean))

