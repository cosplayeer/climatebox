# 3 steps. step 2 is time costing!



# 1.----------------------------------------
# Prepare 20year mean nc first by 
# 'Read_Seasonalforecast-03-April-avg.ncl', output:
#./ncdata/Seasonal-forecast-wind-april-20year.nc
#changed:
#Read_Seasonalforecast-fromonth-First-avg.ncl
#Read_Seasonalforecast-fromonth-Second-avg.ncl
#Read_Seasonalforecast-fromonth-Third-avg.ncl




# 2.----------------------------------------
# time wasting!!!
# Prepare 2020 0.25p nc by
# Read_Seasonalforecast-202003-April-regrid.ncl
# Read_Seasonalforecast-202003-May-regrid.ncl
# 'Read_Seasonalforecast-202003-June-regrid.ncl', output:
# 

# 3.-----------------------------------------
# Percent csv.

#April
# ncl scripts/Read_Seasonalforecast-03-April-avg.ncl
# ncl scripts/Read_Seasonalforecast-202003-April-regrid.ncl
# ncl scripts/Percent2_positive_esemble2020-april.ncl
# May
# ncl scripts/Read_Seasonalforecast-03-May-avg.ncl
# ncl scripts/Read_Seasonalforecast-202003-May-regrid.ncl
# ncl scripts/Percent2_positive_esemble2020-may.ncl
#June
# ncl scripts/Read_Seasonalforecast-03-June-avg.ncl
# ncl scripts/Read_Seasonalforecast-202003-June-regrid.ncl
# ncl scripts/Percent2_positive_esemble2020-june.ncl


#new 2020-04
# May
# ncl scripts/Percent2_positive_esemble202004-may.ncl
#June
# ncl scripts/Percent2_positive_esemble202004-june.ncl

#July
# ncl scripts/Read_Seasonalforecast-04-July-avg.ncl
# ncl scripts/Read_Seasonalforecast-202004-July-regrid.ncl
ncl scripts/Percent2_positive_esemble202004-july.ncl