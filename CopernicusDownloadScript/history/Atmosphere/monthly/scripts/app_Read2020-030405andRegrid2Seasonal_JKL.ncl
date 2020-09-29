; goal:
; step 1 : read in forecast 1x1
; step 2 : forecast 1x1 to 0.25p (regrid)
; step 3 : read in ERA5 0.25p
; step 4 : forecast - ERA5


;------------------month april-------------------------------
monthname = "april"
function test(monthname:string)
begin
;readin forecast 1x1
file2020_03 = "../../../forecast/seasonal-monthly/data/seasonal-monthly-sfc-2019-03_leadtime123.grib"
a1 = addfile(file2020_03,"r")
windspeed10m = a1->10SI_GDS0_SFC

windspeed10m_april = windspeed10m(:,0,:,:)
windspeed10m_april_ea = dim_avg_n_Wrap(windspeed10m_april, 0)
windspeed10m_May = windspeed10m(:,1,:,:)
windspeed10m_May_ea = dim_avg_n_Wrap(windspeed10m_May, 0)
windspeed10m_June = windspeed10m(:,2,:,:)
windspeed10m_June_ea = dim_avg_n_Wrap(windspeed10m_June, 0)
print(avg(windspeed10m_april_ea))
printVarSummary(windspeed10m_april_ea)

;------------------------------------------------------
;regrid to 0.25
;---------------------------------------------
; regrid windspeed10m_april_ea 6 m/s april
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
; regrid windspeed10m_May_ea 6 m/s 
Opt                = True

Opt@SrcFileName    = "src_SCRIP.nc"	;写入的元数据描述文件
Opt@DstFileName    = "dst_SCRIP.nc" ;写入的目标数据描述文件
Opt@WgtFileName    = "NCEP_2_Rect.nc"
Opt@ForceOverwrite = True

Opt@SrcGridMask    = where(.not.ismissing(windspeed10m_May_ea),1,0)   ; use SrcMask2D in NCL V6.2.1 and earlier

Opt@DstGridType    = "0.25x0.25"
Opt@DstLLCorner    = (/ -90.d,   0.d/) ; (default = [-90,-180])
Opt@DstURCorner    = (/  90.d, 359.75/) ;(default = [90,180])

windspeed10m_May_ea_regrid = ESMF_regrid(windspeed10m_May_ea,Opt)

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

