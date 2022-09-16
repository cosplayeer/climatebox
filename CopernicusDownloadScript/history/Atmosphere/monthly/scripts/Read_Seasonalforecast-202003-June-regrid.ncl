; goal:
; step 1 : read in forecast 1x1, 
; step 2 : time 19 years average 6.392915
; step 3 : forecast 1x1 to 0.25p (regrid) ok
; todo
; step 4 : read in ERA5 0.25p
; step 5 : forecast - ERA5

filelist = systemfunc("ls ../../../forecast/seasonal-monthly/data/seasonal-monthly-sfc-2020-03_leadtime123.grib")
print(filelist)
a = addfile(filelist,"r")

speed10m_0 = a->10SI_GDS0_SFC
speed10m_0_june = speed10m_0(:,2,:,:)
printVarSummary(speed10m_0_june)

s = new((/51,721,1440/),float)
do i = 0,50
    print(i)
    ;------------------------------------------------------
    ;regrid to 0.25
    ;---------------------------------------------
    ; regrid windspeed10m_june_ea 6 m/s
    Opt                = True

    Opt@SrcFileName    = "temp/_june_src_SCRIP.nc"	;写入的元数据描述文件
    Opt@DstFileName    = "temp/_junedst_SCRIP.nc" ;写入的目标数据描述文件
    Opt@WgtFileName    = "temp/_juneNCEP_2_Rect.nc"
    Opt@ForceOverwrite = True

    Opt@SrcGridMask    = where(.not.ismissing(speed10m_0_june(i,:,:)),1,0)   ; use SrcMask2D in NCL V6.2.1 and earlier

    Opt@DstGridType    = "0.25x0.25"
    Opt@DstLLCorner    = (/ -90.d,   0.d/) ; (default = [-90,-180])
    Opt@DstURCorner    = (/  90.d, 359.75/) ;(default = [90,180])

    s(i,:,:) = ESMF_regrid(speed10m_0_june(i,:,:),Opt)
    ; printVarSummary(a(i,:,:))
    ; print(avg(speed10m_0_june_regrid))
end do
printVarSummary(s)
printMinMax(s(0,:,:), True)
printMinMax(s(1,:,:), True)
; ;write to nc
outname = "./ncdata/Seasonal-forecast-wind-2020-June-0.25p.nc"
system("/bin/rm -f " + outname)
ncdf = addfile(outname,"c")

; filedimdef(ncdf, "time", -1, True)
s@long_name = "Seasonal-forecast average wind speed at 10m 2020 june 0.25p"
s@units     = "m/s"
ncdf->Speed10m = s