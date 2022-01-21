file_list = systemfunc("ls ./data/reanalysis-era5-single-levels-monthly-means-*.grib | head -n 19")
print(file_list)
f = addfiles(file_list,"r")

ListSetType(f, "join")
wind10m = f[:]->10SI_GDS0_SFC_S123
wind10m_April = wind10m(:,3,:,:)
wind10m_May = wind10m(:,4,:,:)
wind10m_June = wind10m(:,5,:,:)
;20x12x721x1440
print(getvardimnames(wind10m_April))
printVarSummary(wind10m_April)
wind10m_April_20yearly = dim_avg_n_Wrap((wind10m_April), 0)
wind10m_May_20yearly = dim_avg_n_Wrap((wind10m_May), 0)
wind10m_June_20yearly = dim_avg_n_Wrap((wind10m_June), 0)

printVarSummary(wind10m_April_20yearly)
; varallmonthly = dim_avg_n_Wrap((var12monthly), 0)
; var100_12monthly = dim_avg_n_Wrap((var100), 0)
; var100allmonthly = dim_avg_n_Wrap((var100_12monthly), 0)
; printVarSummary(var12monthly)
; printVarSummary(varallmonthly)
; print(min(varallmonthly))
; print(max(varallmonthly))

; ;write to nc
outname = "./ncdata/ERA5-wind10m_April_20year-mean.nc"
system("/bin/rm -f " + outname)
ncdf = addfile(outname,"c")
wind10m_April_20yearly@long_name = "wind10m_April_20year average"
wind10m_April_20yearly@units     = "m/s"
ncdf->Speed10m = wind10m_April_20yearly

outname = "./ncdata/ERA5-wind10m_May_20year-mean.nc"
system("/bin/rm -f " + outname)
ncdf = addfile(outname,"c")
wind10m_May_20yearly@long_name = "wind10m_May_20year average"
wind10m_May_20yearly@units     = "m/s"
ncdf->Speed10m = wind10m_May_20yearly

outname = "./ncdata/ERA5-wind10m_June_20year-mean.nc"
system("/bin/rm -f " + outname)
ncdf = addfile(outname,"c")
wind10m_June_20yearly@long_name = "wind10m_June_20year average"
wind10m_June_20yearly@units     = "m/s"
ncdf->Speed10m = wind10m_June_20yearly
