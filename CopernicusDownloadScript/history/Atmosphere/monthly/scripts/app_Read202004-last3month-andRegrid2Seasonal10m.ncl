; goal:
; step 1 : read in forecast 1x1
; step 2 : forecast 1x1 to 0.25p (regrid)
; step 3 : read in historical 0.25p 10m uv
; step 4 : forecast - historical

;------------------month april-------------------------------
monthname = "May"
fromyear = "2020"
fromonth = "04"
fromtime = "202004"
function test(monthname:string)
begin
;readin forecast 1x1
file1 = "../../../forecast/seasonal-monthly/data/seasonal-monthly-sfc-" + fromyear + "-" + fromonth + "_leadtime123.grib"
a1 = addfile(file1,"r")
windspeed10m = a1->10SI_GDS0_SFC

windspeed10m_April = windspeed10m(:,0,:,:)
windspeed10m_leadtime1_forecast = dim_avg_n_Wrap(windspeed10m_April, 0)
windspeed10m_May = windspeed10m(:,1,:,:)
windspeed10m_leadtime2_forecast = dim_avg_n_Wrap(windspeed10m_May, 0)
windspeed10m_June = windspeed10m(:,2,:,:)
windspeed10m_leadtime3_forecast = dim_avg_n_Wrap(windspeed10m_June, 0)
print(avg(windspeed10m_leadtime1_forecast))
printVarSummary(windspeed10m_leadtime1_forecast)

;------------------------------------------------------
;regrid to 0.25
;---------------------------------------------
; regrid windspeed10m_leadtime1_forecast 6 m/s April
Opt                = True

Opt@SrcFileName    = "src_SCRIP.nc"	;写入的元数据描述文件
Opt@DstFileName    = "dst_SCRIP.nc" ;写入的目标数据描述文件
Opt@WgtFileName    = "NCEP_2_Rect.nc"
Opt@ForceOverwrite = True

Opt@SrcGridMask    = where(.not.ismissing(windspeed10m_leadtime1_forecast),1,0)   ; use SrcMask2D in NCL V6.2.1 and earlier

Opt@DstGridType    = "0.25x0.25"
Opt@DstLLCorner    = (/ -90.d,   0.d/) ; (default = [-90,-180])
Opt@DstURCorner    = (/  90.d, 359.75/) ;(default = [90,180])

windspeed10m_leadtime1_forecast_regrid = ESMF_regrid(windspeed10m_leadtime1_forecast,Opt)
; printVarSummary(windspeed10m_April_ea_regrid)
; print(avg(windspeed10m_April_ea_regrid))
; printMinMax(windspeed10m_April_ea_regrid, False)

;---------------------------------------------
; regrid windspeed10m_leadtime2_forecast 6 m/s 
Opt                = True

Opt@SrcFileName    = "src_SCRIP.nc"	;写入的元数据描述文件
Opt@DstFileName    = "dst_SCRIP.nc" ;写入的目标数据描述文件
Opt@WgtFileName    = "NCEP_2_Rect.nc"
Opt@ForceOverwrite = True

Opt@SrcGridMask    = where(.not.ismissing(windspeed10m_leadtime2_forecast),1,0)   ; use SrcMask2D in NCL V6.2.1 and earlier

Opt@DstGridType    = "0.25x0.25"
Opt@DstLLCorner    = (/ -90.d,   0.d/) ; (default = [-90,-180])
Opt@DstURCorner    = (/  90.d, 359.75/) ;(default = [90,180])

windspeed10m_leadtime2_forecast_regrid = ESMF_regrid(windspeed10m_leadtime2_forecast,Opt)

;---------------------------------------------
; regrid windspeed10m_leadtime3_forecast 6 m/s 
Opt                = True

Opt@SrcFileName    = "src_SCRIP.nc"	;写入的元数据描述文件
Opt@DstFileName    = "dst_SCRIP.nc" ;写入的目标数据描述文件
Opt@WgtFileName    = "NCEP_2_Rect.nc"
Opt@ForceOverwrite = True

