fromyear="2022"
fromonth="10"
; tomonth="6monthly"

;A avg
; file_a = systemfunc("ls ./ncdata/Seasonal-forecast-rad-20year-" + tomonth + ".nc")
; A simple month
; file_a = systemfunc(" ls ./ncdata/Seasonal-forecast-rad-"+ tomonth +"-20year.nc")
; fa = addfile(file_a,"r")
; avgradiation = fa->Radiation
; a = avgradiation

;E forecast avg
; file_e = systemfunc("ls ./ncdata/Seasonal-forecast-rad-" + fromyear + fromonth + "-0.25p-" + tomonth + ".nc")
;E simple month
file_e = systemfunc("ls ./ncdata/Seasonal-forecast-rad-" + fromyear + fromonth + "-" + tomonth +"-0.25p.nc")
fe = addfile(file_e,"r")
lat_e = fe->lat
lon_e = fe->lon
e = fe->Radiation
; printVarSummary(e) ;[ncl0 | 51] x [lat | 721] x [lon | 1440]
; print("a guangdong:")
estat = dim_stat4_n(e,0)
; printVarSummary(estat)
;print(avg(a_guangdong))
;print("e guangdong:")
e_guangdong = e(:,452,453)
;print(e_guangdong)
;print(avg(e_guangdong))

; printMinMax(e_guangdong, True)
eMaxDim0 = dim_max_n(e,0)

eMinDim0 = dim_min_n(e,0)
; eAvgDim0 = dim_avg_n(e,0)
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
; eMaxPercentDemo = (eMaxDim0(452,453)-eAvgDim0(452,453)) / eAvgDim0(452,453) * 100
eMinPercent = (eMinDim0 - eAvgDim0) / eAvgDim0 * 100
eMinPercent@_FillValue = -999.0
; printMinMax(eMaxPercent,True)
; print(eAvgDim0(452,452))
; print(eRSDDim1(452,455))
; print(eSkewness(452,455))
; print(eKurtosis(452,455))

; printMinMax(eAvgDim0,True)
; printMinMax(eRSDDim1,True)

; printMinMax(eSkewness,True)
; printMinMax(eKurtosis,True)

; ;----------------------
; ;output
; ;to do
; ;output percent to csv
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
foutf = "./text/Seasonal-forecast-rad-max-" + fromyear + fromonth + "-regrid-percent-" + tomonth + "-greater-than-average.csv"
header = ("longitude,   latitude,    percent(%)")
hlist1 = [/header/]
alist1 = [/lon2d, lat2d, eMaxPercent/]
system("/bin/rm -f " + foutf)
write_table(foutf, "w", hlist1, "%s")
write_table(foutf, "a", alist1, "%9.4f, %9.4f, %9.4f")

foutf = "./text/Seasonal-forecast-rad-min-" + fromyear + fromonth + "-regrid-percent-" + tomonth + "-greater-than-average.csv"
header = ("longitude,   latitude,    percent(%)")
hlist2 = [/header/]
alist2 = [/lon2d, lat2d, eMinPercent/]
system("/bin/rm -f " + foutf)
write_table(foutf, "w", hlist2, "%s")
write_table(foutf, "a", alist2, "%9.4f, %9.4f, %9.4f")
; SD
foutf = "./text/Seasonal-forecast-rad-sd-" + fromyear + fromonth + "-regrid-percent-" + tomonth + "-greater-than-average.csv"
header = ("longitude,   latitude,    SD(%)")
hlist2 = [/header/]
alist2 = [/lon2d, lat2d, eSDDim1/]
system("/bin/rm -f " + foutf)
write_table(foutf, "w", hlist2, "%s")
write_table(foutf, "a", alist2, "%9.4f, %9.4f, %9.4f")
; RSD
foutf = "./text/Seasonal-forecast-rad-rsd-" + fromyear + fromonth + "-regrid-percent-" + tomonth + "-greater-than-average.csv"
header = ("longitude,   latitude,    RSD(%)")
hlist2 = [/header/]
alist2 = [/lon2d, lat2d, eRSDDim1/]
system("/bin/rm -f " + foutf)
write_table(foutf, "w", hlist2, "%s")
write_table(foutf, "a", alist2, "%9.4f, %9.4f, %9.4f")
;eSkewness
foutf = "./text/Seasonal-forecast-rad-skew-" + fromyear + fromonth + "-regrid-percent-" + tomonth + "-greater-than-average.csv"
header = ("longitude,   latitude,    Skewness")
hlist2 = [/header/]
alist2 = [/lon2d, lat2d, eSkewness/]
system("/bin/rm -f " + foutf)
write_table(foutf, "w", hlist2, "%s")
write_table(foutf, "a", alist2, "%9.4f, %9.4f, %9.4f")
;eKurtosis
foutf = "./text/Seasonal-forecast-rad-kurtosis-" + fromyear + fromonth + "-regrid-percent-" + tomonth + "-greater-than-average.csv"
header = ("longitude,   latitude,    Kurtosis")
hlist2 = [/header/]
alist2 = [/lon2d, lat2d, eKurtosis/]
system("/bin/rm -f " + foutf)
write_table(foutf, "w", hlist2, "%s")
write_table(foutf, "a", alist2, "%9.4f, %9.4f, %9.4f")

