a=addfile("MERRA2/MERRA2_20170115.nc","r")
print(a)
lat=a->lat
lon=a->lon

header = [/"lat,   lon"/]
alist = [/lat, lon/]
format = "%.3f %.3f"

csv_filename = "gridpoint-merra2.csv"
system("rm -rf " + csv_filename)

write_table(csv_filename, "w", header, "%s")
write_table(csv_filename, "a", alist, format)
