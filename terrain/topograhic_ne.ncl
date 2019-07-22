load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
;load "/mnt/f/2017-NCL/NCL/cnmap/cnmap.ncl"
begin
fi = addfile("dixing-china.nc","r")
lon=fi->x
lat=fi->y
z =fi->z

;---Create lat and long coordinate variables 
 lon!0 = "lon" 
 lon@long_name = "lon" 
 lon@units = "degrees-east" 
 lon&lon = lon 
 lat!0 = "lat" 
 lat@long_name = "lat" 
 lat@units = "degrees_north" 
 lat&lat = lat 
 
 
 z!0 = "lat" 
 z!1 = "lon" 
 z&lat = lat 
 z&lon = lon 
 z@long_name = "Z" 
 z@units = "m" 
 ;z@_FillValue = -9999.0 
  
  printVarSummary(lon)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;************************************************
; plotting parameters
;************************************************
 wks   = gsn_open_wks ("pdf","ght-ne_meshfill")        ; open workstation
; gsn_define_colormap(wks"BlueDarkRed18") 
 gsn_define_colormap(wks,"ncl_default") 
; plot = new(2graphic)                       ; create a plot array
  

  res                     = True            ; plot mods desired
  res@gsnDraw             = False           ; don't draw
  res@gsnFrame            = False           ; don't advance frame
  res@cnInfoLabelOn       = False          ; turn off cn info label
  res@cnLinesOn           = False         ; no contour lines
  res@cnFillOn            = True        ; turn on color
;  res@cnFillMode          = "RasterFill";"CellFill";"RasterFill"
  res@cnFillMode    = "MeshFill"   ; for faster draw
  res@pmLabelBarOrthogonalPosF   = 0.15
  res@gsnSpreadColors     = True            ; spread out color table
  res@gsnAddCyclic        = False
  res@lbLabelBarOn        = True           ; turn off individual cb's
  res@cnInfoLabelOn       = False
  res@cnLineLabelsOn      =False

  ; res@mpGeophysicalLineColor = "transparent" ; the map shows or not
 ;>--------------------------------------------<
;            set for the map 
;>--------------------------------------------<  
  res@mpGeophysicalLineColor = "transparent" ; the map shows or not
; res@mpFillOn    = False
  res@mpFillOn                = True 
  res@mpLimitMode       = "Corners"            ; choose range of map
  res@mpLeftCornerLatF  = 20 ;30
  res@mpLeftCornerLonF  = 100; 110
  res@mpRightCornerLatF = 54
  res@mpRightCornerLonF = 135
  
 res@mpOutlineOn             = False  ; Use outlines from shapefile
 res@cnFillDrawOrder         = "PreDraw"
 res@mpDataBaseVersion       = "MediumRes"
 res@mpDataSetName           = "Earth..4"
 res@mpAreaMaskingOn         = True
 ;res@mpMaskAreaSpecifiers    = (/"China""Taiwan","Disputed area between India and China","India:Arunachal Pradesh"/)
 res@mpMaskAreaSpecifiers    = (/"China"/)
 res@mpLandFillColor         = "white"
 res@mpInlandWaterFillColor  = "white"
 res@mpOceanFillColor        = "white"
 res@mpOutlineBoundarySets   = "NoBoundaries"
 ;res@mpOutlineBoundarySets = "National"   
;>--------------------------------------------<  
;>--------------------------------------------<  
  res@gsnLeftStringFontHeightF=0.025
  res@gsnCenterString = " "
  res@gsnRightString  = " "
  res@tmXBLabelFont = "Times-Roman" 
  res@tmYLLabelFont = "Times-Roman" 
  res@gsnLeftString = " "

;---Pick "nice" contour levels
  mnmxint = nice_mnmxintvl( min(z), 2000., 18, False)
  res@cnLevelSelectionMode = "ManualLevels"
  res@cnMinLevelValF       = 0.
  res@cnMaxLevelValF       = mnmxint(1)
  res@cnLevelSpacingF      = mnmxint(2)/8.   ; Increase the number of levels 

