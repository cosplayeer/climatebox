# -*-coding:utf-8-*-
import datetime as dt
import calendar
from xml.sax.saxutils import prepare_input_source
import pandas as pd
import numpy as np
# from statsmodels.tsa.arima_model import ARMA
from arima_model import ARMA
import sys
import os
from dateutil.relativedelta import relativedelta
from copy import deepcopy
import matplotlib.pyplot as plt

# observation


def getdf(fname, fmonth):
    # merge && readin csvs
    csvdir = os.path.join("text_split", fname)
    # 202105->20210x
    # 2020-0x -> 2020-0x
    # 2021-0x -> 2021-0x
    # month2->monthx
    # 03-01->0x-01
    # 03-30->0x-30
    # 28*4->31x4
    # flists = ["jianggongling2018-2021obs6hourlyUTC0month2.csv"]
    flists = [str(fmonth)]

    df = pd.DataFrame(columns=['speed'], dtype=object)
    for i in range(len(flists)):
        a1 = os.path.join(csvdir, flists[i])
        data1 = pd.read_csv(a1, skiprows=1, header=None, index_col=0,
                            usecols=[0, 1], names=['Timeinfo', 'speed'])
        df = df.append(data1, ignore_index=False)

    df.index = pd.to_datetime(df.index)
    df['speed'] = df['speed'].interpolate(method='linear')
    # df['speed'] = df['speed'].interpolate(method='spline', order=3)
    # df['speed'] = df['speed'].interpolate(method='time')
    _ts = df['speed']
    return _ts

# ecmwf forecast 10m wind.


def getdf10m(fname):
    # merge && readin csvs
    csvdir = "./text/"

    flists = [fname]  # jianggongling _bak.csv
    # flists = ["ecmwf_jianggongling_202102.csv"]

    df = pd.DataFrame(columns=['speed'], dtype=object)
    for i in range(len(flists)):
        a1 = os.path.join(csvdir, flists[i])
        data1 = pd.read_csv(a1, skiprows=1, header=None, index_col=0,
                            usecols=[0, 1], names=['Timeinfo', 'speed'])
        df = df.append(data1, ignore_index=False)

    df.index = pd.to_datetime(df.index)
    df['speed'] = df['speed'].interpolate(method='linear')
    # df['speed'] = df['speed'].interpolate(method='spline', order=3)
    # df['speed'] = df['speed'].interpolate(method='time')
    _ts = df['speed']
    # print(_ts.max())
    return _ts


