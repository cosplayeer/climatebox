; goal:
; step 1 : read in forecast 1x1
; step 2 : forecast 1x1 to 0.25p (regrid)
; step 3 : read in historical 0.25p 10m uv
    ; preprocess
; step 4 : forecast - historical
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
;------------------month May-------------------------------
monthname = "May"
fromyear = "2020"
fromonth = "06"
fromtime = "202006"
tomonth1="October"
tomonth2="November"
tomonth3="December"
function test(monthname:string)
begin
;readin forecast 1x1
file1 = "../../../forecast/seasonal-monthly/dataRadiation/seasonal-monthly-rad-2020-06_leadtime123456.grib.target"
print(file1)
a1 = addfile(file1,"r")

radiation = a1->VAR_169_GDS0_SFC ;51x6x181x360

radiation_1 = radiation(:,0,:,:)
radiation_leadtime1_forecast = dim_avg_n_Wrap(radiation_1, 0)
radiation_2 = radiation(:,1,:,:)
radiation_leadtime2_forecast = dim_avg_n_Wrap(radiation_2, 0)
radiation_3 = radiation(:,2,:,:)
radiation_leadtime3_forecast = dim_avg_n_Wrap(radiation_3, 0)

;------------------------------------------------------
;regrid to 0.25
;---------------------------------------------
; regrid radiation_leadtime1_forecast 
Opt                = True

Opt@SrcFileName    = "./temp/rad_src_SCRIP" + tomonth1 +".nc"	;写入的元数据描述文件
Opt@DstFileName    = "./temp/rad_dst_SCRIP" + tomonth1 +".nc" ;写入的目标数据描述文件
Opt@WgtFileName    = "./temp/rad_NCEP_2_Rect" + tomonth1 +".nc"
Opt@ForceOverwrite = True

Opt@SrcGridMask    = where(.not.ismissing(radiation_leadtime1_forecast),1,0)   ; use SrcMask2D in NCL V6.2.1 and earlier

Opt@DstGridType    = "0.25x0.25"
Opt@DstLLCorner    = (/ -90.d,   0.d/) ; (default = [-90,-180])
Opt@DstURCorner    = (/  90.d, 359.75/) ;(default = [90,180])

radiation_leadtime1_forecast_regrid = ESMF_regrid(radiation_leadtime1_forecast,Opt)

;---------------------------------------------
; regrid radiation_leadtime2_forecast 
Opt                = True

Opt@SrcFileName    = "./temp/rad_src_SCRIP" + tomonth2 +".nc"	;写入的元数据描述文件
Opt@DstFileName    = "./temp/rad_dst_SCRIP" + tomonth2 +".nc" ;写入的目标数据描述文件
Opt@WgtFileName    = "./temp/rad_NCEP_2_Rect" + tomonth2 +".nc"
Opt@ForceOverwrite = True

Opt@SrcGridMask    = where(.not.ismissing(radiation_leadtime2_forecast),1,0)   ; use SrcMask2D in NCL V6.2.1 and earlier

Opt@DstGridType    = "0.25x0.25"
Opt@DstLLCorner    = (/ -90.d,   0.d/) ; (default = [-90,-180])
Opt@DstURCorner    = (/  90.d, 359.75/) ;(default = [90,180])

radiation_leadtime2_forecast_regrid = ESMF_regrid(radiation_leadtime2_forecast,Opt)

;---------------------------------------------
; regrid 
Opt                = True

Opt@SrcFileName    = "./temp/rad_src_SCRIP" + tomonth3 +".nc"	;写入的元数据描述文件
Opt@DstFileName    = "./temp/rad_dst_SCRIP" + tomonth3 +".nc" ;写入的目标数据描述文件
Opt@WgtFileName    = "./temp/rad_NCEP_2_Rect" + tomonth3 +".nc"
Opt@ForceOverwrite = True

Opt@SrcGridMask    = where(.not.ismissing(radiation_leadtime3_forecast),1,0)   ; use SrcMask2D in NCL V6.2.1 and earlier

Opt@DstGridType    = "0.25x0.25"
Opt@DstLLCorner    = (/ -90.d,   0.d/) ; (default = [-90,-180])
Opt@DstURCorner    = (/  90.d, 359.75/) ;(default = [90,180])

radiation_leadtime3_forecast_regrid = ESMF_regrid(radiation_leadtime3_forecast,Opt)
; print("radiation_leadtime1_forecast:")
; printMinMax(radiation_leadtime1_forecast, True)
; print("radiation_leadtime1_forecast_regrid:")
; printMinMax(radiation_leadtime1_forecast_regrid, True)

