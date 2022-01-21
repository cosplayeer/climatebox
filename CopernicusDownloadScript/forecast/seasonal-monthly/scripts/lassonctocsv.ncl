 ;后处理，ｎｃ文件转ｃｓｖ文件
 ;在lassoTest.py输出nc文件后执行
 ;修改ffile名字，输出对应时刻点ｃｓｖ文件，为global mapper提供数据
 ffile = "wind202206"
 fname="data_0.25_2022/" + ffile + ".nc"
 a=addfile(fname,"r")
 _lon = a->lon
 _lat = a->lat
 printVarSummary(_lon)
;  print("lon dim sizes:")
;  print(dimsizes(_lon))
;  printVarSummary(_lat)
;  print("lat dim sizes:")
;  print(dimsizes(_lat))

 ;new lat
 lat = new((/dimsizes(_lat),dimsizes(_lon)/),"float")
 i = 0
do while (i .lt. 205)
  j = 0
  do while (j .lt. 253)
  lat(i,j) = tofloat(_lat(i))
  j = j + 1
  end do
i = i + 1
end do

;  printVarSummary(lat)
;  print(dimsizes(_lat))
;  print(dimsizes(_lon))
print(typeof(_lon))
;  i = 0
;  do while(i .lt. 205)    
;      j = 0
;      do while(j .lt. 253)                                        do while(i.lt.dimsizes(_lat))
;         lat(i,j) = 0
;         j=j+1
;      end do
;    i=i+1
;    end do
;new lon
 lon = new((/dimsizes(_lat),dimsizes(_lon)/),"float")
 i = 0
do while (i .lt. 205)
  j = 0
  do while (j .lt. 253)
  lon(i,j) = tofloat(_lon(j))
  j = j + 1
  end do
i = i + 1
end do
 
 spd = a->windspeed
 printVarSummary(spd)
 header  = [/"Longitude ,Latitude, speed(m/s)"/]
 format = "%s"
 csv_filename = "text/" + ffile + ".csv"
 write_table(csv_filename,"w",header,format)
 alist  = [/lon,lat,spd/]
 format = "%11.3f %11.3f %11.3f"
 write_table(csv_filename,"a",alist,format)