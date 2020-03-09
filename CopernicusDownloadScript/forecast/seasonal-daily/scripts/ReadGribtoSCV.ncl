; parameters:
;---------------done---------------
; data 0
;fouttime = "201812-201902"
;timestring = "hours since 2018-12-01 00:00:0.0"
;---------------todo---------------
; data 1
;fouttime = "201901-201903"
;timestring = "hours since 2019-01-01 00:00:0.0"
;---------------done---------------
; data 2
;fouttime = "201902-201904"
;timestring = "hours since 2019-02-01 00:00:0.0"
; data 3
;----------to do, downloading-------
fouttime = "201903-201905"
timestring = "hours since 2019-03-01 00:00:0.0"
; readin
fname = "../data/adaptor.mars.ForecastWindDaily" + fouttime + "-sfc.grib"

a = addfile(fname, "r")
printVarSummary(a)
; [ensemble0 | 51] x [forecast_time1 | 91] x [g0_lat_2 | 181] x [g0_lon_3 | 360]
U10 = a->10U_GDS0_SFC(:,:,::-1,:)
V10 = a->10V_GDS0_SFC(:,:,::-1,:)
Wind10 = a->10FG_GDS0_SFC(:,:,::-1,:)
;time1 {
_time1 = a->forecast_time1
;printVarSummay(_time1)
_time1@units= timestring
time1 = cd_calendar(_time1, -2)
print(time1)
;}
;time4{
_time4 = a->forecast_time4
;printVarSummay(_time4)
_time4@units= timestring
time4 = cd_calendar(_time4, -3)
print(time4)
;}
;-----------
;处理, Wind10_point, Wind10_point_uv
; rcm2points not good
; use linint2_points
;; use nearby point method. todo
PointLon = (/113.0/)
PointLat = (/28.0/)

lon1d = a->g0_lon_3
lat1d = a->g0_lat_2(::-1)

;printVarSummary(lon1d)
;printMinMax(lon1d, True)
;printMinMax(lat1d, True)
;print(lat1d)  ;; reverse key
Wind10_point = linint2_points_Wrap(lon1d, lat1d, Wind10, True, PointLon, PointLat, 0)
U10_point = linint2_points_Wrap(lon1d, lat1d, U10, True, PointLon, PointLat, 0)
V10_point = linint2_points_Wrap(lon1d, lat1d, V10, True, PointLon, PointLat, 0)
Wind10_point_uv = sqrt(U10_point * U10_point + V10_point * V10_point)
;printVarSummary(Wind10_point)
;printMinMax(Wind10_point,True)
printMinMax(Wind10_point_uv,True)
printVarSummary(Wind10_point_uv)
;1.处理, Wind10_point,
print("Gust10 processing...")
dimwind10 = dimsizes(Wind10_point)
rowswind10 = dimwind10(1)
colswind10 = dimwind10(0)
alist = new((/rowswind10, colswind10/), "float")
do j = 0, colswind10 - 1
    alist(:,j) = Wind10_point(j,:,0)
end do

;------------------------------
;2.处理,  Wind10_point_uv
dimuv10 = dimsizes(Wind10_point_uv)
print("Wind10 processing...")
print(dimuv10)
rowsuv10 = dimuv10(1)
colsuv10 = dimuv10(0)
blist = new((/rowsuv10, colsuv10/), "float")
do j = 0, colsuv10 -1
    blist(:,j) = Wind10_point_uv(j,:,0)
end do


;------------------------------
;output
; 1. output alist
dir = "../csv/"
fname = dir + "windgust" + fouttime + ".csv"
dimlist = dimsizes(alist)
nrows = dimlist(0)     ; -- ncols = dimlist(1)
lines = new(nrows, string)
do i = 0, nrows -1
    lines(i) = tostring(time1(i)) + "," + str_concat(sprintf("%7.2f,",alist(i,:)))
end do
asciiwrite(fname, lines)

; 2. output blist
dir = "../csv/"
fnameb = dir + "wind6houly" + fouttime + ".csv"
dimlist = dimsizes(blist)
nrows = dimlist(0)     ; -- ncols = dimlist(1)
linesb = new(nrows, string)
do i = 0, nrows -1
    linesb(i) = tostring(time4(i)) + "," + str_concat(sprintf("%7.2f,",blist(i,:)))
end do
asciiwrite(fnameb, linesb)
