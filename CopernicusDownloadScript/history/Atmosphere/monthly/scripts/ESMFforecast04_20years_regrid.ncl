load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

;read data
;dimension sizes do not conform to other
;read data2
;attributes not ok, need add

i = 1999
do while (i .lt. 2020)


filelist = systemfunc("ls ../../../forecast/seasonal-monthly/data2/seasonal-monthly-sfc-ensemble-avg" + i + "03.nc")
print(filelist)
a = addfile(filelist,"r")
; ListSetType(a, "join")
; spd10 = a->10SI_GDS0_SFC_S123
; u10 = a[:]->10U_GDS0_SFC
; v10 = a[:]->10V_GDS0_SFC
spd10 = a->Wind10_avg_2 ;;;;;;key
; spd10 = sqrt(u10*u10 + v10*v10) ;51x6x181x360
; copy_VarMeta(u10, spd10)
lat1d_old=a->g0_lat_1
lon1d_old=a->g0_lon_2
; spd10_4 = spd10(1,:,:) ;1x6x181x360
; spd10_4 = spd10(0,1,:,:) ;1x6x181x360
; spd10_4_ea = dim_avg_n_Wrap((spd10), 0)
spd10_4 = spd10(:,:)
spd10_4@long_name = "wind speed ea at 10m of seasonal forecast"
spd10_4@gds_grid_type = 0
lat1d_old@long_name = "latitude"
lat1d_old@GridType = "Cylindrical Equidistant Projection Grid"
lon1d_old@long_name = "longitude"
lon1d_old@GridType = "Cylindrical Equidistant Projection Grid"
printVarSummary(spd10)
printVarSummary(spd10_4)
printVarSummary(lat1d_old)   ;-90 90 181
printVarSummary(lon1d_old)   ;1440 0-359 360

; numlat = 721
; numlon = 1440
; lat1d = new((/numlat/),float)
; i = 0
; do while(i .lt. numlat)
;     lat1d(i) = 90.0 - i * 0.25
;     i = i + 1
; end do
; lon1d = new((/numlon/),float)
; i = 0
; do while(i .lt. numlon)
;     lon1d(i) = 0 + i * 0.25
;     i = i + 1
; end do

; lon2d = new((/numlat, numlon/), float)
; lat2d = new((/numlat, numlon/), float)
; ;do loop
; do n = 0, numlon -1
;     lon2d(:,n) = lon1d(n)
; end do
; do n = 0, numlat -1
;     lat2d(n,:) = lat1d(n)
; end do


Opt                = True

Opt@SrcFileName    = "src_SCRIP.nc"	;写入的元数据描述文件
Opt@DstFileName    = "dst_SCRIP.nc" ;写入的目标数据描述文件
Opt@WgtFileName    = "NCEP_2_Rect.nc"
Opt@ForceOverwrite = True

Opt@SrcGridMask    = where(.not.ismissing(spd10_4),1,0)   ; use SrcMask2D in NCL V6.2.1 and earlier

Opt@DstGridType    = "0.25x0.25"
Opt@DstLLCorner    = (/ -90.d,   0.d/) ; (default = [-90,-180])
Opt@DstURCorner    = (/  90.d, 360.0/) ;(default = [90,180])
;经度default是-180至+180
temp_regrid = ESMF_regrid(spd10_4,Opt)
printVarSummary(temp_regrid)

;output nc file
filedir = "../../../forecast/seasonal-monthly/data_0.25/seasonal-monthly-sfc-ensemble-avg-" + i + "04.nc"
system("/bin/rm -f " + filedir)
ncdf = addfile(filedir, "c")
ncdf->Wind10m = temp_regrid

    i = i + 1
end do
; ;output csv1 file
; foutf = "./text/SA1999_03_1_beforeregrid.csv"
; header = ("longitude,   latitude,    spd10_4")
; hlist = [/header/]
; alist = [/lon1d_old, lat1d_old, spd10_4/]
; system("/bin/rm -f " + foutf)
; write_table(foutf, "w", hlist, "%s")
; write_table(foutf, "a", alist, "%9.4f, %9.4f, %9.4f")


; ;output csv2 file
; foutf = "./text/SA1999_03_1_afterregrid.csv"
; header = ("longitude,   latitude,    spd10_4")
; hlist = [/header/]
; alist = [/lon2d, lat2d, temp_regrid/]
; system("/bin/rm -f " + foutf)
; write_table(foutf, "w", hlist, "%s")
; write_table(foutf, "a", alist, "%9.4f, %9.4f, %9.4f")
