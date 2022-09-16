load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_inv_string.ncl"
year="2018"
; month="06"
; day="21"
month="12"
day="22"
text_suffix="_demo"
; ERA5_rad_20180801
; fil = "data/cfsv2_rad/dswsfc.cdas1.201801.grb2"
fil = systemfunc("ls data/cfsv2_rad_1hourly/dswsfc.cdas1.2018*.grb2" +" |head -n 1")
; print(fil)
a=addfile(fil, "r")

DSWRF=a->DSWRF_P8_L1_GGA0_avg(:,:,::-1,:)
printVarSummary(DSWRF)
; print(a)
; _ssrd=a->DSWRF_P8_L1_GGA0_avg
; _ssrd=a->DSWRF_P8_L1_GGA0_avg(:,::-1,:)
; printVarSummary(_ssrd)
; ssrd = short2flt(_ssrd) / 3600
; ssrd@units = "wh m**-2"
; ; 1wh = 3600 j
; printVarSummary(ssrd)
printMinMax(DSWRF, True)

; ; _ssrc=a->ssrc(:,::-1,:)
; ; ssrc = short2flt(_ssrc) / 3600
; ; ssrc@units = "wh m**-2"

; ; _ssr=a->ssr(:,::-1,:)
; ; ssr = short2flt(_ssr) / 3600
; ; ssr@units = "wh m**-2"

; t = a[:]->initial_time0_hours
; ; ; printVarSummary(t)
; xi = a[0]->lon_0
; yi = a[0]->lat_0(::-1)  ;;默认从正到负
; ; print(yi)
; ;dongfang
; xo = (/93.5847/)
; yo = (/43.009/)
; ; ;fuxin
; ; xo = (/90.2915/)
; ; yo = (/44.0462/)
; ; ; ; ;linuo
; ; xo = (/93.6184/)
; ; yo = (/43.0364/)
; ;linint function lat & lon must be increasing.
; ; Surface solar radiation downwards
; RadpointDSWRF = linint2_points(xi, yi, DSWRF, True, xo, yo, 0)

; ; ; ;output csv

; datatype = "radiation"
; targetpoint = "dongfang" ;"fuxin" ; "linuo"
; ; targetpoint = "fuxin" ;"fuxin" ; "linuo"
; ; targetpoint = "linuo"
; foutf = "text/" + "cfsv2_" + datatype + "_" + targetpoint + text_suffix+ ".csv" 
; ; output header
; if (fileexists(foutf)) then
;     system("/bin/rm -f "+ foutf)
; end if
; header = (/"TimeInfo,RadiationCFSv2"/)
; hlist = [/header/]
; ; write_table(foutf,"w",hlist,"%s")
; ; ; siymdh=tostring(t)
; ; siymdh = cd_string(t, "%Y%N%D %H:%M:%S")
; ; ; print(siymdh)
; ; siymdh=tostring(siymdh)
; ; alist = [/siymdh, RadpointSsrd, RadpointSsrc, RadpointSsr/]
; ; write_table(foutf,"a",alist, "%s, %9.3f, %9.3f, %9.3f")