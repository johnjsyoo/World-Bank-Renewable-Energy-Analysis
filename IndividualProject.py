# -*- coding: utf-8 -*-
"""
Created on Tue Nov 11 20:51:52 2014

@author: johnjsyoo
"""

import wbdata
import datetime
import pandas
import MySQLdb as myDB

# Setting the date range for our data
data_date = (datetime.datetime(2011, 1, 1))
             
# GDP (current US$)
gdp = wbdata.get_data("NY.GDP.MKTP.CD", data_date=data_date, pandas = True)[44:]
    
# Data on Electricity production from renewable sources (kWh)
renewableProd = wbdata.get_data("EG.ELC.RNEW.KH", data_date=data_date, pandas = True)[44:]

electricityProd = wbdata.get_data("EG.ELC.PROD.KH", data_date=data_date, pandas = True)[44:]

# Convert the time-series data into a Data Frame
gdpDF = pandas.DataFrame(gdp)
renewableProdDF = pandas.DataFrame(renewableProd)
electricityProdDF = pandas.DataFrame(electricityProd)

energyDF = gdpDF.join(renewableProdDF, lsuffix="GDP",rsuffix="Renewable_kWh")
energyDF = energyDF.join(electricityProdDF)
energyDF.rename(columns = {'value':'Electricity_kWh'}, inplace = True)

# Dropping all NaN values and zero values
energyDF = energyDF[energyDF.valueRenewable_kWh != 0]
energyDF = energyDF.dropna()

# Reading the data to CSV
energyDF.to_csv('/users/johnjsyoo/Dropbox/IndividualAssignment/energy_data.csv')

dbConnect = myDB.connect(host='localhost',
                            user='root',
                            passwd='LAX',
                            db='wbproject')

energyDF.to_sql(con=dbConnect,
                name='energydata',
                if_exists='replace',
                flavor='mysql')
        
#df2 = pandas.read_sql("SELECT * from energyDF", dbConnect2)