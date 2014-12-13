# -*- coding: utf-8 -*-
"""
Created on Fri Dec 12 05:07:07 2014

@author: johnjsyoo
"""

# -*- coding: utf-8 -*-
"""
Created on Tue Nov 11 20:51:52 2014

@author: johnjsyoo
"""

import wbdata
import datetime
import pandas as pd
import MySQLdb as myDB

######################### GETTING ENERGY DATA FOR ALL COUNTRIES ##############################

# Setting the date range for our data
data_date = (datetime.datetime(2011, 1, 1))
             
# GDP (current US$)
gdp = wbdata.get_data("NY.GDP.MKTP.CD", data_date=data_date, pandas = True)[44:]
    
# Data on Electricity production from renewable sources (kWh)
renewableProd = wbdata.get_data("EG.ELC.RNEW.KH", data_date=data_date, pandas = True)[44:]
electricityProd = wbdata.get_data("EG.ELC.PROD.KH", data_date=data_date, pandas = True)[44:]

# Convert the time-series data into a Data Frame
gdpDF = pd.DataFrame(gdp)
renewableProdDF = pd.DataFrame(renewableProd)
electricityProdDF = pd.DataFrame(electricityProd)

energyDF = gdpDF.join(renewableProdDF, lsuffix="GDP",rsuffix="Renewable_kWh")
energyDF = energyDF.join(electricityProdDF)
energyDF.rename(columns = {'value':'Electricity_kWh'}, inplace = True)

# Dropping all NaN values and zero values
energyDF = energyDF[energyDF.valueRenewable_kWh != 0]
energyDF = energyDF.dropna()

######################### GETTING PREDICTIVE DATA FOR US MODEL ##############################

countryList = ["USA", "CHN"]

renewableProdUS = []
electricityProdUS = []

renewableProdCHN = []
electricityProdCHN = []

# Function for grabbing energy data for US and China
def stealingEnergy(countryname):
    data_dateUSC = (datetime.datetime(1971, 1, 1), datetime.datetime(2011, 1, 1))
    
   # Data on Electricity production from renewable sources (kWh) for US
    if countryname == "USA":    
        renewableProdUS.extend(wbdata.get_data("EG.ELC.RNEW.KH", data_date=data_dateUSC, country="USA", pandas = True))
        electricityProdUS.extend(wbdata.get_data("EG.ELC.PROD.KH", data_date=data_dateUSC, country="USA", pandas = True))
    else:
        # Data on Electricity production from renewable sources (kWh) for CHN
        renewableProdCHN.extend(wbdata.get_data("EG.ELC.RNEW.KH", data_date=data_dateUSC, country="CHN", pandas = True))
        electricityProdCHN.extend(wbdata.get_data("EG.ELC.PROD.KH", data_date=data_dateUSC, country="CHN", pandas = True))

for country in countryList:
    stealingEnergy(country)

# Reversing the order of years so that it matches our dictionary values
years = range(1971, 2012)
yearsreversed = years[::-1]

usenergy = pd.DataFrame({'years': yearsreversed, 'renewable': renewableProdUS, 'total': electricityProdUS})
usenergy = usenergy.set_index('years')
                         
chnenergy = pd.DataFrame({'years': yearsreversed, 'renewable': renewableProdCHN, 'total': electricityProdCHN})
chnenergy = chnenergy.set_index('years')

######################### EXPORTING THE DATA AND CONNECTING TO MYSQL ##############################

# Reading the data to CSV
energyDF.to_csv('/users/johnjsyoo/Dropbox/IndividualAssignment/energy_data.csv')
usenergy.to_csv('/users/johnjsyoo/Dropbox/IndividualAssignment/usenergy.csv')
chnenergy.to_csv('/users/johnjsyoo/Dropbox/IndividualAssignment/chnenergy.csv')

# World Energy Data
dbConnect = myDB.connect(host='localhost',
                         user='root',
                         passwd='LAX',
                         db='wbproject')

energyDF.to_sql(con=dbConnect,
                name='energydata',
                if_exists='replace',
                flavor='mysql')

# US Energy Data         
usenergy.to_sql(con=dbConnect,
                name='usenergy',
                if_exists='replace',
                flavor='mysql')
                
# China Energy Data         
chnenergy.to_sql(con=dbConnect,
                 name='chnenergy',
                 if_exists='replace',
                 flavor='mysql')
        