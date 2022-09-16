; goal:
; step 1 : read in forecast 1x1
; step 2 : forecast 1x1 to 0.25p (regrid)
; step 3 : read in historical 0.25p 10m uv
; step 4 : forecast - historical
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
;------------------month May-------------------------------
; monthname = "August"
fromyear = "2020"
fromonth = "07"
fromtime = "202007"
tomonth2="Sep"
tomonth3="Oct"
tomonth4="Nov"
function test(monthname:string)
begin
;readin forecast 1x1
file1 = "../../../forecast/seasonal-monthly/data/seasonal-monthly-sfc-" + fromyear + "-" + fromonth + "_leadtime123456.gribnew"
print(file1)
a1 = addfile(file1,"r")
windspeed10m = a1->10SI_GDS0_SFC

; windspeed10m_May = windspeed10m(:,0,:,:)
; windspeed10m_leadtime1_forecast = dim_avg_n_Wrap(windspeed10m_May, 0)
windspeed10m_run2 = windspeed10m(:,1,:,:)
windspeed10m_leadtime2_forecast = dim_avg_n_Wrap(windspeed10m_run2, 0)
windspeed10mrun3 = windspeed10m(:,2,:,:)
windspeed10m_leadtime3_forecast = dim_avg_n_Wrap(windspeed10mrun3, 0)
windspeed10mrun4 = windspeed10m(:,3,:,:)
windspeed10m_leadtime4_forecast = dim_avg_n_Wrap(windspeed10mrun4, 0)
print(avg(windspeed10m_leadtime4_forecast))
printVarSummary(windspeed10m_leadtime4_forecast)

;------------------------------------------------------
;regrid to 0.25
;---------------------------------------------
; regrid windspeed10m_leadtime1_forecast 6 m/s May
; Opt                = True

; Opt@SrcFileName    = "./temp/src_SCRIP" + tomonth1 +".nc"	;写入的元数据描述文件
; Opt@DstFileName    = "./temp/dst_SCRIP" + tomonth1 +".nc" ;写入的目标数据描述文件
; Opt@WgtFileName    = "./temp/NCEP_2_Rect" + tomonth1 +".nc"
; Opt@ForceOverwrite = True

; Opt@SrcGridMask    = where(.not.ismissing(windspeed10m_leadtime1_forecast),1,0)   ; use SrcMask2D in NCL V6.2.1 and earlier

; Opt@DstGridType    = "0.25x0.25"
; Opt@DstLLCorner    = (/ -90.d,   0.d/) ; (default = [-90,-180])
; Opt@DstURCorner    = (/  90.d, 359.75/) ;(default = [90,180])

; windspeed10m_leadtime1_forecast_regrid = ESMF_regrid(windspeed10m_leadtime1_forecast,Opt)
; printVarSummary(windspeed10m_May_ea_regrid)
; print(avg(windspeed10m_May_ea_regrid))
; printMinMax(windspeed10m_May_ea_regrid, False)

;---------------------------------------------
; regrid windspeed10m_leadtime2_forecast 6 m/s 
Opt                = True

Opt@SrcFileName    = "./temp/src_SCRIP" + tomonth2 +".nc"	;写入的元数据描述文件
Opt@DstFileName    = "./temp/dst_SCRIP" + tomonth2 +".nc" ;写入的目标数据描述文件
Opt@WgtFileName    = "./temp/NCEP_2_Rect" + tomonth2 +".nc"
Opt@ForceOverwrite = True

Opt@SrcGridMask    = where(.not.ismissing(windspeed10m_leadtime2_forecast),1,0)   ; use SrcMask2D in NCL V6.2.1 and earlier

Opt@DstGridType    = "0.25x0.25"
Opt@DstLLCorner    = (/ -90.d,   0.d/) ; (default = [-90,-180])
Opt@DstURCorner    = (/  90.d, 359.75/) ;(default = [90,180])

windspeed10m_leadtime2_forecast_regrid = ESMF_regrid(windspeed10m_leadtime2_forecast,Opt)

;---------------------------------------------
; regrid windspeed10m_leadtime3_forecast 6 m/s 
Opt                = True

Opt@SrcFileName    = "./temp/src_SCRIP" + tomonth3 +".nc"	;写入的元数据描述文件
Opt@DstFileName    = "./temp/dst_SCRIP" + tomonth3 +".nc" ;写入的目标数据描述文件
Opt@WgtFileName    = "./temp/NCEP_2_Rect" + tomonth3 +".nc"
Opt@ForceOverwrite = True

Opt@SrcGridMask    = where(.not.ismissing(windspeed10m_leadtime3_forecast),1,0)   ; use SrcMask2D in NCL V6.2.1 and earlier

Opt@DstGridType    = "0.25x0.25"
Opt@DstLLCorner    = (/ -90.d,   0.d/) ; (default = [-90,-180])
Opt@DstURCorner    = (/  90.d, 359.75/) ;(default = [90,180])

