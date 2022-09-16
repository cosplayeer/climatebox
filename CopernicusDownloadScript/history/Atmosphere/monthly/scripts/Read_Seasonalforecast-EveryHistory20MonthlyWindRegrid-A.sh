ncl ./scripts/Read_Seasonalforecast-EveryHistory20MonthlyWindRegrid-A.ncl 'monthfrom="06"' 'outputmonth="A"' 'forecastmonth="0"'
ncl ./scripts/Read_Seasonalforecast-EveryHistory20MonthlyWindRegrid-A.ncl 'monthfrom="06"' 'outputmonth="B"' 'forecastmonth="1"'
ncl ./scripts/Read_Seasonalforecast-EveryHistory20MonthlyWindRegrid-A.ncl 'monthfrom="06"' 'outputmonth="C"' 'forecastmonth="2"'
ncl ./scripts/Read_Seasonalforecast-EveryHistory20MonthlyWindRegrid-A.ncl 'monthfrom="06"' 'outputmonth="D"' 'forecastmonth="3"'
ncl ./scripts/Read_Seasonalforecast-EveryHistory20MonthlyWindRegrid-A.ncl 'monthfrom="06"' 'outputmonth="E"' 'forecastmonth="4"'
ncl ./scripts/Read_Seasonalforecast-EveryHistory20MonthlyWindRegrid-A.ncl 'monthfrom="06"' 'outputmonth="F"' 'forecastmonth="5"'

# rm -rf ./ncdata/Seasonal-forecast-wind-20year-6monthly.nc
# ncea -v Speed10m ./ncdata/Seasonal-forecast-wind*-20year.nc ./ncdata/Seasonal-forecast-wind-20year-6monthly.nc

