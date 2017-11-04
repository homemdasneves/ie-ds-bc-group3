
setwd("E:/Transformación Digital/Data Science/DataSet/all")
september <- read.csv("september.csv", header = T)
summary(september)
october <- read.csv("october.csv", header = T)
summary(october)
november <- read.csv("november.csv", header = T)
summary(november)
december <- read.csv("december.csv", header = T)
summary(december)
january <- read.csv("january.csv", header = T)
summary(january)
february <- read.csv("february.csv", header = T)
summary(february)
march <- read.csv("march.csv", header = T)
summary(march)
april <- read.csv("april.csv", header = T)
summary(april)
may <- read.csv("may.csv", header = T)
summary(may)
june <- read.csv("june.csv", header = T)
summary(june)
july <- read.csv("july.csv", header = T)
summary(july)
august <- read.csv("august.csv", header = T)
summary(august)

year <- rbind(september, october, november, december, january, february, march, april, may, june, july, august)
head(year)
nrow(year)
write.csv(year, "year.csv")

# REMOVE X COLUMN
year["X"] <- NULL

# REMOVE CARRIER AND AIRLINE_ID
year$AIRLINE_ID <- NULL
year$CARRIER <- NULL
year$ORIGIN_AIRPORT_ID <- NULL
year$DEST_AIRPORT_ID <- NULL

#### RENAME COLUMN NAMES
names(year)
names(year) <- c("YEAR", "QUARTER", "MONTH", "DAY_OF_MONTH", 
                 "DAY_OF_WEEK", "FLIGHT_DATE", "AIRLINE_CODE", "FLIGHT_NUMBER",
                 "ORIGIN", "ORIGIN_CITY", "ORIGIN_WORLD_CODE", "DESTINATION", "DESTINATION_CITY",
                 "DESTINATION_WORLD_CODE", "EXPECTED_DEPARTURE_TIME", "ACTUAL_DEPARTURE_TIME", 
                 "DEPARTURE_DELAY", "EXPECTED_ARRIVAL_TIME", "ACTUAL_ARRIVAL_TIME", 
                 "ARRIVAL_DELAY", "CANCELLED", "DIVERTED", "DISTANCE", "AIRLINE_DELAY", "WEATHER_DELAY",
                 "NATIONAL_AIR_SYSTEM_DELAY", "SECURITY_DELAY", "LATE_AIRCRAFT_DELAY")

summary(year)
str(year)

# CHANGE TYPE COLUMN
year$YEAR <- as.factor(year$YEAR)
year$QUARTER <- as.factor(year$QUARTER)
year$MONTH <- as.factor(year$MONTH)
year$DAY_OF_MONTH <- as.factor(year$DAY_OF_MONTH)
year$DAY_OF_WEEK <- as.factor(year$DAY_OF_WEEK)
year$ORIGIN_WORLD_CODE <- as.factor(year$ORIGIN_WORLD_CODE)
year$DESTINATION_WORLD_CODE <- as.factor(year$DESTINATION_WORLD_CODE)
year$CANCELLED <- as.factor(year$CANCELLED)
year$DIVERTED <- as.factor(year$DIVERTED)

# ANLYSIS
summary(year)
year$ACTUAL_DEPARTURE_TIME[!complete.cases(year$ACTUAL_DEPARTURE_TIME)] <- median(year$ACTUAL_DEPARTURE_TIME[complete.cases(year$ACTUAL_DEPARTURE_TIME)])
year$DEPARTURE_DELAY[!complete.cases(year$DEPARTURE_DELAY)] <- median(year$DEPARTURE_DELAY[complete.cases(year$DEPARTURE_DELAY)])
year$ACTUAL_ARRIVAL_TIME[!complete.cases(year$ACTUAL_ARRIVAL_TIME)] <- median(year$ACTUAL_ARRIVAL_TIME[complete.cases(year$ACTUAL_ARRIVAL_TIME)])
year$ARRIVAL_DELAY[!complete.cases(year$ARRIVAL_DELAY)] <- median(year$ARRIVAL_DELAY[complete.cases(year$ARRIVAL_DELAY)])

library("DataExplorer")
GenerateReport(year)

library(sqldf)
delays <- sqldf("SELECT AIRLINE_CODE, COUNT(*) DELAY FROM year WHERE ARRIVAL_DELAY > 15 GROUP BY AIRLINE_CODE")
no_delays <- sqldf("SELECT AIRLINE_CODE, COUNT(*) NO_DELAY FROM year WHERE ARRIVAL_DELAY <= 15 GROUP BY AIRLINE_CODE")
flights <- sqldf("SELECT AIRLINE_CODE, COUNT(*) TOTAL FROM year GROUP BY AIRLINE_CODE")

total <- merge(delays, flights, by="AIRLINE_CODE")
total$PERC_DELAY = total$DELAY/total$TOTAL

total2 <- merge(delays, no_delays, by="AIRLINE_CODE")
library(ggplot2)

install.packages("reshape")
library(reshape)
dfm <- melt(total2[,c('AIRLINE_CODE','DELAY','NO_DELAY')],id.vars = 1)

od_delays <- sqldf("SELECT ORIGIN, DESTINATION, COUNT(*) DELAY FROM year WHERE ARRIVAL_DELAY > 15 GROUP BY ORIGIN, DESTINATION")
od_no_delays <- sqldf("SELECT ORIGIN, DESTINATION, COUNT(*) NO_DELAY FROM year WHERE ARRIVAL_DELAY <= 15 GROUP BY ORIGIN, DESTINATION")
od_flights <- sqldf("SELECT ORIGIN, DESTINATION, COUNT(*) TOTAL FROM year GROUP BY ORIGIN, DESTINATION")

ggplot(dfm,aes(x = AIRLINE_CODE,y = value)) + 
  geom_bar(aes(fill = variable),stat = "identity",position = "dodge") + 
  scale_y_log10()


barplot(height = total$TOTAL, names.arg = total$AIRLINE_CODE)

detectOutliers <- function(df){
  
}

str(year)

boxplot(year$EXPECTED_DEPARTURE_TIME)
boxplot(year$ACTUAL_DEPARTURE_TIME)
# outliers
boxplot(year$DEPARTURE_DELAY)
boxplot(year$EXPECTED_ARRIVAL_TIME)
boxplot(year$ACTUAL_ARRIVAL_TIME)
# outliers
boxplot(year$ARRIVAL_DELAY)
# outliers
boxplot(year$DISTANCE)

ggplot(year, aes(x = MONTH, y = EXPECTED_DEPARTURE_TIME)) +
  geom_boxplot()

ggplot(year, aes(x = MONTH, y = DEPARTURE_DELAY)) +
  geom_boxplot()

ggplot(dfm,aes(x = AIRLINE_CODE,y = value)) + 
  geom_bar(aes(fill = variable),stat = "identity",position = "dodge") + 
  scale_y_log10()
