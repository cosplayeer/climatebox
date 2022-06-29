import os
import cdsapi

_model = 'cnrm_cm5_2'
_period = '195001-199912'
_fname = _period + '.zip'
c = cdsapi.Client()

c.retrieve(
    'projections-cmip5-monthly-single-levels',
    {
        'ensemble_member': 'r1i1p1',
        'format': 'zip',
        'experiment': 'historical',
        'variable': [
            '10m_u_component_of_wind', '10m_v_component_of_wind', '10m_wind_speed',
            '2m_temperature', 'near_surface_relative_humidity', 'near_surface_specific_humidity',
            'surface_solar_radiation_downwards',
        ],
        'model': _model,
        'period': _period,
    },
    os.path.join('./data', _fname))
