# ncl scripts/Read_Seasonalforecast-EveryMonthRegridRadA.ncl 'mname="A"' 'fromtime="202112"' 'fstname="0"' > log.A 2>&1 &
# ncl scripts/Read_Seasonalforecast-EveryMonthRegridRadA.ncl 'mname="B"' 'fromtime="202112"' 'fstname="1"' > log.B 2>&1 &
# ncl scripts/Read_Seasonalforecast-EveryMonthRegridRadA.ncl 'mname="C"' 'fromtime="202112"' 'fstname="2"' > log.C 2>&1 &
# ncl scripts/Read_Seasonalforecast-EveryMonthRegridRadA.ncl 'mname="D"' 'fromtime="202112"' 'fstname="3"' > log.D 2>&1 &
# ncl scripts/Read_Seasonalforecast-EveryMonthRegridRadA.ncl 'mname="E"' 'fromtime="202112"' 'fstname="4"' > log.E 2>&1 &
# ncl scripts/Read_Seasonalforecast-EveryMonthRegridRadA.ncl 'mname="F"' 'fromtime="202112"' 'fstname="5"' > log.F 2>&1 &

ncea -v Radiation ./ncdata/Seasonal-forecast-rad-202112-*-0.25p.nc ./ncdata/Seasonal-forecast-rad-202112-0.25p-6monthly.nc