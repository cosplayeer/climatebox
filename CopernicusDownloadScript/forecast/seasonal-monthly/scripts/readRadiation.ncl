;readin
f =addfile("./data/SeasonalRadiation20200501June.grib","r")

surfaceSolarDown = f->VAR_169_GDS0_SFC
surfaceSolar = f->VAR_176_GDS0_SFC
; surfaceSolar = f->VAR_179_GDS0_SFC

;  dimensions:
;       ensemble0 = 51
;       g0_lat_1 = 181
;       g0_lon_2 = 360
; do
surfaceSolarDownAvg = dim_avg_n_Wrap(surfaceSolarDown, 0)
surfaceSolarAvg = dim_avg_n_Wrap(surfaceSolar , 0)
lat1d=f->g0_lat_1 ;181
lon1d=f->g0_lon_2 ; 360
numlat = 181
numlon = 360
do k = 0, numlon -1
    if (lon1d(k) .ge. 180) then
        lon1d(k) = lon1d(k) - 360.0
    end if
end do
printVarSummary(surfaceSolarDownAvg)
printMinMax(surfaceSolarDownAvg, True)
print(avg(surfaceSolarDownAvg))
printVarSummary(surfaceSolarAvg)
printMinMax(surfaceSolarAvg, True)
print(avg(surfaceSolarAvg))
lon2d = new((/numlat, numlon/), float)
lat2d = new((/numlat, numlon/), float)

;do loop
do n = 0, numlon -1
    lon2d(:,n) = lon1d(n)
end do
do n = 0, numlat -1
    lat2d(n,:) = lat1d(n)
end do

;output
foutf = "./text/SeasonalSurfaceSolarDown20200501June.csv"
header = ("longitude,   latitude,    VAR_169_GDS0_SFC(W m**-2)")
; header = ("longitude,   latitude,    VAR_176_GDS0_SFC(W m**-2)")
hlist = [/header/]
alist = [/lon2d, lat2d, surfaceSolarDownAvg/]
system("/bin/rm -f " + foutf)
write_table(foutf, "w", hlist, "%s")
write_table(foutf, "a", alist, "%9.4f, %9.4f, %9.4f")

foutf = "./text/SeasonalSurfaceSolar20200501June.csv"
header = ("longitude,   latitude,    VAR_176_GDS0_SFC(W m**-2)")
hlist = [/header/]
alist = [/lon2d, lat2d, surfaceSolarAvg/]
system("/bin/rm -f " + foutf)
write_table(foutf, "w", hlist, "%s")
write_table(foutf, "a", alist, "%9.4f, %9.4f, %9.4f")