Opt@SrcGridMask    = where(.not.ismissing(windspeed10m_leadtime3_forecast),1,0)   ; use SrcMask2D in NCL V6.2.1 and earlier

Opt@DstGridType    = "0.25x0.25"
Opt@DstLLCorner    = (/ -90.d,   0.d/) ; (default = [-90,-180])
Opt@DstURCorner    = (/  90.d, 359.75/) ;(default = [90,180])

windspeed10m_leadtime3_forecast_regrid = ESMF_regrid(windspeed10m_leadtime3_forecast,Opt)

;---------------------------------------------
;read in historical 20year April　
;Prepare: Read_Seasonalforecast-03-April-avg.ncl, output nc data, done
; read in Speed10m, Speed10m_UV, Speed100m_UV
;b1 ;april not change!!!
; fileSea = "ncdata/Seasonal-forecast-wind-" + "May" + "-20year.nc"
; b1 = addfile(fileSea,"r")
; windspeed10m_April_Sea = b1->Speed10m
; windspeed10m_leadtime1_forecast_percent = (windspeed10m_leadtime1_forecast_regrid - windspeed10m_April_Sea) / windspeed10m_April_Sea * 100
fileSea = "ncdata/Seasonal-forecast-wind-" + "May" + "-20year-from03.nc"
b1 = addfile(fileSea,"r")
windspeed10m_03_Sea = b1->Speed10m
windspeed10m_leadtime1_forecast_percent = (windspeed10m_leadtime1_forecast_regrid - windspeed10m_03_Sea) / windspeed10m_03_Sea * 100


print("April")
print(windspeed10m_leadtime1_forecast_percent(472,376))
; print(windspeed10m_leadtime1_forecast_percent(474,374))
print("-------")
;b2
fileSea = "ncdata/Seasonal-forecast-wind-" + "June" + "-20year.nc"
fileSea = "ncdata/Seasonal-forecast-wind-" + "June" + "-20year-from03.nc"
b2 = addfile(fileSea,"r")
windspeed10m_May_Sea = b2->Speed10m
windspeed10m_leadtime2_forecast_percent = (windspeed10m_leadtime2_forecast_regrid - windspeed10m_May_Sea) / windspeed10m_May_Sea * 100
print("May")
print(windspeed10m_leadtime2_forecast_percent(472,376))
; print(windspeed10m_leadtime2_forecast_percent(474,374))
print("-------")
;b3
fileSea = "ncdata/Seasonal-forecast-wind-" + "July" + "-20year.nc"
b3 = addfile(fileSea,"r")
windspeed10m_june_Sea = b3->Speed10m
windspeed10m_leadtime3_forecast_percent = (windspeed10m_leadtime3_forecast_regrid - windspeed10m_june_Sea) / windspeed10m_june_Sea * 100
print("July")
print(windspeed10m_leadtime3_forecast_percent(472,376))
; print(windspeed10m_leadtime3_forecast_percent(474,374))
print("-------")
printMinMax(windspeed10m_leadtime1_forecast_percent,True)
print(avg(windspeed10m_leadtime1_forecast_percent))
printMinMax(windspeed10m_leadtime2_forecast_percent,True)
print(avg(windspeed10m_leadtime2_forecast_percent))
printMinMax(windspeed10m_leadtime3_forecast_percent,True)
print(avg(windspeed10m_leadtime3_forecast_percent))

;output percent to csv
lat1d_org=b1->lat
lon1d_org=b1->lon
printMinMax(lon1d_org, True)
lat1d = tofloat(lat1d_org)
lon1d = tofloat(lon1d_org)
; print(lon1d)
; print(lat1d)
; ; lat1d=a1->g0_lat_2 ;181
; ; lon1d=a1->g0_lon_3 ; 360
numlat = 721
numlon = 1440
do k = 0, numlon -1
    if (lon1d(k) .ge. 180) then
        lon1d(k) = lon1d(k) - 360.0
    end if
