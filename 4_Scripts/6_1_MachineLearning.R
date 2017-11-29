# Machine learning --------
gameplay <- readRDS("./1_data/wcMatchesDoubleWithTraits.RDS")

summary(gameplay$winner)
# make classes for winners:
gameplay <- gameplay[complete.cases(gameplay$winner),]
gameplay[, 18] <- as.factor(make.names(gameplay[, 18]))

# characters -> factors
gameplay$postponed <- as.factor(gameplay$postponed)
gameplay$knockout  <- as.factor(gameplay$knockout)


# removing score1et - score2p - teamids 
gameplay <- gameplay[,-c(1:3, 6, 7, 9:15, 19)]

# rownames
rownames(gameplay) <- c(1:nrow(gameplay))

# "Rounds" reshaping
gameplay$Round[grep("^Match", gameplay$Round)]   <- c("Matchday")
gameplay$Round[grep("^Quarter", gameplay$Round)] <- c("Quarter")
gameplay$Round[grep("^Semi", gameplay$Round)]    <- c("Semi")
gameplay$Round[grep("^Third", gameplay$Round)]   <- c("Third")
gameplay$Round <- as.factor(gameplay$Round)

# mlr

library(mlr)
library(mlrMBO)
library(parallel)
library(parallelMap)
gameplay[1:2,5:10]

# creating task - simple:
task <- makeClassifTask(data = gameplay[, -c(2,3)], target = "winner")
n    <- getTaskSize(task)
train_set <- sample(n, size = 0.8*n)
t <- c(1:n)
test_set  <- sample(t[-train_set])

learner <- makeLearner("classif.randomForest", predict.type = "prob")

m    <- train(learner, task, subset = train_set) 
p    <- predict(m, task, subset = test_set, measures = list(acc, bac, auc))
performance(p, measures = list(acc, mmce))


