file03 = "data/seasonal-monthly-sfc-2019-03_leadtime123.grib"
f3 = addfile(file03,"r")
windgust10m = f3->10FG_GDS0_SFC
windspeed10m = f3->10SI_GDS0_SFC
windspeed10m_U = f3->10U_GDS0_SFC
windspeed10m_V = f3->10V_GDS0_SFC
windspeed10m_UV = sqrt(windspeed10m_U *windspeed10m_U + windspeed10m_V * windspeed10m_V)
print("10m wind gust:")
print(avg(windgust10m(:,0,:,:)))
print(avg(windgust10m(:,1,:,:)))
print(avg(windgust10m(:,2,:,:)))
printMinMax(windgust10m(:,0,:,:), False)
print("10m wind speed:")
print(avg(windspeed10m(:,0,:,:)))
print(avg(windspeed10m(:,1,:,:)))
print(avg(windspeed10m(:,2,:,:)))
printMinMax(windspeed10m(:,0,:,:), False)
print("10m wind speed u:")
print(avg(windspeed10m_U(:,0,:,:)))
print(avg(windspeed10m_U(:,1,:,:)))
print(avg(windspeed10m_U(:,2,:,:)))
printMinMax(windspeed10m_U(:,0,:,:), False)
print("10m wind speed v:")
print(avg(windspeed10m_V(:,0,:,:)))
print(avg(windspeed10m_V(:,1,:,:)))
print(avg(windspeed10m_V(:,2,:,:)))
printMinMax(windspeed10m_V(:,0,:,:), False)
print("10m wind speed uv:")
print(avg(windspeed10m_UV(:,0,:,:)))
print(avg(windspeed10m_UV(:,1,:,:)))
print(avg(windspeed10m_UV(:,2,:,:)))
printMinMax(windspeed10m_UV(:,0,:,:), False)

;output csv
;todo