import os
import numpy as np
import Nio
import Ngl


def ensemble_avg(year, month):
    ifile = "seasonal-monthly-sfc-" + year + "-" + month + "_1.grib"
    fname = "data/" + ifile
    f = Nio.open_file(fname, mode='r',
                    options=None, format='grib')
    u10 = f.variables['10U_GDS0_SFC']
    v10 = f.variables['10V_GDS0_SFC']
    Wind10_ens = f.variables['10SI_GDS0_SFC']
    Wind10_ens2 = np.sqrt(np.multiply(u10,u10) ,np.multiply(v10,v10))
    g0_lat_1 = f.variables['g0_lat_1']
    g0_lon_2 = f.variables['g0_lon_2']
    # print(Wind10_ens.shape)
    Wind10_avg = np.average(Wind10_ens, axis=0)
    print(Wind10_avg.shape)
    Wind10_avg_2 = np.average(Wind10_ens2, axis=0)
    print(Wind10_avg.mean())
    print(Wind10_avg_2.mean())
    
    if not os.path.isdir("data2"):
        os.mkdir("./data2")
    # write to grib.
    testgrib = "./data2/seasonal-monthly-sfc-ensemble-avg-2wind" + year + month +".nc"
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
    outf.create_variable('Wind10_avg_2', 'f', ('g0_lat_1', 'g0_lon_2'))

    # -- write data to file
    outf.variables['g0_lat_1'].assign_value(g0_lat_1)
    outf.variables['g0_lon_2'].assign_value(g0_lon_2)
    outf.variables['Wind10_avg'].assign_value(Wind10_avg)
    outf.variables['Wind10_avg_2'].assign_value(Wind10_avg_2)

    # -- close output stream
    outf.close()

# monthlists = ['01', '02', '03', '04', '05', '06',
#                     '07', '08', '09', '10', '11', '12']
monthlists = ['03']
for iyear in range(1999, 2018):
    for imonth in monthlists:
        print("processing " + str(iyear) + str(imonth))
        ensemble_avg(year=str(iyear),month=str(imonth))