; print("radiation_leadtime2_forecast:")
; printMinMax(radiation_leadtime2_forecast, True)
; print("radiation_leadtime2_forecast_regrid:")
; printMinMax(radiation_leadtime2_forecast_regrid, True)

print("radiation_leadtime3_forecast:")
printMinMax(radiation_leadtime3_forecast, True)
print("radiation_leadtime3_forecast_regrid:")
printMinMax(radiation_leadtime3_forecast_regrid, True)
;---------------------------------------------
;read in historical 20year May　
;Prepare: Read_Seasonalforecast-03-May-avg.ncl, output nc data, done
; read in Speed10m, Speed10m_UV, Speed100m_UV
;b1 ;May not change!!!
; fileSea = "ncdata/Seasonal-forecast-wind-" + "June" + "-20year.nc"
; b1 = addfile(fileSea,"r")
; radiation_May_Sea = b1->Speed10m
; radiation_leadtime1_forecast_percent = (radiation_leadtime1_forecast_regrid - radiation_May_Sea) / radiation_May_Sea * 100
; fileSea = "ncdata/Seasonal-forecast-wind-" + "June" + "-20year-from03.nc"

;b1
fileSea1 = "ncdata/Seasonal-forecast-rad-" + tomonth1 + "-20year.nc"
b1 = addfile(fileSea1,"r")
radiation_June_Sea = b1->Speed10m
radiation_June_Sea =mask(radiation_June_Sea, radiation_June_Sea .le. 0.0001, False)
radiation_June_Sea@_FillValue = 0.0001
radiation_leadtime1_forecast_percent = (radiation_leadtime1_forecast_regrid - radiation_June_Sea) / radiation_June_Sea * 100
print("radiation_June_Sea:")
printMinMax(radiation_June_Sea,True)
;b2
fileSea2 = "ncdata/Seasonal-forecast-rad-" + tomonth2 + "-20year.nc"
b2 = addfile(fileSea2,"r")
radiation_July_Sea = b2->Speed10m
radiation_July_Sea =mask(radiation_July_Sea, radiation_July_Sea .le. 0.0001, False)
radiation_July_Sea@_FillValue = 0.0001
radiation_leadtime2_forecast_percent = (radiation_leadtime2_forecast_regrid - radiation_July_Sea) / radiation_July_Sea * 100
print("radiation_July_Sea:")
printMinMax(radiation_July_Sea,True)
;b3
fileSea3 = "ncdata/Seasonal-forecast-rad-" + tomonth3 + "-20year.nc"
b3 = addfile(fileSea3,"r")
radiation_03_Sea = b3->Speed10m
radiation_03_Sea =mask(radiation_03_Sea, radiation_03_Sea .le. 0.0001, False)
radiation_03_Sea@_FillValue = 0.0001
print("radiation_03_Sea:")
printMinMax(radiation_03_Sea,True)
radiation_leadtime3_forecast_percent = (radiation_leadtime3_forecast_regrid - radiation_03_Sea) / radiation_03_Sea * 100

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
foutf = "./text/Seasonal-forecast-rad-" + fromtime + "-regrid-minus-Seasonalhistory-" + tomonth1 + "-average-10mNew.csv"
header = ("longitude,   latitude,    windspeed-10m")
hlist = [/header/]
alist = [/lon2d, lat2d, radiation_leadtime1_forecast_percent/]
system("/bin/rm -f " + foutf)
write_table(foutf, "w", hlist, "%s")
write_table(foutf, "a", alist, "%9.4f, %9.4f, %9.4f")
;---
; wind 10m 2020 minus Seasonal-history(%) leadtime2
foutf = "./text/Seasonal-forecast-rad-" + fromtime + "-regrid-minus-Seasonalhistory-" + tomonth2 + "-average-10mNew.csv"
header = ("longitude,   latitude,    windspeed-10m")
hlist = [/header/]
alist = [/lon2d, lat2d, radiation_leadtime2_forecast_percent/]
system("/bin/rm -f " + foutf)
write_table(foutf, "w", hlist, "%s")
write_table(foutf, "a", alist, "%9.4f, %9.4f, %9.4f")
;---
; wind 10m 2020 minus Seasonal-history(%) leadtime3
foutf = "./text/Seasonal-forecast-rad-" + fromtime + "-regrid-minus-Seasonalhistory-" + tomonth3 + "-average-10mNew.csv"
header = ("longitude,   latitude,    windspeed-10m")
hlist = [/header/]
alist = [/lon2d, lat2d, radiation_leadtime3_forecast_percent/]
system("/bin/rm -f " + foutf)
write_table(foutf, "w", hlist, "%s")
write_table(foutf, "a", alist, "%9.4f, %9.4f, %9.4f")

return 1
end

begin

s = test("June")

end