class arima_model:

    def __init__(self, ts, maxLag=9):
        self.data_ts = ts
        self.resid_ts = None
        self.predict_ts = None
        self.maxLag = maxLag
        self.p = maxLag
        self.q = maxLag
        self.properModel = None
        self.bic = sys.maxsize

    # 计算最优ARIMA模型，将相关结果赋给相应属性
    def get_proper_model(self):
        self._proper_model()
        self.predict_ts = deepcopy(self.properModel.predict())
        self.resid_ts = deepcopy(self.properModel.resid)

    # 对于给定范围内的p,q计算拟合得最好的arima模型，这里是对差分好的数据进行拟合，故差分恒为0
    def _proper_model(self):
        for p in np.arange(self.maxLag):
            for q in np.arange(self.maxLag):
                # print p,q,self.bic
                model = ARMA(self.data_ts, order=(p, q))
                try:
                    results_ARMA = model.fit(disp=-1, method='css')
                except:
                    continue
                bic = results_ARMA.bic
                # print 'bic:',bic,'self.bic:',self.bic
                if bic < self.bic:
                    self.p = p
                    self.q = q
                    self.properModel = results_ARMA
                    self.bic = bic
                    self.resid_ts = deepcopy(self.properModel.resid)
                    self.predict_ts = self.properModel.predict()

    # 参数确定模型
    def certain_model(self, p, q):
        model = ARMA(self.data_ts, order=(p, q))
        try:
            self.properModel = model.fit(disp=-1, method='css')
            self.p = p
            self.q = q
            self.bic = self.properModel.bic
            self.predict_ts = self.properModel.predict()
            self.resid_ts = deepcopy(self.properModel.resid)
        except:
            print('You can not fit the model with this parameter p,q, '
                  'please use the get_proper_model method to get the best model')

    # 预测第二日的值
    def forecast_next_day_value(self, type='day'):
        # 我修改了statsmodels包中arima_model的源代码，添加了constant属性，需要先运行forecast方法，为constant赋值
        self.properModel.forecast()
        if self.data_ts.index[-1] != self.resid_ts.index[-1]:
            raise ValueError('''The index is different in data_ts and resid_ts, please add new data to data_ts.
            If you just want to forecast the next day data without add the real next day data to data_ts,
            please run the predict method which arima_model included itself''')
        if not self.properModel:
            raise ValueError(
                'The arima model have not computed, please run the proper_model method before')
        para = self.properModel.params

        # print self.properModel.params
        # It will get all the value series with setting self.data_ts[-self.p:] when p is zero
        if self.p == 0:
            ma_value = self.resid_ts[-self.q:]
            values = ma_value.reindex(index=ma_value.index[::-1])
        elif self.q == 0:
            ar_value = self.data_ts[-self.p:]
            values = ar_value.reindex(index=ar_value.index[::-1])
        else:
            ar_value = self.data_ts[-self.p:]
            ar_value = ar_value.reindex(index=ar_value.index[::-1])
            ma_value = self.resid_ts[-self.q:]
            ma_value = ma_value.reindex(index=ma_value.index[::-1])
            values = ar_value.append(ma_value)

        predict_value = np.dot(para[1:], values) + self.properModel.constant[0]
        self._add_new_data(self.predict_ts, predict_value, type)
        return predict_value

    # 动态添加数据函数，针对索引是月份和日分别进行处理
    def _add_new_data(self, ts, dat, type='day'):
        if type == 'day':
            new_index = ts.index[-1] + relativedelta(days=1)
        elif type == 'month':
            new_index = ts.index[-1] + relativedelta(months=1)
        ts[new_index] = dat

    def add_today_data(self, dat, type='day'):
        self._add_new_data(self.data_ts, dat, type)
        if self.data_ts.index[-1] != self.predict_ts.index[-1]:
            raise ValueError(
                'You must use the forecast_next_day_value method forecast the value of today before')
        self._add_new_data(
            self.resid_ts, self.data_ts[-1] - self.predict_ts[-1], type)


def test():
    ts = getdf(fname="obsHuadiankushuiUTC0-6hourly.txt", fmonth=2)
    print(ts)
    # pass


