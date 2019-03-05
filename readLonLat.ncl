
; merra
; outnameoption="merra"
; a=addfile("MERRA2_20170129.nc", "r")
; lon0= a->lon
; lat0= a->lat
;fnl
; outnameoption="fnl"
; a=addfile("gdas1.fnl0p25.2018090100.f00.grib2","r")
; lon0= a->lon_0
; lat0= a->lat_0
;erai
; outnameoption="erai"
; a=addfile("ERA-Int_sfc_2018-02-23.grb","r")
; lon0= a->g0_lon_2
; lat0= a->g0_lat_1
; ; era5
outnameoption="era5"
a=addfile("ERA5_sfc_2015-02-01.grb","r")
lon0= a->g0_lon_2
lat0= a->g0_lat_1

printMinMax(lon0, True)
printVarSummary(lon0)
dimlon0 = dimsizes(lon0)
dimlat0 = dimsizes(lat0)

lon2d0 = new((/dimlat0, dimlon0/), "float")
lat2d0 = new((/dimlat0, dimlon0/), "float")
do i =0, dimlat0 -1
    do j =0, dimlon0 -1
       lat2d0(i,j) = tofloat(lat0(i))
    end do
end do

do i =0, dimlat0 -1
    do j =0, dimlon0 -1
       lon2d0(i,j) = tofloat(lon0(j))
    end do
end do

; output
header = [/"lat,    lon"/]
alist = [/lat2d0, lon2d0/]
format = "%.3f, %.3f"
csv_filename = "gridpoint-"+outnameoption+".csv"
system("rm -rf " + csv_filename)

write_table(csv_filename, "w", header, "%s")
write_table(csv_filename, "a", alist, format)