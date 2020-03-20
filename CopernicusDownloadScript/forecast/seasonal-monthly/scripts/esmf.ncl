load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"


fileERA5 = "../../history/Atmosphere/monthly/data/reanalysis-era5-single-levels-monthly-means-1999.grib"
a = addfile(fileERA5,"r")
; spd10a = a->10SI_GDS0_SFC_S123
u10 = a->10U_GDS0_SFC_S123
v10 = a->10V_GDS0_SFC_S123
lat1d=a->g0_lat_1
lon1d=a->g0_lon_2
; spd10_1 = spd10a(0,:,:)
; printVarSummary(spd10_1)
; printVarSummary(lat1d)   ;-90 90
; printVarSummary(lon1d)   ;1440 0-359.75

; lat lon txt
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

;fileforcast = "data/seasonal-monthly-sfc-2020-02_1-6_new.grib"
fileforcast = "data2/seasonal-monthly-sfc.nc"
b = addfile(fileforcast,"r")
; Speed = b->10SI_GDS0_SFC  ;[ensemble0 | 51] x [forecast_time1 | 6] x [g0_lat_2 | 181] x [g0_lon_3 | 360]
spd10_1_1 = b->Speed
; g0_lat_2  = b->g0_lat_2 
; g0_lon_3  = b->g0_lon_3
; printVarSummary(g0_lat_2) ;[90..-90] ;181
; printVarSummary(g0_lon_3) ;[ 0..359] ;360
lat_temp  = b->g0_lat_1 
lon_temp  = b->g0_lon_2
; lat lon txt
numlat = 181
numlon = 360
lon2db = new((/numlat, numlon/), float)
lat2db = new((/numlat, numlon/), float)
;do loop
do n = 0, numlon -1
    lon2db(:,n) = lon_temp(n)
end do
do n = 0, numlat -1
    lat2db(n,:) = lat_temp(n)
end do

;output csv b file
foutf = "./text/forecast_20yearlymean_1x1.csv"
header = ("longitude,   latitude,    spd10")
hlist = [/header/]
alist = [/lon2db, lat2db, spd10_1_1/]
system("/bin/rm -f " + foutf)
write_table(foutf, "w", hlist, "%s")
write_table(foutf, "a", alist, "%9.4f, %9.4f, %9.4f")


Opt                = True
Opt@SrcFileName    = "src_SCRIP.nc"	;写入的元数据描述文件
Opt@DstFileName    = "dst_SCRIP.nc" ;写入的目标数据描述文件
Opt@WgtFileName    = "NCEP_2_Rect.nc"
Opt@ForceOverwrite = True

Opt@SrcGridMask    = where(.not.ismissing(spd10_1_1),1,0)   ; use SrcMask2D in NCL V6.2.1 and earlier

Opt@DstGridType    = "0.25x0.25"
Opt@DstLLCorner    = (/ -90.d,   0.d/) ; (default = [-90,-180])
Opt@DstURCorner    = (/  90.d, 359.75/) ;(default = [90,180])
;经度是-180至+180，需转换原始文件。
temp_regrid = ESMF_regrid(spd10_1_1,Opt)
printVarSummary(temp_regrid)

;output csv file
foutf = "./text/forecast_20yearlymean_0.25x0.25.csv"
header = ("longitude,   latitude,    temp_regrid")
hlist = [/header/]
alist = [/lon2d, lat2d, temp_regrid/]
system("/bin/rm -f " + foutf)
write_table(foutf, "w", hlist, "%s")
write_table(foutf, "a", alist, "%9.4f, %9.4f, %9.4f")