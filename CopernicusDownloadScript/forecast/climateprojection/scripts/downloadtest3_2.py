import os
import cdsapi

_experiment = 'rcp_4_5'
_model = 'bnu_esm'  # china model
_period = '200601-210012'
_format = 'zip'
_fname = _period + '_' + _experiment + '.' + _format

c = cdsapi.Client()

c.retrieve(
    'projections-cmip5-monthly-single-levels',
    {
        'ensemble_member': 'r1i1p1',
        'format': _format,
        'experiment': _experiment,
        'variable': [
            '10m_u_component_of_wind', '10m_v_component_of_wind', '10m_wind_speed',
            '2m_temperature', 'near_surface_relative_humidity', 'near_surface_specific_humidity',
            'surface_solar_radiation_downwards',
        ],
        'model': _model,
        'period': _period,
    },
    os.path.join('./data', _fname))
