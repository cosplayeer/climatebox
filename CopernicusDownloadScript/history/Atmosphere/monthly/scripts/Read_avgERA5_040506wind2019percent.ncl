file_list = systemfunc("ls ./data/reanalysis-era5-single-levels-monthly-means-2019.grib")

f2019 = addfile(file_list,"r")
print(f2019)
spd10m=f2019->10SI_GDS0_SFC_S123
lat1d = f2019->g0_lat_1
lon1d = f2019->g0_lon_2
printVarSummary(spd10m)

April2019 = spd10m(3,:,:)
May2019 = spd10m(4,:,:)
June2019 = spd10m(5,:,:)

; ;read in nc
outname = "./ncdata/ERA5-wind10m_April_20year-mean.nc"
ncdf = addfile(outname,"r")
April20Year = ncdf->Speed10m 

outname = "./ncdata/ERA5-wind10m_May_20year-mean.nc"
ncdf = addfile(outname,"r")
May20Year = ncdf->Speed10m 

outname = "./ncdata/ERA5-wind10m_June_20year-mean.nc"
ncdf = addfile(outname,"r")
June20Year = ncdf->Speed10m


percentApril2019 = (April2019 - April20Year) / April20Year * 100
print(avg(percentApril2019))
printMinMax(percentApril2019, True)
percentMay2019 = (May2019 - May20Year) / May20Year * 100
print(avg(percentMay2019))
printMinMax(percentMay2019, True)
percentJune2019 = (June2019 - June20Year) / June20Year * 100
print(avg(percentJune2019))
printMinMax(percentJune2019, True)

numlat = 721
numlon = 1440
lon2d = new((/numlat, numlon/), float)
lat2d = new((/numlat, numlon/), float)
;do loop
do n = 0, numlon -1
    lon2d(:,n) = lon1d(n)
end do
do n = 0, numlat -1
    lat2d(n,:) = lat1d(n)
end do

;output csv file
foutf = "./text/PercentApril2019.csv"
header = ("longitude,   latitude,    wind10m")
hlist = [/header/]
alist = [/lon2d, lat2d, percentApril2019/]
system("/bin/rm -f " + foutf)
write_table(foutf, "w", hlist, "%s")
write_table(foutf, "a", alist, "%9.4f, %9.4f, %9.4f")

foutf = "./text/PercentMay2019.csv"
header = ("longitude,   latitude,    wind10m")
hlist = [/header/]
alist = [/lon2d, lat2d, percentMay2019/]
system("/bin/rm -f " + foutf)
write_table(foutf, "w", hlist, "%s")
write_table(foutf, "a", alist, "%9.4f, %9.4f, %9.4f")


foutf = "./text/PercentJune2019.csv"
header = ("longitude,   latitude,    wind10m")
hlist = [/header/]
alist = [/lon2d, lat2d, percentJune2019/]
system("/bin/rm -f " + foutf)
write_table(foutf, "w", hlist, "%s")
write_table(foutf, "a", alist, "%9.4f, %9.4f, %9.4f")

