; goal:
; step 1 : read in forecast 1x1
; step 2 : forecast 1x1 to 0.25p (regrid)
; step 3 : read in ERA5 0.25p
; step 4 : forecast - ERA5



;readin forecast
file2020_03 = "../../../forecast/seasonal-monthly/data/seasonal-monthly-sfc-2019-03_leadtime123.grib"
a1 = addfile(file2020_03,"r")
windgust10m = a1->10FG_GDS0_SFC
windspeed10m = a1->10SI_GDS0_SFC
windspeed10m_U = a1->10U_GDS0_SFC
windspeed10m_V = a1->10V_GDS0_SFC
windspeed10m_UV = sqrt(windspeed10m_U *windspeed10m_U + windspeed10m_V * windspeed10m_V)

windspeed10m_June = windspeed10m(:,2,:,:)
windspeed10m_June_ea = dim_avg_n_Wrap(windspeed10m_June, 0)
print(avg(windspeed10m_June_ea))
; printVarSummary(windspeed10m_June_ea)

;------------------------------------------------------
;regrid to 0.25
;---------------------------------------------
; regrid windspeed10m_June_ea 6 m/s
Opt                = True

Opt@SrcFileName    = "src_SCRIP.nc"	;写入的元数据描述文件
Opt@DstFileName    = "dst_SCRIP.nc" ;写入的目标数据描述文件
Opt@WgtFileName    = "NCEP_2_Rect.nc"
Opt@ForceOverwrite = True

Opt@SrcGridMask    = where(.not.ismissing(windspeed10m_June_ea),1,0)   ; use SrcMask2D in NCL V6.2.1 and earlier

Opt@DstGridType    = "0.25x0.25"
Opt@DstLLCorner    = (/ -90.d,   0.d/) ; (default = [-90,-180])
Opt@DstURCorner    = (/  90.d, 359.75/) ;(default = [90,180])

windspeed10m_June_ea_regrid = ESMF_regrid(windspeed10m_June_ea,Opt)
; printVarSummary(windspeed10m_June_ea_regrid)
; print(avg(windspeed10m_June_ea_regrid))
; printMinMax(windspeed10m_June_ea_regrid, False)


;---------------------------------------------
;read in era5 20year June　
;Prepare: Read_avgERA5_June, output nc data, done
; read in Speed10m, Speed10m_UV, Speed100m_UV
fileERA5 = "ncdata/ERA5-wind-june-20year-average.nc"
b1 = addfile(fileERA5,"r")
windspeed10m_June_ERA5 = b1->Speed10m
; windspeed10m_June_UV_ERA5 = b1->Speed10m_UV
; windspeed100m_June_UV_ERA5 = b1->Speed100m_UV
;windspeed10m_June_ea_regrid 6m/s
;windspeed10m_June_UV_ea_regrid 3m/s
windspeed10m_June_ERA5_minus = (windspeed10m_June_ea_regrid - windspeed10m_June_ERA5) / windspeed10m_June_ERA5
; windspeed10m_June_UV_ERA5minus = (windspeed10m_June_UV_ea_regrid - windspeed10m_June_UV_ERA5 ) / windspeed10m_June_UV_ERA5

printMinMax(windspeed10m_June_ERA5_minus,True)
print(avg(windspeed10m_June_ERA5_minus))

;output csv
lat1d=b1->g0_lat_1
; print(lat1d)
lon1d=b1->g0_lon_2
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

; wind no uv
foutf = "./text/Seasonal-forecast-June-regrid-minus-ERA5-month-average-10m-noUV.csv"
header = ("longitude,   latitude,    windspeed-nouv-10m")
hlist = [/header/]
alist = [/lon2d, lat2d, windspeed10m_June_ERA5_minus/]
system("/bin/rm -f " + foutf)
write_table(foutf, "w", hlist, "%s")
write_table(foutf, "a", alist, "%9.4f, %9.4f, %9.4f")
