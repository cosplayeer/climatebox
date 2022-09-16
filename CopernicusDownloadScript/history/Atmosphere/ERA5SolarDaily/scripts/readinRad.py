import pandas as pd
from datetime import datetime, timedelta
import matplotlib.pyplot as plt

startyear = 2018
startmonth = 12
startday = 22
endyear = 2018
endmonth = 12
endday = 23
pngsuffix = '_dongzhi'


def readinObs(fname):
    df = pd.read_csv('data/'+fname,
                     index_col=0, usecols=[0, 1],
                     skiprows=1,
                     names=['Timeinfo', 'GHI_obs'])
    df.index = pd.to_datetime(df.index)
    s = df.loc[(df.index < datetime(endyear, endmonth, endday)) &
               (df.index >= datetime(startyear, startmonth, startday))]
    return s


def readinERA5(fname):
    df = pd.read_csv('text/'+fname,
                     #  index_col=0, usecols=[0, 1, 2, 3],
                     index_col=0, usecols=[0, 2],
                     skiprows=1,
                     names=['Timeinfo',  'GHI_ERA5_ssrc'])
    # names = ['Timeinfo', 'GHI_ERA5_ssrd', 'GHI_ERA5_ssrc', 'GHI_ERA5_ssr'])
    df.index = pd.to_datetime(df.index)
    s = df.loc[(df.index < datetime(endyear, endmonth, endday)) &
               (df.index >= datetime(startyear, startmonth, startday))]
    return s


def readinMeteoNorm(fname):
    df = pd.read_csv('data/'+fname,
                     index_col=0, usecols=[0, 1],
                     skiprows=13,
                     names=['Timeinfo', 'GHI_MeteoNorm'])
    df.index = pd.to_datetime(df.index)
    s = df.loc[(df.index < datetime(endyear, endmonth, endday)) &
               (df.index >= datetime(startyear, startmonth, startday))]
    return s


def readinWrf(fname):
    df = pd.read_csv('data/'+fname,
                     index_col=0, usecols=[0, 9],
                     skiprows=10,
                     names=['Timeinfo', 'GHI_wrf'])
    df.index = pd.to_datetime(df.index)
    s = df.loc[(df.index < datetime(endyear, endmonth, endday)) &
               (df.index >= datetime(startyear, startmonth, startday))]
    return s


def readinCams(fname):
    df = pd.read_csv('data/'+fname,
                     index_col=0, usecols=[0, 2],
                     skiprows=38,
                     names=['Timeinfo', 'GHI_cams'],
                     sep=';')
    df.index = pd.to_datetime(df.index) - timedelta(hours=5)

    s = df.loc[(df.index < datetime(endyear, endmonth, endday)) &
               (df.index >= datetime(startyear, startmonth, startday))]
    # return s
    return s


if __name__ == '__main__':
    # obs hourly1
    # f1a = readinObs('新疆东方民生石城子2018UTC0-Exported.txt')
    # f2a = readinObs('新疆福新木垒光伏一电站2018UTC0-Exported.txt')
    # f3a = readinObs('新疆力诺石城子2018UTC0-Exported.txt')
    # obs hourly2
    f1a = readinObs('新疆东方民生石城子_1h-UTC0Exported.txt')
    f2a = readinObs('福新木垒光伏一电站_1h-UTC0Exported.txt')
    f3a = readinObs('新疆力诺石城子_1h-UTC0Exported.txt')
    # wrf
    # dongfang
    # f1b = readinWrf('testRadiation_[(93.585,43.009),1,100]_mos0.csv')
    # # xinmulei
    # f2b = readinWrf('testRadiation_[(90.291,44.046),1,100]_mos0.csv')
    # # linuo
    # f3b = readinWrf('testRadiation_[(93.618,43.036),1,100]_mos0.csv')
    # ERA5
    # dongfang
    # f1c = readinERA5('ecmwf_radiation_dongfang.csv')
    # # fuxinmulei
    # f2c = readinERA5('ecmwf_radiation_fuxin.csv')
    # # linuo
    # f3c = readinERA5('ecmwf_radiation_linuo.csv')
    # ERA5 xiazhi
    f1c = readinERA5('ecmwf_radiation_dongfang'+pngsuffix+'.csv')
    # fuxinmulei
    f2c = readinERA5('ecmwf_radiation_fuxin'+pngsuffix+'.csv')
    # linuo
    f3c = readinERA5('ecmwf_radiation_linuo'+pngsuffix+'.csv')
    # MeteoNorm
    # dongfang
    # f1d = readinMeteoNorm(
    #     'meteonorm东方民生石城子_TimeseriesByArrayUTC0-Exported.txt')
    # # fuxinmulei
    # f2d = readinMeteoNorm('meteonorm福新木垒_TimeseriesByArrayUTC0-Exported.txt')
    # # linuo
    # f3d = readinMeteoNorm('meteonorm力诺石城子_TimeseriesByArrayUTC0-Exported.txt')
    f1d = readinMeteoNorm('MeteoNorm东方民生石城子_TimeseriesByArray-Exported.txt')
    print(f1d)
    f2d = readinMeteoNorm('MeteoNorm福新木垒_TimeseriesByArray-Exported.txt')
    f3d = readinMeteoNorm('MeteoNorm力诺石城子_TimeseriesByArray-Exported.txt')
    # cams
    # dongfang
    # f1e = readinCams('CAMSdongfangminsheng.csv')
    # f2e = readinCams('CAMSfuxinmulei.csv')
    # f3e = readinCams('CAMSlinuo.csv')
    result1 = pd.concat([f1a,  f1c, f1d], axis=1)
    result1.plot(x_compat=True).get_figure().savefig(
        'png/x1_dongfang_1h'+pngsuffix+'.png')

    result2 = pd.concat([f2a,  f2c, f2d], axis=1)
    result2.plot(x_compat=True).get_figure().savefig(
        'png/x2_xinmulei_1h'+pngsuffix+'.png')

    result3 = pd.concat([f3a,  f3c, f3d], axis=1)
    result3.plot(x_compat=True).get_figure().savefig(
        'png/x3_linuo_1h'+pngsuffix+'.png')
