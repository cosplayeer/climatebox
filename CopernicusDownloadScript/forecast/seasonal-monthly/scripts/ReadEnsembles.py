import os
import numpy as np
import Nio
import Ngl


def ensemble_avg(year, month):
    ifile = "seasonal-monthly-sfc-" + year + "-" + month + "_1.grib"
    fname = "data/" + ifile
    f = Nio.open_file(fname, mode='r',
                    options=None, format='grib')
    Wind10_ens = f.variables['10SI_GDS0_SFC']
    g0_lat_1 = f.variables['g0_lat_1']
    g0_lon_2 = f.variables['g0_lon_2']
    Wind10_avg = np.average(Wind10_ens, axis=0)
    # print(Wind10_avg.min())
    # print(Wind10_avg.max())
    # print(Wind10_avg.shape)
    if not os.path.isdir("data2"):
        os.mkdir("./data2")
    # write to grib.
    testgrib = "./data2/seasonal-monthly-sfc-ensemble-avg" + year + month +".nc"
    if os.path.exists(testgrib):
        os.remove(testgrib)
    outf = Nio.open_file(testgrib, "c")

    # --create dimensions lat and lon
    outf.create_dimension('g0_lat_1', f.dimensions['g0_lat_1'])
    outf.create_dimension('g0_lon_2', f.dimensions['g0_lon_2'])

    # --create dimension variables
    outf.create_variable('g0_lat_1', g0_lat_1.typecode(), g0_lat_1.dimensions)
    outf.create_variable('g0_lon_2', g0_lat_1.typecode(), g0_lon_2.dimensions)

    # -- create variable speed
    outf.create_variable('Wind10_avg', 'f', ('g0_lat_1', 'g0_lon_2'))

    # -- write data to file
    outf.variables['g0_lat_1'].assign_value(g0_lat_1)
    outf.variables['g0_lon_2'].assign_value(g0_lon_2)
    outf.variables['Wind10_avg'].assign_value(Wind10_avg)

    # -- close output stream
    outf.close()

monthlists = ['01', '02', '03', '04', '05', '06',
                    '07', '08', '09', '10', '11', '12']
for iyear in range(1999, 2018):
    for imonth in monthlists:
        print("processing " + str(iyear) + str(imonth))
        ensemble_avg(year=str(iyear),month=str(imonth))
