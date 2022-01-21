a=addfile("data_0.25/monthly-forecast-wind201912-1-0.25p.nc","r")
spd10_1=a->Speed10m
u10=a->u10m
v10=a->v10m
spd10_2=sqrt(u10*u10+v10*v10)
printMinMax(spd10_1(0,:,:),True)
printMinMax(spd10_2(0,:,:),True)


;plot
;----Plotting options for spd-----------------------------------------------
        filename="pic/spd2.png"
        wks = gsn_open_wks("png",filename)
        gsn_define_colormap(wks,"WhiteBlueGreenYellowRed")
      opts = True
      opts@cnFillOn = True
      opts@cnLevelSelectionMode = "ExplicitLevels"
      ; opts@cnFillPalette        =  "WhiteGreen"
      opts@gsnSpreadColorEnd = -10
      ;opts@cnFillColors         = (/0, 74, 117, 155, 194, 223 /) ; dyp --
      opts@cnLevels        = (/2, 4, 6, 8, 10, 12, 14, 16, 18, 20/)  ; dyp-
      ;----for Label
      opts@lbTitleOn          = True
      opts@lbTitlePosition    = "Right"
      opts@lbTitleDirection   = "Across"
      opts@lbTitleString      = "m/s"
      opts@lbTitleOffsetF     = -0.01
      opts@lbTitleJust        = "CenterCenter"
      opts@lbTitleFontHeightF = 0.025
      opts@lbLabelPosition    = "Bottom"
      opts@lbLabelOffsetF     = 0.05
      opts@pmLabelBarWidthF   = 0.65
      opts@pmLabelBarHeightF     = 0.30              ; default is taller
      opts@lbAutoManage          = False             ; we control label bar
      opts@pmLabelBarDisplayMode = "Always"          ; turns on label bar
      opts@lbLabelFontHeightF    = .025              ; default is HUGE
      opts@lbPerimOn             = False             ; default has box 
      contour_spd = gsn_csm_contour(wks, spd10_2(0,:,:), opts)
      
      