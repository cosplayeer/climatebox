#!/usr/bin/python

import argparse
import cdsapi

def setkeywords():
    parser = argparse.ArgumentParser()
    parser.add_argument('--year',type=str,default=None)
    parser.add_argument('--month',type=str, default = None)
    args = parser.parse_args()
    #print(args.year,args.month)
    return args.year,args.month

def demo(year,month):
    demo.year = year
    demo.month = month
    demo.name = "ERA5MonthlySFC"+demo.year+demo.month+".nc"

def rundemo():
    year, month = setkeywords()
    demo(year, month)

def run():
    rundemo()
    c = cdsapi.Client()
    c.retrieve(
        'reanalysis-era5-single-levels-monthly-means',
        {
            'product_type':'monthly_averaged_reanalysis',
            'variable':[
                '10m_u_component_of_wind'
            ],
            #'year':2016,
            #'month':01,
            'year':demo.year,
            'month':demo.month,
            'time':'00:00',
            'format':'netcdf',
        },
        demo.name)

if __name__ == '__main__':
    #rundemo()
    run()
