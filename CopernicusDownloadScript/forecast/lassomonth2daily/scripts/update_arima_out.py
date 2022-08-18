# coding=utf-8
import os
import pandas as pd
from configparser import ConfigParser


def getdf(fname, fmonth):
    # merge && readin csvs
    csvdir = "./text"
    flists = ["arima_out_wind"+str(fmonth)+"_"+fname+".csv"]

    df = pd.DataFrame(columns=['speed'], dtype=object)
    for i in range(len(flists)):
        a1 = os.path.join(csvdir, flists[i])
        data1 = pd.read_csv(a1, skiprows=1, header=None, index_col=0,
                            usecols=[0, 1], names=['Timeinfo', 'speed'])
        df = df.append(data1, ignore_index=False)

    df.index = pd.to_datetime(df.index)

    # _ts = df['speed']
    return df


def getdfProphet(fname, fmonth):
    # merge && readin txts
    csvdir = "./text"
    flists = ["prophet_out_wind_obs"+str(fmonth)+fname+"UTC0-1hourly.txt"]

    # ignore columns names, user defined column names was used.
    df = pd.DataFrame(columns=['speed'], dtype=object)
    for i in range(len(flists)):
        a1 = os.path.join(csvdir, flists[i])
        data1 = pd.read_csv(a1, skiprows=1, header=None, index_col=0,
                            usecols=[0, 1], names=['Timeinfo', 'speed'])
        df = df.append(data1, ignore_index=False)

    df.index = pd.to_datetime(df.index)
    return df


def ec_before(fname, fmonth, ecstep):
    # merge && readin csvs
    if ecstep == '1hour':
        csvdir = "./text1hour"
    elif ecstep == '6hour':
        ecsdir = "./text"
    flists = ["ecmwf_"+fname + "_" + str(fmonth)+".csv"]

    df = pd.DataFrame(columns=['WindSpeedXm', 'WindDirection10m',
                      'Temperature2m', 'Pressure10m', 'Airdensity'], dtype=object)
    for i in range(len(flists)):
        a1 = os.path.join(csvdir, flists[i])
        data1 = pd.read_csv(a1, skiprows=1, header=None, index_col=0,
                            usecols=[0, 1, 2, 3, 4, 5], names=['Timeinfo', 'WindSpeedXm', 'WindDirection10m',
                                                               'Temperature2m', 'Pressure10m', 'Airdensity'])
        df = df.append(data1, ignore_index=False)

    df.index = pd.to_datetime(df.index)

    # _ts = df['speed']
    return df
# 循环，批量寻找同时期的资料并替换
# 输出ｃｓｖ


def replace(station, timemonth, method='prophet', ecstep='6hour'):
    # arima_out_wind202207_Naomaohu.csv
    if method == 'prophet':
        rep = getdfProphet(station, timemonth)
    elif method == 'arima':
        rep = getdf(station, timemonth)
    # print(ts)
    # ecmwf_Naomaohu_202207.csv
    ec1 = ec_before(station, timemonth, ecstep=ecstep)
    # ec1_df = pd.to_datetime(ec1)
    for index1, rows1 in ec1.iterrows():
        for index2, rows2 in rep.iterrows():
            if index1 == index2:
                ec1.loc[index1, 'WindSpeedXm'] = rep.loc[index1, 'speed']
    # print(ec1)
    # 返回before以后的数据　＃after返回以前的数据
    _result = (ec1.truncate(before=str(timemonth) + '01'))
    return _result


def updateECcsv():
    # outname = station
    # ec_after = replace(station, timemonth)
    from configs import getconfig
    from pchip import pchipfile
    outname, year2, wdays, fmonth = getconfig()
    timemonth = str(year2) + '%02d' % (fmonth)
    # 使用ａｒｉｍａ模式结果风速替换ｅｃ本身的风速预报结果，生成updatec.csv文件
    ec_after = replace(outname, timemonth)
    Outhead = [
        'WindSpeedXm', 'WindDirection10m', 'Temperature2m', 'Pressure10m', 'Airdensity']
    outpath = './text/'
    filename = 'ecmwf_' + outname + '_' + \
        str(timemonth)+'_updatec.csv'
    filenameout = os.path.join(outpath, filename)
    ec_after.to_csv(filenameout, index=True,
                    header=Outhead, encoding='utf-8')
    # 6 hourly 转换逐小时
    pchipfile(filename)


def updateECcsvProphet(method, ecstep):
    # outname = station
    # ec_after = replace(station, timemonth)
    from configs import getconfigProphet
    from pchip import pchipfile
    outname, year, fmonth = getconfigProphet()
    timemonth = str(year) + '%02d' % (fmonth)
    # 1.对ec原始数据进行差值为逐小时
    # 6 hourly ec 原始预报转换逐小时
    _ecfile = 'ecmwf_' + outname + '_' + str(timemonth) + '.csv'
    pchipfile(_ecfile)

    # 2. 使用ａｒｉｍａ模式结果风速替换ｅｃ本身的风速预报结果，生成updatec.csv文件
    ec_after = replace(outname, timemonth, method=method, ecstep=ecstep)
    Outhead = [
        'WindSpeedXm', 'WindDirection10m', 'Temperature2m', 'Pressure10m', 'Airdensity']
    outpath = './text/'
    filename = 'ecmwf_' + outname + '_' + \
        str(timemonth)+'_prophet_updatec.csv'
    filenameout = os.path.join(outpath, filename)
    ec_after.to_csv(filenameout, index=True,
                    header=Outhead, encoding='utf-8')


def test():
    data1 = {'year': [2001, 2002, 2003, 2004], 'numbers': [
        'one', 'two', 'three', 'four'], 'ages': [13, 14, 15, 16]}
    data2 = {'year': [2001, 2002, 2003, 2004], 'numbers': [
        'one', 'two', 'three', 'four'], 'ages': [23, 24, 25, 26]}
    df1 = pd.DataFrame(data1)
    df2 = pd.DataFrame(data2)
    # df3 = df1.copy()
    print(df1)
    for index1, rows1 in df1.iterrows():
        for index2, rows2 in df2.iterrows():
            if index1 == index2:
                df1.loc[index1, 'ages'] = df2.loc[index1, 'ages']
    print(df1)


if __name__ == '__main__':
    # test()
    # outputcsv(station="Naomaohu", timemonth=202207)
    # updateECcsv()
    updateECcsvProphet(method='prophet', ecstep='1hour')
