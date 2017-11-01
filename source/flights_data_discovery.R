getwd()
setwd("/Users/loftis/Documents/Amadeus")
flights = read.csv("/Users/loftis/Documents/Amadeus/Aug_2017.csv")
library(DataExplorer)

# explore dataset
head(flights)
head(flights) %>% t
dim(flights)
str(flights)
summary(flights)

str(amadeus) #seems like all OK 
summary(amadeus)


#_______identify and remove NAs_______________
attach(flights)
table(complete.cases(YEAR))
table(complete.cases(MONTH))
table(complete.cases(DAY_OF_WEEK))
table(complete.cases(FL_DATE))
table(complete.cases(UNIQUE_CARRIER))
table(complete.cases(AIRLINE_ID))
table(complete.cases(CARRIER))
table(complete.cases(FL_NUM))
table(complete.cases(ORIGIN_AIRPORT_ID))
table(complete.cases(ORIGIN))
table(complete.cases(ORIGIN_WAC))
table(complete.cases(DEST_AIRPORT_ID))
table(complete.cases(DEST))
table(complete.cases(DEST_WAC))
table(complete.cases(CRS_DEP_TIME))
table(complete.cases(DEP_TIME)) #NAs
table(complete.cases(DEP_DELAY)) #NAs
table(complete.cases(CRS_ARR_TIME))
table(complete.cases(ARR_TIME)) #NAs
table(complete.cases(ARR_DELAY)) #NAs
table(complete.cases(CANCELLED))
table(complete.cases(DIVERTED))
table(complete.cases(DISTANCE))
table(complete.cases(X)) #all NAs 
detach(flights)

# create vector to identify rows with missing values
missing = complete.cases(DEP_TIME)+complete.cases(ARR_TIME)+complete.cases(ARR_DELAY)+complete.cases(DEP_DELAY)
table(missing)
# filter out rows with missing values
complete_recs = sapply(missing, function(x) if (x < 4) FALSE else TRUE)
table(complete_recs)

flights_complete = flights[complete_recs,]
dim(flights)
dim(flights_complete)

# check to make sure all missing values have been eliminated
table(complete.cases(flights_complete$DEP_TIME))
table(complete.cases(flights_complete$ARR_TIME))
table(complete.cases(flights_complete$DEP_DELAY))
table(complete.cases(flights_complete$ARR_DELAY))


#_______identify and remove outliers_______________

# identify outliers in departure delay based on IQR method
outliers1 = flights_complete$DEP_DELAY < quantile(flights_complete$DEP_DELAY, 0.25) - 1.5*IQR(flights_complete$DEP_DELAY)
outliers2 = flights_complete$DEP_DELAY > quantile(flights_complete$DEP_DELAY, 0.75) + 1.5*IQR(flights_complete$DEP_DELAY)
# identify outliers in arrival delay based on IQR method
outliers3 = flights_complete$ARR_DELAY < quantile(flights_complete$ARR_DELAY, 0.25) - 1.5*IQR(flights_complete$ARR_DELAY)
outliers4 = flights_complete$ARR_DELAY > quantile(flights_complete$ARR_DELAY, 0.75) + 1.5*IQR(flights_complete$ARR_DELAY)

# combine outlier vector
outliers = outliers1+outliers2+outliers3+outliers4
outliers = sapply(outliers, function(x) if (x > 0) TRUE else FALSE)

# final clean dataset without missing values and without delay outliers
flights_clean = flights_complete[outliers,]


#_______plot variables to get an idea of density, frequencies, etc_______________
names(flights_clean)

plot(density(flights_clean$DEP_TIME))
plot(density(flights_clean$ARR_TIME))

barplot(sort(table(flights_clean$CARRIER)))
barplot(table(flights_clean$DAY_OF_WEEK))

origins = sort(table(ORIGIN_CITY_NAME),decreasing=TRUE)
origins[1:5]
barplot(origins[1:5])

dest = sort(table(DEST_CITY_NAME),decreasing=TRUE)
dest[1:5]
barplot(dest[1:5])

plot(density(flights_clean$DISTANCE))
summary(flights_clean$DISTANCE)

summary(flights_clean$DEP_DELAY)
summary(flights_clean$ARR_DELAY)

#generate report 
GenerateReport(flights_clean)