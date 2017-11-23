# Scripts for loading all the data from all the differents months and return the info and save in a file
appendDataToCSV <- function(folder, destFile = ""){
  setwd(folder)
  entireData <- NULL
  for (file in list.files(folder)){
    if(endsWith(file, ".csv")){
      data <- read.csv(file)
      entireData <- rbind(entireData, data)
    }
  }
  if(destFile != ""){
    write.csv(entireData, file = destFile)
  }
  return(entireData)
}

year <- appendDataToCSV("E:/Transformación Digital/Data Science/DataSet/ie-ds-bc-group3/decisiontrees/data", "year.csv")


#####EDA
setwd("E:/Transformación Digital/Data Science/DataSet/ie-ds-bc-group3/decisiontrees/data")
year <- read.csv("year.csv")
  
str(year)
names(year)
library(DataExplorer)
GenerateReport(year)

summary(year)

######## MISSSING VALUES
missingValues <- function(df){
  dfmissing <- NULL
  for (col in names(df)){
    row <- data.frame(variable = col, 
                      missing_values = sum(!complete.cases(df[col])), 
                      perc_missing_values = sum(!complete.cases(df[col]))/nrow(df)*100)
    dfmissing <- rbind(dfmissing, row)
  }
  return(dfmissing)
}
 
missingValues(year)

head(year[order(year["MONTH"]), ])

#Remove X variable, all empty values, remove column
year$X <- NULL
# 81 % of empty values --> remove column
year$WEATHER_DELAY <- NULL

# The other are not really significant so, remove empty values
year <- year[complete.cases(year), ]

#########

uniqueValues <- function(df){
  vunique <- NULL
  for (col in names(df)){
    if (length(unique(df[, col])) == nrow(df)){
      vunique <- c(vunique, col)    
    }
  }
  return(vunique)
}

uniqueValues(year)

# Remove X.1
# Remove X.1 -> Unique Row Identifier
year$X.1 <- NULL

summary(year)


cormat <- round(cor(year[,sapply(year,is.numeric)]), 2)

library(reshape2)
melted_cormat <- melt(cormat)
head(melted_cormat)

library(ggplot2)
ggplot(data = melted_cormat, aes(x=Var1, y=Var2, fill=value)) + 
  geom_tile()

# Get lower triangle of the correlation matrix
get_lower_tri<-function(cormat){
  cormat[upper.tri(cormat)] <- NA
  return(cormat)
}
# Get upper triangle of the correlation matrix
get_upper_tri <- function(cormat){
  cormat[lower.tri(cormat)]<- NA
  return(cormat)
}

upper_tri <- get_upper_tri(cormat)
upper_tri

# Melt the correlation matrix
library(reshape2)
melted_cormat <- melt(upper_tri, na.rm = TRUE)
# Heatmap
library(ggplot2)
ggplot(data = melted_cormat, aes(Var2, Var1, fill = value))+
  geom_tile(color = "white")+
  scale_fill_gradient2(low = "blue", high = "red", mid = "white", 
                       midpoint = 0, limit = c(-1,1), space = "Lab", 
                       name="Pearson\nCorrelation") +
  theme_minimal()+ 
  theme(axis.text.x = element_text(angle = 45, vjust = 1, 
                                   size = 12, hjust = 1))+
  coord_fixed()


reorder_cormat <- function(cormat){
  # Use correlation between variables as distance
  dd <- as.dist((1-cormat)/2)
  hc <- hclust(dd)
  cormat <-cormat[hc$order, hc$order]
}

# Reorder the correlation matrix
cormat <- reorder_cormat(cormat)
upper_tri <- get_upper_tri(cormat)
# Melt the correlation matrix
melted_cormat <- melt(upper_tri, na.rm = TRUE)
# Create a ggheatmap
ggheatmap <- ggplot(melted_cormat, aes(Var2, Var1, fill = value))+
  geom_tile(color = "white")+
  scale_fill_gradient2(low = "blue", high = "red", mid = "white", 
                       midpoint = 0, limit = c(-1,1), space = "Lab", 
                       name="Pearson\nCorrelation") +
  theme_minimal()+ # minimal theme
  theme(axis.text.x = element_text(angle = 45, vjust = 1, 
                                   size = 12, hjust = 1))+
  coord_fixed()
