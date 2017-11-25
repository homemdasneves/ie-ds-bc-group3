smart_load("ggplot2")
smart_load("data.table")
smart_load("lubridate")

# references:
# https://www1.ncdc.noaa.gov/pub/data/cdo/documentation/LCD_documentation.pdf

getwd()

# aux functions
is.leapyear=function(year){
  #http://en.wikipedia.org/wiki/Leap_year
  return(((year %% 4 == 0) & (year %% 100 != 0)) | (year %% 400 == 0))
}

num_days = function(year) {
  if (is.leapyear(year))
    return(366)
  else
    return(365)
}

noaa_file = "weather/201708hourly.txt"
clean_weather_data <- function(noaa_file) 
{
  data = fread(noaa_file)
  
  # associate wban (station id) with iata code (call sign)
  # we need to join station.txt data
  station = fread("weather\\201708station.txt")
  station_filtered = station[,.(WBAN,CallSign,TimeZone)]
  

  # perform the join using the merge function
  # set the ON clause as keys of the tables:
  setkey(data,WBAN)
  setkey(station_filtered,WBAN)
  weather_data <- merge(data, station_filtered, by="WBAN")
  
  # remove unwanted columns
  weather_data = weather_data[,.(Iata = CallSign, Date, Time, Visibility, DryBulbCelsius, 
                                 DewPointCelsius, RelativeHumidity, WindSpeed, Altimeter
                                 #WeatherType, WeatherTypeFlag # TODO: use these columns?
  )]
  
  # remove unwanted airports
  flights_data = fread("Aug_2017.csv")
  our_airports = unique(flights_data$ORIGIN)
  weather_data = weather_data[Iata %in% our_airports]
  
  # in these cols: DewPointCelsius, RelativeHumidity, WindSpeed, Altimeter
  # M represents a missing value - replace by NA
  weather_data[DewPointCelsius == "M", DewPointCelsius:=NA]
  weather_data[RelativeHumidity == "M", RelativeHumidity:=NA]
  weather_data[WindSpeed == "M", WindSpeed:=NA]
  weather_data[Altimeter == "M", Altimeter:=NA]
  weather_data[DryBulbCelsius == "M", DryBulbCelsius:=NA]
  weather_data[Visibility == "M", Visibility:=NA]
  weather_data[Iata == "M", Iata:=NA]
  
  return(weather_data)
}

convertTypes = function(df){
  df[,Visibility := as.numeric(Visibility)]
  df[,DewPointCelsius := as.numeric(DewPointCelsius)]
  df[,DryBulbCelsius := as.numeric(DryBulbCelsius)]
  df[,RelativeHumidity := as.numeric(RelativeHumidity)]
  df[,WindSpeed := as.numeric(WindSpeed)]
  df[,Altimeter := as.numeric(Altimeter)]
  df[,Date := lubridate::ymd(Date)] # lubridate!!!
}

imputeMissingVals = function(df)
{
  # create values to impute (means by week of year - better than overall yearly means)
  df[, VisibilityImp:=round(mean(Visibility, na.rm=T)), by=.(lubridate::week(Date))]
  df[, DryBulbCelsiusImp:=round(mean(DryBulbCelsius, na.rm=T)), by=.(lubridate::week(Date))]
  df[, DewPointCelsiusImp:=round(mean(DewPointCelsius, na.rm=T)), by=.(lubridate::week(Date))]
  df[, RelativeHumidityImp:=round(mean(RelativeHumidity, na.rm=T)), by=.(lubridate::week(Date))]
  df[, WindSpeedImp:=round(mean(WindSpeed, na.rm=T)), by=.(lubridate::week(Date))]
  df[, AltimeterImp:=round(mean(Altimeter, na.rm=T)), by=.(lubridate::week(Date))]
  
  df[is.na(Visibility), Visibility:=VisibilityImp]
  df[is.na(DryBulbCelsius), DryBulbCelsius:=DryBulbCelsiusImp]
  df[is.na(DewPointCelsius), DewPointCelsius:=DewPointCelsiusImp]
  df[is.na(RelativeHumidity), RelativeHumidity:=RelativeHumidityImp]
  df[is.na(WindSpeed), WindSpeed:=WindSpeedImp]
  df[is.na(Altimeter), Altimeter:=AltimeterImp]
}

folder = "weather"
output_file = "weather_year.txt"
# file = "weather/201708hourly.txt"
# raw_noaa_data = fread(noaa_file)
# raw_noaa_data[WBAN == 398,.(WBAN, Date, Time)] # first wban of an airport: PSE
cleanAndBundleWeatherFiles = function(folder, output_file) {
  bundle = data.table(NULL)
  filenames = list.files(folder, pattern="*hourly.txt", full.names=TRUE)
  for (file in filenames) {
    print(file)
    
    clean_data = clean_weather_data(file)
    bundle = rbind(bundle, clean_data)
  }
  
  # convert types: Visibility, DryBulbCelsius, DewPointCelsius, RelativeHumidity, WindSpeed, Altimeter
  convertTypes(bundle)
  
  # nearest full hour - for merging
  bundle[, Hour:= substring(str_pad(Time, 4, pad = "0"), 1, 2)] 
  
  # deal with missing values 
  # missingCounts = getMissingCounts(bundle) 
  # missing_visibility_ids = which(is.na(bundle$Visibility))
  imputeMissingVals(bundle)
  
  # prepare for merge: filter out unnecessary columns, and fix formats
  # final format: iata, date (2017-08-01), hour (2355 -> 23), Visibility, ...
  write.csv(bundle[,.(Iata, Date, Hour, Visibility, DryBulbCelsius, DewPointCelsius,RelativeHumidity, WindSpeed, Altimeter
                #WeatherType, WeatherTypeFlag # TODO: use these columns?
                )], 
            file = output_file)
}


