; goal:
; step 1 : read in forecast 1x1, 
; step 2 : time 19 years average 6.392915
; step 3 : forecast 1x1 to 0.25p (regrid) ok
; todo
; step 4 : read in ERA5 0.25p
; step 5 : forecast - ERA5
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

filelist = systemfunc("ls ../../../forecast/seasonal-monthly/dataRadiation/seasonal-monthly-rad-*-09_leadtime123.grib")
print(filelist)
outputmonth="Oct"
a = addfiles(filelist,"r")
ListSetType (a, "join")

speed10m_0 = a[0]->VAR_169_GDS0_SFC
speed10m_1 = a[1]->VAR_169_GDS0_SFC
speed10m_2 = a[2]->VAR_169_GDS0_SFC
speed10m_3 = a[3]->VAR_169_GDS0_SFC
speed10m_4 = a[4]->VAR_169_GDS0_SFC
speed10m_5 = a[5]->VAR_169_GDS0_SFC
speed10m_6 = a[6]->VAR_169_GDS0_SFC
speed10m_7 = a[7]->VAR_169_GDS0_SFC
speed10m_8 = a[8]->VAR_169_GDS0_SFC
speed10m_9 = a[9]->VAR_169_GDS0_SFC
speed10m_10 = a[10]->VAR_169_GDS0_SFC
speed10m_11 = a[11]->VAR_169_GDS0_SFC
speed10m_12 = a[12]->VAR_169_GDS0_SFC
speed10m_13 = a[13]->VAR_169_GDS0_SFC
speed10m_14 = a[14]->VAR_169_GDS0_SFC
speed10m_15 = a[15]->VAR_169_GDS0_SFC
speed10m_16 = a[16]->VAR_169_GDS0_SFC
speed10m_17 = a[17]->VAR_169_GDS0_SFC
speed10m_18 = a[18]->VAR_169_GDS0_SFC
speed10m_19 = a[19]->VAR_169_GDS0_SFC

speed10m_0_april = speed10m_0(:,0,:,:)
speed10m_1_april = speed10m_1(:,0,:,:)
speed10m_2_april = speed10m_2(:,0,:,:)
speed10m_3_april = speed10m_3(:,0,:,:)
speed10m_4_april = speed10m_4(:,0,:,:)
speed10m_5_april = speed10m_5(:,0,:,:)
speed10m_6_april = speed10m_6(:,0,:,:)
speed10m_7_april = speed10m_7(:,0,:,:)
speed10m_8_april = speed10m_8(:,0,:,:)
speed10m_9_april = speed10m_9(:,0,:,:)
speed10m_10_april = speed10m_10(:,0,:,:)
speed10m_11_april = speed10m_11(:,0,:,:)
speed10m_12_april = speed10m_12(:,0,:,:)
speed10m_13_april = speed10m_13(:,0,:,:)
speed10m_14_april = speed10m_14(:,0,:,:)
speed10m_15_april = speed10m_15(:,0,:,:)
speed10m_16_april = speed10m_16(:,0,:,:)
speed10m_17_april = speed10m_17(:,0,:,:)
speed10m_18_april = speed10m_18(:,0,:,:)
speed10m_19_april = speed10m_19(:,0,:,:)

printVarSummary(speed10m_0_april)
a0 = dim_avg_n_Wrap(speed10m_0_april, 0)
a1 = dim_avg_n_Wrap(speed10m_1_april, 0)
a2 = dim_avg_n_Wrap(speed10m_2_april, 0)
a3 = dim_avg_n_Wrap(speed10m_3_april, 0)
a4 = dim_avg_n_Wrap(speed10m_4_april, 0)
a5 = dim_avg_n_Wrap(speed10m_5_april, 0)
a6 = dim_avg_n_Wrap(speed10m_6_april, 0)
a7 = dim_avg_n_Wrap(speed10m_7_april, 0)
a8 = dim_avg_n_Wrap(speed10m_8_april, 0)
a9 = dim_avg_n_Wrap(speed10m_9_april, 0)
a10 = dim_avg_n_Wrap(speed10m_10_april, 0)
a11 = dim_avg_n_Wrap(speed10m_11_april, 0)
a12 = dim_avg_n_Wrap(speed10m_12_april, 0)
a13 = dim_avg_n_Wrap(speed10m_13_april, 0)
a14 = dim_avg_n_Wrap(speed10m_14_april, 0)
a15 = dim_avg_n_Wrap(speed10m_15_april, 0)
a16 = dim_avg_n_Wrap(speed10m_16_april, 0)
a17 = dim_avg_n_Wrap(speed10m_17_april, 0)
a18 = dim_avg_n_Wrap(speed10m_18_april, 0)
a19 = dim_avg_n_Wrap(speed10m_19_april, 0)
; printVarSummary(a0)

speed10m_year19avg = (a0 + a1 + a2 + a3 + a4 + a5 + \
                 a6 + a7 + a8 + a9 + a10 + \
                 a11 + a12 + a13 + a14 + a15 + \
                 a16 + a17 + a18 + a19) / 20
copy_VarMeta(a0, speed10m_year19avg)
printVarSummary(speed10m_year19avg)
print(avg(speed10m_year19avg))

;------------------------------------------------------
;regrid to 0.25
;---------------------------------------------
; regrid windspeed10m_april_ea 6 m/s
Opt                = True

Opt@SrcFileName    = "/temp/src_SCRIP.nc"	;写入的元数据描述文件
Opt@DstFileName    = "dst_SCRIP.nc" ;写入的目标数据描述文件
Opt@WgtFileName    = "NCEP_2_Rect.nc"
Opt@SrcFileName    = "./temp/Rad_src_SCRIP_avg"+outputmonth+".nc"	;写入的元数据描述文件
Opt@DstFileName    = "./temp/Rad_dst_SCRIP_avg"+outputmonth+".nc" ;写入的目标数据描述文件
Opt@WgtFileName    = "./temp/Rad_NCEP_2_Rect_avg"+outputmonth+".nc"
Opt@ForceOverwrite = True

Opt@SrcGridMask    = where(.not.ismissing(speed10m_year19avg),1,0)   ; use SrcMask2D in NCL V6.2.1 and earlier

Opt@DstGridType    = "0.25x0.25"
Opt@DstLLCorner    = (/ -90.d,   0.d/) ; (default = [-90,-180])
Opt@DstURCorner    = (/  90.d, 359.75/) ;(default = [90,180])

speed10m_year19avg_regrid = ESMF_regrid(speed10m_year19avg,Opt)
printVarSummary(speed10m_year19avg_regrid)
print(avg(speed10m_year19avg_regrid))

; ;write to nc
outname = "./ncdata/Seasonal-forecast-rad-" + outputmonth + "-20year.nc"
system("/bin/rm -f " + outname)
ncdf = addfile(outname,"c")

; filedimdef(ncdf, "time", -1, True)
speed10m_year19avg_regrid@long_name = "Seasonal-forecast average wind speed ratio at 10m may 0.25p"
speed10m_year19avg_regrid@units     = "w/m**2"
ncdf->Speed10m = speed10m_year19avg_regrid
