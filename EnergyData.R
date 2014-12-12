library(ggplot2)
library(reshape2)
library(RMySQL)

con=dbConnect(MySQL(),user='root',password='F00disg00d',host='localhost',dbname='IndividualProject')

combined=dbReadTable(conn=con,name='combined')
attach(combined)


setwd("~/Dropbox/IndividualAssignment/")
energy_data = read.csv("energy_data.csv")

# Set columns names to something more appropriate and 
# add the renewable percentage and nonrenewable amounts

colnames(energy_data) = c('country', 'gdp', 'renewable.kwh', 'total.kwh')
energy_data$renewable.percent = energy_data$renewable.kwh/energy_data$total.kwh
energy_data$nonrenewable.kwh = energy_data$total.kwh - energy_data$renewable.kwh

################################ WHO ARE THE TOP ENERGY PRODUCERS IN THE WORLD? ###################################
# Ordering by top largest energy producers 
largestkwh = energy_data[order(-energy_data[,4]),]

# Selecting our data
largestkwh = largestkwh[1:20,]
largestkwh.stacked = largestkwh[,c(1,3,6)]
colnames(largestkwh.stacked) = c('country', 'Renewable', 'Non-Renewable')

# Melt the data
largestkwh.stacked = melt(largestkwh.stacked)
colnames(largestkwh.stacked)[2] = "Energy"

# Ordering the data by order of largest kWh producers
largestkwh.stacked$country = factor(largestkwh.stacked$country, levels = largestkwh.stacked$country[order(largestkwh$total.kwh)])

# Plotting the Graph!
energyproduction = ggplot(largestkwh.stacked, aes(country, value, fill = Energy)) +
  geom_bar(stat = "identity") +
  coord_cartesian(ylim = c(0,6000000000000)) +
  coord_flip() +
  xlab("Countries") +
  ylab("Total Energy Output (kWh)") +
  ggtitle("Countries that are the Largest Producers of Energy") +
  theme_bw() +
  scale_fill_brewer(palette = 11)
energyproduction

################################ WHICH COUNTRIES USE THE LARGEST PERCENTAGE OF RENEWABLES ###################################

# Ordering by top renewables percentages
largestrenewables = energy_data[order(-energy_data[,5]),]

# Selecting our data
largestrenewables = largestrenewables[1:20,]

# Ordering the data by order of largest kWh producers
largestrenewables$country = factor(largestrenewables$country, 
                                   levels = largestrenewables$country[order(largestrenewables$renewable.percent)]
                                   )

# Plot the Graph!
energypercentage = ggplot(largestrenewables, aes(country, renewable.percent)) +
  geom_bar(stat = "identity", fill = "white", colour = "darkgreen") +
  coord_flip() +
  theme_bw() +
  xlab("Countries") +
  ylab("Renewable Energy Percentage") +
  ggtitle("Countries w/ Largest Percentage of Renewables")
energypercentage

  