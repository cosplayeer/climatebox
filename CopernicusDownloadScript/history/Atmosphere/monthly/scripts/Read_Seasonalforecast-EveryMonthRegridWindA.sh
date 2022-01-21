# ncl ./scripts/Read_Seasonalforecast-EveryMonthRegridWindA.ncl 'mname="A"' 'fromtime="20211２"' 'fstname="0"' > log.A 2>&1 &
# ncl ./scripts/Read_Seasonalforecast-EveryMonthRegridWindA.ncl 'mname="B"' 'fromtime="20211２"' 'fstname="1"' > log.B 2>&1 &
# ncl ./scripts/Read_Seasonalforecast-EveryMonthRegridWindA.ncl 'mname="C"' 'fromtime="20211２"' 'fstname="2"' > log.C 2>&1 &
# ncl ./scripts/Read_Seasonalforecast-EveryMonthRegridWindA.ncl 'mname="D"' 'fromtime="20211２"' 'fstname="3"' > log.D 2>&1 &
# ncl ./scripts/Read_Seasonalforecast-EveryMonthRegridWindA.ncl 'mname="E"' 'fromtime="20211２"' 'fstname="4"' > log.E 2>&1 &
# ncl ./scripts/Read_Seasonalforecast-EveryMonthRegridWindA.ncl 'mname="F"' 'fromtime="20211２"' 'fstname="5"' > log.F 2>&1 &

ncea -v Speed10m ./ncdata/Seasonal-forecast-wind20211２-*-forecastyear.nc ./ncdata/Seasonal-forecast-wind-20211２-0.25p-6monthly.nc