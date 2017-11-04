library(data.table)
library(dplyr)
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
auto_set_wd()
getwd()

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

# usage example
summary = value_counts(full_pax_trips_sample)
summary[1:5] %>% t

View(summary)
fwrite(summ, "summary_count.csv", sep = ",", dec = ".")


# return the names of the columns that contain just numeric values
getNumericColumns <- function(dataFrame) {
  
  if (!is.data.frame(dataFrame))
  {
    print("not a data frame")
    return(NULL)
  }
  else {
    
    # get the names of the columns into the columns var
    columns <- names(dataFrame)
    
    numeric_cols <- NULL
    
    # loop through the columns 
    for (col in columns)
    {
      # check if is numeric
      if (is.numeric(dataFrame[,col,with=FALSE])) {
        
        numeric_cols = c(numeric_cols, col)
      }
    }
    return(numeric_cols)
    
  }
}

# detect outliers using IQR
get_outliers_iqr = function(df)
{
  columns = getNumericColumns(df)  
  result = NULL
  
  for (col in columns)
  {
    upper <- quantile(df[,col,with=FALSE])[4] + 1.5*IQR(df[,col,with=FALSE])
    lower <- quantile(df[,col,with=FALSE])[2] - 1.5*IQR(df[,col,with=FALSE])
    
    outliers = sapply(df[,col], function(x) upper < x || x < lower)
    result = cbind(result, outliers)
  }
  
  # convert the matrix to a dataframe
  df = as.data.frame(result)
  names(df) = columns
  return(df)
}





