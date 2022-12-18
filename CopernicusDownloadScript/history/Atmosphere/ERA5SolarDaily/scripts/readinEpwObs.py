# extract process epw
import os
import pandas as pd
from datetime import datetime, timedelta
from pyepw.epw import EPW


def file_filter(f):
    if f[-4:] == '.epw':
        return True
    else:
        return False


def Create_df_weather(fname):

    # read_ewp_as_link(Link_weather)
    epw = EPW()
    epw.read(os.path.join("data", "epwdata", fname))
    # print(epw.location.country)
    lat = epw.location.latitude
    lon = epw.location.longitude
    # print(epw.location.elevation)
    year = []
    month = []
    day = []
    date = []
    hour = []
    seconde = []
    dry_bulb_temperature = []
    dew_point_temperature = []
    relative_humidity = []
    atmospheric_station_pressure = []
    global_horizontal_radiation = []
    direct_normal_radiation = []
    diffuse_horizontal_radiation = []
    wind_direction = []
    wind_speed = []
    total_sky_cover = []
    opaque_sky_cover = []
    precipitable_water = []

    for wd in epw.weatherdata:
        year.append(wd.year)
        month.append(wd.month)
        day.append(wd.day)
        hour.append(wd.hour)
        global_horizontal_radiation.append(wd.global_horizontal_radiation)
        direct_normal_radiation.append(wd.direct_normal_radiation)
        # diffuse_horizontal_radiation.append(wd.global_horizontal_radiation)

    data_weather = pd.DataFrame(
        [year, month, day, hour, global_horizontal_radiation,
            direct_normal_radiation])  # , diffuse_horizontal_radiation

    data_weather = data_weather.transpose()
    data_weather.columns = ['year', 'month', 'day', 'hour',
                            'global_horizontal_radiation', 'direct_normal_radiation']
    # ,'diffuse_horizontal_radiation']
    data_weather['date'] = data_weather['year'].astype(int).astype(str).str.zfill(
        2) + data_weather['month'].astype(int).astype(str).str.zfill(2) + data_weather['day'].astype(int).astype(str).str.zfill(2)
    # print(data_weather['month'].astype(int).astype(str).str.zfill(2))
    pd.to_datetime(data_weather['date'])
    data_weather['date_time'] = pd.to_datetime(
        data_weather['date'])+pd.TimedeltaIndex(data_weather['hour'], unit="H")
    data_weather = data_weather.drop(
        ['date', 'year', 'month', 'day', 'hour'], axis=1)
    data_weather['date_time'] = data_weather['date_time'] - \
        pd.Timedelta(8, unit='H')
    # utc8 to utc0
    fout = os.path.join("EPW_"+fname.split(".epw")
                        [0].replace(".", "_")+"_"+str(lat)+"_"+str(lon)+".csv")
    order = ['date_time', 'global_horizontal_radiation',
             'direct_normal_radiation']
    data_weather = data_weather[order]
    # ｔｏｄｏ
    # 返回更多包含２００５年年份的
    # 判断２００５年的数据的是否完整
    return data_weather, fout, lat, lon, year[0]


def convert2csv(fname):
    df, foutname, lat, lon, year = Create_df_weather(fname)
    if year == 2005:
        foutpath = os.path.join("data", "data_after_process", "EPW", foutname)
        df.to_csv(foutpath, index=False, sep=",")
        station = '_'.join(foutname.split('_')[:-2])
        return {station: {'lat': lat, 'lon': lon, 'year': year}}
    else:
        return None


def test():
    epw = EPW()
    epw.read(r"data/epwdata/CHN_CQ_Chongqing.Shapingba.575160_CSWD.epw")
    # for wd in epw.weatherdata:
    # print(wd.global_horizontal_radiation)
    print(epw.location.timezone)
    print(epw.weatherdata[0].year)
    print(dir(epw.weatherdata[0]))


def main():
    import json
    x = {}
    frompath = os.path.join("data", "epwdata")
    flist = os.listdir(frompath)
    flist = list(filter(file_filter, flist))
    # print(flist)
    jsdict = dict()
    for f in flist:
        absf = os.path.join("data", "epwdata", f)
        cmd = 'sed -i "2c DESIGN CONDITIONS,0" '+absf
        print(cmd)
        os.system(cmd)
        if convert2csv(f) is not None:
            tempdict = convert2csv(f)
            key = list(tempdict.keys())[0]
            # print(key)
            if key not in x:  # and tempdict[key]["year"] == 2005:
                jsdict.update(tempdict)
                # print(key in jsdict)
    with open(os.path.join("text", "location.txt"), "w") as f:
        json.dump(jsdict, f)


if __name__ == '__main__':
    test()
    # main()
