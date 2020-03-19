import netCDF4 as nc


file_list = "./data2/seasonal-monthly-sfc-ensemble-avg*nc"
f = nc.MFDataset(file_list)

var = f.variables['Wind10_avg']
print(var.dimensions)