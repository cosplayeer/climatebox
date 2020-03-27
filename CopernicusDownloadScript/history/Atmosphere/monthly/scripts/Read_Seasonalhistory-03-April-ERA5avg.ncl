; goal:
; step 1 : read in forecast 1x1, 
; step 2 : time 19 years average 6.392915
; step 3 : forecast 1x1 to 0.25p (regrid) ok
; todo
; step 4 : read in ERA5 0.25p
; step 5 : forecast - ERA5

filename = systemfunc("ls ncdata/Seasonal-forecast-wind-april-20year.nc")
print(filename)
a = addfile(filename,"r")
windspeed10m_april_seasonal_forecast_average = a->Speed10m
printVarSummary(windspeed10m_april_seasonal_forecast_average)
print(avg(windspeed10m_april_seasonal_forecast_average))

;---------------------------------------------
;read in era5 20year april　
;Prepare: Read_avgERA5_April, output nc data, done
; read in Speed10m, Speed10m_UV, Speed100m_UV
fileERA5 = "ncdata/ERA5-wind-april-20year-average.nc"
b = addfile(fileERA5,"r")
windspeed10m_april_ERA5 = b->Speed10m
;windspeed10m_april_ea_regrid 6m/s
printVarSummary(windspeed10m_april_ERA5)
print(avg(windspeed10m_april_ERA5))

minus = windspeed10m_april_ERA5 / windspeed10m_april_seasonal_forecast_average
printMinMax(minus,True)
print(avg(minus))

; ; ;write to nc
; outname = "./ncdata/ERA5-wind-april-20year-divede-Seasonal.nc"
; system("/bin/rm -f " + outname)
; ncdf = addfile(outname,"c")

; ; filedimdef(ncdf, "time", -1, True)
; windspeed10m_april_ERA5_devide@long_name = "wind speed ratio at 10m april ERA5 devide Seasonal"
; windspeed10m_april_ERA5_devide@units     = " "
; ncdf->Speed10mRatio = windspeed10m_april_ERA5_devide