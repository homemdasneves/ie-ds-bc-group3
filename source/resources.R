library(data.table)
library(dplyr)
library(tictoc)
library(stringr)

BASE_FOLDER_NAME = "ie-ds-bc-group3"
DATA_FOLDER_NAME = "data"

# tries to load a package, installing it if necessary
smart_load <- function(pname) 
{
  print(pname)
  
  if (!is.element(pname, installed.packages()[,1]))
  {
    print("need to install package")
    install.packages(pname)
    require(pname, character.only = TRUE)
  }
  else {
    print("package already installed")
    require(pname, character.only = TRUE)
  }
}

# auto-set the data-path
auto_set_wd <- function() 
{
  if (require("rstudioapi") && require("stringr"))
  {
    path = dirname(rstudioapi::getActiveDocumentContext()$path)
    
    # get the full base path
    reg_ex = paste(".*",BASE_FOLDER_NAME,"/", sep = "")
    data_path = paste(str_extract(path, reg_ex), DATA_FOLDER_NAME, sep = "")
    
    setwd(data_path)  
  }
}

# ivan's tips to have a glimpse of the data
full_pax_trips_sample = fread("full_pax_trips_sample.csv")
full_pax_trips_sample[1:5] %>% t # transpose the top 5 rows (this way it never breaks)

# alternatives
head(full_pax_trips_sample)
str(full_pax_trips_sample)
glimpse(full_pax_trips_sample) 

# the function that ivan suggested
# outputs the counts for 100 top records in every column
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





