; forecastmonth="2"
print(forecastmonth)
file_list = systemfunc("ls data_0.25/*-"+ forecastmonth +"-0.25p.nc")

flists = addfiles(file_list,"r")
ListSetType (flists, "join")
s = flists[:]->Speed10m
printVarSummary(s)

; ;write to nc
outname = "./data_0.25/output"+ forecastmonth +"-monthly-forecast-wind-21years-0.25p.nc"
system("/bin/rm -f " + outname)
; setfileoption("nc","Format","LargeFile")
setfileoption("nc","Format","NetCDF4Classic")
ncdf = addfile(outname,"c")

; filedimdef(ncdf, "time", -1, True)
s@long_name = "monthly forecast average speed at 10m forecastmonth " + tostring(forecastmonth) + " 0.25p"
s@units     = "m/s"
ncdf->speed10 = s