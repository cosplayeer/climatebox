# encoding=utf-8
from email.quoprimime import header_check
import json
import pandas as pd
from datetime import datetime, timedelta
import matplotlib.pyplot as plt
import os
import math
import numpy as np
from sklearn.metrics import r2_score

data_process = os.path.join("data", "data_after_process")


def calculateRMSE(df: pd.DataFrame):
    df.columns = ['x', 'y']
    r = ((df.y - df.x) ** 2).mean() ** .5
    return r

# 计算相关度


def computeCorrelation(x, y):
    xBar = np.mean(x)
    yBar = np.mean(y)
    SSR = 0.0
    varX = 0.0
    varY = 0.0
    for i in range(0, len(x)):
        diffXXbar = x[i] - xBar
        difYYbar = y[i] - yBar
        SSR += (diffXXbar * difYYbar)
        varX += diffXXbar**2
        varY += difYYbar**2
    SST = math.sqrt(varX * varY)
    return SSR/SST


class Radiation:
    def __init__(self, startyear, startmonth, startday, endyear, endmonth, endday, dtype) -> None:
        self.startyear = startyear
        self.startmonth = startmonth
        self.startday = startday
        self.endyear = endyear
        self.endmonth = endmonth
        self.endday = endday
        self.dtype = dtype

    def readinObs(self, fname: str):
        df = pd.read_csv(os.path.join(data_process, "EPW", fname),
                         index_col=0, usecols=[0, 1],
                         skiprows=1,
                         names=['Timeinfo', 'GHI_obs'])
        df.index = pd.to_datetime(df.index)
        s = df.loc[(df.index < datetime(self.endyear, self.endmonth, self.endday)) &
                   (df.index >= datetime(self.startyear, self.startmonth, self.startday))]
        return s
    # SolarChina 0.01

    def readinSC(self, fname: str):
        df = pd.read_csv(os.path.join(data_process, "SolarChina", "hourly", fname),
                         index_col=0, usecols=[0, 1],
                         skiprows=1,
                         names=['Timeinfo', 'GHI_SC'])
        df.index = pd.to_datetime(df.index)
        s = df.loc[(df.index < datetime(self.endyear, self.endmonth, self.endday)) &
                   (df.index >= datetime(self.startyear, self.startmonth, self.startday))]
        return s

    def readinMerra2(self, fname: str):
        df = pd.read_csv('data/ninja/'+fname,
                         index_col=0, usecols=[0, 1],
                         skiprows=1,
                         names=['Timeinfo', 'GHI_Merra2'])
        df.index = pd.to_datetime(df.index)
        s = df.loc[(df.index < datetime(self.endyear, self.endmonth, self.endday)) &
                   (df.index >= datetime(self.startyear, self.startmonth, self.startday))]
        return s

    def readinMeteoNorm(self, fname: str):
        df = pd.read_csv('data/'+fname,
                         index_col=0, usecols=[0, 1],
                         skiprows=13,
                         names=['Timeinfo', 'GHI_MeteoNorm'])
        df.index = pd.to_datetime(df.index)
        s = df.loc[(df.index < datetime(self.endyear, self.endmonth, self.endday)) &
                   (df.index >= datetime(self.startyear, self.startmonth, self.startday))]
        return s

    def readinNSRDB(self, fname: str):
        df = pd.read_csv('data/'+fname,
                         usecols=[0, 1, 2, 3, 7],
                         skiprows=3,
                         names=['year', 'month', 'day', 'HH', 'GHI_NSRDB'])
        df['date'] = df['year'].map(
            str) + "/"+df['month'].map(str)+"/"+df['day'].map(str)
        df['datetime'] = pd.to_datetime(
            df['date'])+pd.TimedeltaIndex(df['HH'], unit='H')
        df = df.drop(['year', 'month', 'day', 'HH', 'date'], axis=1)
        df = df.set_index('datetime')
        s = df.loc[(df.index < datetime(self.endyear, self.endmonth, self.endday)) &
                   (df.index >= datetime(self.startyear, self.startmonth, self.startday))]
        return s

    def readinCams(self, fname: str):
        df = pd.read_csv('data/'+fname,
                         index_col=0, usecols=[0, 2],
                         skiprows=38,
                         names=['Timeinfo', 'GHI_cams'],
                         sep=';')
        df.index = pd.to_datetime(df.index) - timedelta(hours=5)

        df.index = pd.to_datetime(df.index)
        s = df.loc[(df.index < datetime(self.endyear, self.endmonth, self.endday)) &
                   (df.index >= datetime(self.startyear, self.startmonth, self.startday))]
        return s

    def readinERA5AndCAMS(self, fnameERA5, fnameCAMS):
        df_era5 = self.readinERA5(fname=fnameERA5)
        df_cams = self.readinCams(fname=fnameCAMS)
        df = pd.concat([df_era5, df_cams], axis=1)
        df['GHI_era5_cams'] = (df['GHI_ERA5_ssrc'] + df['GHI_cams']) / 2
        df2 = df.drop(labels='GHI_ERA5_ssrc', axis=1)
        df2 = df2.drop(labels='GHI_cams', axis=1)
        # print(df2)
        return df2
    # todo

    def readinERA5AndCFSv2(self, fnameERA5, fnameCFS):
        df_era5 = self.readinERA5(fname=fnameERA5)
        df_cams = self.readinCFSv2(fname=fnameCFS)
        df = pd.concat([df_era5, df_cams], axis=1)
        df['GHI_era5_cfs'] = (df['GHI_ERA5_ssrc'] + df['GHI_CFSv2']) / 2
        df2 = df.drop(labels='GHI_ERA5_ssrc', axis=1)
        df2 = df2.drop(labels='GHI_CFSv2', axis=1)
        # print(df2)
        return df2

    def readinCAMSAndCFSv2(self, fnameCAMS, fnameCFS):
        df_cams = self.readinCams(fname=fnameCAMS)
        df_cfs = self.readinCFSv2(fname=fnameCFS)
        df = pd.concat([df_cams, df_cfs], axis=1)
        df['GHI_cams_cfs'] = (df['GHI_cams'] + df['GHI_CFSv2']) / 2
        df2 = df.drop(labels='GHI_cams', axis=1)
        df2 = df2.drop(labels='GHI_CFSv2', axis=1)
        # print(df2)
        return df2

    def readinERA5(self, fname: str):
        df = pd.read_csv(os.path.join(data_process, "ERA5", fname),
                         #  index_col=0, usecols=[0, 1, 2, 3],
                         #  index_col=0, usecols=[0, 2],
                         index_col=0, usecols=[0, 1],
                         skiprows=1,
                         names=['Timeinfo',  'GHI_ERA5_ssrc'])
        # names = ['Timeinfo', 'GHI_ERA5_ssrd', 'GHI_ERA5_ssrc', 'GHI_ERA5_ssr'])
        df.index = pd.to_datetime(df.index)
        s = df.loc[(df.index < datetime(self.endyear, self.endmonth, self.endday)) &
                   (df.index >= datetime(self.startyear, self.startmonth, self.startday))]
        return s

    def readinCFSv2(self, fname: str):
        df = pd.read_csv('text/'+fname,
                         #  index_col=0, usecols=[0, 1, 2, 3],
                         index_col=0, usecols=[0, 1],
                         skiprows=1,
                         names=['Timeinfo',  'GHI_CFSv2'])
        # names = ['Timeinfo', 'GHI_ERA5_ssrd', 'GHI_ERA5_ssrc', 'GHI_ERA5_ssr'])
        df.index = pd.to_datetime(df.index)
        s = df.loc[(df.index < datetime(self.endyear, self.endmonth, self.endday)) &
                   (df.index >= datetime(self.startyear, self.startmonth, self.startday))]
        return s

