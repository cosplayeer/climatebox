load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_inv_string.ncl"

; fromdate="20220701"
; targetmonth="20220901" ; target  =  fromdate add 2 months
; datatype="ECMWF_NewHuadiankushui"
; xo = (/ 95.2555 /)
; yo = (/ 42.5754 /)
; datatype="ECMWF_Naomaohu" ;OK
; xo = (/ 94.9144 /)
; yo = (/ 43.6945 /)
; datatype="ECMWF_xinjiangsantanghu1qi"
; xo = (/ 93.2372 /)
; yo = (/ 44.1552 /)
xo = (/ xlon /)
yo = (/ ylat /)
;FNL---demo end
fil = "data/Seasonal_2month_daily"+fromdate+"china.grib"

do i=0,50,1 ; i <=50
    a=addfile(fil, "r")
    u10_temp = a->10U_GDS0_SFC
    v10_temp = a->10V_GDS0_SFC

    ; g0_lat_1 dimension la1:44.5, la2:42.5
    ; future 2-3 month
    ; u10 = u10_temp(i,124:248,::-1,:)  ;start slice deep hole.闰月闰年 
    ; v10 = v10_temp(i,124:248,::-1,:)
    ; t = a->forecast_time1(124:248) ;6,12,18,24

    ; future 1.5-3 month
    u10 = u10_temp(i,62:248,::-1,:)  ;start slice deep hole.闰月闰年 
    v10 = v10_temp(i,62:248,::-1,:)
    t = a->forecast_time1(62:248) ;6,12,18,24

    dtime_map = (/4,2,2/)
    tst_dtime = str_split_by_length(fromdate, dtime_map)
    yyyy = tst_dtime(0)
    mm = tst_dtime(1)
    dd = tst_dtime(2)
    ; t@units = "hours since 2020-12-01 00:00" ;20211201
    t@units = "hours since "+yyyy+"-"+mm+"-"+dd+" 00:00" ;20211201
    printVarSummary(t)
    xi = a->g0_lon_3 ;124,125
    yi = a->g0_lat_2(::-1) ;44.5 to 42.5

    ;linint function lat & lon must be increasing.
    U10point = linint2_points(xi, yi, u10, True, xo, yo, 0)
    V10point = linint2_points(xi, yi, v10, True, xo, yo, 0)
    wind10 = sqrt(U10point^2 + V10point^2)
    winddir10 = wind_direction(U10point, V10point,0)

    ; ;output csv


    outputname = "text_ec_esembles/" + "test_ecmwf_" + datatype + "_" + targetmonth + "_"+tostring(i) + ".csv" 
    foutf =  outputname
    ; output header
    if (fileexists(foutf)) then
        system("/bin/rm -f "+ foutf)
    end if
    header = (/"TimeInfo,WindSpeed10m,WindDirection10m"/)
    hlist = [/header/]
    write_table(foutf,"w",hlist,"%s")
    ; siymdh=tostring(t)
    siymdh = cd_string(t, "%Y%N%D %H:%M:%S")
    ; print(siymdh)
    siymdh=tostring(siymdh)
    alist = [/siymdh, wind10, winddir10/]
    write_table(foutf,"a",alist, "%s, %9.3f, %9.3f")
end do


