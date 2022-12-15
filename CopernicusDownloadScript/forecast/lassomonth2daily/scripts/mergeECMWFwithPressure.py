import os
import subprocess
from datetime import date
import shutil
from datetime import datetime, timedelta, tzinfo
import json
import pandas as pd


# 1. read in lists
cur_dir = os.path.split(os.path.realpath(__file__))[0]
# print(cur_dir)
file_dir = cur_dir + "/../text"


def readin(station, targetyear):

    all_csv_list = sorted([f for f in os.listdir(file_dir) if str(
        f).startswith("test_ecmwf_ECMWF_"+station+"_"+str(targetyear))], key=lambda i: int(i.split('_')[-3][:-2]))
    print(all_csv_list)
    print('hi')
    for single_csv in all_csv_list:
        single_data_frame = pd.read_csv(os.path.join(file_dir, single_csv))

        single_data_frame['TimeInfo'] = pd.to_datetime(
            single_data_frame['TimeInfo'])
        single_data_frame = single_data_frame.set_index('TimeInfo',
                                                        drop=True)  # 使用drop参数来避免将旧索引添加为列
        print(single_data_frame)
        locmonth = single_csv.split(
            '_')[-3][:4]+'-'+single_csv.split('_')[-3][4:6]
        single_data_frame_imonth = single_data_frame.loc[locmonth]
        # print(single_data_frame.info())
        if single_csv == all_csv_list[0]:
            all_data_frame = single_data_frame_imonth
        else:  # concatenate all csv to a single dataframe, ingore index
            all_data_frame = pd.concat(
                [all_data_frame, single_data_frame_imonth], axis=0, ignore_index=False)
    return all_data_frame
    # return all_csv_list
# merge 'yyyy-mm-01' :loc
# output csv


def outputcsv(data, station, targetyear):
    with open(file_dir + '/result'+station+targetyear + '.csv', 'w') as f:
        data.to_csv(f)


def processStation(station, targetyear: str):
    results = readin(station, targetyear)
    outputcsv(results, station, targetyear)


if __name__ == '__main__':
    stationList = ["NewHuadiankushui", "xinjiangsantanghu1qi", "Naomaohu"]
    for s in stationList:
        processStation(s, "2022")
