smart_load("ggplot2")
smart_load("data.table")

data = fread("data/train2.csv")

# delay / ontime ratio for airlines (normalized by nr of flights)

flights_by_airline = data[, .(N_FLIGHTS = .N), by = .(AIRLINE_CODE)][order(-N_FLIGHTS)]
delays_by_airline = data[ARRIVAL_DELAY_15 == 1, .(N_DELAYS = .N), by = .(AIRLINE_CODE)][order(-N_DELAYS)]
ontime_by_airline = data[ARRIVAL_DELAY_15 == 0, .(N_ONTIME = .N), by = .(AIRLINE_CODE)][order(-N_ONTIME)]

airlines = merge(x=flights_by_airline, y=delays_by_airline, by="AIRLINE_CODE")
airlines = merge(x=airlines, y=ontime_by_airline, by="AIRLINE_CODE")

# normalize by number of flights
airlines[, N_DELAYS_NORM := floor(100 * N_DELAYS / N_FLIGHTS)]
airlines[, N_ONTIME_NORM := ceiling(100 * N_ONTIME / N_FLIGHTS)]

airlines = airlines[order(-N_ONTIME_NORM)]

# melt data into long format: airline, type(delay or ontime), value
melt = melt(airlines, id.vars = "AIRLINE_CODE", measure.vars = c("N_DELAYS_NORM", "N_ONTIME_NORM"))

names(melt) = c("Airline", "Legend", "value")
melt[Legend == 'N_DELAYS_NORM', Legend := 'Delayed']
melt[Legend == 'N_ONTIME_NORM', Legend := 'On-Time']

# order
# melt = transform(melt, Airline = reorder(Airline, -value))
# melt$value <- factor(melt$value, levels = unique(as.character(melt$value)))

fill = c("#F64C72", "#242582")

plot = ggplot(melt, aes(x = reorder(melt$Airline, melt$value), y = value, fill = Legend))
plot = plot + geom_bar(stat = "identity", position = "fill")
plot = plot + labs(x = "Airlines", y = "Delay Percentage")
#plot = plot + geom_text(data = melt, aes(x = Airline, y = value,
    #label = paste0(value, "%")),
    #colour = "white", family = "Montserrat", size = 10)
#plot = plot + theme(
        #plot.title = element_text(colour = "white", family = "Montserrat", size = 24),
        #text = element_text(colour = "white", size = 18, family = "Montserrat"),
        #axis.ticks.x = element_line(colour = "white"),
        #axis.ticks.y = element_line(colour = "white"),
        #axis.text.x = element_text(colour = "white", size = 16, angle = 90, vjust = 0.5),
        #axis.text.y = element_text(colour = "white", size = 16))
plot = plot + theme(axis.line = element_line(size = 1, colour = "white"),
        panel.grid.major = element_line(colour = "white"),
        panel.grid.minor = element_blank(),
        panel.border = element_rect(fill = "transparent", colour = NA),
        plot.background = element_rect(fill = "transparent", colour = NA),
        legend.background = element_rect(fill = "transparent", colour = NA),
        panel.background = element_rect(fill = "transparent", colour = NA))
plot = plot + scale_fill_manual(values = fill)
plot

#png('top_airlines_ggplot_fill.png', width = 700, height = 400, units = "px", type = "cairo", bg = "transparent")
#print(plot)
#dev.off()


#ggsave("top_airlines_ggplot_fill.png", plot = last_plot(),
    #scale = 1.5, width = NA, height = NA, dpi = 300, limitsize = TRUE)


