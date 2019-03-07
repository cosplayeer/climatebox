#!/bin/bash

startdate=$1
enddate=$2
datetemp=$startdate

WORKSPACE=/home/meso/MSP/Shell/WORKSPACE
WORKSPACE_R=${WORKSPACE}/../WORKSPACE_R
tempdir=${WORKSPACE_R}/Global/.tempncldir
test -d ${tempdir} || mkdir ${tempdir}
tempfile="${tempdir}/tempfilemerra50.ncl"
# MERRA2
test -d ${WORKSPACE_R}/Global/Image/MERRA2 || mkdir -p ${WORKSPACE_R}/Global/Image/MERRA2/

while [ "`date -d "$datetemp" +%Y%m%d`" -le "`date -d "$enddate" +%Y%m%d`" ]; do {
cat >${tempfile}<<EOF
;merra data one file for one time
uuyearlyaverage = new((/38, 241, 480/),"float")
vvyearlyaverage = new((/38, 241, 480/),"float")
spdyearlyaverage = new((/38, 241, 480/),"float")
; read in cycle mode.
merrafile = systemfunc("ls ~/DYP/scripts/secret/climatedownload/data/DataMonthlyNetcdf/ERA-InterimMonthlySFC_*.nc")
do iyear = 0, dimsizes(merrafile) - 1
a = addfile(merrafile(iyear),"r")
;[initial_time0_hours | 456] x [g0_lat_1 | 241 x [g0_lon_2 | 480]
;[initial_time0_hours | 12] x [g0_lat_1 | 241 x [g0_lon_2 | 480]

u10 = a->10U_GDS0_SFC_S123
v10 = a->10V_GDS0_SFC_S123
spd10 = a->10SI_GDS0_SFC_S123
;convert monthly to yearly, 3D to 2D:
u10_avg = dim_avg_n_Wrap(u10,0)
v10_avg = dim_avg_n_Wrap(v10,0)
spd10_avg = dim_avg_n_Wrap(spd10,0)
;put every data to a big multiple year matrix
uuyearlyaverage(iyear,:,:) = u10_avg
vvyearlyaverage(iyear,:,:) = v10_avg
spdyearlyaverage(iyear,:,:) = spd10_avg

;lon and lat
lat = a->g0_lat_1
lon = a->g0_lon_2

time0 = a->initial_time0_hours
; time0@units = "hours since 1800-01-01 00:00:00"
;utc_date_1=cd_calendar(time0,-3)  ; YYYYMMDDHH

;spd50_temp = sqrt(u50 * u50 + v50 * v50) ; spd10_temp is less than speed10.
;spdtemp_average = dim_avg_n_Wrap(spd50, 0)

;print("ProcessSignal 10m"+utc_date_1(iyear))
print("ProcessSignal 10m"+iyear)
; single option
    utemp = u10_avg
    vtemp = v10_avg
; calculate speed from u monthly & v monthly
; not good.
    ;sptemp = sqrt(utemp * utemp + vtemp * vtemp)
; use speed directly from speed.
    sptemp = spd10_avg
; all average choice:   
; calculate monthly average of 40 years
; and then get average of all months.
    ;spdtemp_average = dim_avg_n_Wrap(spd50,0)
    ;sptemp = spdtemp_average

    sptemp@long_name = "10 m wind speed deviation(%) of 2017 minus 38 years average "

; output directory and png name
    ;outputdir = "${WORKSPACE_R}/Global/Image/MERRA2/"
    outputdir = "./"
;    wks = gsn_open_wks("png", outputdir+ "ECMWF_vector10m_yearly_map" + utc_date_1(iyear) ) 
    wks = gsn_open_wks("png", outputdir+ "ECMWF_vector10m_yearly_map" + iyear ) 
; color choose
;    gsn_define_colormap(wks,"gui_default")
    gsn_define_colormap(wks,"wind_17lev")

    cnres                   =  True              ; contour/map resources
    vcres                   =  True              ; vector resources
    
  cnres@gsnDraw           = False              ; Turn these off. We
  cnres@gsnFrame          = False              ; will overlay plots
  vcres@gsnDraw           = False              ; later.
  vcres@gsnFrame          = False

  cnres@pmTickMarkDisplayMode = "Always"
;  cnres@mpFillOn              =  False          ; turn off map fill
  cnres@mpOutlineDrawOrder    = "PostDraw"      ; draw continental outline last
;   cnres@mpOutlineBoundarySets = "GeophoysicalAndUSStates" ; state boundaries
  
  cnres@gsnAddCyclic            = True            ; not regional data 
  cnres@cnFillOn                = True
  cnres@cnLinesOn               = False           ; turn off contour lines
  
; Curly Vector  
  vcres@vcRefMagnitudeF          = 10.0             ; define vector ref mag
  vcres@vcRefLengthF             = 0.045            ; define length of vec ref
  vcres@vcGlyphStyle             = "CurlyVector"    ; turn on curly vectors
  vcres@vcMinDistanceF           = 0.017            ; thin vectors
  vcres@vcRefAnnoOrthogonalPosF  = .1               ; move ref vector down
; Curly Vector Color
  vcres@vcRefMagnitudeF          = 15.0             ; define vector ref mag
;  vcres@vcRefLengthF             = 0.045            ; define length of vec ref
;  vcres@vcLevelPalette           = "gui_default"
;  vcres@vcLevelPalette           = "wind_17lev"
;  vcres@vcMonoLineArrowColor     = False
;  vcres@vcGlyphStyle             = "CurlyVector"    ; turn on curly vectors
 ; vcres@pmLabelBarDisplayMode    = "Always"         ; turn a label bar.
;  vcres@pmLabelBarWidthF         = 0.08             ;make it thinner

;  vcres@vcMinDistanceF           = 0.017            ; thin vectors
;  vcres@vcRefAnnoOrthogonalPosF  = .1               ; move ref vector down

  vcres@gsnAddCyclic             = True            ; not regional data 

;---Make sure vector plot doesn't have subtitles
  vcres@gsnLeftString     = ""
  vcres@gsnRightString    = ""

;---Add subtitles to contour plot
  cnres@gsnLeftString     = sptemp@long_name +  " (" + utemp@units + ")"
  cnres@gsnRightString    = " "
;  cnres@gsnRightString    = "wind (" + utemp@units + ")"
;  cnres@cnLevelSelectionMode = "ExplicitLevels" ; use explicit levels
;  cnres@cnLevels          = (/2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30/)
    ; res@mpFillOn     = False
    ; res@mpOutlineOn  = True	              ; turn the map outline on
    ; res@gsnDraw      =  False                   ; do not draw the plot
    ; res@gsnFrame     =  False                   ; do not advance the frame

    ; res@cnLevelSelectionMode = "ExplicitLevels" ; use explicit levels

    ; res@tiMainString = "wind speed @10m"
    ; vector = gsn_csm_vector_map(wks, utemp, vtemp, res)

;---Create the two individual plots
  contour_fill_plot = gsn_csm_contour_map(wks,sptemp,cnres)
  vector_plot       = gsn_csm_vector(wks,utemp,vtemp,vcres)
;---Overlay the vectors on the contour/map plot
  overlay(contour_fill_plot,vector_plot)
;  draw(contour_fill_plot)    ; This will draw everything
;  frame(wks)
end do

; average begin
    printVarSummary(uuyearlyaverage)
    printVarSummary(vvyearlyaverage)
    printVarSummary(spdyearlyaverage)

    wks = gsn_open_wks("png", outputdir+ "ECMWF_vector10m_deviationPercent_map")
; color choose
;    gsn_define_colormap(wks,"gui_default")
   gsn_define_colormap(wks,"wind_17lev")

    cnres                   =  True              ; contour/map resources
    vcres                   =  True              ; vector resources
    
  cnres@gsnDraw           = False              ; Turn these off. We
  cnres@gsnFrame          = False              ; will overlay plots
  vcres@gsnDraw           = False              ; later.
  vcres@gsnFrame          = False

  cnres@pmTickMarkDisplayMode = "Always"
;  cnres@mpFillOn              =  False          ; turn off map fill
  cnres@mpOutlineDrawOrder    = "PostDraw"      ; draw continental outline last
  
  cnres@gsnAddCyclic            = True            ; not regional data 
  cnres@cnFillOn                = True
  cnres@cnLinesOn               = False           ; turn off contour lines
  
; Curly Vector  
  vcres@vcRefMagnitudeF          = 10.0             ; define vector ref mag
  vcres@vcRefLengthF             = 0.045            ; define length of vec ref
  vcres@vcGlyphStyle             = "CurlyVector"    ; turn on curly vectors
  vcres@vcMinDistanceF           = 0.017            ; thin vectors
  vcres@vcRefAnnoOrthogonalPosF  = .1               ; move ref vector down
; Curly Vector Color
  vcres@vcRefMagnitudeF          = 15.0             ; define vector ref mag

  vcres@gsnAddCyclic             = True            ; not regional data 

;---Make sure vector plot doesn't have subtitles
  vcres@gsnLeftString     = ""
  vcres@gsnRightString    = ""
;---Add subtitles to contour plot
;  cnres@gsnLeftString     = sptemp@long_name +  " (" + utemp@units + ")"
;  cnres@gsnRightString    = "wind (" + utemp@units + ")"
;;  cnres@cnLevelSelectionMode = "ExplicitLevels" ; use explicit levels
;;  cnres@cnLevels          = (/2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30/)

u10temp_avg = dim_avg_n_Wrap(uuyearlyaverage,0)
v10temp_avg = dim_avg_n_Wrap(vvyearlyaverage,0)
spdtemp_avg = dim_avg_n_Wrap(spdyearlyaverage,0)

spdtemp_average = spdtemp_avg
printMinMax(spdtemp_average, True)
spdtemp_deviation = spdyearlyaverage(37,:,:) - spdtemp_avg
printMinMax(spdtemp_deviation, True)
percent_deviation = (spdtemp_deviation / spdtemp_average) * 100

;printVarSummary(spdtemp_avg)
;---Create the two individual plots
;  contour_fill_plot = gsn_csm_contour_map(wks,spdtemp_deviation,cnres)
  contour_fill_plot = gsn_csm_contour_map(wks,percent_deviation,cnres)
;  vector_plot       = gsn_csm_vector(wks,u10temp_avg,v10temp_avg,vcres)
;---Overlay the vectors on the contour/map plot
;  overlay(contour_fill_plot,vector_plot)
  draw(contour_fill_plot)    ; This will draw everything
  frame(wks)

; average end
EOF
ncl < ${tempfile}
rm -rf ${tempfile}
datetemp=` date -I -d "$datetemp + 1 day" `
datetemp=` date -d "$datetemp" +%Y%m%d`
} done

