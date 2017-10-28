install.packages("data.table")
library(data.table)

install.packages("parsedate")
library("parsedate")

install.packages("stringr")
library("stringr")

install.packages("DataExplorer")
library(DataExplorer)

# source("C:\\work\\projetos\\ie-ds-bootcamp\\R Coding\\my-resources.R")

# load data
# check column types
# obtain summary of data:
#   - mean, sd, quantiles, range, min, max
#   - histograms
# checking missing values - meaning
#   - substitute by valid values (imputation)
# query in sql-lite
# contigency tables

# file = fread("C:\\work\\projetos\\ie-ds-bootcamp\\Amadeus\\trips.csv")

# # load a smaller sample
# set.seed(12345) # set the seed so that we all get the same results
# mydata = file[sample(nrow(file), 1000)]
# attach(mydata)

# load the merged dataset ~35k rows
mydata = read.csv("/Users/loftis/ie-ds-bc-group3/data/full_pax_trips_sample.csv", sep=",")
attach(mydata)

names(mydata)
#  "X"               "RecLoc"          "Age"             "Nationality"     "Title"          
#  "ArrivalTime"     "BusinessLeisure" "CabinCategory"   "CreationDate"    "CurrencyCode"   
#  "DepartureTime"   "Destination"     "OfficeIdCountry" "Origin"          "TotalAmount"

head(mydata)

# # check column types
# print_types(mydata)

mydata$Arrival_date = sapply(ArrivalTime, function(x) strftime(parse_date(x), format="%x"))
mydata$Arrival_year = sapply(ArrivalTime, function(x) strftime(parse_date(x), format="%Y"))
mydata$Arrival_month = sapply(ArrivalTime, function(x) strftime(parse_date(x), format="%m"))
mydata$Arrival_day = sapply(ArrivalTime, function(x) strftime(parse_date(x), format="%d"))
mydata$Arrival_weekday = sapply(ArrivalTime, function(x) strftime(parse_date(x), format="%A"))
mydata$Arrival_weekdaynum = sapply(ArrivalTime, function(x) strftime(parse_date(x), format="%w"))

mydata$Departure_date = sapply(DepartureTime, function(x) strftime(parse_date(x), format="%x"))

mydata$Departure_year = sapply(DepartureTime, function(x) strftime(parse_date(x), format="%Y"))
mydata$Departure_month = sapply(DepartureTime, function(x) strftime(parse_date(x), format="%m"))
mydata$Departure_day = sapply(DepartureTime, function(x) strftime(parse_date(x), format="%d"))

mydata$Departure_weekday = sapply(DepartureTime, function(x) strftime(parse_date(x), format="%A"))
mydata$Departure_weekdaynum = sapply(DepartureTime, function(x) strftime(parse_date(x), format="%w"))

"2457211" "2458054"

julian_to_unix(as.numeric("2457211"))

strftime(parse_date("2457211"), format="%Y")

# obtain summary of data:
GenerateReport(mydata)

get_outliers_iqr(mydata

# columns with missing values: TotalAmount, CurrencyCode, BusinessLeisure
sum(nchar(BusinessLeisure)==0)
sum(TotalAmount==NA)
sum(nchar(CurrencyCode)==0)

x[nchar(x)==0]

# frequency tables
table(CabinCategory)
table(nPAX)

# table(BusinessLeisure, Destination)


# imputation
for (col in names(data))
{
  if (missing_count[col] > 0) {
    if (class(data[,col]) == "factor") {
      # get the mode, without considering the missing values
      mode = stat_mode(data[!missing_mask[,col],col])
      
      print(paste("mode for",col, "is:", mode))
      
      # replace discrete values with mode
      data[missing_mask[,col],col] = mode
    }
    else {
      # get the median, without considering the missing values
      median = median(data[!missing_mask[,col],col])
      print(paste("median for",col, "is:", median))
      # replace numeric values with median
      missing_mask[missing_mask[,col],col] = median
    }
  }
}

# split gender and maritial status into 2 columns
table(data$personal_status) # check the freq count

females = sapply(data$personal_status,function(x) str_detect("female", paste(x)))
maritial_status = sapply(data$personal_status,function(x) {str_split(paste(x)," ")[[1]][1]})


# 2. outliers
outliers = get_outliers_iqr(mydata)




# possble goals / tasks:
# find connecting flights

# Questions:
# - arrival and departure time - are they effective or expected?
# - if they're effective can we get the expected times?
# - creation date - 
