import Ngl
import Nio
import netCDF4 as nc
import numpy as np
import pandas as pd
from sklearn import linear_model
import os


def filter_lists():
    file_list = []

    def file_filter(f):
        if f[-10:] in ['1-0.25p.nc']:
            return True
        else:
            return False

    _files = list(filter(file_filter, os.listdir('data_0.25')))

    for _f in _files:
        file_list.append(os.path.join('data_0.25', _f))
    return file_list


def lasso_model(f1, f2, ilat, jlon, imonth=1):
    # 1. 读入实测
    # fname = "data_0.25/WindSpeed10mERA5monthly.grib"
    # f = Nio.open_file(fname)
    # print(f.variables["10SI_GDS0_SFC_S123"])
    # print("imonth in lasso_model is %s" % imonth)
    _spd10mObs = f1.variables["10SI_GDS0_SFC_S123"][:, ::-1, :]
    spd10mObs = _spd10mObs[6:, ilat, jlon]
    # print(np.size(spd10mObs))
    spd10mObsArray = np.zeros(21, np.float16)
    for i in range(21):
        # 从第六行开始，每次跳过６行，即为imonth月份结果
        spd10mObsArray[i] = spd10mObs[i*6+imonth-1]
        # spd10mObsArrayPandas = pd.DataFrame(spd10mObsArray)[18:21]
        spd10mObsArrayPandas = spd10mObsArray[18:21]
    # print(spd10mObsArrayPandas)

    # 2. 读入21年点预报 multiple;2001---2021 21years goal:2022nian
    # file_list = "data_0.25/*-1-0.25p.nc"
    # flists = nc.MFDataset(file_list)
    # fname2 = "data_0.25/output1-monthly-forecast-wind-21years-0.25p.nc"
    # f2 = Nio.open_file(fname2)
    # years, members
    # 16:21 is better than :21
    # :5 :25差不多
    # 最近点3年１９，２０，２１年，１５个集合成员
    spd10mFor = f2.variables["speed10"][18:21, :15, ilat, jlon]
    # print((spd10mFor.shape))
    # spd10mForPandas = pd.DataFrame(spd10mFor)  # １
    spd10mForPandas = spd10mFor  # ２

    # 3. 建立模型
    model = linear_model.LassoCV()
    model.fit(spd10mForPandas, spd10mObsArrayPandas)
    # print(model.alpha_)
    # print(model.coef_)

    return model


# change testyearIndex
def test_predict_model_result(f3, model, ilat, jlon):
    # f3 is read in data_0.25
    #    dimensions:
    #       ncl_join = 21
    #       ncl0 = 51
    #       lat = 721
    #       lon = 1440
    #    variables:
    #       float speed10 ( ncl_join, ncl0, lat, lon

    # 从２０２１年点预测资料对比ＥＲＡ５结果是否正确预测
    #　０．２５度格点
    #   １度格点
    # ncl_join = 21
    #   ncl0 = 51
    #   lat = 721
    #   lon = 1440
    # fname3 = "data_0.25/output1-monthly-forecast-wind-21years-0.25p.nc"
    # f3 = Nio.open_file(fname3)
    testyearIndex = 18
    spd10mFor2022 = f3.variables["speed10"][testyearIndex, :15, ilat, jlon]
    spd10mFor2022T = pd.DataFrame(spd10mFor2022).T  # convert 15x1 1x15
    # print(spd10mFor2022T.as_matrix())
    # print(spd10mFor2022T.shape)
    # 4. 测试一个网格点，读入实测
    # 1. 读入实测
    fname = "data_0.25/WindSpeed10mERA5monthly.grib"
    f = Nio.open_file(fname)
    # print(f.variables["10SI_GDS0_SFC_S123"])
    _spd10mObs = f.variables["10SI_GDS0_SFC_S123"][:, ::-1, :]
    spd10mObs = _spd10mObs[6:, ilat, jlon]
    # print(np.size(spd10mObs))
    spd10mObsArray = np.zeros(21, np.float16)
    for i in range(21):
        spd10mObsArray[i] = spd10mObs[i*6]  # 从第7行开始，每次跳过６行，即为１月份结果
        spd10mObsArrayPandas = pd.DataFrame(spd10mObsArray)
    print("obs array:")
    print(spd10mObsArrayPandas)

    # print(spd10mObsArrayPandas.iloc[[2]])
    _result = model.predict(np.array(spd10mFor2022T))
    f3.close()
    print("predict result is: %s" % _result)
    print("test year index: %s" % testyearIndex)