end do
printMinMax(lon1d, True)
lon2d = new((/numlat, numlon/), float)
lat2d = new((/numlat, numlon/), float)
;do loop
do n = 0, numlon -1
    lon2d(:,n) = lon1d(n)
end do
do n = 0, numlat -1
    lat2d(n,:) = lat1d(n)
end do
; wind 10m 2020 minus Seasonal-history(%) leadtime1
foutf = "./text/Seasonal-forecast-" + fromtime + "-regrid-minus-Seasonalhistory-month-" + "May" + "-average-10mNew.csv"
foutf = "./text/Seasonal-forecast-" + fromtime + "-regrid-minus-Seasonalhistory-from03-month-" + "May" + "-average-10m.csv"
header = ("longitude,   latitude,    windspeed-10m")
hlist = [/header/]
alist = [/lon2d, lat2d, windspeed10m_leadtime1_forecast_percent/]
system("/bin/rm -f " + foutf)
write_table(foutf, "w", hlist, "%s")
write_table(foutf, "a", alist, "%9.4f, %9.4f, %9.4f")
;---
;write to nc
; outname = "./ncdata/2020-April-seasonal-percent-10m.nc"
; system("/bin/rm -f " + outname)
; ncdf = addfile(outname,"c")
; ; filedimdef(ncdf, "time", -1, True)
; windspeed10m_leadtime1_forecast_percent@long_name = "wind speed April seasonal percent"
; windspeed10m_leadtime1_forecast_percent@units     = "%"
; ncdf->percent = windspeed10m_leadtime1_forecast_percent
;---
; wind 10m 2020 minus Seasonal-history(%) leadtime2
foutf = "./text/Seasonal-forecast-" + fromtime + "-regrid-minus-Seasonalhistory-month-" + "June" + "-average-10mNew.csv"
foutf = "./text/Seasonal-forecast-" + fromtime + "-regrid-minus-Seasonalhistory-from03-month-" + "June" + "-average-10m.csv"
header = ("longitude,   latitude,    windspeed-10m")
hlist = [/header/]
alist = [/lon2d, lat2d, windspeed10m_leadtime2_forecast_percent/]
system("/bin/rm -f " + foutf)
write_table(foutf, "w", hlist, "%s")
write_table(foutf, "a", alist, "%9.4f, %9.4f, %9.4f")
;---
;write to nc
; outname = "./ncdata/2020-May-seasonal-percent-10mNew.nc"
; system("/bin/rm -f " + outname)
; ncdf = addfile(outname,"c")
; ; filedimdef(ncdf, "time", -1, True)
; windspeed10m_leadtime2_forecast_percent@long_name = "wind speed may seasonal percent"
; windspeed10m_leadtime2_forecast_percent@units     = "%"
; ncdf->percent = windspeed10m_leadtime2_forecast_percent
;---
; wind 10m 2020 minus Seasonal-history(%) leadtime3
foutf = "./text/Seasonal-forecast-" + fromtime + "-regrid-minus-Seasonalhistory-month-" + "July" + "-average-10mNew.csv"
header = ("longitude,   latitude,    windspeed-10m")
hlist = [/header/]
alist = [/lon2d, lat2d, windspeed10m_leadtime3_forecast_percent/]
system("/bin/rm -f " + foutf)
write_table(foutf, "w", hlist, "%s")
write_table(foutf, "a", alist, "%9.4f, %9.4f, %9.4f")
;---
;write to nc
; outname = "./ncdata/2020-June-seasonal-percent-10mNew.nc"
; system("/bin/rm -f " + outname)
; ncdf = addfile(outname,"c")
; ; filedimdef(ncdf, "time", -1, True)
; windspeed10m_leadtime3_forecast_percent@long_name = "wind speed june seasonal percent"
; windspeed10m_leadtime3_forecast_percent@units     = "%"
; ncdf->percent = windspeed10m_leadtime3_forecast_percent
;---
return 1
end

begin

s = test("May")

end