import os
from urllib.request import Request, urlopen
# coding=utf-8
import requests
from bs4 import BeautifulSoup
import wget
# create a directory and write the name of directory here
path_to_save = '/home/meteodyn/DYP/climatebox/CopernicusDownloadScript/history/Atmosphere/ERA5SolarDaily/data/epwdata/epw_scripts_download/'
url = 'https://climate.onebuilding.org/WMO_Region_2_Asia/CHN_China/'
# response = urlopen(url)
# res_str = response.content.decode('utf8')
html = requests.get(url).text
soup = BeautifulSoup(html, 'html.parser')
ziplists = []
for a in soup.find_all('a', href=True):
    if a['href'].endswith('.zip'):
        ziplists.append(a['href'])
        # print("Found the URL: %s" % a['href'])
# print(len(ziplists))
c = 0
for z in ziplists:
    c = c+1
    urlzip = url+z
    # print(urlzip)
    target_name = z.split('/')[-1]
    # print(target_name)
    outdir = "./data/epwdata/epw_scripts_download"
    file_name = wget.download(urlzip, out=os.path.join(outdir, target_name))
    print(file_name)
    print("count: %s / %s" % (c, len(ziplists)))
