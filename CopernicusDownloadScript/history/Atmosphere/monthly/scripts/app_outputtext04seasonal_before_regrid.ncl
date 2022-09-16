;dimensions:
;   initial_time0_hours = 12
;   g0_lat_1 = 721
;   g0_lon_2 = 1440
;   g0_lat_3 = 361
;   g0_lon_4 = 720
;   initial_time5_hours = 12

filelist = systemfunc("ls ../../../forecast/seasonal-monthly/data2/seasonal-monthly-sfc-ensemble-avg*03.nc")
print(filelist)
a = addfiles(filelist,"r")
ListSetType (a, "join")

;;; 2 unit, spd10_uv_4
spd10_uv_4 = a[:]->Wind10_avg_2
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
foutf = "./text/yealy_average_spd10_uv_4_seasonal.csv"
header = ("spd10_uv_4, spd10_uv_4_yearly_avg,spd10_uv_4_yearly_deviation,spd10_uv_4_yearly_deviation_percent")
hlist = [/header/]
alist = [/spd10_uv_4_yearly, spd10_uv_4_yearly_avg,spd10_uv_4_yearly_deviation,spd10_uv_4_yearly_deviation_percent/]
system("/bin/rm -f " + foutf)
write_table(foutf, "w", hlist, "%s")
write_table(foutf, "a", alist, "%9.4f,%9.4f,%9.4f,%9.4f")
;;;2 unit end
