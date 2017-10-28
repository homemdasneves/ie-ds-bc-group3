install.packages("data.table")
library(data.table)

path = "C:\\work\\projetos\\ie-ds-bootcamp\\Amadeus\\"

setwd(path)
getwd()

file = fread("raw_data\\pax_FULL.csv")
names(file) = c("RecLoc","Age","Nationality","Title")

paula_sample = read.csv(file="paula_trips_sample.csv", header=TRUE, sep=";")
names(paula_sample) = c("RecLoc","ArrivalTime","BusinessLeisure","CabinCategory","CreationDate","CurrencyCode","DepartureTime","Destination","OfficeIdCountry","Origin","TotalAmount")







sample_reclocs = paula_sample$RecLoc

num_parts = 9
full_file_size = dim(file)[1]
part_size = full_file_size / num_parts

# get matching records (paula sample vs pax file), in separate files
for (min in seq(0,full_file_size, part_size)) {
  max = min + part_size
  
  print(paste("min: ", min, ", max: ", max))
  file_part = file[min:max,]
  
  file_part_filtered = file_part[is.element(file_part$RecLoc, sample_reclocs),]
  filename = paste(min/part_size,"_filtered.csv",sep = "")
  write.csv(file_part_filtered, file = filename)
  gc()
}

# load the files and merge them
merged_pax = NULL
for (i in seq(0, num_parts-1)) {
  data = read.csv(paste(i,"_filtered.csv", sep = ""), header = FALSE)
  
  merged_pax = rbind(merged_pax, data)
}

# cleanup first col and first row 
merged_pax = merged_pax[-1,-1]

names(merged_pax) = c("RecLoc","Age","Nationality","Title")

# repeated values!!!
dim(merged_pax)
dim(paula_sample)

length(unique(merged_pax$RecLoc))
length(unique(paula_sample$RecLoc))

full_pax_trips_sample = merge(merged_pax, paula_sample, by="RecLoc")
dim(full_pax_trips_sample)

write.csv(full_pax_trips_sample, file = "full_pax_trips_sample.csv")