;---------------------------------------------
;read in era5 20year april　
;Prepare: Read_Seasonalforecast-03-April-avg.ncl, output nc data, done
; read in Speed10m, Speed10m_UV, Speed100m_UV
;b1
fileSea = "ncdata/Seasonal-forecast-wind-" + "april" + "-20year.nc"
b1 = addfile(fileSea,"r")
windspeed10m_april_Sea = b1->Speed10m
windspeed10m_april_Sea_percent = (windspeed10m_april_ea_regrid - windspeed10m_april_Sea) / windspeed10m_april_Sea * 100
;b2
fileSea = "ncdata/Seasonal-forecast-wind-" + "May" + "-20year.nc"
b2 = addfile(fileSea,"r")
windspeed10m_May_Sea = b2->Speed10m
windspeed10m_May_Sea_percent = (windspeed10m_May_ea_regrid - windspeed10m_May_Sea) / windspeed10m_May_Sea * 100
;b3
fileSea = "ncdata/Seasonal-forecast-wind-" + "june" + "-20year.nc"
b3 = addfile(fileSea,"r")
windspeed10m_june_Sea = b3->Speed10m
windspeed10m_june_Sea_percent = (windspeed10m_June_ea_regrid - windspeed10m_june_Sea) / windspeed10m_june_Sea * 100
; printMinMax(windspeed10m_april_Sea_percent,True)
; print(avg(windspeed10m_april_Sea_percent))
; printMinMax(windspeed10m_May_Sea_percent,True)
; print(avg(windspeed10m_May_Sea_percent))
; printMinMax(windspeed10m_june_Sea_percent,True)
; print(avg(windspeed10m_june_Sea_percent))
; get 100m percent
fileratio = "ncdata/ERA5-100-devide-10-ratio-average.nc"
r4 = addfile(fileratio,"r")
Ratio = r4->Ratio
printVarSummary(Ratio)
printMinMax(Ratio,True)
windspeed100m_april_Sea_percent = windspeed10m_april_Sea_percent * Ratio
windspeed100m_May_Sea_percent = windspeed10m_May_Sea_percent * Ratio
windspeed100m_june_Sea_percent = windspeed10m_june_Sea_percent * Ratio
printMinMax(windspeed100m_april_Sea_percent,True)
printMinMax(windspeed100m_May_Sea_percent,True)
printMinMax(windspeed100m_june_Sea_percent,True)
;output percent to csv
lat1d_org=b1->lat
lon1d_org=b1->lon
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
; wind 10m 2020 minus Seasonal-history(%) april
foutf = "./text/Seasonal-forecast-2020-regrid-minus-Seasonalhistory-month-" + "April" + "-average-100mNew.csv"
header = ("longitude,   latitude,    windspeed-100m")
hlist = [/header/]
alist = [/lon2d, lat2d, windspeed100m_april_Sea_percent/]
system("/bin/rm -f " + foutf)
write_table(foutf, "w", hlist, "%s")
write_table(foutf, "a", alist, "%9.4f, %9.4f, %9.4f")
;---
; ;write to nc
; outname = "./ncdata/2020-April-seasonal-percent-10m.nc"
; system("/bin/rm -f " + outname)
; ncdf = addfile(outname,"c")
; ; filedimdef(ncdf, "time", -1, True)
; windspeed10m_april_Sea_percent@long_name = "wind speed april seasonal percent"
; windspeed10m_april_Sea_percent@units     = "%"
; ncdf->percent = windspeed10m_april_Sea_percent
;---
; wind 10m 2020 minus Seasonal-history(%) May
foutf = "./text/Seasonal-forecast-2020-regrid-minus-Seasonalhistory-month-" + "May" + "-average-100mNew.csv"
header = ("longitude,   latitude,    windspeed-100m")
hlist = [/header/]
alist = [/lon2d, lat2d, windspeed100m_May_Sea_percent/]
system("/bin/rm -f " + foutf)
write_table(foutf, "w", hlist, "%s")
write_table(foutf, "a", alist, "%9.4f, %9.4f, %9.4f")
;---
; ;write to nc
; outname = "./ncdata/2020-May-seasonal-percent-10m.nc"
; system("/bin/rm -f " + outname)
; ncdf = addfile(outname,"c")
; ; filedimdef(ncdf, "time", -1, True)
; windspeed10m_May_Sea_percent@long_name = "wind speed may seasonal percent"
; windspeed10m_May_Sea_percent@units     = "%"
; ncdf->percent = windspeed10m_May_Sea_percent
;---
; wind 10m 2020 minus Seasonal-history(%) june
foutf = "./text/Seasonal-forecast-2020-regrid-minus-Seasonalhistory-month-" + "June" + "-average-100mNew.csv"
header = ("longitude,   latitude,    windspeed-100m")
hlist = [/header/]
alist = [/lon2d, lat2d, windspeed100m_june_Sea_percent/]
system("/bin/rm -f " + foutf)
write_table(foutf, "w", hlist, "%s")
write_table(foutf, "a", alist, "%9.4f, %9.4f, %9.4f")
;---
; ;write to nc
; outname = "./ncdata/2020-June-seasonal-percent-10m.nc"
; system("/bin/rm -f " + outname)
; ncdf = addfile(outname,"c")
; ; filedimdef(ncdf, "time", -1, True)
; windspeed10m_june_Sea_percent@long_name = "wind speed june seasonal percent"
; windspeed10m_june_Sea_percent@units     = "%"
; ncdf->percent = windspeed10m_june_Sea_percent
;---
return 1
end

begin

s = test("april")

end