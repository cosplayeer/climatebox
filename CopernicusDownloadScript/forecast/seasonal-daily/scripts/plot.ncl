fi = "SeasonalDaily20190101to5160.grib"
a = addfile(fi, "r")
u10 = a->10U_GDS0_SFC_1
v10 = a->10V_GDS0_SFC_1
Wind10 = a->10FG_GDS0_SFC_1
;  Total precipitation
Pre = a->TP_GDS0_SFC
; Surface solar radiation
Radiation = a->SSR_GDS0_SFC_1
print(a)
; info = a->ensemble0_info
; print(info)
printVarSummary(u10)