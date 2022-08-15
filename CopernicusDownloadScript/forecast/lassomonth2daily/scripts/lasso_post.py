import pandas as pd
import numpy as np
import os
from sklearn import linear_model

'''
readin obs
readin forecast
3yue   |   4 yue
train  |   test
'''
# test
'''
from sklearn import linear_model
clf = linear_model.Lasso(alpha=0.1)
clf.fit([[0, 0], [1, 1], [2, 2]], [0, 1, 2])
print(clf.coef_)
print(clf.intercept_)
'''


def max_member(esembles):
    for i in range(len(esembles)):
        if esembles[i] == esembles.max():
            return i

# readin


file_dir = "./text_ec_esembles"  # file directory
# get csv list


def readin_esemble(station: str, targetmonth):
    # station = "NewHuadiankushui"
    # targetmonth = "06"
    all_csv_list = sorted([f for f in os.listdir(file_dir) if str(
        f).startswith("test_ecmwf_ECMWF_"+station+"_"+str(targetmonth))], key=lambda i: int(i.split('_')[-1][:-4]))
    # print(all_csv_list)
    for single_csv in all_csv_list:
        eId = single_csv.split('_')[-1][:-4]
        # print(eId)
        single_data_frame = pd.read_csv(os.path.join(file_dir, single_csv))
        # print(single_data_frame.info())
        single_data_frame = single_data_frame.drop('WindDirection10m', axis=1)
        # print(single_data_frame)
        single_data_frame['TimeInfo'] = pd.to_datetime(
            single_data_frame['TimeInfo'])
        single_data_frame = single_data_frame.set_index('TimeInfo',
                                                        drop=True)  # 使用drop参数来避免将旧索引添加为列
        # print(single_data_frame)
        single_data_frame.columns = ['yec_'+str(eId)]
        # print(single_data_frame.info())
        if single_csv == all_csv_list[0]:
            all_data_frame = single_data_frame
        else:  # concatenate all csv to a single dataframe, ingore index
            all_data_frame = pd.concat(
                [all_data_frame, single_data_frame], axis=1, ignore_index=False)
    return all_data_frame


def readin_obs(station):
    # station = "NewHuadiankushui"  # "xinjiangsantanghu1qi" #"Naomaohu"
    file_dir = "./text"
    single_csv = "obs"+station+"UTC0-6hourly.txt"
    single_data_frame = pd.read_csv(os.path.join(file_dir, single_csv))
    single_data_frame.columns = ['TimeInfo', 'spdObs', 'dirObs', 'uname']
    single_data_frame = single_data_frame.drop(['dirObs', 'uname'], axis=1)
    single_data_frame['TimeInfo'] = pd.to_datetime(
        single_data_frame['TimeInfo'])
    single_data_frame = single_data_frame.set_index('TimeInfo',
                                                    drop=True)
    return single_data_frame


def printBestMember(station: str, targetmonth: str):
    panda2021 = readin_esemble(station=station, targetmonth=targetmonth)
    # panda_all = panda2021
    # panda_all = pd.concat([panda2020, panda2021, panda2022],
    #   axis=0, ignore_index=False)
    # print(panda_all)
    obs_data_frame = readin_obs(station=station)
    # obs_data_frame = readin_obs(station="Naomaohu")
    # obs_data_frame = readin_obs(station="xinjiangsantanghu1qi")
    # print(single_data_frame)
    df = pd.concat(
        [panda2021, obs_data_frame.reindex(panda2021.index)], axis=1)

    # print(s.info())
    # 这才是真正选择月份时间的时候
    locmonth = targetmonth[0:4]+'-'+targetmonth[4:6]
    df_test = df.loc[locmonth]
    # df_test = pd.concat([df.loc['2020-02'],
    #                     df.loc['2021-02'], df.loc['2022-02']], axis=0)

    # print(df_test.info())
    # print(df_test.iloc[:, :-1])
    # print(df_test.iloc[:, -1])
    cor_obs = df_test.corr()['spdObs'][:-1]

    max_id = max_member(cor_obs)
    # print("target month:{}".format(targetmonth))
    # print(cor_obs.max())
    # print(max_id)
    # -----lasso------
    '''
    model = linear_model.LassoCV()
    model.fit(df_test.iloc[:, :-1], df_test.iloc[:, -1])
    # print(model.coef_)
    print(model.alpha_)
    # _result = model.predict(df_test.iloc[:, :-1])
    '''
    # ----等比例系数
    alpha_2 = np.mean(df_test.iloc[:, -1]) / np.mean(df_test.iloc[:, max_id])
    # print(alpha_2)
    return {str(targetmonth): {'max_id': max_id, 'max_cor': cor_obs.max(), 'alpha': alpha_2}}
    # _result = df_test.iloc[:, -2] * alpha_2
    # print(_result)


if __name__ == '__main__':
    from extractionECMWF import month_add2
    fromdate = 20210101
    todate = 20211201
    station = "NewHuadiankushui"
    # printBestMember(station="NewHuadiankushui", targetmonth="20210901")
    i = fromdate
    result = dict()
    while i <= todate:
        temp = printBestMember(station="NewHuadiankushui", targetmonth=str(i))
        result.update(temp)
        i = int(month_add2(str(i), months=1))
    print(result)
