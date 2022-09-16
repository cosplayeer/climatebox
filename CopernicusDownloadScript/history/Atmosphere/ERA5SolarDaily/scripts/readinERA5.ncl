load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_inv_string.ncl"
year="2018"
; month="06"
; day="21"
month="12"
day="22"
text_suffix="_demo"
; ERA5_rad_20180801
fil = "data/era5_rad/era5_download_nc/ERA5_rad_"+year+month+day+".nc"
a=addfile(fil, "r")
_ssrd=a->ssrd(:,::-1,:)
ssrd = short2flt(_ssrd) / 3600
ssrd@units = "wh m**-2"
; 1wh = 3600 j
printVarSummary(ssrd)
printMinMax(ssrd, True)

_ssrc=a->ssrc(:,::-1,:)
ssrc = short2flt(_ssrc) / 3600
ssrc@units = "wh m**-2"

_ssr=a->ssr(:,::-1,:)
ssr = short2flt(_ssr) / 3600
ssr@units = "wh m**-2"

t = a->time
; printVarSummary(t)
xi = a->longitude ;124,125
yi = a->latitude(::-1) ;44.5 to 42.5
; print(yi)
;dongfang
xo = (/93.5847/)
yo = (/43.009/)
;fuxin
xo = (/90.2915/)
yo = (/44.0462/)
; ; ;linuo
xo = (/93.6184/)
yo = (/43.0364/)
;linint function lat & lon must be increasing.
; Surface solar radiation downwards
RadpointSsrd = linint2_points(xi, yi, ssrd, True, xo, yo, 0)
; Surface net solar radiation, clear sky
RadpointSsrc = linint2_points(xi, yi, ssrc, True, xo, yo, 0)
; Surface net solar radiation
RadpointSsr = linint2_points(xi, yi, ssr, True, xo, yo, 0)

; ;output csv

datatype = "radiation"
targetmonth = "dongfang" ;"fuxin" ; "linuo"
targetmonth = "fuxin" ;"fuxin" ; "linuo"
targetmonth = "linuo"
foutf = "text/" + "ecmwf_" + datatype + "_" + targetmonth + text_suffix+ ".csv" 
; output header
if (fileexists(foutf)) then
    system("/bin/rm -f "+ foutf)
end if
header = (/"TimeInfo,Radiationssrd,Radiationssrc,Radiationssr,"/)
hlist = [/header/]
write_table(foutf,"w",hlist,"%s")
; siymdh=tostring(t)
siymdh = cd_string(t, "%Y%N%D %H:%M:%S")
; print(siymdh)
siymdh=tostring(siymdh)
alist = [/siymdh, RadpointSsrd, RadpointSsrc, RadpointSsr/]
write_table(foutf,"a",alist, "%s, %9.3f, %9.3f, %9.3f")