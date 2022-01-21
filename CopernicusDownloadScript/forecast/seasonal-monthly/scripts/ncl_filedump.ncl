;90 to -90
a=addfile("data_0.25/WindSpeed10mERA5monthly.grib","r")
lat = a->g0_lat_1(::-1)
; lon = a->g0_lon_2
spdobs1 = a->10SI_GDS0_SFC_S123(126,::-1,:)
; print(lat)
; print(lon)

;-90 to 90
b=addfile("data_0.25_2022/monthly-forecast-wind202112-1-0.25p.nc","r")
; lat=b->lat
; print(lat)
lon=b->lon
print(lon)
spdforecast = b->Speed10m(0,:,:)
; print(spdobs1(180,1000))
; print(spdobs1(540,1000))

; print(spdforecast(180,1000))
; print(spdforecast(540,1000))