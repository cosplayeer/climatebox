import cdsapi


# year: 1999-2019

def main():
    monthlists = ['12']
    # for iyear in range(2000,2002):
    for iyear in range(2007, 2008):
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
                        'surface_solar_radiation_downwards',
                    ],
                    'product_type': [
                        'ensemble_mean', 'monthly_mean',
                    ],
                    'month': str(imonth),
                    'year': str(iyear),
                    # 'leadtime_month': ['1','2','3'],
                    'leadtime_month': ['1', '2', '3', '4', '5', '6'],
                    # 'leadtime_month': ['4'],
                },
                # './data/seasonal-monthly-sfc-' + str(iyear) + '-' + str(imonth) + '_leadtime123.grib')
                './dataRadiation/seasonal-monthly-rad-' + str(iyear) + '-' + str(imonth) + '_leadtime123456.grib')


if __name__ == '__main__':
    main()
