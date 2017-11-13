smart_load("sqldf")
smart_load("ggplot2")
smart_load("data.table")

data = fread("Aug_2017.csv")
str(data)
names(data)
head(data)

# add orig_dest column
data$orig_dest = paste(data$ORIGIN, data$DEST, sep="-")

orig_dest_delays = 
  sqldf("select orig_dest, count(*) as num_delays
        from data 
        where ARR_DELAY > 15
        group by orig_dest
        order by num_delays desc")
# orig_dest_delays[1:10,]

orig_dest_flights = 
  sqldf("select orig_dest, count(*) as num_flights
        from data 
        group by orig_dest
        order by orig_dest")
# orig_dest_flights[1:10,]

orig_dest_delay_sum = 
  sqldf("select orig_dest, sum(ARR_DELAY) as agg_delay
        from data 
        where ARR_DELAY > 15
        group by orig_dest
        order by orig_dest")
# orig_dest_delay_sum[1:10,]

orig_dest_full = 
  sqldf("select d.orig_dest, num_delays, num_flights, agg_delay
        from orig_dest_delays d
        inner join orig_dest_flights f on d.orig_dest = f.orig_dest
        inner join orig_dest_delay_sum s on d.orig_dest = s.orig_dest
        ")
# orig_dest_full[1:10,]
dim(orig_dest_full)

# melt data into long format: route, type(delay or num), value
melt = melt(orig_dest_full[1:20,], id.vars = "orig_dest", measure.vars = c("num_delays", "num_flights"))

plot = ggplot(melt, aes(x=orig_dest, y=value, fill=variable)) 
plot = plot + geom_bar(stat="identity", position="dodge")
plot = plot + theme(axis.text.x=element_text(angle=90))
plot


