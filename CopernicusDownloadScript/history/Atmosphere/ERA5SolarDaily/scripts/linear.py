import math
import os
import random

import numpy as np
import pandas as pd
from pandas import DataFrame, Series
from scipy.interpolate import interp1d, pchip
# https: // blog.csdn.net/weixin_43924621/article/details/124063100


def interpolate(filename, inpath, outpath, intervals):
    infile = os.path.join(inpath, filename)
    if not os.path.isfile(infile):
        raise IOError("File is not found.")

    fhand = pd.read_csv(infile, skiprows=1, header=None,
                        usecols=[0, 1],
                        names=['Timeinfo', 'Radiation'])
    timei_index_step1 = fhand['Timeinfo']
    timei_index = pd.to_datetime(timei_index_step1)
    # print(timei_index)
    x0 = timei_index.astype("datetime64[ns]").astype(np.int64)
    # print(x0)
    rad = fhand['Radiation']
    f = interp1d(x0, rad)
    time2_index = pd.date_range(
        timei_index.iloc[0], timei_index.iloc[-1], freq=intervals)
    time2_index = pd.to_datetime(time2_index)
    xnew = time2_index.astype("datetime64[ns]").astype(np.int64)
    # print(xnew)
    rad_after = f(xnew)
    time2_index = pd.Series(time2_index)
    rad_after = pd.Series(rad_after)
    framelist = [time2_index, rad_after]
    fileout = pd.concat(framelist, axis=1)
    outHead = ["Timeinfo", "Radiation"]
    filenameout = os.path.join(outpath, filename)
    fileout.to_csv(filenameout, index=False, header=outHead, encoding='utf-8')


def interpolateFile(fname):
    inpath = "./data/"
    outpath = inpath
    if os.path.exists(os.path.join(inpath, fname)):
        interpolate(filename=fname, inpath=inpath,
                    outpath=outpath, intervals='60min')
    else:
        print("Original File not Exists")


def interpolateMultiple():
    inpath = "./data/data_after_process/SolarChina/3hourly"
    outpath = "./data/data_after_process/SolarChina/hourly"
    flist = os.listdir(inpath)
    for fname in flist:
        if os.path.exists(os.path.join(inpath, fname)):
            interpolate(filename=fname, inpath=inpath,
                        outpath=outpath, intervals='60min')
        else:
            print("Original File not Exists")


def main():
    # todo
    # 1. 批量提取３ｈ数据
    interpolateMultiple()


def test():
    flists = ["SolarChinaradiation_dongfangCMFD.csv",
              "SolarChinaradiation_linuoCMFD.csv",
              "SolarChinaradiation_fuxinCMFD.csv"]
    for f in flists:
        interpolateFile(f)


if __name__ == '__main__':
    # test()
    main()
