import os
downdir="https://www.ncei.noaa.gov/data/climate-forecast-system/access/operational-9-month-forecast/monthly-means/2021/202111/20211101/2021110100/"

frecastmonthlist=["202112","202201","202202","202203","202204","202205","202206","202207",\
    "202208",]
for f in frecastmonthlist:
    os.system('wget -c -N --directory-prefix=data '+downdir+'flxf.01.2021110100.'+str(f)+'.avrg.grib.grb2')

