import os
import logging
from fbprophet import Prophet
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
import warnings
warnings.filterwarnings('ignore')

# 读入数据

testdataname = "obsNaomaohuUTC0-6hourly.txt"
realdataname = "obsNaomaohu202208.txt"


def readInData(obstype='OBS', obsname="obsNaomaohu202208.txt", prediction_size=4*30, freq='6H', trainyears=2):
    # real data name
    # realdataname = "obsNaomaohu202208.txt"
    # testdataname
    # obsname = "obsNaomaohuUTC0-6hourly.txt"
    # 使用过去半年的数据做训练
    # lastyears = 0.5　1/12 3/12 6/12 1 2 3
    datadir = "text"
    if obstype == 'ECMforecast':
        datadir = "text_ec_esembles"
    datapath = os.path.join(datadir, obsname)
    data = pd.read_csv(datapath, sep=',')
    # print(data.info())
    # print(data.iloc[2296:2300])
    data = data.dropna()
    # 处理数据
    if obstype == 'OBS':
        data['Date/Time'] = pd.to_datetime(data['Date/Time'])
        cols_to_drop = ['Direction_70m']
        data = data.drop(cols_to_drop, axis=1)
        # print(data.info())
    if obstype == 'FNLrea':
        data['TimeInfo'] = pd.to_datetime(data['TimeInfo'])  # ,
        #   format='%Y-%m-%d')
        cols_to_drop = ['WindDirection10m', 'WindSpeed80m', 'WindDirection80m', 'WindSpeed100m',
                        'WindDirection100m', 'Pressure80m', 'Temperature100m', 'RelativeHumidity2m']
        data = data.drop(cols_to_drop, axis=1)
        # print(data.info())
        # print(data.info())
    if obstype == 'ERA5':
        # 6hourly Date/Time; 1hourly TimeInfo
        # data['TimeInfo'] = pd.to_datetime(data['TimeInfo'])  # ,
        data['Date/Time'] = pd.to_datetime(data['Date/Time'])  # ,
        #   format='%Y-%m-%d')
        cols_to_drop = ['WindDirection100m']
        data = data.drop(cols_to_drop, axis=1)
    # 如果传参是ｅｃｍ预报，不做模型训练，只读入数据
    if obstype == 'ECMforecast':
        data['TimeInfo'] = pd.to_datetime(data['TimeInfo'])
        cols_to_drop = ['WindDirection10m']
        data = data.drop(cols_to_drop, axis=1)
        df = data.reset_index(drop=True)  # 使用drop参数来避免将旧索引添加为列
        df.columns = ['ds', 'yec']
        df2 = df.set_index(['ds'], drop=True)
        return df2
    # 载入模型
    logging.getLogger().setLevel(logging.ERROR)

    _df = data.reset_index(drop=True)  # 使用drop参数来避免将旧索引添加为列
    df = _df[int(-prediction_size-trainyears*8760):]
    df.columns = ['ds', 'y']

    # 归一化处理
    # df['y'] = (df['y'] - df['y'].mean()) / (df['y'].std())
    # print(df.info())
    # print(df.head())
    # 定义一个训练集。为此将保留最后480个用于预测和验证的条目
    # prediction_size = 480  # 6 hourly, 120 days.
    train_df = df[: -prediction_size]

    m = Prophet(yearly_seasonality=10)  # default 10
    # m = Prophet(holidays_prior_scale=0.05) #default 10
    m.fit(train_df)
    future = m.make_future_dataframe(
        periods=prediction_size, freq=freq)
    forecast = m.predict(future)
    # 将预报变量中小于０的数替换为０，发现相关性还增大了．故注释掉
    # forecast['yhat'] = np.where(forecast['yhat'] < 0, 0, forecast['yhat'])
    # print(forecast.head())
    return df, forecast, m


def output_png(m, forecast, pngname, df):
    p1name = os.path.join('pic', 'forecast' + pngname + '.png')
    p2name = os.path.join('pic', 'forecast_components' + pngname + '.png')
    # print(dir(pic1))
    # x1 = forecast['ds'][:-30]
    # print(x1)
    # y1 = forecast['yhat'][:-30]
    # y2 = forecast['yhat_lower']
    # y3 = forecast['yhat_upper']
    # y2 = df['y'][:-30]
    # plt.plot(x1, y1, color='blue', label='Prophet Predict')
    # plt.plot(x1, y2, color='red', label='Original')
    # # plt.plot(x1, y3)
    # plt.xlabel('time')
    # plt.ylabel('wind speed (m/s)')
    # plt.savefig(p1name)
    p1 = m.plot(forecast)
    p1.savefig(p1name)
    m.plot_components(forecast).savefig(p2name)


'''
我们来看一个常见的时间序列场景，黑色表示原始的时间序列离散点，
深蓝色的线表示使用时间序列来拟合所得到的取值，
而浅蓝色的线表示时间序列的一个置信区间，
也就是所谓的合理的上界和下界。
prophet 所做的事情就是：

输入已知的时间序列的时间戳和相应的值；
输入需要预测的时间序列的长度；
输出未来的时间序列走势。
输出结果可以提供必要的统计指标，包括拟合曲线，上界和下界等。
'''

