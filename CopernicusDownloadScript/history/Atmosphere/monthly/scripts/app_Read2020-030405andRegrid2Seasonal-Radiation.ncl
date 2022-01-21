; goal:
; step 1 : read in forecast 1x1
; step 2 : forecast 1x1 to 0.25p (regrid)
; step 3 : read in ERA5 0.25p
; step 4 : forecast - ERA5
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

;------------------month april-------------------------------
monthname = "May"
mname1 = "June-rad"
mname2 = "July-rad"
mname3 = "August-rad"
function test(monthname:string)
begin
;readin forecast 1x1
file2020_05 = "../../../forecast/seasonal-monthly/dataRadiation/nowseasonal-monthly-rad-2020-05_leadtime123456.grib"
a1 = addfile(file2020_05,"r")
radiation = a1->VAR_169_GDS0_SFC ;51x6x181x360

radiation_June = radiation(:,0,:,:)
radiation_June_ea = dim_avg_n_Wrap(radiation_June, 0)
radiation_July = radiation(:,1,:,:)
radiation_July_ea = dim_avg_n_Wrap(radiation_July, 0)
radiation_Agust = radiation(:,2,:,:)
radiation_Agust_ea = dim_avg_n_Wrap(radiation_Agust, 0)
print(avg(radiation_June_ea))
printVarSummary(radiation_June_ea)

;------------------------------------------------------
;regrid to 0.25
;---------------------------------------------
; regrid radiation_June_ea 6 m/s April
Opt                = True

Opt@SrcFileName    = "src_SCRIP.nc"	;写入的元数据描述文件
Opt@DstFileName    = "dst_SCRIP.nc" ;写入的目标数据描述文件
Opt@WgtFileName    = "NCEP_2_Rect.nc"
Opt@ForceOverwrite = True

Opt@SrcGridMask    = where(.not.ismissing(radiation_June_ea),1,0)   ; use SrcMask2D in NCL V6.2.1 and earlier

Opt@DstGridType    = "0.25x0.25"
Opt@DstLLCorner    = (/ -90.d,   0.d/) ; (default = [-90,-180])
Opt@DstURCorner    = (/  90.d, 359.75/) ;(default = [90,180])

radiation_June_ea_regrid = ESMF_regrid(radiation_June_ea,Opt)
; printVarSummary(radiation_June_ea_regrid)
; print(avg(radiation_June_ea_regrid))
; printMinMax(radiation_June_ea_regrid, False)

;---------------------------------------------
; regrid radiation_July_ea 6 m/s 
Opt                = True

Opt@SrcFileName    = "src_SCRIP.nc"	;写入的元数据描述文件
Opt@DstFileName    = "dst_SCRIP.nc" ;写入的目标数据描述文件
Opt@WgtFileName    = "NCEP_2_Rect.nc"
Opt@ForceOverwrite = True

Opt@SrcGridMask    = where(.not.ismissing(radiation_July_ea),1,0)   ; use SrcMask2D in NCL V6.2.1 and earlier

Opt@DstGridType    = "0.25x0.25"
Opt@DstLLCorner    = (/ -90.d,   0.d/) ; (default = [-90,-180])
Opt@DstURCorner    = (/  90.d, 359.75/) ;(default = [90,180])

radiation_July_ea_regrid = ESMF_regrid(radiation_July_ea,Opt)

;---------------------------------------------
; regrid radiation_Agust_ea 6 m/s 
Opt                = True

Opt@SrcFileName    = "src_SCRIP.nc"	;写入的元数据描述文件
Opt@DstFileName    = "dst_SCRIP.nc" ;写入的目标数据描述文件
Opt@WgtFileName    = "NCEP_2_Rect.nc"
Opt@ForceOverwrite = True

Opt@SrcGridMask    = where(.not.ismissing(radiation_Agust_ea),1,0)   ; use SrcMask2D in NCL V6.2.1 and earlier

Opt@DstGridType    = "0.25x0.25"
Opt@DstLLCorner    = (/ -90.d,   0.d/) ; (default = [-90,-180])
Opt@DstURCorner    = (/  90.d, 359.75/) ;(default = [90,180])

radiation_Agust_ea_regrid = ESMF_regrid(radiation_Agust_ea,Opt)