def predict_model_result(f3, model, ilat, jlon):
    # f3 is read in data_0.25_2022 01
    #   dimensions:
    #       ncl0 = 51
    #       lat = 721
    #       lon = 1440
    #    variables:
    #       float Speed10m ( ncl0, lat, lon )

    # 3.1 下载２０２１年１２月对未来６个月点预报ｅｃｍｗｆ
    # 3.1 插值为０．２５度
    # 3.1 读入２０２１年１２月对未来６个月点预报ｅｃｍｗｆ，０．２５度
    # fname3 = "data_0.25_2022/monthly-forecast-wind202112-1-0.25p.nc"  # 202２年１月份
    # f3 = Nio.open_file(fname3)
    spd10mFor2022 = f3.variables["Speed10m"][:15, ilat, jlon]  # :25
    spd10mFor2022T = pd.DataFrame(spd10mFor2022).T  # convert 25x1 to 1x25
    # print(spd10mFor2022T.as_matrix())
    # print(spd10mFor2022T.shape)
    # 4. 测试一个网格点
    # print(spd10mForPandas.iloc[[2]])
    # result202201 = model.predict(
    #     spd10mForPandas.iloc[[2]])  # , np.newaxis)
    # print(result202201)
    # print(spd10mObsArrayPandas.iloc[[2]])
    _result = model.predict(np.array(spd10mFor2022T))
    # print(_result)
    return _result


# 5. 循环网格点
def circle(imonth=1):
    print("imonth in circle is %s" % imonth)
    # 1. 读入实测
    fname = "data_0.25/WindSpeed10mERA5monthly.grib"
    f1 = Nio.open_file(fname)
    # lassoMerge.sh
    fname2 = "data_0.25/output" + \
        str(imonth) + "-monthly-forecast-wind-21years-0.25p.nc"
    f2 = Nio.open_file(fname2)
    fname3 = "data_0.25_2022/monthly-forecast-wind202112-" + \
        str(imonth) + "-0.25p.nc"  # 202２年imonth月份
    f3 = Nio.open_file(fname3)
    nlat = 577 - 372
    nlon = 545 - 292
    test_matrix = np.zeros((nlat, nlon), dtype=np.float32)
    for i in range(nlat):
        for j in range(nlon):
            _model = lasso_model(f1=f1, f2=f2, ilat=i, jlon=j, imonth=imonth)
            print("ilat:%s" % i)
            print("jlon:%s" % j)
            # print(float(predict_model_result(_model, ilat=i, jlon=j)))
            test_matrix[i, j] = float(
                predict_model_result(f3, model=_model, ilat=i, jlon=j))
    return test_matrix


# ６. 输出ｎｃ
def outputnc(varmatrix, imonth=1):
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
    import os
    outfilepath = os.path.join("data_0.25_2022", "wind20220"+str(imonth)+".nc")
    print(outfilepath)
    # print(type(outfilepath))
    if os.path.exists(outfilepath):
        os.remove(outfilepath)
    outf = Nio.open_file("data_0.25_2022/wind20220"+str(imonth)+".nc", "c")
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

# 从预报场中读入数组


def test_varSpeed1():
    fname3 = "data_0.25_2022/monthly-forecast-wind202112-1-0.25p.nc"
    f3 = Nio.open_file(fname3)
    varSpeed = f3.variables["Speed10m"][0, :, :]
    return varSpeed

# 空数组


def test_varSpeed2():
    nlat = 577 - 372
    nlon = 545 - 292
    test_matrix = np.zeros((nlat, nlon), dtype=np.float32)
    return test_matrix

# change ilat, ilon


def test_1point_0p25():
    # test 0.25 1 point
    fname = "data_0.25/WindSpeed10mERA5monthly.grib"
    f1 = Nio.open_file(fname)
    fname2 = "data_0.25/output1-monthly-forecast-wind-21years-0.25p.nc"
    f2 = Nio.open_file(fname2)
    # fname3 = "data_0.25_2022/monthly-forecast-wind202112-1-0.25p.nc"  # 202２年１月份
    # f3 = Nio.open_file(fname3)
    fname3 = "data_0.25/output1-monthly-forecast-wind-21years-0.25p.nc"
    f3 = Nio.open_file(fname3)
    _model = lasso_model(f1=f1, f2=f2, ilat=402, jlon=1002)
    result = test_predict_model_result(
        f3=f3, model=_model, ilat=402, jlon=1002)
    print("result is:%s" % result)
    f1.close()
    f2.close()


if __name__ == '__main__':
    varSpeed = circle(imonth=4)
    # varSpeed = test_varSpeed2()
    outputnc(varSpeed, imonth=4)
    # test_1point_0p25()
