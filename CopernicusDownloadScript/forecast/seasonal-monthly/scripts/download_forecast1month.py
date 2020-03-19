import cdsapi

c = cdsapi.Client()

c.retrieve(
    'seasonal-monthly-single-levels',
    {
        'originating_centre': 'ecmwf',
        'system': '5',
        'variable': [
            '10m_u_component_of_wind', '10m_v_component_of_wind', '10m_wind_gust_since_previous_post_processing',
            '10m_wind_speed','2m_temperature', 'sea_surface_temperature',
        ],
        'product_type': [
            'ensemble_mean', 'hindcast_climate_mean', 'monthly_maximum',
            'monthly_mean', 'monthly_minimum', 'monthly_standard_deviation',
        ],
        'year': '2020',
        'month': '02',
        'leadtime_month': [
            '1', '2', '3',
            '4', '5', '6',
        ],
        'format': 'grib',
    },
    '../data/seasonal-monthly-sfc-2020-02_1-6_new.grib')