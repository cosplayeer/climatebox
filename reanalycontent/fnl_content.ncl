a=addfile("FNL/gdas1.fnl0p25.2018052218.f00.grib2", "r")
print(a)
lat=a->lat_0
lon=a->lon_0

header = [/"lat,   lon"/]
alist = [/lat, lon/]
format = "%.3f %.3f"

csv_filename = "gridpoint-fnl.csv"
system("rm -rf " + csv_filename)

write_table(csv_filename, "w", header, "%s")
write_table(csv_filename, "a", alist, format)