;res@tiMainString  = "CN05.1_Tm_025_daily 1961-2012 "   ; title
;res@cnLevelSelectionMode = "ExplicitLevels"
;res@cnLevels             = (/510,15,20,25,30,35,40/)
;res@cnFillColors = (/1030,50,70,120,150,190,220,240/)

  res@pmLabelBarHeightF   = 0.05
  res@pmLabelBarOrthogonalPosF = 0.18
  res@tmXBLabelFontHeightF = 0.02 
  res@tmYLLabelFontHeightF = 0.02 
  res@lbLabelFontHeightF= 0.02
  ;res@pmTickMarkDisplayMode = "Always"   ;;;;;;;�Զ����þ�γ�ȹص�����ʹ�����������
   res@tmYROn     = False
   res@tmYLMode   = "Explicit"
  ; LYP source
  ;  res@tmYLValues = (/40,45,50,55/)
  ;  res@tmYLLabels = (/"40~S~o~N~N","45~S~o~N~N","50~S~o~N~N","55~S~o~N~N"/)
  ;  res@tmXTOn     = False
  ;  res@tmXBMode   = "Explicit"
  ;  res@tmXBValues = (/115,120,125,130,135/)
  ;  res@tmXBLabels = (/"115~S~o~N~E","120~S~o~N~E","125~S~o~N~E","130~S~o~N~E", \
  ;                    "135~S~o~N~E"/)           
  ; DYP changed
   res@tmYLValues = (/20, 25, 30, 35, 40,45, 50, 55/)
   res@tmYLLabels = (/"20~S~o~N~N","25~S~o~N~N","30~S~o~N~N","35~S~o~N~N","40~S~o~N~N","45~S~o~N~N","50~S~o~N~N","55~S~o~N~N"/)
   res@tmXTOn     = False
   res@tmXBMode   = "Explicit"
   res@tmXBValues = (/100, 105, 110 ,115,120,125,130,135/)
   res@tmXBLabels = (/"100~S~o~N~E","105~S~o~N~E","110~S~o~N~E","115~S~o~N~E","120~S~o~N~E","125~S~o~N~E","130~S~o~N~E", \
                     "135~S~o~N~E"/) 
  plot = gsn_csm_contour_map(wks,z,res)
  cnres            =   True
; lyp mark version
;  stainfo =  asciiread("lon-lat-22.txt"(/1,3/),"float")
;  zno=tostring(toint(stainfo(:0)))
;  zlon=stainfo(:2)
;  zlat=stainfo(:1)
;  print(zlon)
;  mkres = True
;  mkres@gsMarkerSizeF = 0.010 ;
;  mkres@gsMarkerColor = "black"
;  mkres@gsMarkerIndex = 16
;  dum = gsn_add_polymarker(wksplot,zlon,zlat,mkres)
; DYP mark version
  mkres                   = True
  mkres@gsMarkerIndex     = 16         ; 16=filled dot
  mkres@gsMarkerSizeF     = 0.007 ;0.007
  mkres@gsMarkerColor       = "black"
;
; If you call gsn_add_polymarker multiple times use
; a unique variable each time on the left side of
; the "=" sign. Or use an array for "dum".
;
lat0 = (/41.37215,41.28,41.32,41.36,41.3,41.34,21.72333333,30.12027778,30.06416667,31.43805556,30.0975,31.4725,41.74916667,41.85833333,41.84138889,38.00972222,38.15277778/)
lon0 = (/115.3,115.3,115.4,115.4,115.3,115.4,107.9516667,108.9263889,108.8594444,114.4341667,108.8908333,114.4236111,116.3630556,116.4405556,116.2763889,117.1233333,117.1869444/)
print(dimsizes(lat0))
print(dimsizes(lon0))
printMinMax(lat0, True)
printMinMax(lon0, True)
  ;  lat = (/45/)     ; 1D array of latitude values
  ;  lon = (/120/)     ; 1D array of longitude values

 dum = gsn_add_polymarker(wks,plot,lon0,lat0,mkres)

;   cnres@china      =   True
;   cnres@river      =   True
;   cnres@province   =   False
;   cnres@nanhai     =   False;True 
;   cnres@diqu       =   False
;chinamap1        =   add_china_map(wksplot(0),cnres)
;************************************************
;***************************************************** 
  

draw(plot)
frame(wks)
end
