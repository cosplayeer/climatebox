import pandas as pd
import numpy as np
from pandas import DataFrame as df
import os
from configs import getconfig
# string = pd.Series(np.random.choice(df.string.values, size=100), name='string')


def readinData(inpath='text', outpath='text_split', intervals='60min'):
    outname, year2, wdays, fmonth = getconfig()
    filename = "obs"+outname+"UTC0-6hourly.txt"
    infile = os.path.join(inpath, filename)
    if not os.path.isfile(infile):
        raise IOError("File is not found.")
    # 读取文件时，通过parse_dates=['日期'],将日期转化为datetime类型，相当于 pd.to_datetime。同时可以使用index_col将那一列作为的行索引，相当有set_index
    df = pd.read_csv(infile, skiprows=1, header=None, usecols=[0, 1],
                     names=['Timeinfo', 'WindSpeed10m'], parse_dates=['Timeinfo'])
    #    TimeInfo, WindSpeed10m, WindDirection10m, Temperature2m, Pressure10m, Airdensity

    timei_index_step1 = df['Timeinfo']
    # timei_index = pd.to_datetime(timei_index_step1)
    # df = df.set_index(timei_index)
    df['year'] = df['Timeinfo'].dt.year
    df['month'] = df['Timeinfo'].dt.month

    # qstr = "year == '2019' and month=='1'"
    if not os.path.exists(os.path.join(outpath, filename)):
        os.mkdir(os.path.join(outpath, filename))
        for i in range(12):
            qstr = "month=='{}'".format(i+1)
            monthxlist = df.query(qstr)
            monthxlist.to_csv(os.path.join(outpath, filename, str(i+1)),
                              columns=['Timeinfo', 'WindSpeed10m'], index=False)
    else:
        print("FileExistsError")
    # resamp = df.dt.day
    # print(resamp)
    # dt的其他常用属性和方法如下：
    # df['日期'].dt.day   # 提取日期
    # df['日期'].dt.year  # 提取年份
    # df['日期'].dt.hour  # 提取小时
    # df['日期'].dt.minute  # 提取分钟
    # df['日期'].dt.second  # 提取秒
    # df['日期'].dt.week  # 一年中的第几周
    # df['日期'].dt.weekday  # 返回一周中的星期几，0代表星期一，6代表星期天
    # df['日期'].dt.dayofyear  # 返回一年的第几天
    # df['日期'].dt.quarter  # 得到每个日期分别是第几个季度。
    # df['日期'].dt.is_month_start  # 判断日期是否是每月的第一天
    # df['日期'].dt.is_month_end  # 判断日期是否是每月的最后一天
    # df['日期'].dt.is_leap_year  # 判断是否是闰年
    # df['日期'].dt.month_name()  # 返回月份的英文名称
    # df['日期'].dt.to_period('Q')  # M 表示月份，Q 表示季度，A 表示年度，D 表示按天
    # # 返回星期几的英文 由于pandas版本问题，改变pandas版本在cmd中输入：pip install --upgrade pandas==0.25.3
    # df['日期'].dt.weekday_name
    # Series.dt.normalize()  # 函数将给定系列对象中的时间转换为午夜
    # 原文链接：https: //blog.csdn.net/caoxinjian423/article/details/113029894

    # output some column:


if __name__ == '__main__':
    # readinData(filename='obsNewHuadiankushuiUTC0-1hourly.txt',
    #            inpath='text', outpath='text_split')
    readinData()
