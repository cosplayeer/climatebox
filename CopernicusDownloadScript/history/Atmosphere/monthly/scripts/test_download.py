import cdsapi

c = cdsapi.Client()

c.retrieve(
    'reanalysis-era5-single-levels-monthly-means',
    {
        'product_type': 'monthly_averaged_reanalysis',
        'variable': [
            '100m_u_component_of_wind', '100m_v_component_of_wind', '10m_u_component_of_wind',
            '10m_v_component_of_wind', '10m_wind_speed', '2m_dewpoint_temperature',
            '2m_temperature', 'instantaneous_10m_wind_gust', 'mean_sea_level_pressure',
            'mean_wave_direction', 'mean_wave_period', 'sea_surface_temperature',
            'significant_height_of_combined_wind_waves_and_swell', 'surface_pressure',
        ],
        'year': '2019',
        'month': [
            '01', '02', '03',
            '04', '05', '06',
            '07', '08', '09',
            '10', '11', '12',
        ],
        'time': '00:00',
        'format': 'grib',
    },
    '../data/reanalysis-era5-single-levels-monthly-means-2019.grib')