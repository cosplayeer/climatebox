fromonth="12"
tomonth="Dec"

;A avg
file_a = systemfunc("ls ./ncdata/Seasonal-forecast-rad-" + tomonth + "-20year.nc")
fa = addfile(file_a,"r")
avgspeed = fa->Speed10m
a = avgspeed

;E forecast
file_e = systemfunc("ls ./ncdata/Seasonal-forecast-rad-2020" + fromonth + "-" + tomonth + "-0.25p.nc")

fe = addfile(file_e,"r")
lat_e = fe->lat
lon_e = fe->lon
e = fe->Speed10m
print("a guangdong:")
a_guangdong = a(452,452)
print(avg(a_guangdong))
print("e guangdong:")
e_guangdong = e(:,452,452)
print(e_guangdong)
print(avg(e_guangdong))
a_gd = tofloat(a(452,452))
percent = (avg(e_guangdong) - a_gd) / a_gd * 100
print("percent:")
print(percent)
;----------------------
printVarSummary(e)
printMinMax(e, True)
;----------------------
;process
Array = new((/721,1440/),integer)
Array = 0
; printMinMax(Array,True)
do i = 0,50
    do j = 0, 720
        do k = 0, 1439
            if (e(i,j,k) .gt. a(j,k)) then
                Array(j,k) = Array(j,k) + 1
            end if
        end do
    end do 
end do

printVarSummary(Array)
printMinMax(Array,True)
    
Array2 = tofloat(Array) / 51 * 100
print("Radiation MinMaxAvg:")
printMinMax(Array2,True)
print(avg(Array2))
;----------------------
;output
;to do
;output percent to csv
lat1d_org=lat_e
lon1d_org=lon_e
; printMinMax(lon1d_org, True)
lat1d = tofloat(lat1d_org)
lon1d = tofloat(lon1d_org)

numlat = 721
numlon = 1440
do k = 0, numlon -1
    if (lon1d(k) .ge. 180) then
        lon1d(k) = lon1d(k) - 360.0
    end if
end do
; printMinMax(lon1d, True)
lon2d = new((/numlat, numlon/), float)
lat2d = new((/numlat, numlon/), float)
;do loop
do n = 0, numlon -1
    lon2d(:,n) = lon1d(n)
end do
do n = 0, numlat -1
    lat2d(n,:) = lat1d(n)
end do
; wind2020 Seasonal-history(%) april
foutf = "./text/Seasonal-forecast-rad-2020" + fromonth + "-regrid-percent-" + tomonth + "-greater-than-average-10m.csv"
header = ("longitude,   latitude,    percent(%)")
hlist = [/header/]
alist = [/lon2d, lat2d, Array2/]
system("/bin/rm -f " + foutf)
write_table(foutf, "w", hlist, "%s")
write_table(foutf, "a", alist, "%9.4f, %9.4f, %9.4f")
