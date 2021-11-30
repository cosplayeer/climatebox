
a=addfile("/home/meteodyn/DYP/climatebox/CopernicusDownloadScript/forecast/seasonal-monthly/data/"+ "seasonal-monthly-sfc-2021-11_leadtime123456.grib","r")

; [lat_0 | 190] x [g0_lon_2 | 384]
u10 = a->10U_GDS0_SFC
v10 = a->10V_GDS0_SFC

lat = a->g0_lat_2 ;(51,6,:,:)
lon = a->g0_lon_3
speed10 = sqrt(u10*u10 + v10*v10)
; utc_date_0 = "from: " + tostring(u10@initial_time) + " forecast:" + tostring(toint(u10@forecast_time)-1) + " month"
; utc_date_1 = "_forecastmonth_" + tostring(toint(u10@forecast_time)-1)
fromdate = "202111"
todate=(/"202112","202201","202202","202203","202204","202205"/)
; print(utc_date_0)
i = 0
do while i .le. 6
    utemp = u10(0,i,:,:)
    vtemp = v10(0,i,:,:)
    sptemp = speed10(0,i,:,:)
    sptemp_mean = sptemp

    wks = gsn_open_wks("png", "output/pic/ec_" + fromdate + "_wind10m_forecastmonth_" + tostring(i+1))

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
   cnres@tiMainString = todate(i) + " Monthly Means Wind Speed at 10 m" 
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

