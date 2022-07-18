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


def readInData(obsname="obsNaomaohu202208.txt", prediction_size=480, freq='6H'):
    # real data name
    # realdataname = "obsNaomaohu202208.txt"
    # testdataname
    # obsname = "obsNaomaohuUTC0-6hourly.txt"
    datapath = os.path.join("text", obsname)
    data = pd.read_csv(datapath, sep=',')
    print(data.info())
    # print(data.iloc[2296:2300])
    data = data.dropna()
    # 处理数据
    data['Date/Time'] = pd.to_datetime(data['Date/Time'])
    cols_to_drop = ['Direction_70m']
    data = data.drop(cols_to_drop, axis=1)
    # print(data.info())
    # 载入模型
    logging.getLogger().setLevel(logging.ERROR)

    df = data.reset_index(drop=True)  # 使用drop参数来避免将旧索引添加为列
    df.columns = ['ds', 'y']
    # 归一化处理
    # df['y'] = (df['y'] - df['y'].mean()) / (df['y'].std())
    # print(df.info())
    # print(df.head())
    # 定义一个训练集。为此将保留最后480个用于预测和验证的条目
    # prediction_size = 480  # 6 hourly, 120 days.
    train_df = df[:-prediction_size]

    m = Prophet(yearly_seasonality=20)  # default 10
    # m = Prophet(holidays_prior_scale=0.05) #default 10
    m.fit(train_df)
    future = m.make_future_dataframe(
        periods=prediction_size, freq=freq)
    forecast = m.predict(future)
    # print(forecast.head())
    return df, forecast, m


def output_png(m, forecast, pngname):
    p1name = os.path.join('pic', 'forecast' + pngname + '.png')
    p2name = os.path.join('pic', 'forecast_components' + pngname + '.png')
    # print(dir(pic1))
    x1 = forecast['ds']
    y1 = forecast['yhat']
    y2 = forecast['yhat_lower']
    y3 = forecast['yhat_upper']
    plt.plot(x1, y1)
    # plt.plot(x1, y2)
    # plt.plot(x1, y3)
    plt.xlabel('time')
    plt.savefig(p1name)
    # m.plot(forecast).savefig(p1name)
    # m.plot_components(forecast).savefig(p2name)


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


def calculate_forecast_errors(df, prediction_size):

    df = df.copy()
    df['e'] = df['y'] - df['yhat']
    df['p'] = 100 * df['e'] / df['y']
    df['e2'] = df['e'] * df['e']

    predicted_part = df[-prediction_size:]

    def error_mean(error_name): return np.mean(
        np.abs(predicted_part[error_name]))

    def error_mean_rmse(error_name): return np.sqrt(np.mean(
        predicted_part[error_name]))

    return {'MAPE': error_mean('p'), 'MAE': error_mean('e'), 'RMSE': error_mean_rmse('e2')}


'''
# default
MAPE 932.9874079892937
MAE 2.88242904418861
# yearly_seasonality=20
MAPE 752.7537688486976
MAE 2.9201714078953938
'''


def PrintTheMAPEandMAE(df, forecast, prediction_size):
    cmp_df = make_comparison_dataframe(df, forecast)
    for err_name, err_value in calculate_forecast_errors(cmp_df, prediction_size).items():
        print(err_name, err_value)


def test6hourly():
    testdataname = "obsNaomaohuUTC0-6hourly.txt"
    df, forecast, m = readInData(
        obsname=testdataname, prediction_size=4*30*1, freq='6H')  # forecast 4 months
    output_png(m=m, forecast=forecast, pngname=testdataname)
    output_csv(forecast=forecast, outname=testdataname)
    PrintTheMAPEandMAE(df=df, forecast=forecast, prediction_size=4*30*1)


def main():
    # realdataname = "obs202206NaomaohuUTC0-1hourly.txt"
    # realdataname = "obs202206NewHuadiankushuiUTC0-1hourly.txt"
    realdataname = "obs202206xinjiangsantanghu1qiUTC0-1hourly.txt"
    df, forecast, m = readInData(
        obsname=realdataname, prediction_size=24 * 31 * 2, freq='1H')
    output_png(m=m, forecast=forecast, pngname=realdataname)
    output_csv(forecast=forecast, outname=realdataname)
    PrintTheMAPEandMAE(df=df, forecast=forecast, prediction_size=24 * 31 * 2)
    # todo freq parameter


if __name__ == '__main__':
    test6hourly()
    # main()
