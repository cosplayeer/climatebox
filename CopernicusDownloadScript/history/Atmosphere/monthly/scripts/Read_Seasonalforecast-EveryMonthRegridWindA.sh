# ncl ./scripts/Read_Seasonalforecast-EveryMonthRegridWindA.ncl 'mname="A"' 'fromtime="202206"' 'fstname="0"' > log.A 2>&1 &
# ncl ./scripts/Read_Seasonalforecast-EveryMonthRegridWindA.ncl 'mname="B"' 'fromtime="202206"' 'fstname="1"' > log.B 2>&1 &
# ncl ./scripts/Read_Seasonalforecast-EveryMonthRegridWindA.ncl 'mname="C"' 'fromtime="202206"' 'fstname="2"' > log.C 2>&1 &
# ncl ./scripts/Read_Seasonalforecast-EveryMonthRegridWindA.ncl 'mname="D"' 'fromtime="202206"' 'fstname="3"' > log.D 2>&1 &
# ncl ./scripts/Read_Seasonalforecast-EveryMonthRegridWindA.ncl 'mname="E"' 'fromtime="202206"' 'fstname="4"' > log.E 2>&1 &
# ncl ./scripts/Read_Seasonalforecast-EveryMonthRegridWindA.ncl 'mname="F"' 'fromtime="202206"' 'fstname="5"' > log.F 2>&1 &

ncea -v Speed10m ./ncdata/Seasonal-forecast-wind202206-*-forecastyear.nc ./ncdata/Seasonal-forecast-wind-202206-0.25p-6monthly.nc