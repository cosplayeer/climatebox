; arguments:
    ; inputpath : indata_origin_dir
    ; outputpath : Point/6hour dir
    ; Longitude : float
    ; Latitude :float
    ; datatype : 
    ; timestart : int
    ; timeend : int
; ncl ReanalysisExtractPointERA5Lorg.ncl 'inputpath="/home/meteodyn/MesoScalePlatformWeb/indata_origin/FNL"' \
;  'outputpath="/home/meteodyn/MesoScalePlatformWeb/WORKSPACE_R/Point/6hour"' \
; Longitude=126.4 \
; Latitude=30.1 \
; 'datatype = "ERA5"' \
; timestart =20181102 \
; timeend=20181103

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_inv_string.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

rcpValue = "historical"
timeinfo = "195001-199912"
timeinfo = "200001-200512"
latlist = (/31.39385796,31.59191132,30.90015984,31.27859688,31.2179203, \
            31.36000252,30.82096672,31.27267647,31.08909607,31.08995819, \
            31.25971031,31.12671471,31.01718903,31.16488647,31.30041313, \
            31.20923996/)
lonlist = (/121.4003601 ,121.607605,121.5580444,121.4809647, \
            121.4790878 ,121.2398148,121.2507858,121.4460754, \
            121.4145584,121.745697,121.3874588,121.0807953, \
            121.2156525,121.4348221,121.5249557,121.3763657/)

finput = "data/history/sfcWind_Amon_CNRM-CM5-2_"+rcpValue+"_r1i1p1_" + timeinfo + ".nc"
finput2 = "data/history/tas_Amon_CNRM-CM5-2_"+rcpValue+"_r1i1p1_" + timeinfo + ".nc"
finput3 = "data/history/hurs_Amon_CNRM-CM5-2_"+rcpValue+"_r1i1p1_" + timeinfo + ".nc"
finput4 = "data/history/huss_Amon_CNRM-CM5-2_"+rcpValue+"_r1i1p1_" + timeinfo + ".nc"
finput5 = "data/history/rsds_Amon_CNRM-CM5-2_"+rcpValue+"_r1i1p1_" + timeinfo + ".nc"
outputpath = "text/history1"  + "/"

