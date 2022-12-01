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


c = cdsapi.Client()


def downloads_era5_rad(current_dt: datetime, areas: str):
    c.retrieve(
        'reanalysis-era5-single-levels',
        {
            'product_type': 'reanalysis',
            # 'variable': [
            #     'clear_sky_direct_solar_radiation_at_surface',
            #     'near_ir_albedo_for_diffuse_radiation', 'near_ir_albedo_for_direct_radiation',
            #     'surface_net_solar_radiation', 'surface_net_solar_radiation_clear_sky',
            #     'surface_net_thermal_radiation', 'surface_net_thermal_radiation_clear_sky', 'surface_sensible_heat_flux',
            #     'surface_solar_radiation_downward_clear_sky', 'surface_solar_radiation_downwards',
            #     'total_sky_direct_solar_radiation_at_surface',
            # ],
            'variable': ['surface_net_solar_radiation_clear_sky'],
            # ssrc good, ssrd bad.
            'year': current_dt.year,
            'month': current_dt.month,
            'day': current_dt.day,
            'time': [
                '00:00', '01:00', '02:00', '03:00', '04:00', '05:00',
                '06:00',
                '07:00', '08:00', '09:00', '10:00', '11:00', '12:00',
                '13:00', '14:00', '15:00', '16:00', '17:00', '18:00',
                '19:00', '20:00', '21:00', '22:00', '23:00',
            ],
            'grid': '0.25/0.25',
            'format': 'netcdf',
            'area': areas.split(),

        },
        os.path.join('data', 'era5_rad', 'era5_download_nc', 'ERA5_rad_' + str(current_dt.strftime('%Y%m%d')) + '.nc'))
    # os.path.join('/media/meso/bigdata18/ERA5/origin', 'ERA5_sfc_' + str(current_dt.strftime('%Y%m%d')) + '.grib'))


def mkdir():
    dirpath = os.path.join('data', 'era5_rad', 'era5_download_nc')
    if not os.path.exists(dirpath):
        os.mkdir(dirpath)
    apifile = os.path.join(os.environ['HOME'], '.cdsapirc')
    if not os.path.exists(apifile):
        shutil.copyfile(".cdsapirc", apifile)


def downloads_era5(st_dt: datetime, end_dt: datetime, areas: str):
    current_dt = st_dt
    while current_dt <= end_dt:
        print(current_dt)
        downloads_era5_rad(current_dt, areas)
        current_dt = current_dt.__add__(timedelta(hours=24))
# input
#s_dt = datetime(2018, 12, 30, hour=0, tzinfo=UTC(0))
#e_dt = datetime(2018, 12, 31, hour=0, tzinfo=UTC(0))


def getconfig():
    config_object = ConfigParser()
    config_object.read("scripts/era5_config.ini", encoding='UTF-8')
    # secs = config_object.sections()
    # print(secs)
    timeinfo = config_object["time"]
    # print(timeinfo)
    starttime = str(timeinfo["time_start"])
    endtime = str(timeinfo["time_end"])
    s_dt = datetime(int(starttime[:4]), int(starttime[4:6]), int(
        starttime[6:8]), hour=0, tzinfo=UTC(0))
    e_dt = datetime(int(endtime[:4]), int(endtime[4:6]), int(
        endtime[6:8]), hour=0, tzinfo=UTC(0))

    areainfo = config_object["areas"]
    areas = areainfo["areas"]

    return s_dt, e_dt, areas


def main():
    s_dt, e_dt, areas = getconfig()
    mkdir()
    downloads_era5(st_dt=s_dt, end_dt=e_dt, areas=areas)


def test():
    s_dt, e_dt, areas = getconfig()
    # print(s_dt)
    # print(e_dt)
    # print(areas.split())
    # print(type(areas))
    mkdir()


if __name__ == '__main__':
    # test()
    main()
