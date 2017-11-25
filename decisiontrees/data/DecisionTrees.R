##### DECISION TREES
setwd("E:/Transformación Digital/Data Science/DataSet/ie-ds-bc-group3/decisiontrees/data")

data <- read.csv("year_clean.csv")

#### ATTEMPT 1
# INCLUDING DEP_DEL15

#### ATTEMPT 2

# REORDER THE DATA RANDOMLY
data <- year[sample(nrow(year)), ]
names(data)
# ONLY COLUMNS WE ARE GOING TO USE
data <- data[, c("DAY_OF_WEEK", "ORIGIN_WAC", "DEST_WAC", "CARRIER", "DEP_TIME_BLK", "ARR_DEL15")]
# REMOVE EMPTY VALUES
data <- data[complete.cases(data), ]


set.seed(100)

indexes <- sample.int(nrow(data), floor(nrow(data)*0.75))
train <- data[indexes,]
# to obtain the reverse with -, ! is only for logical. - is for numbers
test <- data[-indexes,]

# variables to build the tree
trainx <- train[, c("DAY_OF_WEEK", "ORIGIN_WAC", "DEST_WAC", "CARRIER", "DEP_TIME_BLK")]
# the variable we want to predict
trainy <- train[, c("ARR_DEL15")]

testx <- test[, c("DAY_OF_WEEK", "ORIGIN_WAC", "DEST_WAC", "CARRIER", "DEP_TIME_BLK")]
testy <- test[, c("ARR_DEL15")]

trainx$DAY_OF_WEEK <- as.factor(trainx$DAY_OF_WEEK)
trainx$CARRIER <- as.factor(trainx$CARRIER)
trainx$DEP_TIME_BLK <- as.factor(trainx$DEP_TIME_BLK)
trainx$ORIGIN_WAC <- as.factor(trainx$ORIGIN_WAC)
trainx$DEST_WAC <- as.factor(trainx$DEST_WAC)
testx$DAY_OF_WEEK <- as.factor(testx$DAY_OF_WEEK)
testx$CARRIER <- as.factor(testx$CARRIER)
testx$DEP_TIME_BLK <- as.factor(testx$DEP_TIME_BLK)
testx$ORIGIN_WAC <- as.factor(testx$ORIGIN_WAC)
testx$DEST_WAC <- as.factor(testx$DEST_WAC)

testy <- as.factor(testy)
trainy <- as.factor(trainy)

# generate the model and observe the results
model <- C50::C5.0(trainx, trainy)
summary(model)
plot(model)

# test the predictive capacity of the model
p <- predict(model, testx, type="class")
sum(p == testy)/length(p)
# 81 % of success


vImportance <- C50::C5imp(model, scale = FALSE)
vImportance <- C50::C5imp(model, metric = "splits")
vImportance <- C50::C5imp(model)
plot(vImportance)


# plotting a ROC curve:
install.packages("ROCR")
library(ROCR)
pred <- prediction(as.numeric(p), as.numeric(testy))

perf <- performance( pred, "tpr", "fpr" )
plot(perf)
plot(perf, col=rainbow(10))


par(bg="lightblue", mai=c(1.2,1.5,1,1))
plot(perf, main="ROCR for a decision tree", colorize=TRUE,
     xlab="Mary's axis", ylab="", box.lty=7, box.lwd=5,
     box.col="gold", lwd=17, colorkey.relwidth=0.5, xaxis.cex.axis=2,
     xaxis.col='blue', xaxis.col.axis="blue", yaxis.col='green', yaxis.cex.axis=2,
     yaxis.at=c(0,0.5,0.8,0.85,0.9,1), yaxis.las=1, xaxis.lwd=2, yaxis.lwd=3,
     yaxis.col.axis="orange", cex.lab=2, cex.main=2)

perf1 <- performance(pred, "prec", "rec")
plot(perf1)


## S4 method for signature 'performance, missing':
plot(perf, avg="none", spread.estimate="none",
     spread.scale=1, show.spread.at=c(), colorize=F,
     colorize.palette=rev(rainbow(256,start=0, end=4/6)),
     colorkey=colorize, colorkey.relwidth=0.25, colorkey.pos="right",
     print.cutoffs.at=c(), cutoff.label.function=function(x) { round(x,2) },
     downsampling=0, add=FALSE )


testy
?prediction
class(p)


###### It's not a good model, beacause you obtain a lot of False positived
# Look at confusion matrix
table(p, testy)

# PUT THE PREVIOUS TREE, WITH DEP_DELAY15
# AND THE SECOND WITHOUT THE NAME OF THE AIRPORTS
# without reorder at the beginning
# for testing the last two months

# TRY BOOSTING

# MOVE TO RANDOM FOREST

# DELAY IN FUNCTION OF THE DISTANCE