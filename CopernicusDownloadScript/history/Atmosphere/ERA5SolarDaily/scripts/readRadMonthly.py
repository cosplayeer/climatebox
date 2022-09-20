import pandas as pd
from datetime import datetime, timedelta
import matplotlib.pyplot as plt


def calculateRMSE(df: pd.DataFrame):
    df.columns = ['x', 'y']
    r = ((df.y - df.x) ** 2).mean() ** .5
    return r


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
        df = pd.read_csv('data/'+fname,
                         index_col=0, usecols=[0, 1],
                         skiprows=1,
                         names=['Timeinfo', 'GHI_obs'])
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
        df = pd.read_csv('text/'+fname,
                         #  index_col=0, usecols=[0, 1, 2, 3],
                         index_col=0, usecols=[0, 2],
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
    # sheet 2

    def RMSEwithObs(self, fname, obsname, fname2=''):
        s = {}
        dfObs = self.readinObs(obsname)
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
        elif self.dtype == 'cams':
            dfRad = self.readinCams(fname)
        elif self.dtype == 'cfsv2':
            dfRad = self.readinCFSv2(fname)
        df = pd.concat([dfObs, dfRad], axis=1)
        # print(calculateRMSE(df))
        # print(df)
        for imonth in range(1, 13):
            startdate = datetime(self.startyear, imonth, self.startday)
            todate = startdate + pd.tseries.offsets.DateOffset(months=1)
            _idata = df.loc[(df.index < todate) &
                            (df.index >= startdate)]

            s[str(imonth)] = '{:.2f}'.format(calculateRMSE(_idata))
        # s to csv
        s['13'] = '{:.2f}'.format(calculateRMSE(df))
        s2 = pd.DataFrame.from_dict(s, orient='index')
        if 'ecmwf_radiation' in fname:
            if 'CAMS' in fname2:
                s2.to_csv('text/RMSE_ERA5_CAMS'+fname)
            elif 'cfsv2' in fname2:
                s2.to_csv('text/RMSE_ERA5_CFSV2'+fname)
            else:
                s2.to_csv('text/RMSE'+fname)
        if 'CAMS' in fname and 'cfsv2' in fname2:
            s2.to_csv('text/RMSE_CAMS_CFSv2'+fname)
        else:
            s2.to_csv('text/RMSE'+fname)
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
        # print(result)
        return result


# month mean bias
# obs = Radiation(startyear=2018, startmonth=1, startday=1,
#                 endyear=2019, endmonth=1, endday=1, dtype='obs')
# obs.processSumMonth(fname='新疆东方民生石城子_1h-UTC0Exported.txt')
# obs.processSumMonth(fname='福新木垒光伏一电站_1h-UTC0Exported.txt')
# obs.processSumMonth(fname='新疆力诺石城子_1h-UTC0Exported.txt')

# era5 = Radiation(startyear=2018, startmonth=1, startday=1,
#                  endyear=2019, endmonth=1, endday=1, dtype='era5')
# era5.processSumMonth(fname='ecmwf_radiation_dongfang_demo.csv')
# era5.processSumMonth(fname='ecmwf_radiation_fuxin_demo.csv')
# era5.processSumMonth(fname='ecmwf_radiation_linuo_demo.csv')

# mn = Radiation(startyear=2018, startmonth=1, startday=1,
#                endyear=2019, endmonth=1, endday=1, dtype='meteonorm')
# mn.processSumMonth(
#     fname='MeteoNorm东方民生石城子_TimeseriesByArray-Exported.txt')
# mn.processSumMonth(fname='MeteoNorm福新木垒_TimeseriesByArray-Exported.txt')
# mn.processSumMonth(fname='MeteoNorm力诺石城子_TimeseriesByArray-Exported.txt')

# cams = Radiation(startyear=2018, startmonth=1, startday=1,
#                  endyear=2019, endmonth=1, endday=1, dtype='cams')
# cams.processSumMonth(
#     fname='CAMSdongfangminshengYear2018.csv')
# cams.processSumMonth(fname='CAMSfuxinmuleiYear2018.csv')
# cams.processSumMonth(fname='CAMSlinuoYear2018.csv')


# cfs = Radiation(startyear=2018, startmonth=1, startday=1,
#                 endyear=2019, endmonth=1, endday=1, dtype='cfsv2')
# cfs.processSumMonth(
#     fname='cfsv2_radiation_dongfang_demo.csv')
# cfs.processSumMonth(fname='cfsv2_radiation_fuxin_demo.csv')
# cfs.processSumMonth(fname='cfsv2_radiation_linuo_demo.csv')

#  demo 2 input
test1 = Radiation(startyear=2018, startmonth=1, startday=1,
                  #                  # Era5Cfsv2
                  #                  #  endyear=2019, endmonth=1, endday=1, dtype='Era5Cfsv2')
                  #                  # Era5Cams
                  #                  endyear=2019, endmonth=1, endday=1, dtype='Era5Cams')
                  # CamsCFSv2
                  endyear=2019, endmonth=1, endday=1, dtype='CamsCFSv2')
test1.processSumMonth(
    # fname='ecmwf_radiation_dongfang_demo.csv',
    fname='CAMSdongfangminshengYear2018.csv',
    fname2='cfsv2_radiation_dongfang_demo.csv')
test1.processSumMonth(
    # fname='ecmwf_radiation_fuxin_demo.csv',
    fname='CAMSfuxinmuleiYear2018.csv',
    fname2='cfsv2_radiation_fuxin_demo.csv')
test1.processSumMonth(
    # fname='ecmwf_radiation_linuo_demo.csv',
    fname='CAMSlinuoYear2018.csv',
    fname2='cfsv2_radiation_linuo_demo.csv')


# sheet 2. month RMSE
# cams = Radiation(startyear=2018, startmonth=1, startday=1,
#                  endyear=2019, endmonth=1, endday=1, dtype='cams')
# cams.RMSEwithObs(fname='CAMSdongfangminshengYear2018.csv',
#                  obsname='新疆东方民生石城子_1h-UTC0Exported.txt')
# cams.RMSEwithObs(fname='CAMSfuxinmuleiYear2018.csv',
#                  obsname='福新木垒光伏一电站_1h-UTC0Exported.txt')
# cams.RMSEwithObs(fname='CAMSlinuoYear2018.csv',
#                  obsname='新疆力诺石城子_1h-UTC0Exported.txt')


# mn = Radiation(startyear=2018, startmonth=1, startday=1,
#                endyear=2019, endmonth=1, endday=1, dtype='meteonorm')
# mn.RMSEwithObs(
#     fname='MeteoNorm东方民生石城子_TimeseriesByArray-Exported.txt',
#     obsname='新疆东方民生石城子_1h-UTC0Exported.txt')
# mn.RMSEwithObs(fname='MeteoNorm福新木垒_TimeseriesByArray-Exported.txt',
#                obsname='福新木垒光伏一电站_1h-UTC0Exported.txt')
# mn.RMSEwithObs(fname='MeteoNorm力诺石城子_TimeseriesByArray-Exported.txt',
#                obsname='新疆力诺石城子_1h-UTC0Exported.txt')

# era5 = Radiation(startyear=2018, startmonth=1, startday=1,
#                  endyear=2019, endmonth=1, endday=1, dtype='era5')
# era5.RMSEwithObs(fname='ecmwf_radiation_dongfang_demo.csv',
#                  obsname='新疆东方民生石城子_1h-UTC0Exported.txt')
# era5.RMSEwithObs(fname='ecmwf_radiation_fuxin_demo.csv',
#                  obsname='福新木垒光伏一电站_1h-UTC0Exported.txt')
# era5.RMSEwithObs(fname='ecmwf_radiation_linuo_demo.csv',
#                  obsname='新疆力诺石城子_1h-UTC0Exported.txt')

# # month RMSE：　ERA5  && CAMS test
# test = Radiation(startyear=2018, startmonth=1, startday=1,
#                  endyear=2019, endmonth=1, endday=1, dtype='Era5Cams')
# test.RMSEwithObs(fname='ecmwf_radiation_dongfang_demo.csv',
#                  fname2='CAMSdongfangminshengYear2018.csv',
#                  obsname='新疆东方民生石城子_1h-UTC0Exported.txt')
# test.RMSEwithObs(fname='ecmwf_radiation_fuxin_demo.csv',
#                  fname2='CAMSfuxinmuleiYear2018.csv',
#                  obsname='福新木垒光伏一电站_1h-UTC0Exported.txt')
# test.RMSEwithObs(fname='ecmwf_radiation_linuo_demo.csv',
#                  fname2='CAMSlinuoYear2018.csv',
#                  obsname='新疆力诺石城子_1h-UTC0Exported.txt')

# month RMSE：　cfs test
# cfs = Radiation(startyear=2018, startmonth=1, startday=1,
#                 endyear=2019, endmonth=1, endday=1, dtype='cfsv2')
# cfs.RMSEwithObs(fname='cfsv2_radiation_dongfang_demo.csv',
#                 obsname='新疆东方民生石城子_1h-UTC0Exported.txt')
# cfs.RMSEwithObs(fname='cfsv2_radiation_fuxin_demo.csv',
#                 obsname='福新木垒光伏一电站_1h-UTC0Exported.txt')
# cfs.RMSEwithObs(fname='cfsv2_radiation_linuo_demo.csv',
#                 obsname='新疆力诺石城子_1h-UTC0Exported.txt')

# month RMSE：　ERA5  && CFSV2 test
# test = Radiation(startyear=2018, startmonth=1, startday=1,
#                  endyear=2019, endmonth=1, endday=1, dtype='Era5Cfsv2')
# test.RMSEwithObs(fname='ecmwf_radiation_dongfang_demo.csv',
#                  fname2='cfsv2_radiation_dongfang_demo.csv',
#                  obsname='新疆东方民生石城子_1h-UTC0Exported.txt')
# test.RMSEwithObs(fname='ecmwf_radiation_fuxin_demo.csv',
#                  fname2='cfsv2_radiation_fuxin_demo.csv',
#                  obsname='福新木垒光伏一电站_1h-UTC0Exported.txt')
# test.RMSEwithObs(fname='ecmwf_radiation_linuo_demo.csv',
#                  fname2='cfsv2_radiation_linuo_demo.csv',
#                  obsname='新疆力诺石城子_1h-UTC0Exported.txt')

# month RMSE：　ERA5  && CAMS test
# test2 = Radiation(startyear=2018, startmonth=1, startday=1,
#                  endyear=2019, endmonth=1, endday=1, dtype='Era5Cams')
# test2.RMSEwithObs(fname='ecmwf_radiation_dongfang_demo.csv',
#                  fname2='CAMSdongfangminshengYear2018.csv',
#                  obsname='新疆东方民生石城子_1h-UTC0Exported.txt')
# test2.RMSEwithObs(fname='ecmwf_radiation_fuxin_demo.csv',
#                  fname2='CAMSfuxinmuleiYear2018.csv',
#                  obsname='福新木垒光伏一电站_1h-UTC0Exported.txt')
# test2.RMSEwithObs(fname='ecmwf_radiation_linuo_demo.csv',
#                  fname2='CAMSlinuoYear2018.csv',
#                  obsname='新疆力诺石城子_1h-UTC0Exported.txt')
# month CAMS  && CFSv2 test
test2 = Radiation(startyear=2018, startmonth=1, startday=1,
                  endyear=2019, endmonth=1, endday=1, dtype='CamsCFSv2')
test2.RMSEwithObs(fname='CAMSdongfangminshengYear2018.csv',
                  fname2='cfsv2_radiation_dongfang_demo.csv',
                  obsname='新疆东方民生石城子_1h-UTC0Exported.txt')
test2.RMSEwithObs(fname='CAMSfuxinmuleiYear2018.csv',
                  fname2='cfsv2_radiation_fuxin_demo.csv',
                  obsname='福新木垒光伏一电站_1h-UTC0Exported.txt')
test2.RMSEwithObs(fname='CAMSlinuoYear2018.csv',
                  fname2='cfsv2_radiation_linuo_demo.csv',
                  obsname='新疆力诺石城子_1h-UTC0Exported.txt')
