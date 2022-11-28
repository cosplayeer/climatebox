load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_inv_string.ncl"
; year="2018"
; month="06"
; day="21"

text_suffix="_"+lat+"_"+lon

fil = systemfunc("ls data/SolarChina3hourly0.1/srad_CMFD_V0106_B-01_03hr_010deg_"+year+"*.nc ")
a=addfiles(fil, "r")
ListSetType(a, "cat")
; short srad ( time, lat, lon ) units :        W m-2
_DSWRF=a[:]->srad(:,:,:) 
; DSWRF = _DSWRF2(:,::-1,:) ;是否需要翻转纬度, 不需要
            ; lat: [15.05..54.95]
            ; lon: [70.05..139.95]
DSWRF = short2flt(_DSWRF)
; printVarSummary(DSWRF)
; printMinMax(DSWRF, True)

t = a[:]->time
; printVarSummary(t)
xi = a[0]->lon
yi = a[0]->lat
; yi = _yi(::-1)
; print(yi)
; ;dongfang
; xo = (/93.5847/) 
; yo = (/43.009/)
; ; ;fuxin
; xo = (/90.2915/)
; yo = (/44.0462/)
; ; ; ; ;linuo
; xo = (/93.6184/)
; yo = (/43.0364/)
xo = (/ tofloat(lon) /)
yo = (/ tofloat(lat) /)
; ;linint function lat & lon must be increasing.
; ; Surface solar radiation downwards
RadpointDSWRF = linint2_points(xi, yi, DSWRF, True, xo, yo, 0)
; ; print(RadpointDSWRF)
; ; ; ;output csv

datatype = "SolarChina"
; targetpoint = "dongfang" ;"fuxin" ; "linuo"
; targetpoint = "fuxin" ;"fuxin" ; "linuo"
targetpoint = "linuo"
foutf = "data/data_after_process/" + datatype +"/3hourly/" +  datatype + "_" + targetloc + text_suffix+ ".csv" 
; ; output header
if (fileexists(foutf)) then
    system("/bin/rm -f "+ foutf)
    
end if
header = (/"TimeStamp,    SolarChina"/)
hlist = [/header/]
write_table(foutf,"w",hlist,"%s")
; siymdh=tostring(t)
siymdh = cd_string(t, "%Y%N%D %H:%M:%S")
; print(siymdh)
siymdh=tostring(siymdh)
alist = [/ siymdh, RadpointDSWRF /]
write_table(foutf,"a",alist, "%s, %9.3f")