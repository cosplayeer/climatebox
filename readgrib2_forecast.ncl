; test data
; a=addfile("2017SFCMonthly.grib","r")
;history data
; a=addfile("/home/meso/DYP/scripts/secret/climatedownload/data/ERA-InterimMonthlySFC_2017.grb","r")
;forecast data
a=addfile("/home/meso/DYP/climatedata/adaptor.mars.external-201710-6month.grib","r")
;[ensemble0 | 51] x [forecast_time1 | 6] x [g0_lat_2 | 181] x [g0_lon_3 | 360]
u10 = a->10U_GDS0_SFC
v10 = a->10V_GDS0_SFC
speed10 = a->10SI_GDS0_SFC

u10_51 = dim_avg_n_Wrap(u10,0)
v10_51 = dim_avg_n_Wrap(v10,0)
speed10_51 = dim_avg_n_Wrap(speed10,0)

;member1
member1 = 50
u10_m1 = a->10U_GDS0_SFC(member1,:,:,:)
v10_m1 = a->10V_GDS0_SFC(member1,:,:,:)
speed10_m1 = a->10SI_GDS0_SFC(member1,:,:,:)

;lon and lat
lat = a->g0_lat_2
lon = a->g0_lon_3

time0 = a->forecast_time1
time0@units = "hours since 2017-09-01 00:00:00"
utc_date_1=cd_calendar(time0,-1)
; spd10_temp = sqrt(u10 * u10 + v10 * v10) ; spd10_temp is less than speed10.
; print(spd10_temp(0,1,1))
inumber = dimsizes(utc_date_1)
i = 0 ;10 month
do while i .le. 0 ;inumber -1
; do while i .le. inumber - 1
; single option
    utemp = u10_m1(i,:,:)
    vtemp = v10_m1(i,:,:)
    sptemp = speed10_m1(i,:,:)

; average option
    ; utemp = u10_51(i,:,:)
    ; vtemp = v10_51(i,:,:)
    ; sptemp = speed10_51(i,:,:)

; single option
    wks = gsn_open_wks("png", "vector_map_forecast_member_"+ member1+ "_" + utc_date_1(i))
; average option
    ; wks = gsn_open_wks("png", "vector_map_forecast_average" + utc_date_1(i))

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
  cnres@gsnLeftString     = sptemp@long_name + " of member "+ member1 + " (" + sptemp@units + ")"
  cnres@gsnRightString    = "wind (" + utemp@units + ")"
    ; res@mpFillOn     = False
    ; res@mpOutlineOn  = True	              ; turn the map outline on
    ; res@gsnDraw      =  False                   ; do not draw the plot
    ; res@gsnFrame     =  False                   ; do not advance the frame

    ; ; res@cnLevelSelectionMode = "ExplicitLevels" ; use explicit levels

    ; res@tiMainString = "wind speed @10m"
    ; vector = gsn_csm_vector_map(wks, utemp, vtemp, res)

;---Create the two individual plots
  contour_fill_plot = gsn_csm_contour_map(wks,sptemp,cnres)
  vector_plot       = gsn_csm_vector(wks,utemp,vtemp,vcres)
;---Overlay the vectors on the contour/map plot
  overlay(contour_fill_plot,vector_plot)

  draw(contour_fill_plot)    ; This will draw everything
  frame(wks)
  i = i + 1
end do
