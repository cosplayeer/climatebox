file_list = systemfunc("ls ./data/reanalysis-era5-single-levels-monthly-means-*.grib")
f = addfiles(file_list,"r")

ListSetType(f, "join")
; var = f[:]->10SI_GDS0_SFC_S123
u10 = f[:]->10U_GDS0_SFC_S123
v10 = f[:]->10V_GDS0_SFC_S123
u100 = f[:]->100U_GDS0_SFC_S123
v100 = f[:]->100V_GDS0_SFC_S123
var = sqrt(u10*u10 + v10*v10)
var100 = sqrt(u100*u100 + v100*v100)
copy_VarMeta(u10, var)
copy_VarMeta(u10, var100)
;12x721x1440
print(getvardimnames(var))
printVarSummary(var)
var12monthly = dim_avg_n_Wrap((var), 0)
varallmonthly = dim_avg_n_Wrap((var12monthly), 0)
var100_12monthly = dim_avg_n_Wrap((var100), 0)
var100allmonthly = dim_avg_n_Wrap((var100_12monthly), 0)
printVarSummary(var12monthly)
printVarSummary(varallmonthly)
print(min(varallmonthly))
print(max(varallmonthly))

; ; ;write to nc
; outname = "./ncdata/ERA5-all-month-average.nc"
; system("/bin/rm -f " + outname)
; ncdf = addfile(outname,"c")

; ; filedimdef(ncdf, "time", -1, True)
; varallmonthly@long_name = "wind speed"
; varallmonthly@units     = "m/s"
; ncdf->Speed = varallmonthly

ratio = var100allmonthly / varallmonthly
; write to nc ratio
outname = "./ncdata/ERA5-100-devide-10-ratio-average.nc"
system("/bin/rm -f " + outname)
ncdf = addfile(outname,"c")

; filedimdef(ncdf, "time", -1, True)
ratio@long_name = "wind speed 100m devide 10m"
ratio@units     = " "
printVarSummary(ratio)
printMinMax(ratio, True)
ncdf->Ratio = ratio