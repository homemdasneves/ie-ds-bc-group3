smart_load("sqldf")
smart_load("ggplot2")
smart_load("data.table")

getwd()

data = fread("data/train2.csv")
str(data)

# delay / ontime ratio for airlines (normalized by nr of flights)

flights_by_airline = data[, .(N_FLIGHTS = .N), by = .(AIRLINE_CODE)][order(-N_FLIGHTS)]
delays_by_airline = data[ARRIVAL_DELAY_15 == 1, .(N_DELAYS = .N), by = .(AIRLINE_CODE)][order(-N_DELAYS)]
ontime_by_airline = data[ARRIVAL_DELAY_15 == 0, .(N_ONTIME = .N), by = .(AIRLINE_CODE)][order(-N_ONTIME)]

airlines = merge(   x = flights_by_airline,
                    y = delays_by_airline,
                    by = "AIRLINE_CODE")

airlines = merge(   x = airlines,
                    y = ontime_by_airline,
                    by = "AIRLINE_CODE")

airlines[, N_DELAYS_NORM := floor(100 * N_DELAYS / N_FLIGHTS)]
airlines[, N_ONTIME_NORM := ceiling(100 * N_ONTIME / N_FLIGHTS)]

airlines[order(-N_FLIGHTS)]
airlines[order(N_FLIGHTS)]

# last aux table: airline, num_delays, num_ontime

# melt data into long format: airline, type(delay or ontime), value
melt = melt(airlines, id.vars = "AIRLINE_CODE", measure.vars = c("N_DELAYS_NORM", "N_ONTIME_NORM"))

plot = ggplot(melt, aes(x = AIRLINE_CODE, y = value, fill = variable))
plot = plot + geom_bar(stat="identity", position="fill")
plot = plot + theme(axis.text.x=element_text(angle=90, vjust = 0.5))
plot

ggsave("top_airlines_ggplot_fill.png", plot = last_plot(),
    scale = 1.5, width = NA, height = NA, dpi = 300, limitsize = TRUE)