do k = 0, 15          
    print("processing" + tostring(k+1))
    lonf = lonlist(k)
    latf = latlist(k)

    outputname = rcpValue+"_r1i1p1_" + timeinfo + "_"+tostring(lonf)+"_"+tostring(latf)+".csv"
    ; outputname = "/" + datatype + "_" + sprintf("%.3f",Longitude) + "_" + sprintf("%.3f",Latitude) + "_" + timestart + "_" + timeend + ".csv" 
    foutf = outputpath + outputname

    if fileexists(finput) then 
            f = addfile(finput,"r")
        else
            print("warning, file not exist, skipped")
            continue
    end if
    if fileexists(finput2) then 
            f2 = addfile(finput2,"r")
        else
            print("warning, file not exist, skipped")
            continue
    end if
    if fileexists(finput3) then 
            f3 = addfile(finput3,"r")
        else
            print("warning, file not exist, skipped")
            continue
    end if
    if fileexists(finput4) then 
            f4 = addfile(finput4,"r")
        else
            print("warning, file not exist, skipped")
            continue
    end if
    if fileexists(finput5) then 
            f5 = addfile(finput5,"r")
        else
            print("warning, file not exist, skipped")
            continue
    end if
    sfcWind = f->sfcWind
    tc = f2->tas
    rh = f3->hurs
    sh = f4->huss
    rad = f5->rsds
    lat = f->lat
    lon = f->lon
    time = f->time
    time2 = cd_calendar(time,-2)
    ; print(time2)
    ;   lat = 64
    ;   lon = 128
    ; wind
    Opt                = True
    Opt@SrcFileName    = "./temp/Wind_src_SCRIP.nc"	;写入的元数据描述文件
    Opt@DstFileName    = "./temp/Wind_dst_SCRIP.nc" ;写入的目标数据描述文件
    Opt@WgtFileName    = "./temp/Wind_NCEP_2_Rect.nc"
    Opt@ForceOverwrite = True

    ; Opt@SrcGridMask    = where(.not.ismissing(sfcWind),1,0)   ; use SrcMask2D in NCL V6.2.1 and earlier

    Opt@DstGridType    = "1.0x1.0"
    Opt@DstLLCorner    = (/ -90.d,   0.d/) ; (default = [-90,-180])
    Opt@DstURCorner    = (/  90.d, 359.d/) ;(default = [90,180])

    sfcWind_esmf = ESMF_regrid(sfcWind,Opt)
    ; tc
    Opt                = True

    Opt@SrcFileName    = "./temp/tc_src_SCRIP.nc"	;写入的元数据描述文件
    Opt@DstFileName    = "./temp/tc_dst_SCRIP.nc" ;写入的目标数据描述文件
    Opt@WgtFileName    = "./temp/tc_NCEP_2_Rect.nc"
    Opt@ForceOverwrite = True

    ; Opt@SrcGridMask    = where(.not.ismissing(sfcWind),1,0)   ; use SrcMask2D in NCL V6.2.1 and earlier

    Opt@DstGridType    = "1.0x1.0"
    Opt@DstLLCorner    = (/ -90.d,   0.d/) ; (default = [-90,-180])
    Opt@DstURCorner    = (/  90.d, 359.d/) ;(default = [90,180])

    tc_esmf = ESMF_regrid(tc,Opt)

    ; printVarSummary(sfcWind_esmf)
    ; printVarSummary(tc_esmf)
    ; printMinMax(sfcWind_esmf,True)
    ; printMinMax(tc_esmf, True)
    ;rh
    Opt                = True

    Opt@SrcFileName    = "./temp/rh_src_SCRIP.nc"	;写入的元数据描述文件
    Opt@DstFileName    = "./temp/rh_dst_SCRIP.nc" ;写入的目标数据描述文件
    Opt@WgtFileName    = "./temp/rh_NCEP_2_Rect.nc"
    Opt@ForceOverwrite = True

    ; Opt@SrcGridMask    = where(.not.ismissing(sfcWind),1,0)   ; use SrcMask2D in NCL V6.2.1 and earlier

    Opt@DstGridType    = "1.0x1.0"
    Opt@DstLLCorner    = (/ -90.d,   0.d/) ; (default = [-90,-180])
    Opt@DstURCorner    = (/  90.d, 359.d/) ;(default = [90,180])

    rh_esmf = ESMF_regrid(rh,Opt)
    ;sh
    Opt                = True

    Opt@SrcFileName    = "./temp/sh_src_SCRIP.nc"	;写入的元数据描述文件
    Opt@DstFileName    = "./temp/sh_dst_SCRIP.nc" ;写入的目标数据描述文件
    Opt@WgtFileName    = "./temp/sh_NCEP_2_Rect.nc"
    Opt@ForceOverwrite = True

    ; Opt@SrcGridMask    = where(.not.ismissing(sfcWind),1,0)   ; use SrcMask2D in NCL V6.2.1 and earlier

    Opt@DstGridType    = "1.0x1.0"
    Opt@DstLLCorner    = (/ -90.d,   0.d/) ; (default = [-90,-180])
    Opt@DstURCorner    = (/  90.d, 359.d/) ;(default = [90,180])

    sh_esmf = ESMF_regrid(sh,Opt)
    ;rad
    Opt                = True

    Opt@SrcFileName    = "./temp/rad_src_SCRIP.nc"	;写入的元数据描述文件
    Opt@DstFileName    = "./temp/rad_dst_SCRIP.nc" ;写入的目标数据描述文件
    Opt@WgtFileName    = "./temp/rad_NCEP_2_Rect.nc"
    Opt@ForceOverwrite = True

    ; Opt@SrcGridMask    = where(.not.ismissing(sfcWind),1,0)   ; use SrcMask2D in NCL V6.2.1 and earlier

    Opt@DstGridType    = "1.0x1.0"
    Opt@DstLLCorner    = (/ -90.d,   0.d/) ; (default = [-90,-180])
    Opt@DstURCorner    = (/  90.d, 359.d/) ;(default = [90,180])

    rad_esmf = ESMF_regrid(rad,Opt)
    if (fileexists(foutf)) then
        system("/bin/rm -f "+ foutf)
    end if
    header = (/"TimeInfo,   Temperature,   WindSpeed,  RelativeHumidity, SpecificHumidity,  Radiation"/)
    hlist = [/header/]
    write_table(foutf,"w",hlist,"%s")
    ; do i = 0, dimfile - 1
    ;     ; print(files(i))
    ;     if fileexists(files[i]) then 
    ;         f = addfile(files[i],"r")
    ;     else
    ;         print("warning, file not exist, skipped")
    ;         continue
    ;     end if

    ;     lat0 = f->g0_lat_1
    ;     lon0 = f->g0_lon_2

        xi = fspan(0,359,360)
        yi = fspan(-90, 90, 181)
        ; xo = (/ Longitude /)
        ; yo = (/ Latitude /)
        xo = (/ lonf /)
        yo = (/ latf /)
        ; xo = (/31.39385796,31.59191132/)
        ; yo = (/121.4003601,121.607605/)
    ;     time="yyyymmddhh"
    ;     U10=f->10U_GDS0_SFC(:,:,:)
    ;     V10=f->10V_GDS0_SFC(:,:,:) 
    ;     ;PSFC
    ;     PSFC=f->SP_GDS0_SFC(:,:,:) ; 
    ;     ; new variables
    ;     T2=f->2T_GDS0_SFC(:,:,:)

    ;     ; interpolation todo
        Windpoint = linint2_points(xi, yi, sfcWind_esmf, True, xo, yo, 0)
        T2point = linint2_points(xi, yi, tc_esmf, True, xo, yo, 0)
    ;     U10point = linint2_points(xi, yi, U10, True, xo, yo, 0)
    ;     V10point = linint2_points(xi, yi, V10, True, xo, yo, 0)
        RH_point = linint2_points(xi, yi, rh_esmf, True, xo, yo, 0)
        SH_point = linint2_points(xi, yi, sh_esmf, True, xo, yo, 0)
        Rad_point = linint2_points(xi, yi, rad_esmf, True, xo, yo, 0)
        
    ;     ; interpolation todo
    ;     ; convert from u, v to wind and winddir
    ;     wind10 = sqrt(U10point^2 + V10point^2)
    ;     winddir10 = wind_direction(U10point, V10point,0)
        
    ;     ;output write csv file.
    ;     timehours=f->initial_time0_hours
    ;     timehours0=timehours(0)
    ;     timehours1=timehours(1)
    ;     timehours2=timehours(2)
    ;     timehours3=timehours(3)
    ;     time0=cd_calendar(timehours0,-3)
    ;     time1=cd_calendar(timehours1,-3)
    ;     time2=cd_calendar(timehours2,-3)
    ;     time3=cd_calendar(timehours3,-3)

    ;     timelist0 = (/time0, time1, time2, time3/)
    ;     itime=0
    ;     siymdh_list=new((/4,1/),string)

    ;     do while( itime .lt. 4)
    ;     timetemp = timelist0(itime)
    ;     stringiymdh = tostring(timetemp)
    ;     chariymdh = stringtochar(stringiymdh)
        
    ;     stringYYYY= tostring(chariymdh(0:3))
    ;     stringMM= tostring(chariymdh(4:5))
    ;     stringDD= tostring(chariymdh(6:7))
    ;     stringhh= tostring(chariymdh(8:9))
    ;     siymdh_list(itime,0) = stringYYYY + "-" + stringMM + "-" + stringDD + " " + stringhh + ":00:00"
    ;     itime = itime + 1
    ;     end do

    ;     ;other variables.
        T2point = T2point - 273.15
    ;     PSFCpoint = PSFCpoint * 0.01

    ;     ; sheet todo: windspeed, winddir
        alist = [/time2, T2point, Windpoint, RH_point, SH_point, Rad_point/]
        ; alist = [/time2,T2point/]
        write_table(foutf,"a",alist, "%d, %9.3f,%9.3f,%9.3f,%9.3f,%9.3f")
    ;     write_table(foutf,"a",alist, "%s,%9.3f,%9.3f,%9.3f,%9.3f,%9.3f,%9.3f")
    ;     ;---- update progress
    ;     procmd = "echo ProgressSignal: " + 100 * (tofloat(i)+1) / dimfile
    ;     system(procmd)
 end do