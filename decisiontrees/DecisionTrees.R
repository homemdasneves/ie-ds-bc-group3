# LOAD THE DATASET (AUGUST 2017)
setwd("E:/Transformación Digital/Data Science/DataSet")
data <- read.csv("139381196_T_ONTIME.csv",header = T)
nrow(data)
summary(data)
str(data)

################# DECISION TREES
# SOME DATA FOR BUILDING THE MODEL AND TRAINING THE AGORITHM
# ANOTHER DATA FOR TESTING THE ALGORITHM
install.packages("C50")
library(C50)
head(data)
# reorder the data randomly, it's interested because in some data set the data 
# is order in a way that it could be distort the model we want to build
data <- data[sample(nrow(data)), ]

# choose the variables for building the tree
# it's not interesting unique values or columns with a lot of different values.
# we are going to select columns with a little different values
summary(data)

uniqueValues <- function(df){
  for (col in names(df)){
    print(paste("Col", col, " diff values ", nrow(unique(data[col]))))
  }
}

uniqueValues(data)

########### FIRST ATTEMPT 
data <- data[, c("DAY_OF_WEEK", "AIRLINE_ID", "DEP_DEL15", "DEP_TIME_BLK", "ARR_DEL15")]
data <- data[complete.cases(data), ]

# variables to build the tree
x <- data[, c("DAY_OF_WEEK", "AIRLINE_ID", "DEP_DEL15", "DEP_TIME_BLK")]
# the variable we want to predict
y <- data[, c("ARR_DEL15")]

# rule ot 2/3
# 2/3 for training
nrow(data)*(2/3) # 332108
nrow(data)*(1/3) # 166055
trainx <- x[1:332108,]
trainy <- y[1:332108]
# 1/3 for testing
testx <- x[332109:498163,]
testy <- y[332109:498163]

# convert all the variables to a factor
trainx$DAY_OF_WEEK <- as.factor(trainx$DAY_OF_WEEK)
trainx$AIRLINE_ID <- as.factor(trainx$AIRLINE_ID)
trainx$DEP_TIME_BLK <- as.factor(trainx$DEP_TIME_BLK)
trainx$DEP_DEL15 <- as.factor(trainx$DEP_DEL15)
testx$DAY_OF_WEEK <- as.factor(testx$DAY_OF_WEEK)
testx$AIRLINE_ID <- as.factor(testx$AIRLINE_ID)
testx$DEP_TIME_BLK <- as.factor(testx$DEP_TIME_BLK)
testx$DEP_DEL15 <- as.factor(testx$DEP_DEL15)
testy <- as.factor(testy)
trainy <- as.factor(trainy)

# generate the model and observe the results
model <- C50::C5.0(trainx, trainy)
summary(model)
plot(model)

# test the predictive capacity of the model
p <- predict(model, testx, type="class")
sum(p == testy)/length(p)
# 92% of success 

####SECOND ATTEMPT

# LOAD DATA
data <- read.csv("139381196_T_ONTIME.csv",header = T)

# REORDER THE DATA RANDOMLY
data <- data[sample(nrow(data)), ]

# ONLY COLUMNS WE ARE GOING TO USE
data <- data[, c("DAY_OF_WEEK", "AIRLINE_ID", "DEP_TIME_BLK", "ARR_DEL15")]
# REMOVE EMPTY VALUES
data <- data[complete.cases(data), ]

# variables to build the tree
x <- data[, c("DAY_OF_WEEK", "AIRLINE_ID", "DEP_TIME_BLK")]
# the variable we want to predict
y <- data[, c("ARR_DEL15")]

# rule ot 2/3
# 2/3 for training
nrow(data)*(2/3) # 332108
nrow(data)*(1/3) # 166055
trainx <- x[1:332108,]
trainy <- y[1:332108]
# 1/3 for testing
testx <- x[332109:498163,]
testy <- y[332109:498163]

trainx$DAY_OF_WEEK <- as.factor(trainx$DAY_OF_WEEK)
trainx$AIRLINE_ID <- as.factor(trainx$AIRLINE_ID)
trainx$DEP_TIME_BLK <- as.factor(trainx$DEP_TIME_BLK)
testx$DAY_OF_WEEK <- as.factor(testx$DAY_OF_WEEK)
testx$AIRLINE_ID <- as.factor(testx$AIRLINE_ID)
testx$DEP_TIME_BLK <- as.factor(testx$DEP_TIME_BLK)
testy <- as.factor(testy)
trainy <- as.factor(trainy)

# generate the model and observe the results
model <- C50::C5.0(trainx, trainy)
summary(model)
plot(model)

# test the predictive capacity of the model
p <- predict(model, testx, type="class")
sum(p == testy)/length(p)
# 79 % of success
