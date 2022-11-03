fromyear="2022"
fromonth="10"
; tomonth="6monthly"
; tomonth="C"
;A avg
; file_a = systemfunc("ls ./ncdata/Seasonal-forecast-wind-20year-" + tomonth + ".nc")
; A simple month
file_a = systemfunc(" ls ./ncdata/Seasonal-forecast-wind-"+ tomonth +"-20year.nc")
fa = addfile(file_a,"r")
avgspeed = fa->Speed10m
a = avgspeed

;E forecast avg
; file_e = systemfunc("ls ./ncdata/Seasonal-forecast-wind-" + fromyear + fromonth + "-0.25p-" + tomonth + ".nc")
;E simple month
file_e = systemfunc("ls ./ncdata/Seasonal-forecast-wind" + fromyear + fromonth + "-" + tomonth +"-forecastyear.nc")
fe = addfile(file_e,"r")
lat_e = fe->lat
lon_e = fe->lon
e = fe->Speed10m
estat = dim_stat4_n(e,0)
printVarSummary(e)
eMaxDim0 = dim_max_n(e,0)
eMinDim0 = dim_min_n(e,0)
eAvgDim0 = estat(0,:,:) ;等价于dim_avg_n(e,0)
eAvgDim0@_FillValue = -999.0
eAvgDim0 = where( eAvgDim0 .ne. 0, eAvgDim0, eAvgDim0@_FillValue)
eSDDim1 = sqrt(estat(1,:,:))
eSDDim1@_FillValue = -999.0
eSkewness = estat(2,:,:)
eSkewness@_FillValue = -999.0
eKurtosis = estat(3,:,:)
eKurtosis@_FillValue = -999.0
eRSDDim1 = eSDDim1 / eAvgDim0 * 100
eRSDDim1@_FillValue = -999.0
eMaxPercent = (eMaxDim0 - eAvgDim0) / eAvgDim0 * 100
eMaxPercent@_FillValue = -999.0
eMinPercent = (eMinDim0 - eAvgDim0) / eAvgDim0 * 100
eMinPercent@_FillValue = -999.0
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
; ; wind2020 Seasonal-history(%) april
; foutf = "./text/Seasonal-forecast-wind-max-" + fromyear + fromonth + "-regrid-percent-" + tomonth + "-greater-than-average.csv"
; header = ("longitude,   latitude,    percent(%)")
; hlist1 = [/header/]
; alist1 = [/lon2d, lat2d, eMaxPercent/]
; system("/bin/rm -f " + foutf)
; write_table(foutf, "w", hlist1, "%s")
; write_table(foutf, "a", alist1, "%9.4f, %9.4f, %9.4f")

; foutf = "./text/Seasonal-forecast-wind-min-" + fromyear + fromonth + "-regrid-percent-" + tomonth + "-greater-than-average.csv"
; header = ("longitude,   latitude,    percent(%)")
; hlist2 = [/header/]
; alist2 = [/lon2d, lat2d, eMinPercent/]
; system("/bin/rm -f " + foutf)
; write_table(foutf, "w", hlist2, "%s")
; write_table(foutf, "a", alist2, "%9.4f, %9.4f, %9.4f")
; ; SD
; foutf = "./text/Seasonal-forecast-wind-sd-" + fromyear + fromonth + "-regrid-percent-" + tomonth + "-greater-than-average.csv"
; header = ("longitude,   latitude,    SD(%)")
; hlist2 = [/header/]
; alist2 = [/lon2d, lat2d, eSDDim1/]
; system("/bin/rm -f " + foutf)
; write_table(foutf, "w", hlist2, "%s")
; write_table(foutf, "a", alist2, "%9.4f, %9.4f, %9.4f")
; RSD
foutf = "./text/Seasonal-forecast-wind-rsd-" + fromyear + fromonth + "-regrid-percent-" + tomonth + "-greater-than-average.csv"
header = ("longitude,   latitude,    RSD(%)")
hlist2 = [/header/]
alist2 = [/lon2d, lat2d, eRSDDim1/]
system("/bin/rm -f " + foutf)
write_table(foutf, "w", hlist2, "%s")
write_table(foutf, "a", alist2, "%9.4f, %9.4f, %9.4f")
;eSkewness
foutf = "./text/Seasonal-forecast-wind-skew-" + fromyear + fromonth + "-regrid-percent-" + tomonth + "-greater-than-average.csv"
header = ("longitude,   latitude,    Skewness")
hlist2 = [/header/]
alist2 = [/lon2d, lat2d, eSkewness/]
system("/bin/rm -f " + foutf)
write_table(foutf, "w", hlist2, "%s")
write_table(foutf, "a", alist2, "%9.4f, %9.4f, %9.4f")
;eKurtosis
foutf = "./text/Seasonal-forecast-wind-kurtosis-" + fromyear + fromonth + "-regrid-percent-" + tomonth + "-greater-than-average.csv"
header = ("longitude,   latitude,    Kurtosis")
hlist2 = [/header/]
alist2 = [/lon2d, lat2d, eKurtosis/]
system("/bin/rm -f " + foutf)
write_table(foutf, "w", hlist2, "%s")
write_table(foutf, "a", alist2, "%9.4f, %9.4f, %9.4f")