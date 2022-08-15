from datetime import date
import os
import shutil
from datetime import datetime, timedelta, tzinfo
from configparser import ConfigParser
import cdsapi


class UTC(tzinfo):
    def __init__(self, offset=0):
        self._offset = offset

    def utcoffset(self, dt):
        return timedelta(hours=self._offset)

    def tzname(self, dt):
        return "UTC + %s" % self._offset

    def dst(self, dt):
        return timedelta(hours=self._offset)


def addYears(d, years):
    try:
        # Return same day of the current year
        return d.replace(year=d.year + years)
    except ValueError:
        # If not same day, it will return other, i.e.  February 29 to March 1 etc.
        return d + (date(d.year + years, 1, 1) - date(d.year, 1, 1))


c = cdsapi.Client()


def _downloads_seasonal_daily_before2month_onetime(current_dt: datetime, areas: str):
    c.retrieve(
        'seasonal-original-single-levels',
        {
            'originating_centre': 'ecmwf',
            'system': '5',
            'variable': [
                '10m_u_component_of_wind', '10m_v_component_of_wind', '2m_temperature',
                'mean_sea_level_pressure',
            ],
            'year': current_dt.year,
            'month': current_dt.month,
            'day': current_dt.day,
            'leadtime_hour': [
                '720', '726', '732', '738',
                '744', '750', '756', '762',
                '768', '774', '780', '786',
                '792', '798', '804', '810',
                '816', '822', '828', '834',
                '840', '846', '852', '858',
                '864', '870', '876', '882',
                '888', '894', '900', '906',
                '912', '918', '924', '930',
                '936', '942', '948', '954',
                '960', '966', '972', '978',
                '984', '990', '996', '1002',
                '1008', '1014', '1020',
                '1026', '1032', '1038',
                '1044', '1050', '1056',
                '1062', '1068', '1074',
                '1080', '1086', '1092',
                '1098', '1104', '1110',
                '1116', '1122', '1128',
                '1134', '1140', '1146',
                '1152', '1158', '1164',
                '1170', '1176', '1182',
                '1188', '1194', '1200',
                '1206', '1212', '1218',
                '1224', '1230', '1236',
                '1242', '1248', '1254',
                '1260', '1266', '1272',
                '1278', '1284', '1290',
                '1296', '1302', '1308',
                '1314', '1320', '1326',
                '1332', '1338', '1344',
                '1350', '1356', '1362',
                '1368', '1374', '1380',
                '1386', '1392', '1398',
                '1404', '1410',
                '1416', '1422', '1428',
                '1434', '1440', '1446',
                '1452', '1458', '1464',
                '1470', '1476',
                '1482', '1488', '1494',
                '1500', '1506', '1512',
                '1518', '1524', '1530',
                '1536', '1542', '1548',
                '1554', '1560', '1566',
                '1572', '1578', '1584',
                '1590', '1596', '1602',
                '1608', '1614', '1620',
                '1626', '1632', '1638',
                '1644', '1650', '1656',
                '1662', '1668', '1674',
                '1680', '1686', '1692',
                '1698', '1704', '1710',
                '1716', '1722', '1728',
                '1734', '1740', '1746',
                '1752', '1758', '1764',
                '1770', '1776', '1782',
                '1788', '1794', '1800',
                '1806', '1812', '1818',
                '1824', '1830', '1836',
                '1842', '1848', '1854',
                '1860', '1866', '1872',
                '1878', '1884', '1890',
                '1896', '1902', '1908',
                '1914', '1920', '1926',
                '1932', '1938', '1944',
                '1950', '1956', '1962',
                '1968', '1974', '1980',
                '1986', '1992', '1998',
                '2004', '2010', '2016',
                '2022', '2028', '2034',
                '2040', '2046', '2052',
                '2058', '2064', '2070',
                '2076', '2082', '2088',
                '2094', '2100', '2106',
                '2112', '2118', '2124',
                '2130', '2136', '2142',
                '2148', '2154', '2160',
                '2166', '2172', '2178',
                '2184', '2190', '2196',
                '2202', '2208', '2214',
                '2220'
            ],
            'format': 'grib',
            'area': areas.split(),
        },
        os.path.join('data', 'Seasonal_2month_daily' + str(current_dt.strftime('%Y%m%d')) + 'china.grib'))


def mkdir():
    if not os.path.exists('data'):
        os.mkdir('data')
    apifile = os.path.join(os.environ['HOME'], '.cdsapirc')
    if not os.path.exists(apifile):
        shutil.copyfile(os.path.join("scripts", ".cdsapirc"), apifile)


def downloads_2month(st_dt: datetime, end_dt: datetime, areas: str):
    current_dt = st_dt
    while current_dt <= end_dt:
        # print("hi:")
        print(current_dt)
        filename = os.path.join('data', 'Seasonal_2month_daily' +
                                str(current_dt.strftime('%Y%m%d')) + 'china.grib')
        if not os.path.exists(filename):
            _downloads_seasonal_daily_before2month_onetime(current_dt, areas)
        else:
            print("file already existed, passing")
        current_dt = month_add1(current_dt)


def getconfig():
    config_object = ConfigParser()
    configfile = os.path.join("scripts", "download.conf")
    config_object.read(configfile, encoding='UTF-8')
    print(config_object)
    timeinfo = config_object["time"]
    starttime = str(timeinfo["time_start"])
    endtime = str(timeinfo["time_end"])
    s_dt = datetime(int(starttime[:4]), int(starttime[4:6]), int(
        starttime[6:8]), hour=0, tzinfo=UTC(0))
    e_dt = datetime(int(endtime[:4]), int(endtime[4:6]), int(
        endtime[6:8]), hour=0, tzinfo=UTC(0))

    areainfo = config_object["areas"]
    areas = areainfo["areas"]
    mkdir()
    return s_dt, e_dt, areas


def main():
    s_dt, e_dt, areas = getconfig()
    downloads_2month(st_dt=s_dt, end_dt=e_dt, areas=areas)


def month_add1(d: datetime):
    from dateutil.relativedelta import relativedelta
    return d + relativedelta(months=1)


def month_add2(mytime: str):  # 20170101
    from dateutil.relativedelta import relativedelta
    _year = int(mytime[:4])
    _month = int(mytime[4:6].lstrip('0'))
    _day = int(mytime[6:].lstrip('0'))
    resultdate = datetime(year=_year, month=_month,
                          day=_day) + relativedelta(months=2)
    return resultdate.strftime('%Y%m%d')


def test():
    # s_dt, e_dt, areas = getconfig()
    # print(s_dt)
    # print(addYears(s_dt, 1))
    # print(datetime(year=2020, month=6, day=1))
    # s_dt = '20170101'
    print(month_add2('20170101'))


if __name__ == '__main__':
    test()
    # main()
