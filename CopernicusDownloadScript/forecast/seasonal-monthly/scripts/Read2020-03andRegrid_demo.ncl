;readin forecast
file2020_03 = "data/seasonal-monthly-sfc-2019-03_leadtime123.grib"
a1 = addfile(file2020_03,"r")
windgust10m = a1->10FG_GDS0_SFC
windspeed10m = a1->10SI_GDS0_SFC
windspeed10m_U = a1->10U_GDS0_SFC
windspeed10m_V = a1->10V_GDS0_SFC
windspeed10m_UV = sqrt(windspeed10m_U *windspeed10m_U + windspeed10m_V * windspeed10m_V)

windspeed10m_april = windspeed10m(:,0,:,:)
windspeed10m_april_ea = dim_avg_n_Wrap(windspeed10m_april, 0)
printVarSummary(windspeed10m_april_ea)

windspeed10m_UV_april = windspeed10m_UV(:,0,:,:)
windspeed10m_april_UV_ea = dim_avg_n_Wrap(windspeed10m_UV_april, 0)
copy_VarMeta(windspeed10m_april_ea, windspeed10m_april_UV_ea)
printVarSummary(windspeed10m_april_UV_ea)
;---------------------------------------------
;regrid to 0.25




;---------------------------------------------
;read in era5 20year april
; todo







; print("10m wind gust:")
; print(avg(windgust10m(:,0,:,:)))
; print(avg(windgust10m(:,1,:,:)))
; print(avg(windgust10m(:,2,:,:)))
; printMinMax(windgust10m(:,0,:,:), False)
; print("10m wind speed:")
; print(avg(windspeed10m(:,0,:,:)))
; print(avg(windspeed10m(:,1,:,:)))
; print(avg(windspeed10m(:,2,:,:)))
; printMinMax(windspeed10m(:,0,:,:), False)
; print("10m wind speed u:")
; print(avg(windspeed10m_U(:,0,:,:)))
; print(avg(windspeed10m_U(:,1,:,:)))
; print(avg(windspeed10m_U(:,2,:,:)))
; printMinMax(windspeed10m_U(:,0,:,:), False)
; print("10m wind speed v:")
; print(avg(windspeed10m_V(:,0,:,:)))
; print(avg(windspeed10m_V(:,1,:,:)))
; print(avg(windspeed10m_V(:,2,:,:)))
; printMinMax(windspeed10m_V(:,0,:,:), False)
; print("10m wind speed uv:")
; print(avg(windspeed10m_UV(:,0,:,:)))
; print(avg(windspeed10m_UV(:,1,:,:)))
; print(avg(windspeed10m_UV(:,2,:,:)))
; printMinMax(windspeed10m_UV(:,0,:,:), False)

;output csv
;todo