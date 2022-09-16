;dimensions:
;   initial_time0_hours = 12
;   g0_lat_1 = 721
;   g0_lon_2 = 1440
;   g0_lat_3 = 361
;   g0_lon_4 = 720
;   initial_time5_hours = 12

filenames = systemfunc("ls data/reanalysis-era5-single-levels-monthly-means-*.grib")
print(filenames)
a = addfiles(filenames,"r")
ListSetType (a, "join")
; [years | 20] x [month | 12] x [g0_lat_1 | 721] x [g0_lon_2 | 1440]
spd10 = a[:]->10SI_GDS0_SFC_S123
u10 = a[:]->10U_GDS0_SFC_S123
v10 = a[:]->10V_GDS0_SFC_S123
spd10_uv = sqrt(u10*u10 + v10*v10)
u100 = a[:]->100U_GDS0_SFC_S123
v100 = a[:]->100V_GDS0_SFC_S123
spd100_uv = sqrt(u100*u100 + v100*v100)
lat1d=a[0]->g0_lat_1
lon1d=a[0]->g0_lon_2
;;; 1 unit, spd10_4
spd10_4 = spd10(:,3,:,:)
spd10_4_yearly = new(20, float)
spd10_4_yearly_avg = new(20, float)
spd10_4_yearly_deviation = new(20, float)
spd10_4_yearly_deviation_percent = new(20, float)
i = 0
do while(i.lt.20)
    spd10_4_yearly(i) = avg(spd10_4(i,:,:))
    i = i + 1
end do
i = 0
do while(i.lt.20)
    spd10_4_yearly_avg(i) = avg(spd10_4_yearly)
    i = i + 1
end do
spd10_4_yearly_deviation = spd10_4_yearly - spd10_4_yearly_avg
i = 0
do while(i.lt.20)
    spd10_4_yearly_deviation_percent(i) = abs(spd10_4_yearly_deviation(i)) / spd10_4_yearly_avg(i) * 100
    i = i + 1
end do
; print(spd10_4_yearly)
; print(spd10_4_yearly_avg)
; print(spd10_4_yearly_deviation)
; print(spd10_4_yearly_deviation_percent)

;output csv file
foutf = "./text/yealy_average_spd10_4.csv"
header = ("spd10_4, spd10_4_yearly_avg,spd10_4_yearly_deviation,spd10_4_yearly_deviation_percent")
hlist = [/header/]
alist = [/spd10_4_yearly, spd10_4_yearly_avg,spd10_4_yearly_deviation,spd10_4_yearly_deviation_percent/]
system("/bin/rm -f " + foutf)
write_table(foutf, "w", hlist, "%s")
write_table(foutf, "a", alist, "%9.4f,%9.4f,%9.4f,%9.4f")
;;;1 unit end

;;; 2 unit, spd10_uv_4
spd10_uv_4 = spd10_uv(:,3,:,:)
spd10_uv_4_yearly = new(20, float)
spd10_uv_4_yearly_avg = new(20, float)
spd10_uv_4_yearly_deviation = new(20, float)
spd10_uv_4_yearly_deviation_percent = new(20, float)
i = 0
do while(i.lt.20)
    spd10_uv_4_yearly(i) = avg(spd10_uv_4(i,:,:))
    i = i + 1
end do
i = 0
do while(i.lt.20)
    spd10_uv_4_yearly_avg(i) = avg(spd10_uv_4_yearly)
    i = i + 1
end do
spd10_uv_4_yearly_deviation = spd10_uv_4_yearly - spd10_uv_4_yearly_avg
i = 0
do while(i.lt.20)
    spd10_uv_4_yearly_deviation_percent(i) = abs(spd10_uv_4_yearly_deviation(i)) / spd10_uv_4_yearly_avg(i) * 100
    i = i + 1
end do
print(spd10_uv_4_yearly)
print(spd10_uv_4_yearly_avg)
print(spd10_uv_4_yearly_deviation)
print(spd10_uv_4_yearly_deviation_percent)

;output csv file
foutf = "./text/yealy_average_spd10_uv_4.csv"
header = ("spd10_uv_4, spd10_uv_4_yearly_avg,spd10_uv_4_yearly_deviation,spd10_uv_4_yearly_deviation_percent")
hlist = [/header/]
alist = [/spd10_uv_4_yearly, spd10_uv_4_yearly_avg,spd10_uv_4_yearly_deviation,spd10_uv_4_yearly_deviation_percent/]
system("/bin/rm -f " + foutf)
write_table(foutf, "w", hlist, "%s")
write_table(foutf, "a", alist, "%9.4f,%9.4f,%9.4f,%9.4f")
;;;2 unit end


;;; 3 unit, spd10_uv_4
spd100_uv_4 = spd100_uv(:,3,:,:)
spd100_uv_4_yearly = new(20, float)
spd100_uv_4_yearly_avg = new(20, float)
spd100_uv_4_yearly_deviation = new(20, float)
spd100_uv_4_yearly_deviation_percent = new(20, float)
i = 0
do while(i.lt.20)
    spd100_uv_4_yearly(i) = avg(spd100_uv_4(i,:,:))
    i = i + 1
end do
i = 0
do while(i.lt.20)
    spd100_uv_4_yearly_avg(i) = avg(spd100_uv_4_yearly)
    i = i + 1
end do
spd100_uv_4_yearly_deviation = spd100_uv_4_yearly - spd100_uv_4_yearly_avg
i = 0
do while(i.lt.20)
    spd100_uv_4_yearly_deviation_percent(i) = abs(spd100_uv_4_yearly_deviation(i)) / spd100_uv_4_yearly_avg(i) * 100
    i = i + 1
end do
print(spd100_uv_4_yearly)
print(spd100_uv_4_yearly_avg)
print(spd100_uv_4_yearly_deviation)
print(spd100_uv_4_yearly_deviation_percent)

;output csv file
foutf = "./text/yealy_average_spd100_uv_4.csv"
header = ("spd100_uv_4, spd100_uv_4_yearly_avg,spd100_uv_4_yearly_deviation,spd100_uv_4_yearly_deviation_percent")
hlist = [/header/]
alist = [/spd100_uv_4_yearly, spd100_uv_4_yearly_avg,spd100_uv_4_yearly_deviation,spd100_uv_4_yearly_deviation_percent/]
system("/bin/rm -f " + foutf)
write_table(foutf, "w", hlist, "%s")
write_table(foutf, "a", alist, "%9.4f,%9.4f,%9.4f,%9.4f")
;;;3 unit end











; numlat = 721
; numlon = 1440
; lon2d = new((/numlat, numlon/), float)
; lat2d = new((/numlat, numlon/), float)
; ;do loop
; do n = 0, numlon -1
;     lon2d(:,n) = lon1d(n)
; end do
; do n = 0, numlat -1
;     lat2d(n,:) = lat1d(n)
; end do

; ;output csv file
; foutf = "./text/ERA5199901.csv"
; header = ("longitude,   latitude,    wind10m")
; hlist = [/header/]
; alist = [/lon2d, lat2d, spd10_1/]
; system("/bin/rm -f " + foutf)
; write_table(foutf, "w", hlist, "%s")
; write_table(foutf, "a", alist, "%9.4f, %9.4f, %9.4f")
