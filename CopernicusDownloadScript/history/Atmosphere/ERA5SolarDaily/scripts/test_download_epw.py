import json
import re
from urllib.request import Request, urlopen
# coding=utf-8
import requests
from bs4 import BeautifulSoup
# create a directory and write the name of directory here
path_to_save = '/home/meteodyn/DYP/climatebox/CopernicusDownloadScript/history/Atmosphere/ERA5SolarDaily/data/epwdata/epw_scripts_download/'
url = 'https://climate.onebuilding.org/WMO_Region_2_Asia/CHN_China/'
# response = urlopen(url)
# res_str = response.content.decode('utf8')
html = requests.get(url).text
soup = BeautifulSoup(html, 'html.parser')
print(soup)
# if html:
#     try:
#         data = json.loads(html)
#     except Exception as ex:
#         print(ex)
# print(html)
# data = json.loads(response.read().decode('utf8'))
# print(response.read().decode('utf8'))
# response = urlopen(
#     'https://github.com/NREL/EnergyPlus/raw/develop/weather/master.geojson')
# data = json.loads(response.read().decode('utf8'))
# count = 0
# for location in data['features']:
#     for file_type in ['epw']:
#         match = re.search(r'href=[\'"]?([^\'" >]+)',
#                           location['properties'][file_type])
#         if match:
#             url = match.group(1)
#             name = url[url.rfind('/') + 1:]
#             count += 1
#             print(count, ':', name, '\t')
#             response = Request(url, headers={'User-Agent': "Magic Browser"})
#             with open(path_to_save + name, 'wb') as f:
#                 f.write(urlopen(response).read())
# print('done!')
