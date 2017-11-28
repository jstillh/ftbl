# Subset World Bank data to complete cases

wcSumAll <- readRDS('./1_data/WorldCupSummaryAll.RDS')

# Read world cup data
WDI <- read.csv('./1_data/worldBank/WDI_csv/WDIData.csv')

WDI <- WDI[WDI$Country.Code %in% wcSumAll$codeWB,]
saveRDS(WDI, './1_data/wdi.RDS')

WGI <- read.csv('./1_data/worldBank/WGI_csv/WGIData.csv')
WGI <- WGI[WGI$Country.Code %in% wcSumAll$codeWB,]
saveRDS(WGI, './1_data/wgi.RDS')

GenderStats <- read.csv('./1_data/worldBank/Gender_Stats_csv/Gender_StatsData.csv')
GenderStats <- GenderStats[GenderStats$Country.Code %in% wcSumAll$codeWB,]
saveRDS(GenderStats, './1_data/GenderStats.RDS')

GenderStats <- readRDS('./1_data/GenderStats.RDS')

unique(GenderStats$Indicator.Name)

wgi <- readRDS('./1_data/wgi.RDS')
unique(wgi$Indicator.Name)
