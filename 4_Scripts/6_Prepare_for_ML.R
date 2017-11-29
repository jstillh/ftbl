wdiftbl         <- readRDS('./1_data/wdi.RDS')
wcSumAll        <- readRDS('./1_data/WorldCupSummaryAll.RDS')
country_codes   <- readRDS("./1_data/teams.RDS")
wcMatchesDouble <- readRDS('./1_data/WorldCupDoubledUp.RDS')



#wcMatchesDouble[,ncol(wcMatchesDouble) - 1] <- as.factor(wcMatchesDouble[,ncol(wcMatchesDouble) - 1])


colnames(wdiftbl) <-c('CountryName',"CountryCode", "IndicatorName", "IndicatorCode", (substr(cnames[5:length(cnames)], 2,6)))



# Selecting Worldcup years -----------
# Better: create trend from years before worldcup? -> additional features
z  <- unique(wcSumAll[,1])[2:14]
t  <- wdiftbl
tt <- t[,1:57] %>% select(z)
wdi_only_wc <- cbind(t[,1:4], tt)



# Reshaping -----
country_traits <- data.frame()
for(i in unique(wdi_only_wc[,1])){
  m  <- data.frame()
  m2 <- data.frame()
  m  <- wdi_only_wc[wdi_only_wc$CountryName %in% i,]
  rownames(m) <- m[,4]
  m2 <- data.frame(t(m[,5:ncol(m)]))
  m2 <- cbind(data.frame(rownames(m2)), m2)
  m2 <- cbind(data.frame(i), m2)
  country_traits <- rbind(country_traits, m2)
  rm(m)
  rm(m2)
}

cnames <- colnames(country_traits)
colnames(country_traits) <- c("Land", "Year", cnames[3:length(cnames)])


# Counting Na's ------------------------
na_data <-data.frame()

for(i in 3:ncol(country_traits) ){
  m       <- data.frame()
  name    <- colnames(country_traits)[i]
  na      <- as.numeric(summary(country_traits[,i])[7])
  m       <- cbind(data.frame(name), data.frame(na))
  na_data <- rbind(na_data, m)
  rm(m)
  
}

colnames(na_data) <- c("Feature", "Na_numbers")
head(na_data)

na_data       <- arrange(na_data, Na_numbers)
complete_data <- data.frame()
complete_data <- na_data[is.na(na_data$Na_numbers),]

# -> chossing traits with NA's < 25%
# -> 910 observations (years*countries)
cutoff <- 0.25*910
cutoff_traits_25 <- data.frame(na_data[na_data$Na_numbers <= cutoff,])
cutoff_traits_25[(nrow(cutoff_traits_25) - 2):nrow(cutoff_traits_25),] <- complete_data
names <- as.character(cutoff_traits_25$Feature)
country_traits_cutoff <- country_traits[,names]
country_traits_cutoff <- cbind(country_traits[,1:2], country_traits_cutoff)


# Imputation with missForest ------------------
require(missForest)

imp_country_traits_cutoff      <- missForest(country_traits_cutoff[,2:ncol(country_traits_cutoff)])
imp_country_traits_cutoff$ximp <- cbind(country_traits_cutoff[,1], imp_country_traits_cutoff$ximp)

summary(country_traits_cutoff[,63])
colnames(country_traits_cutoff)[64]

# Well... ^^




# Creating gameplay data with traits -------------
playlist             <- wcMatchesDouble
playlist$year        <- as.numeric(playlist$year)
playlist$teamH       <- as.factor(playlist$teamH)
playlist$teamA       <- as.factor(playlist$teamA)
playlist             <- playlist[playlist$year >= 1966,]
ic_traits            <- imp_country_traits_cutoff$ximp
colnames(ic_traits)[1] <- "Country"
ic_traits[,2]        <- as.numeric(as.character(ic_traits[,2]))
country_codes$team   <- as.factor(country_codes$team)
country_codes$WBName <- as.factor(country_codes$WBName)

#For both teams in year X select all traits and take the difference for each one

playlist_with_traits <- data.frame()
for(i in 1:nrow(playlist)){
  #i=5
  missing    <- data.frame()
  df         <- data.frame()
  teamA_tr   <- data.frame()
  teamA_tr_y <- data.frame()
  teamH_tr   <- data.frame()
  teamH_tr_y <- data.frame()
  
  teamH <- playlist$teamH[i]
  teamA <- playlist$teamA[i]
  year  <- playlist$year[i]
  
  teamH      <- country_codes[country_codes$team %in% droplevels(teamH),6]  #Switch from team name to country name
  teamA      <- country_codes[country_codes$team %in% droplevels(teamA),6]
  teamH_tr   <- ic_traits[ic_traits$Country %in% droplevels(teamH),]
  teamH_tr_y <- data.frame(teamH_tr[teamH_tr$Year==year,])
  teamA_tr   <- ic_traits[ic_traits$Country %in% droplevels(teamA),]
  teamA_tr_y <- data.frame(teamA_tr[teamA_tr$Year==year,])

  
  if(nrow(teamH_tr_y) & nrow(teamA_tr_y)){
  df <- (teamH_tr_y[,3:ncol(teamH_tr_y)] - teamA_tr_y[,3:ncol(teamA_tr_y)])
  df <- cbind(playlist[i,], df)
  playlist_with_traits <- rbind(playlist_with_traits, df)       
  }
  rm(df)

}

wcMatchesDoubleWithTraits <- droplevels(playlist_with_traits)

saveRDS(wcMatchesDoubleWithTraits, './1_data/wcMatchesDoubleWithTraits.RDS')

# Around 500 games get los...not sure if its better to switch for idwB code (im switching from team name to WBname)... 




