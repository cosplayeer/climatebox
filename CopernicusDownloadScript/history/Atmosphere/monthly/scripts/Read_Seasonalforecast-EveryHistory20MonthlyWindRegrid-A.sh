# ncl ./scripts/Read_Seasonalforecast-EveryHistory20MonthlyWindRegrid-A.ncl 'monthfrom="1２"' 'outputmonth="A"' 'forecastmonth="0"'
# ncl ./scripts/Read_Seasonalforecast-EveryHistory20MonthlyWindRegrid-A.ncl 'monthfrom="1２"' 'outputmonth="B"' 'forecastmonth="1"'
# ncl ./scripts/Read_Seasonalforecast-EveryHistory20MonthlyWindRegrid-A.ncl 'monthfrom="1２"' 'outputmonth="C"' 'forecastmonth="2"'
# ncl ./scripts/Read_Seasonalforecast-EveryHistory20MonthlyWindRegrid-A.ncl 'monthfrom="1２"' 'outputmonth="D"' 'forecastmonth="3"'
# ncl ./scripts/Read_Seasonalforecast-EveryHistory20MonthlyWindRegrid-A.ncl 'monthfrom="1２"' 'outputmonth="E"' 'forecastmonth="4"'
# ncl ./scripts/Read_Seasonalforecast-EveryHistory20MonthlyWindRegrid-A.ncl 'monthfrom="1２"' 'outputmonth="F"' 'forecastmonth="5"'

# rm -rf ./ncdata/Seasonal-forecast-wind-20year-6monthly.nc
ncea -v Speed10m ./ncdata/Seasonal-forecast-wind*-20year.nc ./ncdata/Seasonal-forecast-wind-20year-6monthly.nc

