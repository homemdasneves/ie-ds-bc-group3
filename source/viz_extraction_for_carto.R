library(sqldf)

data = fread("Aug_2017.csv")

data$orig_dest = paste(data$ORIGIN, data$DEST, sep="-")
data$is_delay = data$ARR_DELAY > 0

## extraction for carto map
airport_delays = 
  sqldf("select DEST, DEST_CITY_NAME, sum(ARR_DELAY) as agg_delay
        from data 
        where ARR_DELAY > 0
        group by DEST, DEST_CITY_NAME
        order by DEST, DEST_CITY_NAME") 

airport_delays$state = sapply(airport_delays$DEST_CITY_NAME, function (x) str_sub(x,-2)) 

