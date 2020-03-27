file03 = "data/seasonal-monthly-sfc-1999-03_1.grib"
f3 = addfile(file03,"r")
windgust10m = f3->10FG_GDS0_SFC
windspeed10m = f3->10SI_GDS0_SFC
windspeed10m_U = f3->10U_GDS0_SFC
windspeed10m_V = f3->10V_GDS0_SFC
windspeed10m_UV = sqrt(windspeed10m_U *windspeed10m_U + windspeed10m_V * windspeed10m_V)
print("10m wind gust:")
print(avg(windgust10m(:,:,:)))
printMinMax(windgust10m(:,:,:), False)
print("10m wind speed:")
print(avg(windspeed10m(:,:,:)))
printMinMax(windspeed10m(:,:,:), False)
print("10m wind speed u:")
print(avg(windspeed10m_U(:,:,:)))
printMinMax(windspeed10m_U(:,:,:), False)
print("10m wind speed v:")
print(avg(windspeed10m_V(:,:,:)))
printMinMax(windspeed10m_V(:,:,:), False)
print("10m wind speed uv:")
print(avg(windspeed10m_UV(:,:,:)))
printMinMax(windspeed10m_UV(:,:,:), False)

;output csv
;todo