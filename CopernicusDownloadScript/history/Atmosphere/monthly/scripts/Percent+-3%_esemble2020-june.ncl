file_a = systemfunc("ls ./ncdata/Seasonal-forecast-wind-june-20year.nc")
fa = addfile(file_a,"r")
;A
avgspeed = fa->Speed10m
printVarSummary(avgspeed)
printMinMax(avgspeed,True)
;B
file_b = systemfunc("ls ./ncdata/2020-June-seasonal-percent-10m.nc")
fb = addfile(file_b,"r")
percent = fb->percent
printVarSummary(percent)
printMinMax(percent, True)

;scale
scale = 0.03
c = avgspeed * (1 + percent / 100 + scale)
printVarSummary(c)
printMinMax(c,True)
d = avgspeed * (1 + percent / 100 - scale)
printVarSummary(d)
printMinMax(d,True)

;E
file_e = systemfunc("ls ./ncdata/Seasonal-forecast-wind-2020-june-0.25p.nc")
fe = addfile(file_e,"r")
lat_e = fe->lat
lon_e = fe->lon
e = fe->Speed10m
printVarSummary(e)
printMinMax(e, True)
;----------------------
;process
Array = new((/721,1440/),integer)
Array = 0
; printMinMax(Array,True)
do i = 0,50
    do j = 0, 720
        do k = 0, 1439
            if (e(i,j,k) .gt. d(j,k) .and. e(i,j,k) .lt. c(j,k)) then
            ; if (e(i,j,k) .gt. 0.0) then
                Array(j,k) = Array(j,k) + 1
            end if
        end do
    end do 
end do

printVarSummary(Array)
printMinMax(Array,True)
    
Array2 = tofloat(Array) / 51 * 100
printMinMax(Array2,True)
;----------------------
;output
;to do
;output percent to csv
lat1d_org=lat_e
lon1d_org=lon_e
; printMinMax(lon1d_org, True)
lat1d = tofloat(lat1d_org)
lon1d = tofloat(lon1d_org)

; ; lat1d=a1->g0_lat_2 ;181
; ; lon1d=a1->g0_lon_3 ; 360
numlat = 721
numlon = 1440
do k = 0, numlon -1
    if (lon1d(k) .ge. 180) then
        lon1d(k) = lon1d(k) - 360.0
    end if
end do
; printMinMax(lon1d, True)
lon2d = new((/numlat, numlon/), float)
lat2d = new((/numlat, numlon/), float)
;do loop
do n = 0, numlon -1
    lon2d(:,n) = lon1d(n)
end do
do n = 0, numlat -1
    lat2d(n,:) = lat1d(n)
end do
; wind2020 Seasonal-history(%) april
foutf = "./text/Seasonal-forecast-2020-regrid-percent+-3%" + "June" + "-average-10m.csv"
header = ("longitude,   latitude,    percent(%)")
hlist = [/header/]
alist = [/lon2d, lat2d, Array2/]
system("/bin/rm -f " + foutf)
write_table(foutf, "w", hlist, "%s")
write_table(foutf, "a", alist, "%9.4f, %9.4f, %9.4f")
