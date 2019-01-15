a=addfile("ERA-Interim/ERA-Int_sfc_2018-09-10.grb", "r")
print(a)
lat=a->g0_lat_1
lon=a->g0_lon_2

header = [/"lat,   lon"/]
alist = [/lat, lon/]
format = "%.3f %.3f"

csv_filename = "fnlgridpoint.csv"
system("rm -rf " + csv_filename)

write_table(csv_filename, "w", header, "%s")
write_table(csv_filename, "a", alist, format)
