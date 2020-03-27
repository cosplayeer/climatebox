;goal : output 20 year average speed in month 4
;
file_list = systemfunc("ls ./data/reanalysis-era5-single-levels-monthly-means-*.grib")
f = addfiles(file_list,"r")

ListSetType(f, "join")
spd10m = f[:]->10SI_GDS0_SFC_S123
u10 = f[:]->10U_GDS0_SFC_S123
v10 = f[:]->10V_GDS0_SFC_S123
u100 = f[:]->100U_GDS0_SFC_S123
v100 = f[:]->100V_GDS0_SFC_S123
spd10m_uv = sqrt(u10*u10 + v10*v10)
spd100m_uv = sqrt(u100*u100 + v100*v100)
copy_VarMeta(u10, spd10m_uv)
copy_VarMeta(u100, spd100m_uv)
;12x721x1440
print(getvardimnames(spd10m_uv))
printVarSummary(spd10m_uv)
spd10m_monthly = dim_avg_n_Wrap((spd10m), 0)
spd10m_uv_monthly = dim_avg_n_Wrap((spd10m_uv), 0)
spd100m_uv_monthly = dim_avg_n_Wrap((spd100m_uv), 0)

spd10m_monthly_april = spd10m_monthly(3,:,:)
spd10m_uv_monthly_april = spd10m_uv_monthly(3,:,:)
spd100m_uv_monthly_april = spd100m_uv_monthly(3,:,:)
printVarSummary(spd10m_monthly_april)
print(avg(spd10m_monthly_april))
print(avg(spd10m_uv_monthly_april))
print(avg(spd100m_uv_monthly_april))

; ;write to nc
outname = "./ncdata/ERA5-wind-april-20year-average.nc"
system("/bin/rm -f " + outname)
ncdf = addfile(outname,"c")

; filedimdef(ncdf, "time", -1, True)
spd10m_monthly_april@long_name = "wind speed origin at 10m monthly april"
spd10m_monthly_april@units     = "m/s"
ncdf->Speed10m = spd10m_monthly_april

spd10m_uv_monthly_april@long_name = "wind speed from uv at 10m monthly april"
spd10m_uv_monthly_april@units     = "m/s"
ncdf->Speed10m_UV = spd10m_uv_monthly_april

spd100m_uv_monthly_april@long_name = "wind speed from uv at 100m monthly april"
spd100m_uv_monthly_april@units     = "m/s"
ncdf->Speed100m_UV = spd100m_uv_monthly_april