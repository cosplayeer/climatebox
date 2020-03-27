import cdsapi



# year: 1999-2018

def main():
    monthlists = ['03']
    #for iyear in range(1999,2018):
    for iyear in range(2020,1999,-1):
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
                        '10m_u_component_of_wind', '10m_v_component_of_wind',
                        '10m_wind_speed','10m_wind_gust_since_previous_post_processing',
                    ],
                    'product_type': [
                        'ensemble_mean','monthly_mean',
                    ],
                    'month': str(imonth),
                    'year': str(iyear),
                    'leadtime_month': ['1','2','3'],
                },
                './data/seasonal-monthly-sfc-' + str(iyear) + '-' + str(imonth) + '_leadtime123.grib')

if __name__ == '__main__':
    main()
