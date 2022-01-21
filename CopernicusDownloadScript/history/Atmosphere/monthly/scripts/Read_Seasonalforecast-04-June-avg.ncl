; goal:
; step 1 : read in forecast 1x1, 
; step 2 : time 19 years average 6.392915
; step 3 : forecast 1x1 to 0.25p (regrid) ok
; todo
; step 4 : read in ERA5 0.25p
; step 5 : forecast - ERA5

filelist = systemfunc("ls ../../../forecast/seasonal-monthly/data/seasonal-monthly-sfc-*-04_leadtime123.grib")
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
;5 may
speed10m_0_may = speed10m_0(:,1,:,:)
speed10m_1_may = speed10m_1(:,1,:,:)
speed10m_2_may = speed10m_2(:,1,:,:)
speed10m_3_may = speed10m_3(:,1,:,:)
speed10m_4_may = speed10m_4(:,1,:,:)
speed10m_5_may = speed10m_5(:,1,:,:)
speed10m_6_may = speed10m_6(:,1,:,:)
speed10m_7_may = speed10m_7(:,1,:,:)
speed10m_8_may = speed10m_8(:,1,:,:)
speed10m_9_may = speed10m_9(:,1,:,:)
speed10m_10_may = speed10m_10(:,1,:,:)
speed10m_11_may = speed10m_11(:,1,:,:)
speed10m_12_may = speed10m_12(:,1,:,:)
speed10m_13_may = speed10m_13(:,1,:,:)
speed10m_14_may = speed10m_14(:,1,:,:)
speed10m_15_may = speed10m_15(:,1,:,:)
speed10m_16_may = speed10m_16(:,1,:,:)
speed10m_17_may = speed10m_17(:,1,:,:)
speed10m_18_may = speed10m_18(:,1,:,:)
speed10m_19_may = speed10m_19(:,1,:,:)

printVarSummary(speed10m_0_may)
a0 = dim_avg_n_Wrap(speed10m_0_may, 0)
a1 = dim_avg_n_Wrap(speed10m_1_may, 0)
a2 = dim_avg_n_Wrap(speed10m_2_may, 0)
a3 = dim_avg_n_Wrap(speed10m_3_may, 0)
a4 = dim_avg_n_Wrap(speed10m_4_may, 0)
a5 = dim_avg_n_Wrap(speed10m_5_may, 0)
a6 = dim_avg_n_Wrap(speed10m_6_may, 0)
a7 = dim_avg_n_Wrap(speed10m_7_may, 0)
a8 = dim_avg_n_Wrap(speed10m_8_may, 0)
a9 = dim_avg_n_Wrap(speed10m_9_may, 0)
a10 = dim_avg_n_Wrap(speed10m_10_may, 0)
a11 = dim_avg_n_Wrap(speed10m_11_may, 0)
a12 = dim_avg_n_Wrap(speed10m_12_may, 0)
a13 = dim_avg_n_Wrap(speed10m_13_may, 0)
a14 = dim_avg_n_Wrap(speed10m_14_may, 0)
a15 = dim_avg_n_Wrap(speed10m_15_may, 0)
a16 = dim_avg_n_Wrap(speed10m_16_may, 0)
a17 = dim_avg_n_Wrap(speed10m_17_may, 0)
a18 = dim_avg_n_Wrap(speed10m_18_may, 0)
; a19 = dim_avg_n_Wrap(speed10m_19_may, 0)
; printVarSummary(a0)

speed10m_year19avg = (a0 + a1 + a2 + a3 + a4 + a5 + \
                 a6 + a7 + a8 + a9 + a10 + \
                 a11 + a12 + a13 + a14 + a15 + \
                 a16 + a17 + a18 ) / 19
copy_VarMeta(a0, speed10m_year19avg)
printVarSummary(speed10m_year19avg)
print(avg(speed10m_year19avg))

;------------------------------------------------------
;regrid to 0.25
;---------------------------------------------
; regrid windspeed10m_may_ea 6 m/s
Opt                = True

Opt@SrcFileName    = "src_SCRIP.nc"	;写入的元数据描述文件
Opt@DstFileName    = "dst_SCRIP.nc" ;写入的目标数据描述文件
Opt@WgtFileName    = "NCEP_2_Rect.nc"
Opt@ForceOverwrite = True

Opt@SrcGridMask    = where(.not.ismissing(speed10m_year19avg),1,0)   ; use SrcMask2D in NCL V6.2.1 and earlier

Opt@DstGridType    = "0.25x0.25"
Opt@DstLLCorner    = (/ -90.d,   0.d/) ; (default = [-90,-180])
Opt@DstURCorner    = (/  90.d, 359.75/) ;(default = [90,180])

speed10m_year19avg_regrid = ESMF_regrid(speed10m_year19avg,Opt)
printVarSummary(speed10m_year19avg_regrid)
print(avg(speed10m_year19avg_regrid))

; ;write to nc
outname = "./ncdata/Seasonal-forecast-wind-June-20year.nc"
system("/bin/rm -f " + outname)
ncdf = addfile(outname,"c")

; filedimdef(ncdf, "time", -1, True)
speed10m_year19avg_regrid@long_name = "Seasonal-forecast average wind speed ratio at 10m June 0.25p"
speed10m_year19avg_regrid@units     = "m/s"
ncdf->Speed10m = speed10m_year19avg_regrid
