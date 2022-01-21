; goal:
; step 1 : read in forecast 1x1
; step 2 : forecast 1x1 to 0.25p (regrid)
; step 3 : read in historical 0.25p 10m uv
    ; preprocess
; step 4 : forecast - historical
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
;------------------month May-------------------------------
monthname = "Sep"
fromyear = "2020"
fromonth = "09"
fromtime = "202009"
tomonth1="Oct"
tomonth2="Nov"
tomonth3="Dec"
function test(monthname:string)
begin
;readin forecast 1x1
file1 = "../../../forecast/seasonal-monthly/data/seasonal-monthly-sfc-2020-09_leadtime123.grib"
print(file1)
a1 = addfile(file1,"r")

wind10m = a1->10SI_GDS0_SFC ;51x6x181x360

wind10m_1 = wind10m(:,0,:,:)
wind10m_leadtime1_forecast = dim_avg_n_Wrap(wind10m_1, 0)
wind10m_2 = wind10m(:,1,:,:)
wind10m_leadtime2_forecast = dim_avg_n_Wrap(wind10m_2, 0)
wind10m_3 = wind10m(:,2,:,:)
wind10m_leadtime3_forecast = dim_avg_n_Wrap(wind10m_3, 0)

;------------------------------------------------------
;regrid to 0.25
;---------------------------------------------
; regrid wind10m_leadtime1_forecast 
Opt                = True

Opt@SrcFileName    = "./temp/wind_src_SCRIP" + tomonth1 +".nc"	;写入的元数据描述文件
Opt@DstFileName    = "./temp/wind_dst_SCRIP" + tomonth1 +".nc" ;写入的目标数据描述文件
Opt@WgtFileName    = "./temp/wind_NCEP_2_Rect" + tomonth1 +".nc"
Opt@ForceOverwrite = True

Opt@SrcGridMask    = where(.not.ismissing(wind10m_leadtime1_forecast),1,0)   ; use SrcMask2D in NCL V6.2.1 and earlier

Opt@DstGridType    = "0.25x0.25"
Opt@DstLLCorner    = (/ -90.d,   0.d/) ; (default = [-90,-180])
Opt@DstURCorner    = (/  90.d, 359.75/) ;(default = [90,180])

wind10m_leadtime1_forecast_regrid = ESMF_regrid(wind10m_leadtime1_forecast,Opt)

;---------------------------------------------
; regrid wind10m_leadtime2_forecast 
Opt                = True

Opt@SrcFileName    = "./temp/wind_src_SCRIP" + tomonth2 +".nc"	;写入的元数据描述文件
Opt@DstFileName    = "./temp/wind_dst_SCRIP" + tomonth2 +".nc" ;写入的目标数据描述文件
Opt@WgtFileName    = "./temp/wind_NCEP_2_Rect" + tomonth2 +".nc"
Opt@ForceOverwrite = True

Opt@SrcGridMask    = where(.not.ismissing(wind10m_leadtime2_forecast),1,0)   ; use SrcMask2D in NCL V6.2.1 and earlier

Opt@DstGridType    = "0.25x0.25"
Opt@DstLLCorner    = (/ -90.d,   0.d/) ; (default = [-90,-180])
Opt@DstURCorner    = (/  90.d, 359.75/) ;(default = [90,180])

wind10m_leadtime2_forecast_regrid = ESMF_regrid(wind10m_leadtime2_forecast,Opt)

;---------------------------------------------
; regrid 
Opt                = True

Opt@SrcFileName    = "./temp/wind_src_SCRIP" + tomonth3 +".nc"	;写入的元数据描述文件
Opt@DstFileName    = "./temp/wind_dst_SCRIP" + tomonth3 +".nc" ;写入的目标数据描述文件
Opt@WgtFileName    = "./temp/wind_NCEP_2_Rect" + tomonth3 +".nc"
Opt@ForceOverwrite = True

Opt@SrcGridMask    = where(.not.ismissing(wind10m_leadtime3_forecast),1,0)   ; use SrcMask2D in NCL V6.2.1 and earlier

Opt@DstGridType    = "0.25x0.25"
Opt@DstLLCorner    = (/ -90.d,   0.d/) ; (default = [-90,-180])
Opt@DstURCorner    = (/  90.d, 359.75/) ;(default = [90,180])

wind10m_leadtime3_forecast_regrid = ESMF_regrid(wind10m_leadtime3_forecast,Opt)


