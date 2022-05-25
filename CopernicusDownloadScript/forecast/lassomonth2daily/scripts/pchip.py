import math
import os
import random

import numpy as np
import pandas as pd
from pandas import DataFrame, Series
from scipy.interpolate import pchip


def trans10(x):
    return math.atan2(x[1], x[2]) * 180 / math.pi + 180


def trans80(x):
    return math.atan2(x[1], x[2]) * 180 / math.pi + 180


def trans100(x):
    return math.atan2(x[1], x[2]) * 180 / math.pi + 180


def interpolate(filename, inpath, outpath, intervals):
    infile = os.path.join(inpath, filename)
    if not os.path.isfile(infile):
        raise IOError("File is not found.")

    fhand = pd.read_csv(infile, skiprows=1, header=None, usecols=[0, 1, 2, 3, 4, 5],
                        names=['Timeinfo', 'WindSpeed10m', 'WindDirection10m',  'Temperature2m',
                               'Pressure10m',  'Airdensity'])
    #    TimeInfo, WindSpeed10m, WindDirection10m, Temperature2m, Pressure10m, Airdensity

    timei_index_step1 = fhand['Timeinfo']
    timei_index = pd.to_datetime(timei_index_step1)
    # before replace
    # print(timei_index)
    #timei_index = timei_index.str.replace('_', ' ')
    # after replace
    # print(timei_index)
    # timei_index = pd.to_datetime(timei_index)
    # temperature = fhand['temperature']
    # rh = fhand['rh']
    # print(fhand)
    wind10 = fhand['WindSpeed10m']
    direct10 = fhand['WindDirection10m']
    # wind80 = fhand['WindSpeed80m']
    # direct80 = fhand['WindDirection80m']
    # wind100 = fhand['WindSpeed100m']
    # direct100 = fhand['WindDirection100m']
    Pressure10m = fhand['Pressure10m']
    Temperature2m = fhand['Temperature2m']
    Airdensity = fhand['Airdensity']

    # fault how to convert
    U10com = np.sin(np.radians(direct10-180))*wind10
    V10com = np.cos(np.radians(direct10-180))*wind10
    # U80com = np.sin(np.radians(direct80-180))*wind80
    # V80com = np.cos(np.radians(direct80-180))*wind80
    # U100com = np.sin(np.radians(direct100-180))*wind100
    # V100com = np.cos(np.radians(direct100-180))*wind100

    wind10 = np.sqrt(U10com*U10com+V10com*V10com)
    # wind80 = np.sqrt(U80com*U80com+V80com*V80com)
    # wind100 = np.sqrt(U100com*U100com+V100com*V100com)
    pchip_obj_wind10 = pchip(timei_index, wind10)
    # pchip_obj_wind80 = pchip(timei_index, wind80)
    # pchip_obj_wind100 = pchip(timei_index, wind100)
    # pchip_obj_p80 = pchip(timei_index, pressure80)
    # pchip_obj_t100 = pchip(timei_index, Temperature100)
    pchip_Airdensity = pchip(timei_index, Airdensity)

    pchip_Temperature2m = pchip(timei_index, Temperature2m)
    pchip_Pressure10m = pchip(timei_index, Pressure10m)
    pchip_U10 = pchip(timei_index, U10com)
    pchip_V10 = pchip(timei_index, V10com)
    # pchip_U80 = pchip(timei_index, U80com)
    # pchip_V80 = pchip(timei_index, V80com)
    # pchip_U100 = pchip(timei_index, U100com)
    # pchip_V100 = pchip(timei_index, V100com)

    #xi =np.sort(np.random.random(20))
    # print xi
    #yi =np.random.random(20)
    # print yi
    #pchip_obj = pchip(xi,yi)
    #x2=np.arange(xi[0],xi[-1], 0.001)
    # y2=pchip_obj(x2)

    # hourly time stamp building:
    time2_index = pd.date_range(
        timei_index.iloc[0], timei_index.iloc[-1], freq=intervals)
    wind10_after = pchip_obj_wind10(time2_index)  # array format
    # wind80_after = pchip_obj_wind80(time2_index)  # array format
    # wind100_after = pchip_obj_wind100(time2_index)  # array format
    p10_after = pchip_Pressure10m(time2_index)  # array format
    t2_after = pchip_Temperature2m(time2_index)
    air2_after = pchip_Airdensity(time2_index)

    wind10_after = pd.Series(wind10_after)       # series format
    # wind80_after = pd.Series(wind80_after)       # series format
    # wind100_after = pd.Series(wind100_after)       # series format
    pressure10_after = pd.Series(p10_after)
    t2m_after = pd.Series(t2_after)
    airdensity_after = pd.Series(air2_after)

    # dyp add
    total = wind10_after.shape[0]
    for i in range(total):
        wind10_after[i] = round(wind10_after[i], 3)  # save 3 digital number
        # wind80_after[i] = round(wind80_after[i], 3)  # save 3 digital number
        # wind100_after[i] = round(wind100_after[i], 3)  # save 3 digital number
        pressure10_after[i] = round(pressure10_after[i], 3)
        t2m_after[i] = round(t2m_after[i], 3)
        airdensity_after[i] = round(airdensity_after[i], 3)

    # temp2 = pchip_tem(time2_index) # array format
    # temp2 = pd.Series(temp2)       # series format
    # rh2 = pchip_rh(time2_index) # array format
    # rh2 = pd.Series(rh2)       # series format
    # rh2 = pd.to_numeric(rh2, errors = 'coerce')

    U10com2 = pchip_U10(time2_index)  # array format
    U10com2 = pd.Series(U10com2)       # series format
    V10com2 = pchip_V10(time2_index)  # array format
    V10com2 = pd.Series(V10com2)       # series format

    # U80com2 = pchip_U80(time2_index)  # array format
    # U80com2 = pd.Series(U80com2)       # series format
    # V80com2 = pchip_V80(time2_index)  # array format
    # V80com2 = pd.Series(V80com2)       # series format

    # U100com2 = pchip_U100(time2_index)  # array format
    # U100com2 = pd.Series(U100com2)       # series format
    # V100com2 = pchip_V100(time2_index)  # array format
    # V100com2 = pd.Series(V100com2)       # series format
    # time2_index = pd.Series(time2_index)
    # print time2_index
    # time3_index = time2_index.str.replace(' ', '_') #wrong

    # intermediate matrix
    # reanalfile = pd.concat([time2_index, temp2, rh2, wind2, Ucom2, Vcom2], axis=1)
    time2_index = pd.Series(time2_index)
    reanaldirtemp10 = pd.concat([time2_index, U10com2, V10com2], axis=1)
    wind10dir_after = reanaldirtemp10.apply(trans10, axis=1)
    # reanaldirtemp80 = pd.concat([time2_index, U80com2, V80com2], axis=1)
    # wind80dir_after = reanaldirtemp80.apply(trans80, axis=1)
    # reanaldirtemp100 = pd.concat([time2_index, U100com2, V100com2], axis=1)
    # wind100dir_after = reanaldirtemp100.apply(trans100, axis=1)

    totaldir = wind10dir_after.shape[0]
    for i in range(totaldir):
        wind10dir_after[i] = round(
            wind10dir_after[i], 3)  # save 3 digital number
        # wind80dir_after[i] = round(
        #     wind80dir_after[i], 3)  # save 3 digital number
        # wind100dir_after[i] = round(
        #     wind100dir_after[i], 3)  # save 3 digital number

    # print type(wind_dir)
    # wind_dir_column = DataFrame(wind_dir, columns = ["dir"])
    # wind_dir_head = wind_dir_head.astype(int)
    # print type(wind_dir_column)
    framelist = [time2_index, wind10_after,
                 wind10dir_after, pressure10_after, t2m_after, airdensity_after]
    reanalfile2 = pd.concat(framelist, axis=1)
    # Outhead = ["#TimeStamp", "Temperature", "RelativeHumidity", "WindDir", "WindSpeed"]
    Outhead = ["TimeInfo", " WindSpeed10m", " WindDirection10m",
               "Pressure10m", "Temperature2m", "AirDensity10m"]
    # Outhead = ["#TimeStamp         ", "Wind10MDir", "Wind10MSpeed", "Wind80MDir", "Wind80MSpeed", "Wind100MDir", "Wind100MSpeed", "Pressure80", "Temperature100", "QV2"]

    filenameout = os.path.join(outpath, filename)
    reanalfile2.to_csv(filenameout, index=False,
                       header=Outhead, encoding='utf-8')


if __name__ == '__main__':
    # 使用ａｒｉｍａ＿ｏｕｔ．ｃｓｖ中的模型风速替换预报风速
    # flists = ["ecmwf_aletai_201802.csv",
    #           "ecmwf_aletai_201902.csv",
    #           "ecmwf_aletai_202002.csv",
    #           "ecmwf_aletai_202102.csv"]
    # flists = ["ecmwf_diqingyuan_202102.csv"]
    # flists = ["ecmwf_jianggongling_202102_85m.csv"]
    # flists = ["ecmwf_xinjiangsantanghu1qi_202202_result.csv"]
    # flists = ["ecmwf_Naomaohu_202202_result.csv"]
    flists = ["ecmwf_NewHuadiankushui_202202_result.csv"]
    for fname in flists:
        # fname = "ecmwf_aletai_201802.csv"
        # print(fname)
        ipath = "./text/"
        outpath = "./text1hour/"
        interpolate(filename=fname, inpath=ipath,
                    outpath=outpath, intervals='60min')
