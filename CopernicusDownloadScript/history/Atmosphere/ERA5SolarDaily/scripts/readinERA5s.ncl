load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_inv_string.ncl"
; lat=35.87
; lon=104.15
text_suffix="_"+lat+"_"+lon
; year=2018
fil = systemfunc("ls data/era5_rad/era5_download_nc/ERA5_rad_"+year+"*.nc")
; print(fil)
a=addfiles(fil, "r")
ListSetType(a, "cat")

_ssrc=a[:]->ssrc(:,::-1,:)
ssrc = short2flt(_ssrc) / 3600
ssrc@units = "wh m**-2"


t = a[:]->time
; printVarSummary(t)
xi = a[0]->longitude ;124,125
yi = a[0]->latitude(::-1) ;44.5 to 42.5
; print(yi)
;dongfang
xo = (/ tofloat(lon) /)
yo = (/ tofloat(lat) /)
;linint function lat & lon must be increasing.
RadpointSsrc = linint2_points(xi, yi, ssrc, True, xo, yo, 0)
; ;output csv

datatype = "ERA5"
; targetloc = "CHN_Gansu_Yuzhong_529830_CSWD" ;"fuxin" ; "linuo"
foutf = "data/data_after_process/ERA5/" + datatype + "_" + targetloc + text_suffix+ ".csv" 
; output header
if (fileexists(foutf)) then
    system("/bin/rm -f "+ foutf)
end if
header = (/"TimeInfo, Radiationssrc"/)
hlist = [/header/]
write_table(foutf,"w",hlist,"%s")
; siymdh=tostring(t)
siymdh = cd_string(t, "%Y%N%D %H:%M:%S")
; print(siymdh)
siymdh=tostring(siymdh)
alist = [/siymdh, RadpointSsrc/]
write_table(foutf,"a",alist, "%s, %9.3f")