;---------------------------------------------
;read in era5 20year April　
;Prepare: Read_Seasonalforecast-03-April-avg.ncl, output nc data, done
; read in Speed10m, Speed10m_UV, Speed100m_UV
;b1 ;april not change!!!
fileSea = "ncdata/Seasonal-forecast-rad-" + "april" + "-20year.nc"
b1 = addfile(fileSea,"r")
radiation_June_Sea = b1->Speed10m
radiation_June_Sea_percent = (radiation_June_ea_regrid - radiation_June_Sea) / radiation_June_Sea * 100
print("April")
print(radiation_June_Sea_percent(472,376))
; print(radiation_June_Sea_percent(474,374))
print("-------")
;b2
fileSea = "ncdata/Seasonal-forecast-rad-" + "May" + "-20year.nc"
b2 = addfile(fileSea,"r")
radiation_July_Sea = b2->Speed10m
radiation_July_Sea_percent = (radiation_July_ea_regrid - radiation_July_Sea) / radiation_July_Sea * 100
print("May")
print(radiation_July_Sea_percent(472,376))
; print(radiation_July_Sea_percent(474,374))
print("-------")
;b3
fileSea = "ncdata/Seasonal-forecast-rad-" + "june" + "-20year.nc"
b3 = addfile(fileSea,"r")
radiation_Agust_Sea = b3->Speed10m
radiation_Agust_Sea_percent = (radiation_Agust_ea_regrid - radiation_Agust_Sea) / radiation_Agust_Sea * 100
print("June")
print(radiation_Agust_Sea_percent(472,376))
; print(radiation_Agust_Sea_percent(474,374))
print("-------")
printMinMax(radiation_June_Sea_percent,True)
print(avg(radiation_June_Sea_percent))
printMinMax(radiation_July_Sea_percent,True)
print(avg(radiation_July_Sea_percent))
printMinMax(radiation_Agust_Sea_percent,True)
print(avg(radiation_Agust_Sea_percent))

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
; rad 10m 2020 minus Seasonal-history(%) april
foutf = "./text/Seasonal-forecast-2020-regrid-minus-Seasonalhistory-month-" + mname1 + "-average-10mNew.csv"
header = ("longitude,   latitude,    radspeed-10m")
hlist = [/header/]
alist = [/lon2d, lat2d, radiation_June_Sea_percent/]
system("/bin/rm -f " + foutf)
write_table(foutf, "w", hlist, "%s")
write_table(foutf, "a", alist, "%9.4f, %9.4f, %9.4f")
;---
;write to nc
outname = "./ncdata/2020-" + mname1 + "-seasonal-percent-10m.nc"
system("/bin/rm -f " + outname)
ncdf = addfile(outname,"c")
; filedimdef(ncdf, "time", -1, True)
radiation_June_Sea_percent@long_name = "rad speed April seasonal percent"
radiation_June_Sea_percent@units     = "%"
ncdf->percent = radiation_June_Sea_percent
;---
; rad 10m 2020 minus Seasonal-history(%) May
foutf = "./text/Seasonal-forecast-2020-regrid-minus-Seasonalhistory-month-" + mname2 + "-average-10mNew.csv"
header = ("longitude,   latitude,    radspeed-10m")
hlist = [/header/]
alist = [/lon2d, lat2d, radiation_July_Sea_percent/]
system("/bin/rm -f " + foutf)
write_table(foutf, "w", hlist, "%s")
write_table(foutf, "a", alist, "%9.4f, %9.4f, %9.4f")
;---
;write to nc
outname = "./ncdata/2020-" + mname2 + "-seasonal-percent-10mNew.nc"
system("/bin/rm -f " + outname)
ncdf = addfile(outname,"c")
; filedimdef(ncdf, "time", -1, True)
radiation_July_Sea_percent@long_name = "rad speed may seasonal percent"
radiation_July_Sea_percent@units     = "%"
ncdf->percent = radiation_July_Sea_percent
;---
; rad 10m 2020 minus Seasonal-history(%) june
foutf = "./text/Seasonal-forecast-2020-regrid-minus-Seasonalhistory-month-" + mname3 + "-average-10mNew.csv"
header = ("longitude,   latitude,    radspeed-10m")
hlist = [/header/]
alist = [/lon2d, lat2d, radiation_Agust_Sea_percent/]
system("/bin/rm -f " + foutf)
write_table(foutf, "w", hlist, "%s")
write_table(foutf, "a", alist, "%9.4f, %9.4f, %9.4f")
;---
;write to nc
outname = "./ncdata/2020-" + mname3 + "-seasonal-percent-10mNew.nc"
system("/bin/rm -f " + outname)
ncdf = addfile(outname,"c")
; filedimdef(ncdf, "time", -1, True)
radiation_Agust_Sea_percent@long_name = "rad speed august seasonal percent"
radiation_Agust_Sea_percent@units     = "%"
ncdf->percent = radiation_Agust_Sea_percent
;---
return 1
end

begin

s = test("april")

end