# -*-coding:utf-8-*-
import pandas as pd
import numpy as np
# from statsmodels.tsa.arima_model import ARMA
from arima_model import ARMA
import sys
import os
from dateutil.relativedelta import relativedelta
from copy import deepcopy
import matplotlib.pyplot as plt


def getdf():
    # merge && readin csvs
    csvdir = "./text2/"
    flists = ["ecmwf_rad_201712_ts.csv",
              "ecmwf_rad_201806_ts.csv",
              "ecmwf_rad_201812_ts.csv",
              "ecmwf_rad_201906_ts.csv",
              "ecmwf_rad_201912_ts.csv",
              "ecmwf_rad_202006_ts.csv",
              "ecmwf_rad_202012_ts.csv",
              "ecmwf_rad_202106_ts.csv"]
    df = pd.DataFrame(columns=['rad'])
    for i in range(len(flists)):
        a1 = os.path.join(csvdir, flists[i])
        data1 = pd.read_csv(a1, skiprows=1, header=None, index_col=0,
                            usecols=[0, 1], names=['Timeinfo', 'rad'])
        df = df.append(data1, ignore_index=False)

    df.index = pd.to_datetime(df.index)
    _ts = df['rad']
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


if __name__ == '__main__':
    ts = getdf()

    # 数据预处理
    ts_log = np.log(ts)
    # rol_mean = ts_log.rolling(window=12).mean()
    # rol_mean.dropna(inplace=True)
    # ts_diff_1 = rol_mean.diff(1)
    # ts_diff_1.dropna(inplace=True)
    # ts_diff_2 = ts_diff_1.diff(1)
    # ts_diff_2.dropna(inplace=True)

    # # 模型拟合
    # model = arima_model(ts_diff_2)
    # #  这里使用模型参数自动识别
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
# 差分操作


def diff_ts(ts, d):
    global shift_ts_list
    #  动态预测第二日的值时所需要的差分序列
    global last_data_shift_list
    shift_ts_list = []
    last_data_shift_list = []
    tmp_ts = ts
    for i in d:
        last_data_shift_list.append(tmp_ts[-i])
        print(last_data_shift_list)
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
diffed_ts = diff_ts(ts_log, d=[12, 1])
model = arima_model(diffed_ts)
model.certain_model(0, 1)
# model.get_proper_model()
predict_ts = model.properModel.predict()
diff_recover_ts = predict_diff_recover(predict_ts, d=[12, 1])
log_recover = np.exp(diff_recover_ts)
log_recover_train = log_recover[:'2021-06']
# print(ts_log)
# print(log_recover_train)

# ts_train = ts[log_recover_train.index]
# plt.figure(facecolor='white')
# log_recover_train.plot(color='blue', label='Predict')
# ts_train.plot(color='red', label='Original')
# plt.legend(loc='best')
# plt.title('RMSE: %.4f' % np.sqrt(
#     sum((log_recover_train-ts_train)**2)/ts_train.size))
# plt.show()

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
    return predict_diff_recover(fc, [12, 1])


# print(ts_log)
# 滚动向外预测,以2０2１七月以前的为训练集，７－１2月为测试集
ts_train = ts_log[:'2021-06']
ts_test = ts_log['2021-07':]

diffed_ts = diff_ts(ts_train, [12, 1])
forecast_list = []

for i, dta in enumerate(ts_test):
    if i % 7 == 0:
        model = arima_model(diffed_ts)
        model.certain_model(0, 1)
    forecast_data = forecast_next_day_data(model, type='month')
    forecast_list.append(forecast_data)
    add_today_data(model, ts_train, dta, [12, 1], type='month')

predict_ts = pd.Series(data=forecast_list, index=ts['2021-07':].index)
log_recover = np.exp(predict_ts)
original_ts = ts['2021-07':]

ts = ts[log_recover.index]
plt.figure(facecolor='white')
log_recover.plot(color='blue', label='Predict')
ts.plot(color='red', label='Original')
plt.legend(loc='best')
plt.title('RMSE: %.4f' % np.sqrt(sum((log_recover-ts)**2)/ts.size))
plt.savefig('pic/Figure_rad_xxx.png')
