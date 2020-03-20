file_list = systemfunc("ls ./data/reanalysis-era5-single-levels-monthly-means-*.grib")
f = addfiles(file_list,"r")

ListSetType(f, "join")
var = f[:]->10SI_GDS0_SFC_S123
;12x721x1440
print(getvardimnames(var))
printVarSummary(var)
var12monthly = dim_avg_n_Wrap((var), 0)
printVarSummary(var12monthly)
varallmonthly = dim_avg_n_Wrap((var12monthly), 0)
printVarSummary(varallmonthly)
print(min(varallmonthly))
print(max(varallmonthly))

; ;write to nc
outname = "./ncdata/ERA5-all-month-average.nc"
system("/bin/rm -f " + outname)
ncdf = addfile(outname,"c")

; filedimdef(ncdf, "time", -1, True)
varallmonthly@long_name = "wind speed"
varallmonthly@units     = "m/s"
ncdf->Speed = varallmonthly