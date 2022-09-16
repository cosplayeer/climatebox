import netCDF4 as nc
import Ngl
import Nio

fname = "data/ERA5_rad_20180801.grib"

f = Nio.open_file(fname)
# print(f.variables)
print(f.variables["SSRD_GDS0_SFC_acc1h"])
