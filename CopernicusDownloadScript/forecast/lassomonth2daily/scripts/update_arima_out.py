# coding=utf-8
import os
import pandas as pd


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


def ec_before(fname, fmonth):
    # merge && readin csvs
    csvdir = "./text"
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


def replace(station, timemonth):
    _timemonth = timemonth
    # arima_out_wind202207_Naomaohu.csv
    rep = getdf(station, _timemonth)
    # print(ts)
    # ecmwf_Naomaohu_202207.csv
    ec1 = ec_before(station, _timemonth)
    # ec1_df = pd.to_datetime(ec1)
    for index1, rows1 in ec1.iterrows():
        for index2, rows2 in rep.iterrows():
            if index1 == index2:
                ec1.loc[index1, 'WindSpeedXm'] = rep.loc[index1, 'speed']
    # print(ec1)
    # 返回before以后的数据　＃after返回以前的数据
    _result = (ec1.truncate(before=str(_timemonth) + '01'))
    return _result


def outputcsv(station, timemonth):
    outname = station
    ec_after = replace(station, timemonth)
    Outhead = [
        'WindSpeedXm', 'WindDirection10m', 'Temperature2m', 'Pressure10m', 'Airdensity']
    outpath = './text/'
    filename = 'ecmwf_' + outname + '_' + \
        str(timemonth)+'_updatec.csv'
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
    outputcsv(station="Naomaohu", timemonth=202207)
    # print(ec_after)
