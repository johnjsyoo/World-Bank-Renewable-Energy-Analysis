library(ggplot2)
library(reshape2)
library(RMySQL)

# Import all of our data!
connect = dbConnect(MySQL(), user='root', password='LAX', host='localhost', dbname='wbproject')

energy_data = dbReadTable(conn=connect, name='energydata')
energy_data = attach(energy_data)

usenergy = dbReadTable(conn=connect, name='usenergy')
usenergy = attach(usenergy)

chnenergy = dbReadTable(conn=connect, name='chnenergy')
chnenergy = attach(chnenergy)

# Set columns names to something more appropriate and 
# add the renewable percentage and nonrenewable amounts

colnames(energy_data) = c('country', 'GDP', 'renewable.kwh', 'total.kwh')
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
  ggtitle("Countries that are the Largest Producers of Energy, 2011") +
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
  ggtitle("Countries w/ Largest Percentage of Renewables, 2011")
energypercentage

################################ PREDICTIVE CAUSATION FOR THE US VS CHINA ###################################
# Rename some of our columns
colnames(usenergy) = c('years', 'renewable.kwh', 'total.kwh')
usenergy$renewable.percent = usenergy$renewable.kwh/usenergy$total.kwh

colnames(chnenergy) = c('years', 'renewable.kwh', 'total.kwh')
chnenergy$renewable.percent = chnenergy$renewable.kwh/chnenergy$total.kwh

################################ ENERGY AS A PERCENTAGE COMPARE ###################################
# Create a Single Data Frame From the US and China energy datasets
renewable = data.frame(usenergy$years, 
                       usenergy$renewable.percent, 
                       chnenergy$renewable.percent, 
                       usenergy$total.kwh, 
                       chnenergy$total.kwh)

# Build the Linear Regression Models
RenewablePercentageModel <- lm(usenergy.renewable.percent~chnenergy.renewable.percent, data=renewable)
summary(RenewablePercentageModel)

# Select and Melt the Data for Graphing
renewablepercentage.stacked = renewable[,c(1,2,3)]
colnames(renewablepercentage.stacked) = c('Years', 'US', 'China')
renewablepercentage.melt = melt(renewablepercentage.stacked, id = c("Years"))

# Graph the Data
ggplot(renewablepercentage.melt,aes(x = Years, y = value, color = variable)) + 
  geom_point(shape = 1) +
  scale_colour_hue(l = 50) +
  geom_smooth(method = loess) +
  theme_bw() +
  xlab("Years") +
  ylab("Renewable Energy Percentage") +
  ggtitle("Renewable Energy as a Percentage by Year, US and CHINA")

################################ TOTAL ENERGY PRODUCTION COMPARE ###################################
TotalEnergyModel <- lm(chnenergy.total.kwh~usenergy.total.kwh, data=renewable)
summary(TotalEnergyModel)

renewabletotal.stacked = renewable[,c(1,4,5)]
colnames(renewabletotal.stacked) = c('Years', 'US', 'China')
renewabletotal.melt = melt(renewabletotal.stacked, id = c("Years"))

ggplot(renewabletotal.melt,aes(x = Years, y = value, color = variable)) + 
  geom_point(shape = 1) +
  scale_colour_hue(l = 50) +
  geom_smooth(method = loess, se = FALSE) +
  theme_bw() +
  xlab("Years") +
  ylab("Renewable Energy Production (kWh)") +
  ggtitle("Renewable Energy in kWh by Year, US and CHINA")
