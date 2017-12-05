# references:
# https://www1.ncdc.noaa.gov/pub/data/cdo/documentation/LCD_documentation.pdf
# https://www.ncdc.noaa.gov/orders/qclcd/

# Weather Data Dictionary
# Visibility:  he horizontal distance an object can be seen and identified given in whole miles. 
# DryBulbCelsius:the dry - bulb temperature and is commonly used as the standard air temperature reported
# DewPointCelsius:the temperature at which air will condense when in contact with a colder surface than the air. When the temperature is below the freezing point of water, the dew point is called the frost point.
# RelativeHumidity:relative humidity given to the nearest whole percentage
# WindSpeed:wind speed in miles per hour
# Altimeter:Atmospheric pressure reduced to sea level using temperature profile of the “standard” atmosphere. Given in inches of Mercury(in Hg) .

# Aux functions
# tries to load a package, installing it if necessary
smart_load <- function(pname) {
    print(pname)

    if (!is.element(pname, installed.packages()[, 1])) {
        print("need to install package")
        install.packages(pname)
        require(pname, character.only = TRUE)
    }
    else {
        print("package already installed")
        require(pname, character.only = TRUE)
    }
}

smart_load("ggplot2")
smart_load("data.table")
smart_load("lubridate")
smart_load("stringr")

clean_weather_data <- function(file, our_airports, weather_stations)
{
    data = fread(file, na.strings = "M") # M represents a missing val
  
    # perform the join using the merge function
    # set the ON clause as keys of the tables:
    setkey(data,WBAN)
    setkey(weather_stations, WBAN)
    weather_data <- merge(data, weather_stations, by="WBAN")
  
    # remove unwanted columns
    weather_data = weather_data[, .(Iata = CallSign, Date, Time, Visibility,
                                    DryBulbCelsius, DewPointCelsius, RelativeHumidity,
                                    WindSpeed, Altimeter
                                    # TODO: use these columns?
                                    #WeatherType, WeatherTypeFlag 
    )]
  
    # remove unwanted airports
    weather_data = weather_data[Iata %in% our_airports]
  
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

cleanAndBundleWeatherFiles = function(folder, output_file) {

    print("loading flights...")
    flights_data = fread("data/test.csv")
    our_airports = unique(flights_data$ORIGIN)

    # associate wban (station id) with iata code (call sign)
    # we need to join station.txt data
    print("loading weather stations...")
    weather_stations = fread("data/weather/201609station.txt")
    weather_stations = weather_stations[, .(WBAN, CallSign, TimeZone)]

    bundle = data.table(NULL)
    filenames = list.files(folder, pattern="*hourly.txt", full.names=TRUE)
    for (file in filenames) {

        print("loading weather file...")
        print(file)
    
        clean_data = clean_weather_data(file, our_airports, weather_stations)
        bundle = rbind(bundle, clean_data)
    }
  
    # convert types: Visibility, DryBulbCelsius, DewPointCelsius, RelativeHumidity, WindSpeed, Altimeter
    print("converting types...")
    convertTypes(bundle)
  
    # nearest full hour - for merging
    bundle[, Hour:= substring(str_pad(Time, 4, pad = "0"), 1, 2)] 
  
    # deal with missing values 
    # missingCounts = getMissingCounts(bundle) 
    # missing_visibility_ids = which(is.na(bundle$Visibility))
    print("imputing missing vals...")
    imputeMissingVals(bundle)

    # there are multiple observations in same hour (even tough it should be hourly)
    # eliminate duplicates
    weather_no_dupes = bundle[, lapply(.SD, mean), by = .(Iata, Date, Hour)]

    # prepare for merge: filter out unnecessary columns, and fix formats
    # final format: iata, date (2017-08-01), hour (2355 -> 23), Visibility, ...

    fwrite(
        weather_no_dupes[, .(Iata, Date, Hour, Visibility, DryBulbCelsius, DewPointCelsius, RelativeHumidity, WindSpeed, Altimeter
                #WeatherType, WeatherTypeFlag # TODO: use these columns?
                )], 
        file = output_file
        )

    return(weather_no_dupes)
}

mergeWeatherWithFlights = function(flights_data, weather) {

    convertTypes(weather)
    weather[, Hour := substring(str_pad(Hour, 2, pad = "0"), 1, 2)]
    weather[Hour == "00", Hour := "24"] # replace 00 -> 24

    # - create the flight keys 
    flights_data[, orig_key := paste0(ORIGIN, "|", FLIGHT_DATE, "|", substring(str_pad(DEPARTURE_TIME, 4, pad = "0"), 1, 2))]
    # adjust for flights that arrive the next day
    flights_data[, dest_key := paste0(DESTINATION, "|", ifelse((as.integer(ARRIVAL_TIME) < as.integer(DEPARTURE_TIME)),
                                      as.character(lubridate::ymd(FLIGHT_DATE) + lubridate::days(1)),
                                      FLIGHT_DATE),
                               "|", substring(str_pad(ARRIVAL_TIME, 4, pad = "0"), 1, 2))]
    # check out the new keys
    t(flights_data[1:3, .(ORIGIN, DESTINATION, FLIGHT_DATE, DEPARTURE_TIME, ARRIVAL_TIME, orig_key, dest_key)])

    # setup weather aux datasets
    weather[, key := paste0(Iata, "|", Date, "|", Hour)]

    # merge on the origin flights
    # left join (all.x): keep all flights even if there's no weather match
    setkeyv(weather, c("key"))
    setkeyv(flights_data, c("orig_key"))
    merged_data = merge(x = flights_data, y = weather,
                    by.x = c("orig_key"), by.y = c("key"),
                    all.x = TRUE )

    # merge on the destination flights
    # left join (all.x): keep all flights even if there's no weather match
    setkeyv(flights_data, c("dest_key"))
    merged_data = merge(x = merged_data, y = weather,
                    by.x = c("dest_key"), by.y = c("key"),
                    suffixes = c("_origin", "_destination"), # if there are name conflicts, use this
                    all.x = TRUE)

    # getMissingCounts(merged_data)
}

cut_in_bins = function(x) {
    bins = 10
    if (is.numeric(x)) {
        return(cut(x, bins))
    }
    else {
        return(x)
    }
}

# bundle = cleanAndBundleWeatherFiles(folder = "data/weather", output_file = "data/weather_train.csv")

flights_data = fread("data/train.csv")
weather = fread("data/weather_train.csv")

# checks:
# weather[, .N, by = .(Iata)][order(-N)] # weather observations per airport (should be 8784)
# missing_airports = setdiff(unique(flights_data$ORIGIN), unique(weather$Iata)) # 21 airports without weather data

flights_data[, V1 := NULL] # remove V1 column before merge
merged_data = mergeWeatherWithFlights(flights_data, weather)
merged_data_complete = merged_data[complete.cases(merged_data)] # 3% incomplete
# merged_data_complete_factorized = weather[, lapply(.SD, cut_in_bins)]

names(merged_data_complete)

# incompete airports
# weather[, .N, by = .(Iata)][N < 8784][order(-N)]

# outliers
# outliers = get_outliers_iqr(weather)
# outliers[, lapply(.SD, sum)][, lapply(.SD, function(x) return(x / nrow(weather)))]

# - run the model with and without weather data and compare (c5.0 auto discretizes) 
# - try discretize by ourselves and compare
# - try to find weather info for the missing airports (nearby)
# - ExtraMile: convert weather data in difference from average (test the impact of unusual weather)
# - adjust for flights arriving in a different timezone (always keeping the localtime)
