; goal:
; step 1 : read in forecast 1x1
; step 2 : forecast 1x1 to 0.25p (regrid)
; step 3 : read in ERA5 0.25p
; step 4 : forecast - ERA5



;readin forecast 1x1
file2020_03 = "../../../forecast/seasonal-monthly/data/seasonal-monthly-sfc-2019-03_leadtime123.grib"
a1 = addfile(file2020_03,"r")
windspeed10m = a1->10SI_GDS0_SFC

windspeed10m_april = windspeed10m(:,0,:,:)
windspeed10m_april_ea = dim_avg_n_Wrap(windspeed10m_april, 0)
print(avg(windspeed10m_april_ea))
printVarSummary(windspeed10m_april_ea)

;------------------------------------------------------
;regrid to 0.25
;---------------------------------------------
; regrid windspeed10m_april_ea 6 m/s
Opt                = True

Opt@SrcFileName    = "src_SCRIP.nc"	;写入的元数据描述文件
Opt@DstFileName    = "dst_SCRIP.nc" ;写入的目标数据描述文件
Opt@WgtFileName    = "NCEP_2_Rect.nc"
Opt@ForceOverwrite = True

Opt@SrcGridMask    = where(.not.ismissing(windspeed10m_april_ea),1,0)   ; use SrcMask2D in NCL V6.2.1 and earlier

Opt@DstGridType    = "0.25x0.25"
Opt@DstLLCorner    = (/ -90.d,   0.d/) ; (default = [-90,-180])
Opt@DstURCorner    = (/  90.d, 359.75/) ;(default = [90,180])

windspeed10m_april_ea_regrid = ESMF_regrid(windspeed10m_april_ea,Opt)
; printVarSummary(windspeed10m_april_ea_regrid)
; print(avg(windspeed10m_april_ea_regrid))
; printMinMax(windspeed10m_april_ea_regrid, False)

;---------------------------------------------
;read in era5 20year april　
;Prepare: Read_avgERA5_April, output nc data, done
; read in Speed10m, Speed10m_UV, Speed100m_UV
fileSea = "ncdata/Seasonal-forecast-wind-april-20year.nc"
b1 = addfile(fileSea,"r")
windspeed10m_april_Sea = b1->Speed10m

;windspeed10m_april_ea_regrid 6m/s
windspeed10m_april_Sea_percent = (windspeed10m_april_ea_regrid - windspeed10m_april_Sea) / windspeed10m_april_Sea * 100

printMinMax(windspeed10m_april_Sea_percent,True)
print(avg(windspeed10m_april_Sea_percent))

;output percent to csv
lat1d_org=b1->lat
lon1d_org=b1->lon
lat1d = tofloat(lat1d_org)
lon1d = tofloat(lon1d_org)
; print(lon1d)
; print(lat1d)
; ; lat1d=a1->g0_lat_2 ;181
; ; lon1d=a1->g0_lon_3 ; 360
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
; wind 10m 2020 minus Seasonal-history(%)
foutf = "./text/Seasonal-forecast-2020-april-regrid-minus-Seasonalhistory-month-april-average-10m.csv"
header = ("longitude,   latitude,    windspeed-10m")
hlist = [/header/]
alist = [/lon2d, lat2d, windspeed10m_april_Sea_percent/]
system("/bin/rm -f " + foutf)
write_table(foutf, "w", hlist, "%s")
write_table(foutf, "a", alist, "%9.4f, %9.4f, %9.4f")

