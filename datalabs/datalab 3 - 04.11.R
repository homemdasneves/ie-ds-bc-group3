

# Generate scaled 4*5 matrix with random std normal samples
set.seed(101)
mat <- scale(matrix(rnorm(20), 4, 5))
dimnames(mat) <- list(paste("Sample", 1:4), paste("Var", 1:5))

# Perform PCA
myPCA <- prcomp(mat, scale. = F, center = F)
myPCA$rotation # loadings
myPCA$x # scores


wine <- read.table("http://archive.ics.uci.edu/ml/machine-learning-databases/wine/wine.data", sep=",")

# Name the variables
colnames(wine) <- c("Cvs","Alcohol","Malic acid","Ash","Alcalinity of ash", "Magnesium", "Total phenols", "Flavanoids", "Nonflavanoid phenols", "Proanthocyanins", "Color intensity", "Hue", "OD280/OD315 of diluted wines", "Proline")

# The first column corresponds to the classes
wineClasses <- factor(wine$Cvs)


# Use pairs to create a scatterplot matrix of all the descriptive variables
pairs(wine[,-1], col = wineClasses, upper.panel = NULL, pch = 16, cex = 0.5)
legend("topright", bty = "n", legend = c("Cv1","Cv2","Cv3"), pch = 16, col = c("black","red","green"),xpd = T, cex = 2, y.intersp = 0.5)


dev.off() # clear the format from the previous plot
winePCA <- prcomp(scale(wine[,-1]))
winePCA <- prcomp(wine[,-1])
plot(winePCA$x[,1:2], col = wineClasses)

winePCA$x[,1:2]


###############

data = fread("year.csv")
head(data)
names(data)

# add new column with delay factor
delays = factor(data$ARR_DELAY > 15)
data$is_delayed = delays

# remove ARR_DELAY column
dim(data)
data$ARR_DELAY <- NULL
dim(data)

# all but the new column
head(data[,1:33])

# apply PCA
dev.off() # clear the format from the previous plot
flightsPCA <- prcomp(scale(data[,1:33]))
flightsPCA <- prcomp(data[,1:33])
plot(flightsPCA$x[,1:2], col = delays)

##########

library(sqldf)

names(data)

data$orig_dest = paste(data$ORIGIN, data$DEST, sep="-")

head(data)

orig_dest_delays = 
  sqldf("select orig_dest, count(*) as num_delays
      from data 
      where ARR_DELAY > 15
      group by orig_dest
      order by orig_dest")
orig_dest_delays[1:10,]

orig_dest_flights = 
  sqldf("select orig_dest, count(*) as num_flights
        from data 
        group by orig_dest
        order by orig_dest")
orig_dest_flights[1:10,]

orig_dest_delay_sum = 
  sqldf("select orig_dest, sum(ARR_DELAY) as agg_delay
        from data 
        where ARR_DELAY > 15
        group by orig_dest
        order by orig_dest")
orig_dest_delay_sum[1:10,]

orig_dest_full = 
  sqldf("select d.orig_dest, num_delays, num_flights, agg_delay
        from orig_dest_delays d
        inner join orig_dest_flights f on d.orig_dest = f.orig_dest
        inner join orig_dest_delay_sum s on d.orig_dest = s.orig_dest
        ")
orig_dest_full[1:10,]

orig_dest_full$ratio = orig_dest_full$num_delays / orig_dest_full$num_flights

orig_dest_full = sqldf("select * 
                       from orig_dest_full 
                       where num_flights > 500
                       order by num_delays desc")

orig_dest_full[1:100,]
dim(orig_dest_full)
 
# try to compute all correlations
# and use them to easily identify most correlated vars
for (i in names(data)){
  for (j in names(data))
  {
     cor(i, j)
  }
}

cor(data$)




cbind(orig_dest_flights, orig_dest_delays)

value_counts(orig_dest_delays)



