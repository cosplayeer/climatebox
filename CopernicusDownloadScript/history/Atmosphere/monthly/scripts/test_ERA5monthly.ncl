fname="./data/ERA5monthlyaverage2000_2020.grib"
f = addfile(fname,"r")
t = f->initial_time0
p = f->SP_GDS0_SFC_S123
t2 = f->2T_GDS0_SFC_S123
spd = f->10SI_GDS0_SFC_S123
lat1d = f->g0_lat_1
lon1d = f->g0_lon_2
numlat = 721
numlon = 1440
do k = 0, numlon -1
    if (lon1d(k) .ge. 180) then
        lon1d(k) = lon1d(k) - 360.0
    end if
end do
lon2d = new((/numlat, numlon/), float)
lat2d = new((/numlat, numlon/), float)
;do loop
do n = 0, numlon -1
    lon2d(:,n) = lon1d(n)
end do
do n = 0, numlat -1
    lat2d(n,:) = lat1d(n)
end do

function my_func (x:integer)
begin
    i = x
    ; sum_t2 = new(dimsizes(t2(0,:,:)),typeof(t2),0)
    sum_t2 = t2(0,:,:)
    sum_t2 = 0
    sum_spd = spd(0,:,:)
    sum_spd = 0
    sum_p = p(0,:,:)
    sum_p = 0
    printVarSummary(sum_t2)
    do while(i .lt. dimsizes(t) - 6)
        sum_t2 = sum_t2 + t2(i,:,:)
        sum_p = sum_p + p(i,:,:)
        sum_spd = sum_spd + spd(i,:,:)
        ; printMinMax(sum_t2, True)
        ; printMinMax(t2(i,:,:), True)
        i = i + 12
    end do
    avg_t2 = sum_t2 / 20.0 -273.15
    avg_p = sum_p / 20.0 / 100
    avg_spd = sum_spd / 20.0
    printVarSummary(avg_t2)
    printMinMax(avg_t2, True)
    printMinMax(avg_p, True)
    printMinMax(avg_spd, True)

    ; output csv
    foutf = "./MonthlyMean20year0p25-" + tostring(x+1) + ".csv"
    header = ("Longitude,   Latitude,    Temp(C),    Pres(hPa),    Spd(m/s)")
    hlist = [/header/]
    alist = [/lon2d, lat2d, avg_t2, avg_p, avg_spd/]
    system("/bin/rm -f " + foutf)
    write_table(foutf, "w", hlist, "%s")
    write_table(foutf, "a", alist, "%9.4f, %9.4f, %9.4f, %9.4f, %9.4f")
    return x
end

s = my_func(0)
print(s)
s1 = my_func(1)
print(s1)
s1 = my_func(2)
print(s1)
s1 = my_func(3)
print(s1)
s1 = my_func(4)
print(s1)
s1 = my_func(5)
print(s1)
s1 = my_func(6)
print(s1)
s1 = my_func(7)
print(s1)
s1 = my_func(8)
print(s1)
s1 = my_func(9)
print(s1)
s1 = my_func(10)
print(s1)
s1 = my_func(11)
print(s1)
