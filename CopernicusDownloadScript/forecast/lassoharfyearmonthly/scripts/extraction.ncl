load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_inv_string.ncl"
yearfrom="2020"
; yearfrom="2020"
timestart="1２"
; timestart="06"



fil = "data/seasonal-monthly-sfc-"+yearfrom+"-"+timestart+"_leadtime123456.grib"

a=addfile(fil, "r")
u10_temp = a->10U_GDS0_SFC
;[ensemble0 | 51] x [forecast_time1 | 860] x [g0_lat_2 | 2] x [g0_lon_3 | 2]
u1051 = u10_temp(:,:,::-1,:)
; u10 = dim_avg_n_Wrap(u1051, 0) 
u10 = u1051
printVarSummary(u10)
v1051 = a->10V_GDS0_SFC(:,:,::-1,:)
; v10 = dim_avg_n_Wrap(v1051, 0)
v10 = v1051
; t = a->forecast_time1 ;6,12,18,24  ;202106
t = a->forecast_time4 ;6,12,18,24 ; time before 202106
t@units = "hours since "+yearfrom+"-"+timestart+"-01 00:00:0.0"
printVarSummary(t)
xi = a->g0_lon_3 ;124,125
yi = a->g0_lat_2(::-1) ;43,42
xo = (/ 124.268 /)
yo = (/ 42.6329 /)
U10point = linint2_points(xi, yi, u10, True, xo, yo, 0)
V10point = linint2_points(xi, yi, v10, True, xo, yo, 0)
wind10 = sqrt(U10point^2 + V10point^2)
printVarSummary(wind10)
winddir10 = wind_direction(U10point, V10point,0)
; iymdh = u10@initial_time
; symdh = tostring(iymdh)
; iiymdh = grib_stime2itime(symdh)
; stringiymdh = tostring(iiymdh)
; print(iiymdh)
; print(stringiymdh)
; print(wind10)
; print(t(:10))
; print(lat0)
; print(lon0)
; printVarSummary(u10)
; print(u10_temp(0,0,:,:))
; print(u10(0,0,:,:))

; ;output csv
datatype="ecmwf_all"

outputname = "text/" + datatype + "_" + yearfrom + timestart + ".csv" 
foutf =  outputname
; output header
if (fileexists(foutf)) then
    system("/bin/rm -f "+ foutf)
end if
header = (/"TimeInfo, WindSpeed10m, WindDirection10m "/)
hlist = [/header/]
write_table(foutf,"w",hlist,"%s")
; siymdh=tostring(t)
siymdh = cd_string(t, "%Y%N01 %H:%M:%S")
; print(siymdh)
; do i = 0, dimfile - 1
siymdh=tostring(siymdh)
; alist = [/siymdh, wind10, winddir10/]
alist = [/siymdh, wind10/]
write_table(foutf,"a",alist, "%s, %9.3f,%9.3f,%9.3f")
; end do