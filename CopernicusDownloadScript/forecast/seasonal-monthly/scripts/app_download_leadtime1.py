import cdsapi



# year: 1999-2018

def main():
    monthlists = ['01','02','03','04','05','06',
                    '07','08','09','10','11','12']
    #for iyear in range(1999,2018):
    for iyear in range(2018,2020):
        for imonth in monthlists:
            print("downloading " + str(iyear) + str(imonth))
            c = cdsapi.Client()
            c.retrieve(
                'seasonal-monthly-single-levels',
                {
                    'format': 'grib',
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
                    'month': str(imonth),
                    'year': str(iyear),
                    'leadtime_month': '1',
                },
                './data/seasonal-monthly-sfc-' + str(iyear) + '-' + str(imonth) + '_1.grib')

if __name__ == '__main__':
    main()
