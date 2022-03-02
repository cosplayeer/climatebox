import Ngl
import Nio
import numpy as np


# 1. 读入实测
def readERA5Matrix(year=2021):
    fname = "data_0.25/WindSpeed10mERA5monthly.grib"
    f1 = Nio.open_file(fname)
    _spd10mObs = f1.variables["10SI_GDS0_SFC_S123"][:, ::-1, :]
    print(np.shape(_spd10mObs))  # (22x6, 721, 1440) #132
    if year == 2021:
        spd10mObs01 = _spd10mObs[126, 372:577, 292:545]
        spd10mObs02 = _spd10mObs[127, 372:577, 292:545]
        spd10mObs03 = _spd10mObs[128, 372:577, 292:545]
        spd10mObs04 = _spd10mObs[129, 372:577, 292:545]
        spd10mObs05 = _spd10mObs[130, 372:577, 292:545]
        spd10mObs06 = _spd10mObs[131, 372:577, 292:545]
    elif year == 2020:
        print("year is %s" % year)
        spd10mObs01 = _spd10mObs[120, 372:577, 292:545]
        spd10mObs02 = _spd10mObs[121, 372:577, 292:545]
        spd10mObs03 = _spd10mObs[122, 372:577, 292:545]
        spd10mObs04 = _spd10mObs[123, 372:577, 292:545]
        spd10mObs05 = _spd10mObs[124, 372:577, 292:545]
        spd10mObs06 = _spd10mObs[125, 372:577, 292:545]
    return spd10mObs01, spd10mObs02, spd10mObs03, spd10mObs04, spd10mObs05, spd10mObs06
    # 132 out range
    # spd10mObs07 = _spd10mObs[132, 372:577, 292:545]
    # print(np.shape(spd10mObs))  # (22x6, 721, 1440)
    # 2020 0
    # 202101 21x6 = 126
    # 202102 21x6+1 = 127
    # 202103 21x6+2 = 128
    # 202104 21x6+3 = 129
    # 202105 21x6+4 = 130
    # 202106 21x6+5 = 131

    # nlat = 577 - 372
    # nlon = 545 - 292
# 2.  输出ｎｃ


def outputnc(varmatrix, imonth=1, year=2021):
    # template lat lon
    fname3 = "data_0.25_2022/monthly-forecast-wind202112-" + \
        str(imonth) + "-0.25p.nc"
    f3 = Nio.open_file(fname3)
    latorg = f3.variables["lat"]
    lonorg = f3.variables["lon"]
    lat = f3.variables["lat"][372:577]
    lon = f3.variables["lon"][292:545]
    # print((f3.dimensions['lat']))
    print("imonth in outputnc:%s" % imonth)
    import os
    outfilepath = os.path.join(
        "data_0.25_"+str(year), "ERA5Wind"+str(year)+"0"+str(imonth)+".nc")
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


def output(year=2021):
    month1, month2, month3, month4, month5, month6 = readERA5Matrix(year=year)
    outputnc(month1, imonth=1, year=year)
    outputnc(month2, imonth=2, year=year)
    outputnc(month3, imonth=3, year=year)
    outputnc(month4, imonth=4, year=year)
    outputnc(month5, imonth=5, year=year)
    outputnc(month6, imonth=6, year=year)


if __name__ == '__main__':
    output(year=2020)