# sheet 1

    def processSumMonth(self, fname, fname2=''):
        s = dict()
        if self.dtype == 'obs':
            df = self.readinObs(fname)
        elif self.dtype == 'meteonorm':
            df = self.readinMeteoNorm(fname)
        elif self.dtype == 'era5':
            df = self.readinERA5(fname)
        elif self.dtype == 'cams':
            df = self.readinCams(fname)
        elif self.dtype == 'cfsv2':
            df = self.readinCFSv2(fname)
        elif self.dtype == 'Era5Cfsv2':
            df = self.readinERA5AndCFSv2(fname, fname2)
        elif self.dtype == 'Era5Cams':
            df = self.readinERA5AndCAMS(fname, fname2)
        elif self.dtype == 'CamsCFSv2':
            df = self.readinCAMSAndCFSv2(fname, fname2)
        elif self.dtype == 'NSRDB':
            df = self.readinNSRDB(fname)
        elif self.dtype == 'SC':
            df = self.readinSC(fname)
        elif self.dtype == 'Merra2':
            df = self.readinMerra2(fname)
        for imonth in range(1, 13):
            startdate = datetime(self.startyear, imonth, self.startday)
            todate = startdate + pd.tseries.offsets.DateOffset(months=1)
            _idata = df.loc[(df.index < todate) &
                            (df.index >= startdate)]
            # test
            # s[imonth] = todate
            # real
            if self.dtype == 'obs':
                s[str(imonth)] = '{:.2f}'.format(
                    _idata['GHI_obs'].sum() / 1000)
            elif self.dtype == 'era5':
                s[str(imonth)] = '{:.2f}'.format(
                    _idata['GHI_ERA5_ssrc'].sum() / 1000)
            elif self.dtype == 'meteonorm':
                s[str(imonth)] = '{:.2f}'.format(
                    _idata['GHI_MeteoNorm'].sum() / 1000)
            elif self.dtype == 'cams':
                s[str(imonth)] = '{:.2f}'.format(
                    _idata['GHI_cams'].sum() / 1000)
            elif self.dtype == 'cfsv2':
                s[str(imonth)] = '{:.2f}'.format(
                    _idata['GHI_CFSv2'].sum() / 1000)
            elif self.dtype == 'Era5Cfsv2':
                s[str(imonth)] = '{:.2f}'.format(
                    _idata['GHI_era5_cfs'].sum() / 1000)
            elif self.dtype == 'Era5Cams':
                s[str(imonth)] = '{:.2f}'.format(
                    _idata['GHI_era5_cams'].sum() / 1000)
            elif self.dtype == 'CamsCFSv2':
                s[str(imonth)] = '{:.2f}'.format(
                    _idata['GHI_cams_cfs'].sum() / 1000)
            elif self.dtype == 'NSRDB':
                s[str(imonth)] = '{:.2f}'.format(
                    _idata['GHI_NSRDB'].sum() / 1000)
            elif self.dtype == 'SC':
                s[str(imonth)] = '{:.2f}'.format(
                    _idata['GHI_SC'].sum() / 1000)
            elif self.dtype == 'Merra2':
                s[str(imonth)] = '{:.2f}'.format(
                    _idata['GHI_Merra2'].sum() / 1000)

        # s to csv
        s['13'] = '{:.2f}'.format(self.processSumYear(fname, fname2))
        s2 = pd.DataFrame.from_dict(s, orient='index')
        if 'ecmwf_radiation' in fname:
            if 'CAMS' in fname2:
                s2.to_csv('text/Monthly_ERA5_CAMS'+fname)
            elif 'cfsv2' in fname2:
                s2.to_csv('text/Monthly_ERA5_CFSV2'+fname)
            else:
                s2.to_csv('text/Monthly'+fname)
        if 'CAMS' in fname and 'cfsv2' in fname2:
            s2.to_csv('text/Monthly_CAMS_CFSv2'+fname)

        else:
            s2.to_csv('text/Monthly'+fname)

        # return s

    def processSumYear(self, fname, fname2=''):
        if self.dtype == 'obs':
            df = self.readinObs(fname)
            result = df['GHI_obs'].sum() / 1000
        elif self.dtype == 'meteonorm':
            df = self.readinMeteoNorm(fname)
            result = df['GHI_MeteoNorm'].sum() / 1000
        elif self.dtype == 'era5':
            df = self.readinERA5(fname)
            result = df['GHI_ERA5_ssrc'].sum() / 1000
        elif self.dtype == 'cams':
            df = self.readinCams(fname)
            result = df['GHI_cams'].sum() / 1000
        elif self.dtype == 'cfsv2':
            df = self.readinCFSv2(fname)
            result = df['GHI_CFSv2'].sum() / 1000
        elif self.dtype == 'Era5Cfsv2':
            df = self.readinERA5AndCFSv2(fname, fname2)
            result = df['GHI_era5_cfs'].sum() / 1000
        elif self.dtype == 'Era5Cams':
            df = self.readinERA5AndCAMS(fname, fname2)
            result = df['GHI_era5_cams'].sum() / 1000
        elif self.dtype == 'CamsCFSv2':
            df = self.readinCAMSAndCFSv2(fname, fname2)
            result = df['GHI_cams_cfs'].sum() / 1000
        elif self.dtype == 'NSRDB':
            df = self.readinNSRDB(fname)
            result = df['GHI_NSRDB'].sum() / 1000
        elif self.dtype == 'SC':
            df = self.readinSC(fname)
            result = df['GHI_SC'].sum() / 1000
        elif self.dtype == 'Merra2':
            df = self.readinMerra2(fname)
            result = df['GHI_Merra2'].sum() / 1000
        # print(result)
        return result

    # sheet 2

    def RMSEwithObs(self, fname, obsname, fname2=''):
        s = {}
        dfObs = self.readinObs(obsname)
        resultObs = dfObs['GHI_obs'].sum() / 1000
        if self.dtype == 'Era5Cams':
            dfRad = self.readinERA5AndCAMS(fname, fname2)
        if self.dtype == 'Era5Cfsv2':
            dfRad = self.readinERA5AndCFSv2(fname, fname2)
        if self.dtype == 'CamsCFSv2':
            dfRad = self.readinCAMSAndCFSv2(fname, fname2)
        elif self.dtype == 'meteonorm':
            dfRad = self.readinMeteoNorm(fname)
        elif self.dtype == 'era5':
            dfRad = self.readinERA5(fname)
            resultERA5 = dfRad['GHI_ERA5_ssrc'].sum() / 1000
            # for test
            print('resultObs: %s' % resultObs)
            print('resultERA5: %s' % resultERA5)
            bias = (resultERA5 - resultObs) / resultObs * 100
        elif self.dtype == 'cams':
            dfRad = self.readinCams(fname)
        elif self.dtype == 'cfsv2':
            dfRad = self.readinCFSv2(fname)
        elif self.dtype == 'NSRDB':
            dfRad = self.readinNSRDB(fname)
        elif self.dtype == 'SC':
            dfRad = self.readinSC(fname)
            resultSC = dfRad['GHI_SC'].sum() / 1000
            print('resultSC: %s' % resultSC)
            bias = (resultSC - resultObs)/resultObs * 100
        elif self.dtype == 'Merra2':
            dfRad = self.readinMerra2(fname)
        dfObs_reindex = dfObs.reindex(dfRad.index)
        df = pd.concat([dfObs_reindex, dfRad], axis=1)

        # for imonth in range(1, 13):
        #     startdate = datetime(self.startyear, imonth, self.startday)
        #     todate = startdate + pd.tseries.offsets.DateOffset(months=1)
        #     _idata = df.loc[(df.index < todate) &
        #                     (df.index >= startdate)]

        #     s[str(imonth)] = '{:.2f}'.format(calculateRMSE(_idata))
        # # s to csv
        # s['13'] = '{:.2f}'.format(calculateRMSE(df))

        _rmse = '{:.2f}'.format(calculateRMSE(df))
        _bias = '%.2f' % bias
        df = df.dropna(axis=0)
        # r2 = r2_score(df.iloc[:, 0], df.iloc[:, 1])
        # _r2 = '%.2f' % r2
        r = computeCorrelation(df.iloc[:, 0], df.iloc[:, 1])
        r2_new = '%.2f' % (r*r)
        # corr_matrix = np.corrcoef(df.iloc[:, 0], df.iloc[:, 1])
        # corr = corr_matrix[0, 1]
        # R_sq = '%.2f' % corr**2
        result = {self.dtype: {'bias': _bias,
                               'rmse': _rmse,
                               #    'r2_sklearn': _r2,
                               #    'r2_numpy': R_sq,
                               'r2_new': r2_new}}

        # print('bias: %s' % _bias)
        return result


