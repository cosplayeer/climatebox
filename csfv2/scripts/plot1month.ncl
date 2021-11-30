prefixname="flxf"
;prefixname="pgbf"
a=addfile("/home/meteodyn/DYP/climatebox/csfv2/data/"+ prefixname +".01."+ fromdate +"0100."+ todate +".avrg.grib.grb2","r")

; [lat_0 | 190] x [g0_lon_2 | 384]
u10 = a->UGRD_P8_L103_GGA0_avg1m
v10 = a->VGRD_P8_L103_GGA0_avg1m

lat = a->lat_0
lon = a->lon_0
speed10 = sqrt(u10*u10 + v10*v10)
utc_date_0 = "from: " + tostring(u10@initial_time) + " forecast:" + tostring(toint(u10@forecast_time)-1) + " month"
utc_date_1 = "_forecastmonth_" + tostring(toint(u10@forecast_time)-1)
print(utc_date_0)
i = 0
do while i .le. 0
    utemp = u10(:,:)
    vtemp = v10(:,:)
    sptemp = speed10(:,:)
    sptemp_mean = sptemp

    wks = gsn_open_wks("png", "output/pic/csf_" + prefixname + fromdate + "_wind10m" + utc_date_1)

    cnres                   =  True              ; contour/map resources
    vcres                   =  True              ; vector resources

    
  cnres@gsnDraw           = False              ; Turn these off. We
  cnres@gsnFrame          = False              ; will overlay plots
  vcres@gsnDraw           = False              ; later.
  vcres@gsnFrame          = False


  cnres@pmTickMarkDisplayMode = "Always"
  cnres@mpFillOn              =  False          ; turn off map fill
  cnres@mpOutlineDrawOrder    = "PostDraw"      ; draw continental outline last
;   cnres@mpOutlineBoundarySets = "GeophoysicalAndUSStates" ; state boundaries

  
  cnres@gsnAddCyclic            = True            ; not regional data 
  cnres@cnFillOn                = True
  cnres@cnLinesOn               = False           ; turn off contour lines
  
  
  vcres@vcRefMagnitudeF          = 10.0             ; define vector ref mag
  vcres@vcRefLengthF             = 0.045            ; define length of vec ref
  vcres@vcGlyphStyle             = "CurlyVector"    ; turn on curly vectors
  vcres@vcMinDistanceF           = 0.017            ; thin vectors
  vcres@vcRefAnnoOrthogonalPosF  = .1               ; move ref vector down
  vcres@gsnAddCyclic             = True            ; not regional data 

;---Make sure vector plot doesn't have subtitles
  vcres@gsnLeftString     = ""
  vcres@gsnRightString    = ""

;---Add subtitles to contour plot
   cnres@tiMainString = todate + " Monthly Means Wind Speed at 10 m" 
   cnres@gsnRightString    = "Wind (" + utemp@units + ")"
    ; res@mpFillOn     = False
    ; res@mpOutlineOn  = True	              ; turn the map outline on
    ; res@gsnDraw      =  False                   ; do not draw the plot
    ; res@gsnFrame     =  False                   ; do not advance the frame

    cnres@cnLevelSelectionMode = "ExplicitLevels" ; use explicit levels
    cnres@cnLevels        = (/1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16/)  

    ; res@tiMainString = utc_date_0
    ; vector = gsn_csm_vector_map(wks, utemp, vtemp, res)

;---Create the two individual plots
  contour_fill_plot = gsn_csm_contour_map(wks,sptemp_mean,cnres)
  ; gsn_define_colormap(wks,"BlueWhiteOrangeRed")
  ; vector_plot       = gsn_csm_vector(wks,utemp,vtemp,vcres)
;---Overlay the vectors on the contour/map plot
  ; overlay(contour_fill_plot,vector_plot)

  draw(contour_fill_plot)    ; This will draw everything
  frame(wks)
  i = i + 1
end do

