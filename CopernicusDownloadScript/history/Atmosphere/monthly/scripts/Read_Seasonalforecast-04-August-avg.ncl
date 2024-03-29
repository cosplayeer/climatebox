; goal:
; step 1 : read in forecast 1x1, 
; step 2 : time 19 years average 6.392915
; step 3 : forecast 1x1 to 0.25p (regrid) ok
; todo
; step 4 : read in ERA5 0.25p
; step 5 : forecast - ERA5

filelist = systemfunc("ls ../../../forecast/seasonal-monthly/data/seasonal-monthly-sfc-*-04_leadtime123456.grib")
print(filelist)
a = addfiles(filelist,"r")
ListSetType (a, "join")

speed10m_0 = a[0]->10SI_GDS0_SFC
speed10m_1 = a[1]->10SI_GDS0_SFC
speed10m_2 = a[2]->10SI_GDS0_SFC
speed10m_3 = a[3]->10SI_GDS0_SFC
speed10m_4 = a[4]->10SI_GDS0_SFC
speed10m_5 = a[5]->10SI_GDS0_SFC
speed10m_6 = a[6]->10SI_GDS0_SFC
speed10m_7 = a[7]->10SI_GDS0_SFC
speed10m_8 = a[8]->10SI_GDS0_SFC
speed10m_9 = a[9]->10SI_GDS0_SFC
speed10m_10 = a[10]->10SI_GDS0_SFC
speed10m_11 = a[11]->10SI_GDS0_SFC
speed10m_12 = a[12]->10SI_GDS0_SFC
speed10m_13 = a[13]->10SI_GDS0_SFC
speed10m_14 = a[14]->10SI_GDS0_SFC
speed10m_15 = a[15]->10SI_GDS0_SFC
speed10m_16 = a[16]->10SI_GDS0_SFC
speed10m_17 = a[17]->10SI_GDS0_SFC
speed10m_18 = a[18]->10SI_GDS0_SFC
speed10m_19 = a[19]->10SI_GDS0_SFC


; 8 august
speed10m_0_august = speed10m_0(:,3,:,:)
speed10m_1_august = speed10m_1(:,3,:,:)
speed10m_2_august = speed10m_2(:,3,:,:)
speed10m_3_august = speed10m_3(:,3,:,:)
speed10m_4_august = speed10m_4(:,3,:,:)
speed10m_5_august = speed10m_5(:,3,:,:)
speed10m_6_august = speed10m_6(:,3,:,:)
speed10m_7_august = speed10m_7(:,3,:,:)
speed10m_8_august = speed10m_8(:,3,:,:)
speed10m_9_august = speed10m_9(:,3,:,:)
speed10m_10_august = speed10m_10(:,3,:,:)
speed10m_11_august = speed10m_11(:,3,:,:)
speed10m_12_august = speed10m_12(:,3,:,:)
speed10m_13_august = speed10m_13(:,3,:,:)
speed10m_14_august = speed10m_14(:,3,:,:)
speed10m_15_august = speed10m_15(:,3,:,:)
speed10m_16_august = speed10m_16(:,3,:,:)
speed10m_17_august = speed10m_17(:,3,:,:)
speed10m_18_august = speed10m_18(:,3,:,:)
speed10m_19_august = speed10m_19(:,3,:,:)

printVarSummary(speed10m_0_august)
a0 = dim_avg_n_Wrap(speed10m_0_august, 0)
a1 = dim_avg_n_Wrap(speed10m_1_august, 0)
a2 = dim_avg_n_Wrap(speed10m_2_august, 0)
a3 = dim_avg_n_Wrap(speed10m_3_august, 0)
a4 = dim_avg_n_Wrap(speed10m_4_august, 0)
a5 = dim_avg_n_Wrap(speed10m_5_august, 0)
a6 = dim_avg_n_Wrap(speed10m_6_august, 0)
a7 = dim_avg_n_Wrap(speed10m_7_august, 0)
a8 = dim_avg_n_Wrap(speed10m_8_august, 0)
a9 = dim_avg_n_Wrap(speed10m_9_august, 0)
a10 = dim_avg_n_Wrap(speed10m_10_august, 0)
a11 = dim_avg_n_Wrap(speed10m_11_august, 0)
a12 = dim_avg_n_Wrap(speed10m_12_august, 0)
a13 = dim_avg_n_Wrap(speed10m_13_august, 0)
a14 = dim_avg_n_Wrap(speed10m_14_august, 0)
a15 = dim_avg_n_Wrap(speed10m_15_august, 0)
a16 = dim_avg_n_Wrap(speed10m_16_august, 0)
a17 = dim_avg_n_Wrap(speed10m_17_august, 0)
a18 = dim_avg_n_Wrap(speed10m_18_august, 0)
a19 = dim_avg_n_Wrap(speed10m_19_august, 0)
; printVarSummary(a0)

; speed10m_year19avg = (a0 + a1 + a2 + a3 + a4 + a5 + \
;                  a6 + a7 + a8 + a9 + a10 + \
;                  a11 + a12 + a13 + a14 + a15 + \
;                  a16 + a17 + a18 ) / 19
yearnumber = 20
speed10m_year20avg = (a0 + a1 + a2 + a3 + a4 + a5 + \
                 a6 + a7 + a8 + a9 + a10 + \
                 a11 + a12 + a13 + a14 + a15 + \
                 a16 + a17 + a18 + a19 ) / yearnumber  ; Key
copy_VarMeta(a0, speed10m_year20avg)
printVarSummary(speed10m_year20avg)
print(avg(speed10m_year20avg))

;------------------------------------------------------
;regrid to 0.25
;---------------------------------------------
; regrid windspeed10m_august_ea 6 m/s
Opt                = True

Opt@SrcFileName    = "./temp/src_SCRIP.nc"	;写入的元数据描述文件
Opt@DstFileName    = "./temp/dst_SCRIP.nc" ;写入的目标数据描述文件
Opt@WgtFileName    = "./temp/NCEP_2_Rect.nc"
Opt@ForceOverwrite = True

Opt@SrcGridMask    = where(.not.ismissing(speed10m_year20avg),1,0)   ; use SrcMask2D in NCL V6.2.1 and earlier

Opt@DstGridType    = "0.25x0.25"
Opt@DstLLCorner    = (/ -90.d,   0.d/) ; (default = [-90,-180])
Opt@DstURCorner    = (/  90.d, 359.75/) ;(default = [90,180])

speed10m_year20avg_regrid = ESMF_regrid(speed10m_year20avg,Opt)
printVarSummary(speed10m_year20avg_regrid)
print(avg(speed10m_year20avg_regrid))

; ;write to nc
outname = "./ncdata/Seasonal-forecast-wind-August-1999-2018-"+tostring(yearnumber)+"-year.nc"
system("/bin/rm -f " + outname)
ncdf = addfile(outname,"c")

; filedimdef(ncdf, "time", -1, True)
speed10m_year20avg_regrid@long_name = "Seasonal-forecast average wind speed ratio at 10m july 0.25p"
speed10m_year20avg_regrid@units     = "m/s"
ncdf->Speed10m = speed10m_year20avg_regrid