if __name__ == '__main__':
    # test era5 rmse
    obspath = os.path.join(data_process, "EPW")
    obslists = os.listdir(obspath)
    result = {}
    for obsname in obslists:
        # if obsname == 'EPW_CHN_GD_Heyuan_592930_TMYx_2004-2018_23.8_114.7333.csv':
        # if obsname == 'EPW_CHN_GZ_Tongzi_576060_CSWD_28.13333_106.8333.csv':
        testERA5 = Radiation(startyear=2005, startmonth=1, startday=1,
                             endyear=2006, endmonth=1, endday=1, dtype='era5')
        # testSC.processSumMonth(fname='ninja_linuo_43.0364_93.6184_uncorrected.csv')
        era5dict = testERA5.RMSEwithObs(fname='ERA5_'+obsname,
                                        obsname=obsname)
        # test SolarChina rmse
        testSC = Radiation(startyear=2005, startmonth=1, startday=1,
                           endyear=2006, endmonth=1, endday=1, dtype='SC')
        # testSC.processSumMonth(fname='ninja_linuo_43.0364_93.6184_uncorrected.csv')
        scdict = testSC.RMSEwithObs(fname='SolarChina_'+obsname,
                                    obsname=obsname)
        key = obsname.split('.csv')[0]
        r = {key: (
            era5dict, scdict)}
        # 最简单的就是在这里判断异常的r，
        # 偏差太大的和负值的都不 update．
        print(r)
        if (abs(float(r[key][0]['era5']['bias'])) < 100
                and abs(float(r[key][1]['SC']['bias'])) < 100):
            # and abs(float(r[key][0]['era5']['r2'])) > 0
            #     and abs(float(r[key][1]['SC']['r2'])) > 0):
            result.update(r)
        # print(result['EPW_CHN_HB_Wuhan_574940_CSWD_30.61667_114.1333']
        #       [0]['era5']['bias'])
    # 输出 csv from json
    import csv
    # with open("text/statistics.txt", "r") as fr:
    #     data = json.load(fr)
    # print(type(data))
    data = result
    if not data is None:
        with open(os.path.join("text", "statistics_solarR2_new.csv"), "w+") as f:
            csv_writer = csv.writer(f)
            count = 0
            # csv_writer.writerow(['stationId', 'biasERA5',
            #                     'biasSolarChina', 'rmseERA5', 'rmseSolarChina', 'r2_sklearnERA5', 'r2_sklearnSolarChina',
            #                      'r2_numpyERA5', 'r2_numpySolarChina', 'r2ERA5new', 'r2SolarChinanew'])
            csv_writer.writerow(['stationId', 'lat', 'lon', 'biasERA5',
                                'biasSolarChina', 'rmseERA5', 'rmseSolarChina', 'r2ERA5', 'r2SolarChina'])
            for emp in data:
                # todo:把合格的列名输出到文本
                print('emp:%s' % emp)
                csv_writer.writerow(['_'.join(str(emp).split('_')[1:-2]),
                                    str(emp).split('_')[-2],
                                    str(emp).split('_')[-1],
                                    data[emp][0]['era5']['bias'], data[emp][1]['SC']['bias'],
                                    data[emp][0]['era5']['rmse'], data[emp][1]['SC']['rmse'],
                                    # data[emp][0]['era5']['r2_sklearn'], data[emp][1]['SC']['r2_sklearn'],
                                     # data[emp][0]['era5']['r2_numpy'], data[emp][1]['SC']['r2_numpy'],
                                     data[emp][0]['era5']['r2_new'], data[emp][1]['SC']['r2_new']])
    else:
        print("data is None")
