load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"

fromdir="data/"
; fromyear="2000"
f=fromdir+"seasonal-monthly-sfc-"+ fromyear + "-1２_leadtime123456.grib"
; filelist = systemfunc("ls ./data/seasonal-monthly-sfc-2020-1２_leadtime123456.grib")
print(f)
fromtime=fromyear+"12"
; mname=1
a = addfile(f,"r")
print(a)
speed10m_0 = a->10SI_GDS0_SFC
; U10m_0 = a->10U_GDS0_SFC
; V10m_0 = a->10V_GDS0_SFC

speed10m_temp = speed10m_0(:,mname-1,:,:) ;9, 10 11
; u10m_temp = U10m_0(:,mname-1,:,:) ;9, 10 11
; v10m_temp = V10m_0(:,mname-1,:,:) ;9, 10 11
; printVarSummary(speed10m_temp)

s = new((/51,721,1440/),float)
; us = new((/51,721,1440/),float)
; vs = new((/51,721,1440/),float)
do i = 0,50
    print(i)
    ;------------------------------------------------------
    ;regrid to 0.25
    ;---------------------------------------------
    ; regrid windspeed10m_april_ea 6 m/s
    Opt                = True

    Opt@SrcFileName    = "./temp/Wind_src_SCRIP"+fromtime+mname+".nc"	;写入的元数据描述文件
    Opt@DstFileName    = "./temp/Wind_dst_SCRIP"+fromtime+mname+".nc" ;写入的目标数据描述文件
    Opt@WgtFileName    = "./temp/Wind_NCEP_2_Rect"+fromtime+mname+".nc"
    Opt@ForceOverwrite = True

    Opt@SrcGridMask    = where(.not.ismissing(speed10m_temp(i,:,:)),1,0)   ; use SrcMask2D in NCL V6.2.1 and earlier

    Opt@DstGridType    = "0.25x0.25"
    Opt@DstLLCorner    = (/ -90.d,   0.d/) ; (default = [-90,-180])
    Opt@DstURCorner    = (/  90.d, 359.75/) ;(default = [90,180])

    s(i,:,:) = ESMF_regrid(speed10m_temp(i,:,:),Opt)
    ; us(i,:,:) = ESMF_regrid(u10m_temp(i,:,:),Opt)
    ; vs(i,:,:) = ESMF_regrid(v10m_temp(i,:,:),Opt)
    ; printVarSummary(a(i,:,:))
    ; print(avg(speed10m_temp_regrid))
end do
; printVarSummary(s)
; printMinMax(s(0,:,:), True)

; ;write to nc
outname = "./data_0.25/monthly-forecast-wind"+ fromtime + "-"+tostring(mname)+"-0.25p.nc"
system("/bin/rm -f " + outname)
ncdf = addfile(outname,"c")

; filedimdef(ncdf, "time", -1, True)
s@long_name = "monthly forecast average speed at 10m " + tostring(mname) + " 0.25p"
s@units     = "m/s"
; us@long_name = "monthly forecast average u speed at 10m " + tostring(mname) + " 0.25p"
; us@units     = "m/s"
; vs@long_name = "monthly forecast average v speed at 10m " + tostring(mname) + " 0.25p"
; vs@units     = "m/s"
ncdf->Speed10m = s
; ncdf->u10m = us
; ncdf->v10m = vs