# 输出文本


def output_csv(forecast, outname="obsNaomaohu202208.csv"):
    # outname = "Naomaohu202208"
    outpath = "./text"
    y1 = forecast[['ds', 'yhat']]

    # realtsPredict = pd.Series(
    #     y1, index=forecast['ds'])
    # print(forecast[['ds', 'yhat', 'yhat_lower', 'yhat_upper']])
    # print(forecast[['ds', 'yhat', 'yhat_lower', 'yhat_upper']].tail())
    # Outhead = [" Timeinfo, WindSpeed10m"]
    filenameout = os.path.join("./text", "prophet_out_wind_" + outname)
    y1.to_csv(filenameout, index=False, encoding='utf-8')
#  header=Outhead, encoding='utf-8')
# 检验和实际值的偏差
# 通过计算模型的平均绝对百分误差（MAPE）和平均绝对误差（MAE）来评估模型的性能
# Define a function to make a dataframe containing the prediction and actual values


def make_comparison_dataframe(historical, forecast):
    return forecast.set_index('ds')[['yhat', 'yhat_lower',
                                     'yhat_upper']].join(historical.set_index('ds'))


# Define a function to calculate MAPE and MAE

def R_Square(x, y):
    p1 = x2 = y2 = 0.0
    # 计算平均值
    x_ = np.mean(x)
    y_ = np.mean(y)
    # 循环读取每个值，计算对应值的累和
    for i in range(len(x)):
        p1 += (x[i]-x_)*(y[i]-y_)
        x2 += (x[i]-x_)**2
        y2 += (y[i]-y_)**2
    # print(p1,x2,y2)
    # 计算相关系数
    r = p1/((x2 ** 0.5)*(y2 ** 0.5))
    return r


def Kvalue(x, y):
    x_ = np.mean(x)
    y_ = np.mean(y)
    return x_ / y_


def err_mean_percent(x, y):
    return 100 * np.mean(x) / np.mean(y)


def calculate_forecast_errors(df, prediction_size, testmonth=1):

    df = df.copy()
    df['e'] = df['y'] - df['yhat']
    df['p'] = 100 * df['e'] / df['y']
    df['e2'] = df['e'] * df['e']
    # df['e_p_2'] = 100 * np.mean(df['e']) / np.mean(df['y'])

    test_size_from = -prediction_size + 24 * 30 * (testmonth - 1)
    test_size_to = -prediction_size + 24 * 30 * testmonth - 1
    predicted_part = df[test_size_from:test_size_to]
    # print(predicted_part)
    r_square = R_Square(predicted_part['y'], predicted_part['yhat'])
    e_p_2 = err_mean_percent(predicted_part['e'], predicted_part['y'])
    #r_square_test = R_Square(predicted_part['yhat'], predicted_part['yhat'])

    def error_mean(error_name): return np.mean(
        np.abs(predicted_part[error_name]))

    def error_mean_rmse(error_name): return np.sqrt(np.mean(
        predicted_part[error_name]))

    # , 'R_square_test': r_square_test}
    return {'MAPE': error_mean('p'), 'MAE': error_mean('e'), 'RMSE': error_mean_rmse('e2'), 'EP2': e_p_2}


def calculate_forecast_errors_compare_ecmwf(df, prediction_size, df2, testmonth=1):
    # pd.concat axis=1,left-right
    # 在df2同期的数据，与观测df1做对比，定量输出ｅｃ模式预报点误差
    # print(df.info())
    # print(df2.info())
    df = pd.concat([df.copy().loc[df2.index, :], df2], axis=1)

    # print("hi:")
    # print(df)
    # df['e'] = df['y'] - df2['yec']      #b = 1.4
    df['e'] = df['y'] - df2['yec'] * 1.4  # apply b to get after train e_p_2
    df['p'] = 100 * df['e'] / df['y']
    df['e2'] = df['e'] * df['e']

    predicted_part = df[-prediction_size:]

    # test_size_from = -prediction_size + 4 * 30 * (testmonth - 1)
    # test_size_to = -prediction_size + 4 * 30 * testmonth - 1
    # predicted_part = df[test_size_from:test_size_to]
    # print(predicted_part)
    r_square = R_Square(predicted_part['y'], predicted_part['yec'])
    e_p_2 = err_mean_percent(predicted_part['e'], predicted_part['y'])
    b = Kvalue(predicted_part['y'], predicted_part['yec'])

    def error_mean(error_name): return np.mean(
        np.abs(predicted_part[error_name]))

    def error_mean_rmse(error_name): return np.sqrt(np.mean(
        predicted_part[error_name]))
    # train
    # filetxt = 'text/temp_b_2022.txt'
    # if os.path.exists(filetxt):
    #     with open(filetxt, 'a') as f:
    #         f.write(str(b))
    #         f.write("\n")
    # else:
    #     with open(filetxt, 'w') as f:
    #         f.write(str(b))
    #         f.write("\n")
    # f.close()
    # test
    filetxt = 'text/temp_ep2_2022.txt'
    if os.path.exists(filetxt):
        with open(filetxt, 'a') as f:
            f.write(str(e_p_2))
            f.write("\n")
    else:
        with open(filetxt, 'w') as f:
            f.write(str(e_p_2))
            f.write("\n")
    f.close()
    return {'MAPE ec': error_mean('p'), 'MAE ec': error_mean('e'), 'RMSE ec': error_mean_rmse('e2'), 'R_square': r_square}


