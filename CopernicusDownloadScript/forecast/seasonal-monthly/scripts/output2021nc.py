import Ngl
import Nio
import netCDF4 as nc
import numpy as np
import pandas as pd
from sklearn import linear_model
import os


# ６. 输出ｎｃ

# f1 = "data_0.25/monthly-forecast-wind202012-6-0.25p.nc"
def get2020ForcastMatrix(imonth=1):
    fname1 = "data_0.25/monthly-forecast-wind202012-" + \
        str(imonth) + "-0.25p.nc"  # 2022年imonth月份
    f1 = Nio.open_file(fname1)
    spdForTemplate = f1.variables["Speed10m"]
    matrix = spdForTemplate[0, 372:577, 292:545]  # avg
    # matrix = spdForTemplate[:, :, :]
    return matrix


def get2019ForcastMatrix(imonth=1):
    fname1 = "data_0.25/monthly-forecast-wind201912-" + \
        str(imonth) + "-0.25p.nc"  # 2022年imonth月份
    f1 = Nio.open_file(fname1)
    spdForTemplate = f1.variables["Speed10m"]
    matrix = spdForTemplate[0, 372:577, 292:545]  # avg
    # matrix = spdForTemplate[:, :, :]
    return matrix


def outputnc(varmatrix, imonth=1, year=2021):
    # template lat lon
    fname3 = "data_0.25_2022/monthly-forecast-wind202112-" + \
        str(imonth) + "-0.25p.nc"
    f3 = Nio.open_file(fname3)
    spdTemplate = f3.variables["Speed10m"]  # [0, 372:577, 292:545]
    latorg = f3.variables["lat"]
    lonorg = f3.variables["lon"]
    lat = f3.variables["lat"][372:577]
    lon = f3.variables["lon"][292:545]
    # print((f3.dimensions['lat']))
    print("imonth in outputnc:%s" % imonth)
    # ncname = "data_0.25_2022/wind20220"+str(imonth)+".nc"
    # os.system("rm data_0.25_2022/wind20220".nc")
    # create new file
    outfilepath = os.path.join(
        "data_0.25_"+str(year), "wind_originforecast_"+str(year)+"0"+str(imonth)+".nc")
    print(outfilepath)
    # print(type(outfilepath))
    if os.path.exists(outfilepath):
        os.remove(outfilepath)
    outf = Nio.open_file(outfilepath, "c")
    # -- create dimensions lat, lon
    # outf.create_dimension('lat', f3.dimensions['lat'])
    # outf.create_dimension('lon', f3.dimensions['lon'])

    outf.create_dimension('lat', 577 - 372)
    outf.create_dimension('lon', 545 - 292)
    # -- create dimension variables
    outf.create_variable('lat', latorg.typecode(), latorg.dimensions)
    outf.create_variable('lon', lonorg.typecode(), lonorg.dimensions)

    # -- create variable windspeed
    outf.create_variable('windspeed', 'f', ('lat', 'lon'))

    # -- write data to new file( assign values)
    outf.variables['lat'].assign_value(lat)
    outf.variables['lon'].assign_value(lon)
    outf.variables['windspeed'].assign_value(varmatrix)

    # -- close output stream
    outf.close()


def test():
    m = get2019ForcastMatrix(imonth=1)
    # print(m)
    # print(m.shape)
    outputnc(m, imonth=1, year=2020)


if __name__ == "__main__":
    test()
    # for i in range(1, 7):
    #     m = get2020ForcastMatrix(imonth=i)
    #     outputnc(m, imonth=i, year=2021)
    for i in range(1, 7):
        m = get2019ForcastMatrix(imonth=i)
        outputnc(m, imonth=i, year=2020)