# cleanup all weather files in the data\weather directory
# cleanAndBundleWeatherFiles(folder = "weather", output_file = "weather_year.txt")

# load a previously cleaned weather file
weather = fread("weather_year.txt")
convertTypes(weather)

# merge weather data + flights

# - load flights
flights_year = fread("year_clean.csv")

# - create the flight keys 
flights_year[,orig_key:=paste0(FLIGHT_DATE, "|", substring(str_pad(EXPECTED_DEPARTURE_TIME, 4, pad = "0"), 1, 2))]
# adjust for flights that arrive the next day
flights_year[,dest_key:=paste0(ifelse((as.integer(EXPECTED_ARRIVAL_TIME) < as.integer(EXPECTED_DEPARTURE_TIME)), 
                                      as.character(lubridate::ymd(FLIGHT_DATE) + lubridate::days(1)), 
                                      FLIGHT_DATE), 
                               "|", substring(str_pad(EXPECTED_ARRIVAL_TIME, 4, pad = "0"), 1, 2))] 
# check out the new keys
flights_year[,.(FLIGHT_DATE, EXPECTED_DEPARTURE_TIME, EXPECTED_ARRIVAL_TIME, orig_key, dest_key)]

# setup weather aux datasets
weather_origin = weather[,.(ORIGIN=Iata, 
                            orig_key=paste0(Date, "|", Hour), 
                            Orig_Visibility       = Visibility, 
                            Orig_DryBulbCelsius   = DryBulbCelsius, 
                            Orig_DewPointCelsius  = DewPointCelsius, 
                            Orig_RelativeHumidity = RelativeHumidity, 
                            Orig_WindSpeed        = WindSpeed, 
                            Orig_Altimeter        = Altimeter)]
weather_dest = weather[,.(DESTINATION=Iata, 
                            dest_key=paste0(Date, "|", Hour), 
                            Dest_Visibility       = Visibility, 
                            Dest_DryBulbCelsius   = DryBulbCelsius, 
                            Dest_DewPointCelsius  = DewPointCelsius, 
                            Dest_RelativeHumidity = RelativeHumidity, 
                            Dest_WindSpeed        = WindSpeed, 
                            Dest_Altimeter        = Altimeter)]

# merge on the origin flights
setkeyv(weather_origin, c("ORIGIN", "orig_key"))
setkeyv(flights_year, c("ORIGIN", "orig_key"))
merged_data = merge(x = flights_year, 
                    y = weather_origin, 
                    by=c("ORIGIN", "orig_key"), 
                    all.x=TRUE # left join: keep all flights even if there's no weather match
                    )
# getMissingCounts(merged_data)

# merge on the destination flights
setkeyv(weather_dest, c("DESTINATION", "dest_key"))
setkeyv(flights_year, c("DESTINATION", "dest_key"))
merged_data = merge(x = flights_year, 
                    y = weather_dest, 
                    by=c("DESTINATION", "dest_key"), 
                    all.x=TRUE # left join: keep all flights even if there's no weather match
                    )
write.csv(merged_data, file = "flights_and_weather.csv")

# TODO - in order of importance: 
# (2) round flight's departure time to the next full hour (so that it always matches a previous weather observation)
# (3) adjust for flights arriving in a different timezone (always keeping the localtime)

# TODO (maybe...?) 
# COUNT RECORDS (SHOULD BE 24*NUMDAYS OF YEAR / AIRPORT)

# 3. summary statistics: sd, skew, mean, ...
# summary is useful but SD's are not included
# summary(weather_data)

# get SDs for all columns
# apply(weather_data,2,sd)

# 4. plot data
# plot(data$Sales)
# boxplot(data$Sales)

# 5. detect outliers
# outliers = get_outliers_iqr(weather_data)

# 6. trend







#weather_data[1:10000, 
#             .(Iata, 
#               Date = strftime(parse_date(Date), format="%Y-%m-%d"), 
#               Time = substring(str_pad(Time, 4, pad = "0"), 1, 2), # round weather observation times to the previous hour
#               Visibility, DryBulbCelsius, DewPointCelsius,RelativeHumidity, WindSpeed, Altimeter
#               #WeatherType, WeatherTypeFlag # TODO: use these columns?
#               )] %>% t

# TODO: merge weather data with departures


# TODO: merge weather data with arrivals
# we should take into account the weather at the destination, by the time of departure :)
# because while predicting, we don't know what's the weather like in the destinatation at arrival time (future)
# these calculation should take timezones into consideration





