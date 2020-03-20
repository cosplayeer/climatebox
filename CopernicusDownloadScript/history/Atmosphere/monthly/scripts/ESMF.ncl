load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"


;dimensions:
;   initial_time0_hours = 12
;   g0_lat_1 = 721
;   g0_lon_2 = 1440
;   g0_lat_3 = 361
;   g0_lon_4 = 720
;   initial_time5_hours = 12


filename = "data/reanalysis-era5-single-levels-monthly-means-1999.grib"
a = addfile(filename,"r")
spd10 = a->10SI_GDS0_SFC_S123
u10 = a->10U_GDS0_SFC_S123
v10 = a->10V_GDS0_SFC_S123
lat1d=a->g0_lat_1
lon1d=a->g0_lon_2
spd10_1 = spd10(0,:,:)
printVarSummary(spd10_1)
printVarSummary(lat1d)   ;-90 90
printVarSummary(lon1d)   ;1440 0-359.75

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

;output csv file
; foutf = "./text/ERA5199901.csv"
; header = ("longitude,   latitude,    wind10m")
; hlist = [/header/]
; alist = [/lon2d, lat2d, spd10_1/]
; system("/bin/rm -f " + foutf)
; write_table(foutf, "w", hlist, "%s")
; write_table(foutf, "a", alist, "%9.4f, %9.4f, %9.4f")


Opt                = True

Opt@SrcFileName    = "src_SCRIP.nc"	;写入的元数据描述文件
Opt@DstFileName    = "dst_SCRIP.nc" ;写入的目标数据描述文件
Opt@WgtFileName    = "NCEP_2_Rect.nc"
Opt@ForceOverwrite = True

Opt@SrcGridMask    = where(.not.ismissing(spd10_1),1,0)   ; use SrcMask2D in NCL V6.2.1 and earlier

Opt@DstGridType    = "0.25x0.25"
Opt@DstLLCorner    = (/ -90.d,   0.d/) ; (default = [-90,-180])
Opt@DstURCorner    = (/  90.d, 359.75/) ;(default = [90,180])
;经度是-180至+180，需转换原始文件。
temp_regrid = ESMF_regrid(spd10_1,Opt)
printVarSummary(temp_regrid)

;output csv2 file
foutf = "./text/ERA5199901_esmf.csv"
header = ("longitude,   latitude,    temp_regrid")
hlist = [/header/]
alist = [/lon2d, lat2d, temp_regrid/]
system("/bin/rm -f " + foutf)
write_table(foutf, "w", hlist, "%s")
write_table(foutf, "a", alist, "%9.4f, %9.4f, %9.4f")