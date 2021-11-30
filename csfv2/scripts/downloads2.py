def getmonthlist(year=2021,month=11,day=1):
    import os
    from datetime import datetime, timedelta
    downdir="https://www.ncei.noaa.gov/data/climate-forecast-system/access/operational-9-month-forecast/monthly-means/2021/202111/20211101/2021110100/"
    fromdate=datetime(year,month,day)
    fromdate1=fromdate+timedelta(days=32)
    print(fromdate1.strftime('%Y%m'))
    frecastmonthlist=[]
    i=1
    while i < 10:
        frecastmonthlist.append((fromdate+timedelta(days=i*31)).strftime('%Y%m'))
        i+=1
    return frecastmonthlist


def download(frecastmonthlist):
    for f in frecastmonthlist:
        os.system('wget -c -N --directory-prefix=data '+downdir+'flxf.01.'+fromdate+'0100.'+str(f)+'.avrg.grib.grb2')

if __name__ == '__main__':
    mlist=getmonthlist(year=2021,month=11,day=1)
    print(mlist)
    #测试ｍｌｉｓｔ是否正确再下载
    download(frecastmonthlist=mlist)