windspeed10m_leadtime3_forecast_regrid = ESMF_regrid(windspeed10m_leadtime3_forecast,Opt)


;---------------------------------------------
; regrid windspeed10m_leadtime4_forecast 6 m/s 
Opt                = True

Opt@SrcFileName    = "./temp/src_SCRIP" + tomonth4 +".nc"	;写入的元数据描述文件
Opt@DstFileName    = "./temp/dst_SCRIP" + tomonth4 +".nc" ;写入的目标数据描述文件
Opt@WgtFileName    = "./temp/NCEP_2_Rect" + tomonth4 +".nc"
Opt@ForceOverwrite = True

Opt@SrcGridMask    = where(.not.ismissing(windspeed10m_leadtime4_forecast),1,0)   ; use SrcMask2D in NCL V6.2.1 and earlier

Opt@DstGridType    = "0.25x0.25"
Opt@DstLLCorner    = (/ -90.d,   0.d/) ; (default = [-90,-180])
Opt@DstURCorner    = (/  90.d, 359.75/) ;(default = [90,180])

windspeed10m_leadtime4_forecast_regrid = ESMF_regrid(windspeed10m_leadtime4_forecast,Opt)

;---------------------------------------------
;read in historical 20year May　
;Prepare: Read_Seasonalforecast-03-May-avg.ncl, output nc data, done
; read in Speed10m, Speed10m_UV, Speed100m_UV
;b2
fileSea2 = "ncdata/Seasonal-forecast-wind-" + tomonth2 + "-20year.nc"
b2 = addfile(fileSea2,"r")
windspeed10m_02_Sea = b2->Speed10m
windspeed10m_leadtime2_forecast_percent = (windspeed10m_leadtime2_forecast_regrid - windspeed10m_02_Sea) / windspeed10m_02_Sea * 100
;b3
fileSea3 = "ncdata/Seasonal-forecast-wind-" + tomonth3 + "-20year.nc"
b3 = addfile(fileSea3,"r")
windspeed10m_03_Sea = b3->Speed10m
windspeed10m_leadtime3_forecast_percent = (windspeed10m_leadtime3_forecast_regrid - windspeed10m_03_Sea) / windspeed10m_03_Sea * 100
;b4
fileSea4 = "ncdata/Seasonal-forecast-wind-" + tomonth4 + "-20year.nc"
b4 = addfile(fileSea4,"r")
windspeed10m_04_Sea = b4->Speed10m
windspeed10m_leadtime4_forecast_percent = (windspeed10m_leadtime4_forecast_regrid - windspeed10m_04_Sea) / windspeed10m_04_Sea * 100


print("August")
print(windspeed10m_leadtime4_forecast_percent(472,376))
print("-------")

;output percent to csv
lat1d_org=b2->lat
lon1d_org=b2->lon
printMinMax(lon1d_org, True)
lat1d = tofloat(lat1d_org)
lon1d = tofloat(lon1d_org)
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
; wind 10m 2020 minus Seasonal-history(%) leadtime2
foutf = "./text/Seasonal-forecast-" + fromtime + "-regrid-minus-Seasonalhistory-" + tomonth2 + "-average-10mNew.csv"
header = ("longitude,   latitude,    windspeed-10m")
hlist = [/header/]
alist = [/lon2d, lat2d, windspeed10m_leadtime2_forecast_percent/]
system("/bin/rm -f " + foutf)
write_table(foutf, "w", hlist, "%s")
write_table(foutf, "a", alist, "%9.4f, %9.4f, %9.4f")
; ;---
; ; wind 10m 2020 minus Seasonal-history(%) leadtime3
foutf = "./text/Seasonal-forecast-" + fromtime + "-regrid-minus-Seasonalhistory-" + tomonth3 + "-average-10mNew.csv"
header = ("longitude,   latitude,    windspeed-10m")
hlist = [/header/]
alist = [/lon2d, lat2d, windspeed10m_leadtime3_forecast_percent/]
system("/bin/rm -f " + foutf)
write_table(foutf, "w", hlist, "%s")
write_table(foutf, "a", alist, "%9.4f, %9.4f, %9.4f")
; ;---
; ; wind 10m 2020 minus Seasonal-history(%) leadtime4
foutf = "./text/Seasonal-forecast-" + fromtime + "-regrid-minus-Seasonalhistory-" + tomonth4 + "-average-10mNew.csv"
header = ("longitude,   latitude,    windspeed-10m")
hlist = [/header/]
alist = [/lon2d, lat2d, windspeed10m_leadtime4_forecast_percent/]
system("/bin/rm -f " + foutf)
write_table(foutf, "w", hlist, "%s")
write_table(foutf, "a", alist, "%9.4f, %9.4f, %9.4f")

return 1
end

begin

s = test("aaa")

end