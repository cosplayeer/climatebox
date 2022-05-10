load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_inv_string.ncl"
; yearfrom="2017"
; targetmonth="201802"

; yearfrom="2018"
; targetmonth="201902"

; yearfrom="2019"
; targetmonth="202002"

yearfrom="2020"
targetmonth="202102"

fil = "data/ec"+yearfrom+"12"+"_"+targetmonth+"_global.grib"

a=addfile(fil, "r")
u10_temp = a->10U_GDS0_SFC
;[ensemble0 | 51] x [forecast_time1 | 860] x [g0_lat_2 | 2] x [g0_lon_3 | 2]
u10 = u10_temp(0,:,::-1,:)
v10 = a->10V_GDS0_SFC(0,:,::-1,:)
pressure = a->MSL_GDS0_SFC(0,:,::-1,:) /100
t2m = a->2T_GDS0_SFC(0,:,::-1,:) -273.15
density = pressure * 0.1 * 3.4837 / (t2m + 273.15)
t = a->forecast_time1 ;6,12,18,24
t@units = "hours since "+yearfrom+"-12-01 00:00:0.0"
printVarSummary(t)
xi = a->g0_lon_3 ;124,125
yi = a->g0_lat_2(::-1) ;43,42
;diqingyuan
xo = (/ 109.202914 /)
yo = (/ 37.6528 /)
;jianggongling
xo = (/ 116.1528 /)
yo = (/ 29.4395 /)
U10point = linint2_points(xi, yi, u10, True, xo, yo, 0)
V10point = linint2_points(xi, yi, v10, True, xo, yo, 0)
pressurepoint = linint2_points(xi, yi, pressure, True, xo, yo, 0)
t2mpoint = linint2_points(xi, yi, t2m, True, xo, yo, 0)
densitypoint = linint2_points(xi, yi, density, True, xo, yo, 0)
wind10 = sqrt(U10point^2 + V10point^2)
winddir10 = wind_direction(U10point, V10point,0)

; ;output csv
datatype="ecmwf_jianggongling"

outputname = "text/" + datatype + "_" + targetmonth + ".csv" 
foutf =  outputname
; output header
if (fileexists(foutf)) then
    system("/bin/rm -f "+ foutf)
end if
header = (/"TimeInfo, WindSpeed10m, WindDirection10m, Temperature2m, Pressure10m, Airdensity "/)
hlist = [/header/]
write_table(foutf,"w",hlist,"%s")
; siymdh=tostring(t)
siymdh = cd_string(t, "%Y%N%D %H:%M:%S")
; print(siymdh)
; do i = 0, dimfile - 1
siymdh=tostring(siymdh)
alist = [/siymdh, wind10, winddir10, t2mpoint, pressurepoint, densitypoint/]
write_table(foutf,"a",alist, "%s, %9.3f, %9.3f, %9.3f, %9.3f, %9.3f")
; end do