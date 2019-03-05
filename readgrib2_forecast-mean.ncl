a=addfile("/home/meso/DYP/climatedata/adaptor.mars.external-201710-6month.grib","r")
b=addfile("/home/meso/DYP/scripts/secret/climatedownload/data/ERA-InterimMonthlySFC_2017.grb","r")

;[ensemble0 | 51] x [forecast_time1 | 6] x [g0_lat_2 | 181] x [g0_lon_3 | 360]
speed10 = a->10SI_GDS0_SFC
printVarSummary(speed10)
print(a)
;print(speed10)
speed10_51 = dim_avg_n_Wrap(speed10, 0)
;speed10_51_sep = speed10_51(9,:,:)

speed10b = b->10SI_GDS0_SFC_S123
printVarSummary(speed10b)
;[initial_time0_hours | 12] x [g0_lat_1 | 241] x [g0_lon_2 | 480]
;speed10b_sep = speed10(9,:,:)
lat = a->g0_lat_2
lon = a->g0_lon_3
time0 = a->initial_time0_hours
;exit
speed10Clm = clmMonTLL(speed10)
; printVarSummary(speed10Clm) ;time, l, l
speed10ClmAvg = dim_avg_n(speed10Clm, 0)
printVarSummary(speed10ClmAvg) ;time, l, l
utc_date_1=cd_calendar(time0,-1)
; spd10_temp = sqrt(u10 * u10 + v10 * v10) ; spd10_temp is less than speed10.
; print(spd10_temp(0,1,1))
inumber = dimsizes(utc_date_1)
i = 0
do while i .le. 0
; do while i .le. inumber - 1
    sptemp = speed10(i,:,:)
    sptemp_mean = sptemp - speed10ClmAvg

    wks = gsn_open_wks("png", "anonymous_map" + utc_date_1(i))

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
  cnres@gsnLeftString     = sptemp@long_name + " deviation " + " (" + sptemp@units + ")"
  ; cnres@gsnRightString    = "Wind (" + utemp@units + ")"
    ; res@mpFillOn     = False
    ; res@mpOutlineOn  = True	              ; turn the map outline on
    ; res@gsnDraw      =  False                   ; do not draw the plot
    ; res@gsnFrame     =  False                   ; do not advance the frame

    ; ; res@cnLevelSelectionMode = "ExplicitLevels" ; use explicit levels

    ; res@tiMainString = "wind speed @10m"
    ; vector = gsn_csm_vector_map(wks, utemp, vtemp, res)

;---Create the two individual plots
  contour_fill_plot = gsn_csm_contour_map(wks,sptemp_mean,cnres)
  ; vector_plot       = gsn_csm_vector(wks,utemp,vtemp,vcres)
;---Overlay the vectors on the contour/map plot
  ; overlay(contour_fill_plot,vector_plot)

  draw(contour_fill_plot)    ; This will draw everything
  frame(wks)
  i = i + 1
end do
