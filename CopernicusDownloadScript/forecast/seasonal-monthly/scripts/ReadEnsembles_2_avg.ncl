
file_list = systemfunc("ls ./data2/seasonal-monthly-sfc-ensemble-avg*.nc")
f = addfiles(file_list,"r")

ListSetType(f, "join")
var = f[:]->Wind10_avg
; var = f[:]->Wind10_avg_2
print(getvardimnames(var))
printVarSummary(var)
var2 = dim_avg_n_Wrap((var), 0)
printVarSummary(var2)
; print(min(var2))
; print(max(var2))

;write to nc
outname = "./data2/seasonal-monthly-sfc.nc"
system("/bin/rm -f " + outname)
ncdf = addfile(outname,"c")

; filedimdef(ncdf, "time", -1, True)
var2@long_name = "wind speed"
var2@units     = "m/s"
ncdf->Speed = var2