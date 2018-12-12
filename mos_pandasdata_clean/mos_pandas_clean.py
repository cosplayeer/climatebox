#!/usr/bin/python
#input :dypObs70mPoint1_2015daochu_final.csv
#output:obsfinal.csv
import pandas as pd
#from pandas import Series, DataFrame
import numpy as np
from datetime import datetime

filepath = "./"
filename = filepath + "dypObs70mPoint1_2015daochu.csv"
fileout = filepath + "dypObs70mPoint1_2015daochu_final.csv"

obsinput = pd.read_csv(filename, skiprows=2,header=None, usecols=[0,1,2],
			names=['Timeinfo','speed','direction'])
# change timeinfo format as new index column
index =  obsinput['Timeinfo']
indexdate = pd.to_datetime(index) # .astype(str)
indexdate2 = [datetime.strftime(x, '%Y-%m-%d_%H:%M:%S') for x in indexdate] # list
#list to series
#indexdate2_s = pd.Series(indexdate2)
#list to frame
indexdate2_s = pd.DataFrame({'Timeinfo':indexdate2})
print indexdate2_s

#speed and directioncolumn
columnspeed = pd.DataFrame(obsinput['speed'])
columndir = pd.DataFrame(obsinput['direction'])
print columnspeed
#columnspeed_frame = pd.Dataframe(columnspeed)

# 'key' in common choince
#obsoutput = pd.merge(indexdate2_s, columnspeed, columndir, on='key')
# 'key' not included
#result = indexdate2_s.append([columnspeed,columndir])
# concat 
frames = [indexdate2_s, columnspeed, columndir]
result_temp = pd.concat(frames, axis = 1)
print result_temp
result = result_temp.set_index('Timeinfo')
print result
result.to_csv("obsfinal.csv",sep = ',')