def main(outname, year2, wdays, fmonth):
    month2 = '%02d' % (fmonth)
    fname = "obs" + outname + "UTC0-6hourly.txt"
    ts = getdf(fname=fname, fmonth=fmonth)
    # print(ts)
    ecname = "ecmwf_" + outname + "_" + year2 + month2 + ".csv"
    print(ecname)
    ts2 = getdf10m(fname=ecname)
    # print("ts2 in 182:")
    # print(ts2)
    # outname = "huadiankushui"
    # year2 = '2021'
    # 数据预处理
    ts_log = np.log(ts)
    # rol_mean = ts_log.rolling(window=28*4).mean()
    # rol_mean.dropna(inplace=True)
    # ts_diff_1 = rol_mean.diff(1)
    # ts_diff_1.dropna(inplace=True)
    # ts_diff_2 = ts_diff_1.diff(1)
    # ts_diff_2.dropna(inplace=True)

    # # 模型拟合
    # model = arima_model(ts_diff_2)
    # # #  这里使用模型参数自动识别
    # model.get_proper_model()
    # print('bic:%s, p:%s, q:%s' % (model.bic, model.p, model.q))
    # print(model.properModel.forecast()[0])
    # # print(model.forecast_next_day_value(type='month'))

    # # # 预测结果还原
    # predict_ts = model.properModel.predict()
    # diff_shift_ts = ts_diff_1.shift(1)
    # diff_recover_1 = predict_ts.add(diff_shift_ts)
    # rol_shift_ts = rol_mean.shift(1)
    # diff_recover = diff_recover_1.add(rol_shift_ts)
    # rol_sum = ts_log.rolling(window=11).sum()
    # rol_recover = diff_recover*12 - rol_sum.shift(1)
    # log_recover = np.exp(rol_recover)
    # log_recover.dropna(inplace=True)

    # # 预测结果作图
    # ts = ts[log_recover.index]
    # plt.figure(facecolor='white')
    # log_recover.plot(color='blue', label='Predict')
    # ts.plot(color='red', label='Original')
    # plt.legend(loc='best')
    # plt.title('RMSE: %.4f' % np.sqrt(sum((log_recover-ts)**2)/ts.size))
    # plt.show()

 # 6.完善ＡＲＩＭＡ模型
    # 差分操作 version 2

    def diff_ts(ts, d):
        global shift_ts_list
        #  动态预测第二日的值时所需要的差分序列
        global last_data_shift_list
        shift_ts_list = []
        last_data_shift_list = []
        tmp_ts = ts
        for i in d:
            last_data_shift_list.append(tmp_ts[-i])
            # print(last_data_shift_list)
            shift_ts = tmp_ts.shift(i)
            shift_ts_list.append(shift_ts)
            tmp_ts = tmp_ts - shift_ts
        tmp_ts.dropna(inplace=True)
        return tmp_ts

    # 还原操作

    def predict_diff_recover(predict_value, d):
        if isinstance(predict_value, float):
            tmp_data = predict_value
            for i in range(len(d)):
                tmp_data = tmp_data + last_data_shift_list[-i-1]
        elif isinstance(predict_value, np.ndarray):
            tmp_data = predict_value[0]
            for i in range(len(d)):
                tmp_data = tmp_data + last_data_shift_list[-i-1]
        else:
            tmp_data = predict_value
            for i in range(len(d)):
                try:
                    tmp_data = tmp_data.add(shift_ts_list[-i-1])
                except:
                    raise ValueError('What you input is not pd.Series type!')
            tmp_data.dropna(inplace=True)
        return tmp_data

    # 差分数据处理
    diffed_ts = diff_ts(ts_log, d=[wdays*4, 1])
    model = arima_model(diffed_ts)
    # # model.certain_model(0, 1)
    model.get_proper_model()
    predict_ts = model.properModel.predict()
    diff_recover_ts = predict_diff_recover(predict_ts, d=[wdays*4, 1])
    log_recover = np.exp(diff_recover_ts)
    log_recover_train = log_recover[:year2 +
                                    '-'+month2+'-01 00:00:00'][:-1]  # dyp
    # log_recover_train = log_recover[:'2020' +
    #                                 '-'+month2+'-28 18:00:00']  # dyp true
    # # print(ts_log)
    # print(log_recover_train)

    ts_train = ts[log_recover_train.index]
    # print(ts_train.index.shape[0])
    # print(ts_train.index)
    time = ts_train.index
    timeseries = time.to_series().apply(lambda x: x.strftime('%Y-%m-%d'))
    newindex = pd.Series(range(ts_train.index.shape[0]))  # 223
    # print(newindex)
    log_recover_train_df = pd.DataFrame(log_recover_train)
    ts_train_df = pd.DataFrame(ts_train)
    log_recover_train_df = log_recover_train_df.set_index(newindex)
    ts_train_df = ts_train_df.set_index(newindex)

    num = 10
    plt.figure(facecolor='white')
    # plt.xticks(np.arange(ts_train.index.shape[0]), ts_train.index)
    plt.xticks(log_recover_train_df[::len(timeseries)//num].index,
               timeseries[::np.size(timeseries)//num], rotation=20)

    plt.plot(log_recover_train_df, color='blue', label='Predict')
    plt.plot(ts_train_df, color='red', label='Original')
    plt.legend(loc='best')
    plt.title('RMSE: %.4f' % np.sqrt(
        sum((log_recover_train-ts_train)**2)/ts_train.size))
    plt.savefig('pic/Figure_wind_test_' + outname + '_month' + month2+'.png')

    # 7. 滚动预测

    def _add_new_data(ts, dat, type='day'):
        if type == 'day':
            new_index = ts.index[-1] + relativedelta(days=1)
        elif type == 'month':
            new_index = ts.index[-1] + relativedelta(months=1)
        ts[new_index] = dat

    def add_today_data(model, ts,  data, d, type='day'):
        _add_new_data(ts, data, type)  # 为原始序列添加数据
        # 为滞后序列添加新值
        d_ts = diff_ts(ts, d)
        model.add_today_data(d_ts[-1], type)

    def forecast_next_day_data(model, type='day'):
        if model == None:
            raise ValueError('No model fit before')
        fc = model.forecast_next_day_value(type)
        # return predict_diff_recover(fc, [12, 1])
        return predict_diff_recover(fc, [wdays*4, 1])  # dyp

    # 滚动向外预测,以２０２１七月以前的为训练集，７－１２月为测试集
    # ts_train = ts_log[:'2020'+'-'+month2+'-28 18:00:00']
    ts_train = ts_log[:year2+'-'+month2+'-01 00:00:00'][:-1]
    _ts_test = ts_log[year2+'-'+month2+'-01 00:00:00':]
    # print(_ts_test)

    def get_ts_test(_ts_test):
        # if test data empty, append 1 month fake data frame to forecast
        if _ts_test.empty:
            now = dt.datetime(int(year2), fmonth, 1)
            days_1_month = calendar.monthrange(int(year2), fmonth)[1]
            future = now + dt.timedelta(days=days_1_month)
            dates_plus = pd.date_range(now, future, freq='6H')
            # print(dates_plus.shape[0])
            winds_plus = pd.DataFrame(np.random.randn(dates_plus.shape[0], 1),
                                      index=dates_plus,
                                      columns=['speed'])
            # convert series to dataframe
            _ts_test_frame = _ts_test.to_frame(name='speed')
            ts_new_test = _ts_test_frame.append(
                winds_plus,  ignore_index=False)
            # convert dataframe to series.
            return ts_new_test.squeeze()
        return _ts_test

    ts_test = get_ts_test(_ts_test)
    diffed_ts = diff_ts(ts_train, [wdays*4, 1])
    forecast_list = []

    for i, dta in enumerate(ts_test):
        # if i % (28) == 0:
        model = arima_model(diffed_ts)
        model.certain_model(0, 2)  # dyp
        # model.get_proper_model()

        forecast_data = forecast_next_day_data(model, type='month')
        forecast_list.append(forecast_data)
        add_today_data(model, ts_train, dta, [wdays*4, 1], type='month')

    # _predict_ts = pd.Series(
    #     data=forecast_list, index=ts[year2+'-'+month2+'-01 00:00:00':].index)
    _predict_ts = pd.Series(
        data=forecast_list, index=ts_test[year2+'-'+month2+'-01 00:00:00':].index)
    log_recover = np.exp(_predict_ts)
    original_ts = ts_test[year2+'-'+month2+'-01 00:00:00':]

    # ts = ts_test[log_recover.index]
    ts = np.exp(ts_test)
    ts2 = ts2[log_recover.index]
    # plt.figure(facecolor='white')
    # plt.plot(log_recover, color='blue', label='Predict_arima')
    # plt.plot(ts2, color='green', label='Pridict_ec')

    # def test_rmse(ts_obs=ts, ts_ari=log_recover, ndays=1):
    #     print('RMSE arima: %.4f' % np.sqrt(
    #         sum((ts_ari-ts_obs)**2)/ts.size))
    #     ndays = range(-20, 20, 1)
    #     for i in ndays:
    #         ts_ari = log_recover.shift(periods=i).dropna()
    #         ts_obs = ts.reindex(ts_ari.index)
    #         # print(ts_ari)
    #         print('RMSE arima %1d: %.4f' % (i, np.sqrt(
    #             sum((ts_ari-ts_obs)**2)/ts_ari.size)))
    # test_rmse()

    # def get_min_key_train_rmse(ts_obs=ts, ts_ari=log_recover_train):
    #     _rmse_list = dict()
    #     ndays = range(-20, 20, 1)
    #     for i in ndays:
    #         ts_ari = log_recover_train.shift(periods=i).dropna()
    #         ts_obs = ts.reindex(ts_ari.index)
    #         v = np.sqrt(sum((ts_ari-ts_obs)**2)/ts_ari.size)
    #         _rmse_list[i] = float(v)
    #     key_min = min(_rmse_list.keys(), key=(lambda k: _rmse_list[k]))
    #     return key_min
    # min_key = get_min_key_train_rmse()
    # print('min key in train is: %s' % min_key)

    def get_min_key_rmse(ts_obs=ts, ts_ari=log_recover):
        _rmse_list = dict()
        ndays = range(-5, 5, 1)
        for i in ndays:
            ts_ari = log_recover.shift(periods=i).dropna()
            ts_obs = ts.reindex(ts_ari.index)
            v = np.sqrt(sum((ts_ari-ts_obs)**2)/ts_ari.size)
            _rmse_list[i] = float(v)
        key_min = min(_rmse_list.keys(), key=(lambda k: _rmse_list[k]))
        return key_min
    min_key = get_min_key_rmse()
    print('min key in test is: %s' % min_key)

    shiftstep = -1
    # shiftstep = -1
    ts_ari_result = log_recover.shift(periods=shiftstep).dropna()
    ts_obs_result = ts.reindex(ts_ari_result.index)
    ts_ec_result = ts2[ts_ari_result.index]
    plt.figure(facecolor='white')
    plt.plot(ts_ari_result, color='blue', label='Predict_arima')
    plt.plot(ts_ec_result, color='green', label='Pridict_ec')
    # 有原始数据可以测试，而不是预报未来没有观测数据
    if not _ts_test.empty:
        # title 3
        # plt.title('RMSE arima: %.4f RMSE ec: %.4f' % (np.sqrt(
        #     sum((log_recover-ts)**2)/ts.size), np.sqrt(sum((ts-ts2)**2)/ts.size)))
        # plt.plot(ts, color='red', label='Original')
        # plt shift
        plt.title('RMSE arima: %.4f RMSE ec: %.4f' % (np.sqrt(
            sum((ts_ari_result-ts_obs_result)**2)/ts_obs_result.size), np.sqrt(sum((ts_ec_result-ts_obs_result)**2)/ts_obs_result.size)))
        plt.plot(ts_obs_result, color='red', label='Original')
    else:
        # no true obs, no use RMSE
        # plt.title('RMSE arima: %.4f' % np.sqrt(
        #     sum((log_recover-ts)**2)/ts.size))
        pass

    plt.legend(loc='best')
    plt.xticks(rotation=20)
    plt.savefig('pic/Figure_wind_valid_' + outname + '_month'+month2+'.png')

    # output csv
    # time2_index = pd.Series(log_recover.index)
    # framelist = [ts]
    # realts = pd.concat(framelist, axis=1)
    # print(realts)
    realtsPredict = pd.Series(ts_ari_result, index=ts_ari_result.index)
    # print(realtsPredict)
    Outhead = [" Timeinfo, WindSpeed10m"]
    outpath = './text/'
    filename = 'arima_out_wind' + year2 + month2+'_' + outname + '_month2.csv'
    filenameout = os.path.join(outpath, filename)
    realtsPredict.to_csv(filenameout, index=True,
                         header=Outhead, encoding='utf-8')


if __name__ == '__main__':
    # test()
    # main(outname="huadiankushui", year2='2021', wdays=31, fmonth=7)
    # main(outname="huadiankushui", year2='2021',wdays=30, fmonth=6)
    # valid Huadiankushui
    main(outname="NewHuadiankushui", year2='2022', wdays=28, fmonth=2)
    # main(outname="NewHuadiankushui", year2='2022', wdays=31, fmonth=3)
    # main(outname="NewHuadiankushui", year2='2022', wdays=31, fmonth=1)
    # main(outname="NewHuadiankushui", year2='2022', wdays=31, fmonth=7)
    # valid naomaohu
    # main(outname="Naomaohu", year2='2022', wdays=28, fmonth=2)  # ec better?
    # main(outname="Naomaohu", year2='2022', wdays=31, fmonth=3)
    # main(outname="Naomaohu", year2='2022', wdays=31, fmonth=1)
    # valid santanghu
    # main(outname="xinjiangsantanghu1qi", year2='2022', wdays=28, fmonth=2)
    # main(outname="xinjiangsantanghu1qi", year2='2022', wdays=31, fmonth=3)
    # main(outname="xinjiangsantanghu1qi", year2='2022', wdays=31, fmonth=1)
