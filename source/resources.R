

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

smart_load("data.table")
smart_load("dplyr")
smart_load("stringr")
smart_load("rstudioapi")

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
#auto_set_wd()
#getwd()

# ivan's tips to have a glimpse of the data
#full_pax_trips_sample = fread("full_pax_trips_sample.csv")
#full_pax_trips_sample[1:5] %>% t # transpose the top 5 rows (this way it never breaks)

# alternatives
#head(full_pax_trips_sample)
#str(full_pax_trips_sample)
#glimpse(full_pax_trips_sample) 

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
# value_counts(data)

# usage example
#summary = value_counts(data)
#summary[1:5] %>% t

#View(summary)
#fwrite(summ, "summary_count.csv", sep = ",", dec = ".")


# return the names of the columns that contain just numeric values
getNumericColumns <- function(dataFrame) {
  
  is.numeric_data.frame = function(x)all(sapply(x,is.numeric))
  
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
    for (colName in columns)
    {
      print(colName)
      
      # a data.table is indexed differently from a data.frame
      if (is.na(match('data.table',class(dataFrame))))
        column = dataFrame[,colName]
      else
        column = dataFrame[,colName,with=FALSE]
      
      # check if is numeric
      # for data.table's:  dataFrame[,colName, with=FALSe]
      if (is.numeric_data.frame(column)) {
        numeric_cols = c(numeric_cols, colName)
      }
    }
    return(numeric_cols)
  }
}

getMissingCounts <- function(dataFrame) {
  
  if (!is.data.frame(dataFrame))
  {
    print("not a data frame")
    return(NULL)
  }
  else {
    # get the names of the columns into the columns var
    columns <- names(dataFrame)
    
    cols <- NULL
    rows = dim(dataFrame)[1]
    
    # loop through the columns 
    for (colName in columns)
    {
      # a data.table is indexed differently from a data.frame
      if (is.na(match('data.table',class(dataFrame))))
        column = dataFrame[,colName]
      else
        column = dataFrame[,colName,with=FALSE]
      
      ratio = 100*sum(!complete.cases(column))/rows
      cols = c(cols, ratio)
    }
    
    df <- data.frame(missing_ratio = cols)
    rownames(df) <- names(dataFrame)
    
    return(df)
  }
}

# detect outliers using IQR
# still not fixed for data tables and data frames
get_outliers_iqr = function(df)
{
  columns = getNumericColumns(df)  
  result = NULL
  
  for (colName in columns)
  {
    # a data.table is indexed differently from a data.frame
    if (is.na(match('data.table',class(df))))
    {
      column = df[,colName]
    }
    else {
      column = df[,colName,with=FALSE][[1]]
    }
    
    upper <- quantile(column)[4] + 1.5*IQR(column)
    lower <- quantile(column)[2] - 1.5*IQR(column)
    
    outliers = sapply(column, function(x) upper < x || x < lower)
    result = cbind(result, outliers)
  }
  
  # convert the matrix to a datatable
  out = as.data.table((result))
  names(out) = columns
  return(out)
}

# correlations
# TODO: get another version, whith a treshold input T and we get correlations above T
get_correlations = function(df)
{
  num_cols = getNumericColumns(df)
  
  if (is.na(match('data.table',class(df))))
        aux_df = df[,num_cols]
      else
        aux_df = df[,num_cols,with=FALSE]
  
  return(cor(aux_df))
}


# 
getFormula = function (target, predictors)
{
  return(as.formula(paste(target,"~",do.call(paste,c(as.list(predictors),sep="+")))))
}


getFormula <- function(target,predictors) {
  return(as.formula(paste(target,"~",do.call(paste,c(as.list(predictors),sep="+")))))
}

backwardRSquared <- function(data, target, predictors) {
  
  # todo: put this to work with factors (dummies package)
  # dummies: turns factors into numbers
  
  # this is a drawback: we're using only the numeric cols
  predictors <- predictors[which(sapply(data[,predictors],is.numeric))]
  
  while(TRUE) {
    f <- getFormula(target,predictors)
    model <- lm(f,data)
    current <- summary(model)$adj.r.squared
    
    # get the Adjusted R-squared values for the removal of all predictors
    adjrs <- sapply(predictors, function(x)
      summary(lm(getFormula(target,predictors[-which(predictors == x)]),data))$adj.r.squared
      )
    
    # if we can't improve by removing any of the predictors, return the model
    if (current > max(adjrs)) {
      return(model)
    }
    
    # choose to remove the predictor which upon removal will get the max adjusted r sq
    predictors <- predictors[-which(adjrs == max(adjrs))]
  }
}

# Carlos' version - unmodified 
backwardPValue <- function(data, target, predictors) {
  
  predictors <- predictors[which(sapply(data[,predictors],is.numeric))]
  
  repeat {
    f <- getFormula(target,predictors)
    model <- lm(f,data)
    pvalues <- summary(model)$coefficients[-1,4]
    print(summary(model))
    imax = which(pvalues == max(pvalues))
    if (pvalues[imax] < 0.05 | length(predictors) == 1) {
      return(model)
    }
    predictors <- predictors[-imax]
  }
}

forwardRSquared <- function(data, target, predictors) {
  
  predictors <- predictors[which(sapply(data[,predictors],is.numeric))]
  candidates <- NULL
  repeat {
    if (length(candidates) > 0) {
      f <- getFormula(target,candidates)
      model <- lm(f,data)
      current <- summary(model)$adj.r.squared
    } else {
      current <- 0
    }
    print(paste("Current features: ",do.call(paste,as.list(candidates)), "Adjusted R squared: ",current))
    adjrs <- sapply(predictors, function(x)
      summary(lm(getFormula(target,c(candidates,x)),data))$adj.r.squared)
    if (current > max(adjrs)) {
      return(model)
    }
    imax = which(adjrs == max(adjrs))
    candidates <- c(candidates,predictors[imax])
    predictors <- predictors[-imax]
  }
}

# by Morane
statmode=function(x){
  freq=table(x)
  names(which(freq==max(freq,na.rm=TRUE)))
}