# Print the heatmap
print(ggheatmap)


ggheatmap + 
  geom_text(aes(Var2, Var1, label = value), color = "black", size = 4) +
  theme(
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    panel.grid.major = element_blank(),
    panel.border = element_blank(),
    panel.background = element_blank(),
    axis.ticks = element_blank(),
    legend.justification = c(1, 0),
    legend.position = c(0.6, 0.7),
    legend.direction = "horizontal")+
  guides(fill = guide_colorbar(barwidth = 7, barheight = 1,
                               title.position = "top", title.hjust = 0.5))

# save corr.png

# Corr 1 with DEST_AIRPORT_ID
year$DEST_AIRPORT_SEQ_ID <- NULL
# Corr 1 with ORIGIN_AIRPORT_ID
year$ORIGIN_AIRPORT_SEQ_ID <- NULL

# Corr 1 with CARRIER (GenerateReport)
year$UNIQUE_CARRIER <- NULL

# 0.97 Correlative with month, so remove, the threshold is 0.8
year$QUARTER <- NULL

summary(year)
str(year)

uniqueValues <- function(df){
  for (col in names(df)){
    print(paste("Col", col, " diff values ", nrow(unique(data[col]))))
  }
}

uniqueValues(year)

### Convert to factor
year$YEAR <- as.factor(year$YEAR)
year$MONTH <- as.factor(year$MONTH)
year$DAY_OF_MONTH <- as.factor(year$DAY_OF_MONTH)
year$DAY_OF_WEEK <- as.factor(year$DAY_OF_WEEK)
year$AIRLINE_ID <- as.factor(year$AIRLINE_ID)
year$CARRIER <- as.factor(year$CARRIER)
year$ORIGIN_AIRPORT_ID <- as.factor(year$ORIGIN_AIRPORT_ID)
year$ORIGIN_WAC <- as.factor(year$ORIGIN_WAC)
year$DEST_AIRPORT_ID <- as.factor(year$DEST_AIRPORT_ID)
year$DEST_WAC <- as.factor(year$DEST_WAC)
year$DEP_DEL15 <- as.factor(year$DEP_DEL15)
year$DEP_TIME_BLK <- as.factor(year$DEP_TIME_BLK)
year$ARR_DEL15 <- as.factor(year$ARR_DEL15)
year$CANCELLED <- as.factor(year$CANCELLED)
year$DIVERTED <- as.factor(year$DIVERTED)

# mutual information between airline_id y carrier
library(infotheo)
mutinformation(year$AIRLINE_ID, year$CARRIER)
chisq.test(year$AIRLINE_ID, year$CARRIER)
chisq.test(year$AIRLINE_ID, year$DEST_WAC)

library(DataExplorer)
GenerateReport(year[, c("AIRLINE_ID","CARRIER")])

# They are the same
year$AIRLINE_ID <- NULL

# The sama value among all the data set
# so remove
unique(year$CANCELLED)
unique(year$DIVERTED)
plot(year$CANCELLED)
plot(year$DIVERTED)
year$CANCELLED <- NULL
year$DIVERTED <- NULL

## Look for outliers
png("boxplot.png")
boxplot(year$ARR_DELAY)
dev.off()
plotColumns <- function(df){
  for(col in names(df)){
    print(paste0(col, ".png"))
    png(paste0(col, ".png"))
    plot(year[col])
    dev.off()
  }
}

densityplotColumns <- function(df){
  for(col in names(df)){
    print(paste0(col, ".png"))
    png(paste0(col, ".png"))
    plot(density(year[col]))
    dev.off()
  }
}

names(year)
densityplotColumns(year)

write.csv(year, "year_clean.csv")

str(year)

library(gpairs)
data <- year[, c("AIRLINE_ID", "CARRIER")]
data <- year[sample(nrow(year), 1000), ]
gpairs(data)

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

library(gpairs)
gpairs(year)