print("wind10m_leadtime3_forecast:")
printMinMax(wind10m_leadtime3_forecast, True)
print("wind10m_leadtime3_forecast_regrid:")
printMinMax(wind10m_leadtime3_forecast_regrid, True)
;---------------------------------------------
;read in historical 20year May　
;Prepare: Read_Seasonalforecast-03-May-avg.ncl, output nc data, done
; read in Speed10m, Speed10m_UV, Speed100m_UV
;b1 ;May not change!!!
; fileSea = "ncdata/Seasonal-forecast-wind-" + "June" + "-20year.nc"
; b1 = addfile(fileSea,"r")
; wind10m_May_Sea = b1->Speed10m
; wind10m_leadtime1_forecast_percent = (wind10m_leadtime1_forecast_regrid - wind10m_May_Sea) / wind10m_May_Sea * 100
; fileSea = "ncdata/Seasonal-forecast-wind-" + "June" + "-20year-from03.nc"

;b1
fileSea1 = "ncdata/Seasonal-forecast-wind-" + tomonth1 + "-20year.nc"
b1 = addfile(fileSea1,"r")
wind10m_June_Sea = b1->Speed10m
wind10m_June_Sea =mask(wind10m_June_Sea, wind10m_June_Sea .le. 0.0001, False)
wind10m_June_Sea@_FillValue = 0.0001
wind10m_leadtime1_forecast_percent = (wind10m_leadtime1_forecast_regrid - wind10m_June_Sea) / wind10m_June_Sea * 100
print("wind10m_June_Sea:")
printMinMax(wind10m_June_Sea,True)
;b2
fileSea2 = "ncdata/Seasonal-forecast-wind-" + tomonth2 + "-20year.nc"
b2 = addfile(fileSea2,"r")
wind10m_July_Sea = b2->Speed10m
wind10m_July_Sea =mask(wind10m_July_Sea, wind10m_July_Sea .le. 0.0001, False)
wind10m_July_Sea@_FillValue = 0.0001
wind10m_leadtime2_forecast_percent = (wind10m_leadtime2_forecast_regrid - wind10m_July_Sea) / wind10m_July_Sea * 100
print("wind10m_July_Sea:")
printMinMax(wind10m_July_Sea,True)
;b3
fileSea3 = "ncdata/Seasonal-forecast-wind-" + tomonth3 + "-20year.nc"
b3 = addfile(fileSea3,"r")
wind10m_03_Sea = b3->Speed10m
wind10m_03_Sea =mask(wind10m_03_Sea, wind10m_03_Sea .le. 0.0001, False)
wind10m_03_Sea@_FillValue = 0.0001
print("wind10m_03_Sea:")
printMinMax(wind10m_03_Sea,True)
wind10m_leadtime3_forecast_percent = (wind10m_leadtime3_forecast_regrid - wind10m_03_Sea) / wind10m_03_Sea * 100

;output percent to csv
lat1d_org=b1->lat
lon1d_org=b1->lon
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
;---
; wind 10m 2020 minus Seasonal-history(%) leadtime1
foutf = "./text/Seasonal-forecast-wind-" + fromtime + "-regrid-minus-Seasonalhistory-" + tomonth1 + "-average-10m.csv"
header = ("longitude,   latitude,    windspeed-10m")
hlist = [/header/]
alist = [/lon2d, lat2d, wind10m_leadtime1_forecast_percent/]
system("/bin/rm -f " + foutf)
write_table(foutf, "w", hlist, "%s")
write_table(foutf, "a", alist, "%9.4f, %9.4f, %9.4f")
;---
; wind 10m 2020 minus Seasonal-history(%) leadtime2
foutf = "./text/Seasonal-forecast-wind-" + fromtime + "-regrid-minus-Seasonalhistory-" + tomonth2 + "-average-10m.csv"
header = ("longitude,   latitude,    windspeed-10m")
hlist = [/header/]
alist = [/lon2d, lat2d, wind10m_leadtime2_forecast_percent/]
system("/bin/rm -f " + foutf)
write_table(foutf, "w", hlist, "%s")
write_table(foutf, "a", alist, "%9.4f, %9.4f, %9.4f")
;---
; wind 10m 2020 minus Seasonal-history(%) leadtime3
foutf = "./text/Seasonal-forecast-wind-" + fromtime + "-regrid-minus-Seasonalhistory-" + tomonth3 + "-average-10m.csv"
header = ("longitude,   latitude,    windspeed-10m")
hlist = [/header/]
alist = [/lon2d, lat2d, wind10m_leadtime3_forecast_percent/]
system("/bin/rm -f " + foutf)
write_table(foutf, "w", hlist, "%s")
write_table(foutf, "a", alist, "%9.4f, %9.4f, %9.4f")

return 1
end

begin

s = test("Sep")

end