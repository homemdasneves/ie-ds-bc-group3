

# matrix with a value count per column
# when to choose python or R

path = "C:\\work\\projetos\\ie-ds-bootcamp\\Amadeus\\"

setwd(path)
getwd()

file = fread("raw_data\\pax_FULL.csv")
names(file) = c("RecLoc","Age","Nationality","Title")

paula_sample = read.csv(file="paula_trips_sample.csv", header=TRUE, sep=";")
names(paula_sample) = c("RecLoc","ArrivalTime","BusinessLeisure","CabinCategory","CreationDate","CurrencyCode","DepartureTime","Destination","OfficeIdCountry","Origin","TotalAmount")



full_pax_trips_sample.csv