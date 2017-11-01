library(data.table)
library(dplyr)
library(tictoc)
library(stringr)

# auto-set the data-path
install.packages("rstudioapi")
path = dirname(rstudioapi::getActiveDocumentContext()$path)
data_path = paste(str_extract(path, ".*ie-ds-bc-group3/"), "data", sep = "")
setwd(data_path)

# ivan's tips to have a glimpse of the data
full_pax_trips_sample = fread("full_pax_trips_sample.csv")
full_pax_trips_sample[1:5] %>% t # transpose the top 5 rows (this way it never breaks)

# alternatives
head(full_pax_trips_sample)
str(full_pax_trips_sample)
glimpse(full_pax_trips_sample) 


value_counts <- function(dt)
{
  colnames = names(dt)
  summ = data.table(index = 1:100)
  
  for (col in colnames){
    print(col)
    column = dt[,.N,by=eval(col)][order(-N)][1:100]
    summ = cbind(summ, column)
  }
  
  return(summ)
}

summary = value_counts(full_pax_trips_sample)
summary[1:5] %>% t

View(summary)

fwrite(summ, "summary_count.csv", sep = ",", dec = ".")





