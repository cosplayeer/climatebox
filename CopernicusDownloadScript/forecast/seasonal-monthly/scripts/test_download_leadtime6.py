import cdsapi



# year: 1999-2019

def main():
    monthlists = ['07']
    # for iyear in range(2005,2021):
    for iyear in range(2004,2021):
    # for iyear in range(2020,2021):
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
                        # '10m_u_component_of_wind', '10m_v_component_of_wind',
                        '10m_wind_speed',
                    ],
                    'product_type': [
                        'ensemble_mean','monthly_mean',
                    ],
                    'month': str(imonth),
                    'year': str(iyear),
                    # 'leadtime_month': ['1','2','3'],
                    'leadtime_month': ['1','2','3','4','5','6'],
                    # 'leadtime_month': ['4'],
                },
                # './data/seasonal-monthly-sfc-' + str(iyear) + '-' + str(imonth) + '_leadtime123.grib')
                './data/seasonal-monthly-sfc-' + str(iyear) + '-' + str(imonth) + '_leadtime123456.grib')

if __name__ == '__main__':
    main()
