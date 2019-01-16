#!/usr/bin/env python
import cdsapi

c = cdsapi.Client()

c.retrieve(
    'seasonal-monthly-single-levels',
    {
        'originating_centre':'ecmwf',
        'variable':[
            '10m_u_component_of_wind','10m_v_component_of_wind','10m_wind_speed',
            'mean_sea_level_pressure','surface_sensible_heat_flux','surface_solar_radiation',
            'surface_solar_radiation_downwards','surface_thermal_radiation','surface_thermal_radiation_downwards',
            'top_solar_radiation','total_precipitation'
        ],
        'product_type':[
            'monthly_maximum','monthly_mean','monthly_minimum',
            'monthly_standard_deviation'
        ],
        'year':'2015',
        'month':[
            '01','02'
        ],
        'leadtime_month':[
            '1','2','3',
            '4','5','6'
        ],
        'format':'grib',
        'system':'5'
    },
    'download.grib')