''' FNL forecast prophet vs FNL obs:
# default=10更好
MAPE 932.9874079892937
MAE 2.88242904418861

MAPE 103.59710801143197
MAE 2.892630418530004
RMSE 3.701260608496166

ECMWF forecast vs FNL obs:
# yearly_seasonality=20
MAPE 752.7537688486976
MAE 2.9201714078953938

MAPE 119.62815711467756
MAE 3.362411900782705
RMSE 4.27910775092178

todo:
ERA5 forecast prophet vs ERA5 obs
ECMWF forecast vs ERA5 obs:
2021年６月对未来６个月的预报
'''


def PrintTheMAPEandMAE(df, forecast, prediction_size, testmonth):
    cmp_df = make_comparison_dataframe(df, forecast)
    for err_name, err_value in calculate_forecast_errors(cmp_df, prediction_size, testmonth).items():
        print(err_name, err_value)


def PrintTheMAPEandMAEwithEC(df, forecast, prediction_size, df2):
    cmp_df = make_comparison_dataframe(df, forecast)
# def PrintTheMAPEandMAEwithEC(df, prediction_size, df2):
#     cmp_df = df.set_index('ds')[['yhat', 'yhat_lower',
#                                  'yhat_upper']]
    for err_name, err_value in calculate_forecast_errors_compare_ecmwf(cmp_df, prediction_size, df2).items():
        print(err_name, err_value)


'''
def CompareObsPredictionWithObs(i):
    #testdataname = "obsNaomaohuUTC0-6hourly.txt"
    # testdataname = "FNL_100.000_39.750_20200101_20220601.csv"
    testdataname = "ecmwf_ERA5_NewHuadiankushui-Exported6hourlyFrom2019.txt"
    _prediction_size = 4 * 30 * 6
    _freq = '6H'
    _trainyears = 1/12
    # _trainyears = 3/12
    _trainyears = 6/12
    # _trainyears = 12/12
    # _trainyears = 24/12
    # _trainyears = 36/12
    df, forecast, m = readInData(obstype='ERA5',
                                 obsname=testdataname, prediction_size=_prediction_size, freq=_freq, trainyears=_trainyears)  # forecast 6 months
    # output_png(m=m, forecast=forecast, pngname=testdataname, df=df)
    # output_csv(forecast=forecast, outname=testdataname)
    PrintTheMAPEandMAE(df=df, forecast=forecast,
                       prediction_size=_prediction_size, testmonth=int(i))


def multiCompareObsPredictionWithObs():
    for i in range(1, 7):
        CompareObsPredictionWithObs(i)
        print('month: %s' % str(i))
'''
# ｅｃ预报与ｅｒａ５观测对比，无训练

# 目标


def Compare6hourlyFNLwithEC(historyFile, forecastFile):
    # 读入历史ＦＮＬ
    # historyFile = "ecmwf_ERA5_NewHuadiankushui-Exported6hourlyFrom2019.txt"
    # forecastFile = "test_ecmwf_ECMWF_NewHuadiankushui_20220630_"+str(x)+".csv"
    df, forecast, m = readInData(obstype='ERA5',
                                 # df = readInData(obstype='ERA5',
                                 obsname=historyFile, prediction_size=4*30*6, freq='6H')
    # 读入ｅｃ的６月预报
    df2 = readInData(obstype='ECMforecast',
                     obsname=forecastFile)  # FNL 是坐标名，实际是ｅｃ六个月的预报
    # compare df fnl vs ecmwf forecast
    PrintTheMAPEandMAEwithEC(df=df, forecast=forecast,
                             prediction_size=4*30*1, df2=df2)
    # PrintTheMAPEandMAEwithEC(df=df, prediction_size=4*30*1, df2=df2)
    # compare df fnl vs fnl forecast
    # PrintTheMAPEandMAE(df=df, forecast=forecast, prediction_size=4*30*1)


def multiCompare6hourlyFNLwithEC(n):
    for i in range(n):
        Compare6hourlyFNLwithEC(historyFile="ecmwf_ERA5_NewHuadiankushui-Exported6hourlyFrom2019.txt",
                                forecastFile="test_ecmwf_ECMWF_NewHuadiankushui_20220630_"+str(i)+".csv")
        print(i)


if __name__ == '__main__':
    # 6hourly ERA5
    # Compare6hourlyFNLwithEC()
    multiCompare6hourlyFNLwithEC(n=5)
