# coding=utf-8
import netCDF4 as nc
import numpy as np
import pandas as pd
from matplotlib.font_manager import FontProperties
import matplotlib.pyplot as plt
import maskout
from scipy.interpolate import Rbf

# conda install pyproj
from mpl_toolkits.basemap import Basemap
# python3 -m pip install basemap
# font = FontProperties(fname=r"C:\\Windows\\Fonts\\impact.ttf")
# font1 = FontProperties(fname=u"C:\\Windows\\Fonts\\simkai.ttf")

# ncdata=nc.Dataset(r'2004_500_grtuvw.nc')
filename = 'text/statistics_solarR2_new.csv'
df = pd.read_csv(filename)
# exit()
# lat=ncdata.variables['latitude'][:]
# lon=ncdata.variables['longitude'][:]
lon = df['lon']
lat = df['lat']


def myplot(v: str):
    fig = plt.figure(figsize=(16, 9.6))
    ax = fig.add_subplot(111)
    if v == 'r2ERA5' or v == 'r2SolarChina':
        biasERA5 = df[v] * 100
    else:
        biasERA5 = df[v]
    # todo
    # 修改ｎｃ网格为不规则网格l
    # 较难
    lon1, lon2 = 73, 136
    lat1, lat2 = 3, 54
    nx = 63
    ny = 51
    olat = np.linspace(lat, lat2, ny)
    olon = np.linspace(lon1, lon2, nx)
    olon, olat = np.meshgrid(olon, olat)
    m = Basemap(llcrnrlon=lon1, llcrnrlat=lat1, urcrnrlon=lon2,
                urcrnrlat=lat2, projection='cyl')
    xx, yy = m.makegrid(nx, ny)
    m.readshapefile('png/country1', 'whatevername', color='gray')
    minval, maxval = int(np.amin(biasERA5)), int(np.amax(biasERA5))
    print(minval)
    print('maxval:%s' % maxval)
    func = Rbf(lon, lat, biasERA5, function='linear')
    bias_new = func(olon, olat)
    cs = m.contourf(olon, olat, bias_new, range(minval, maxval))  # ,
    # cmap=plt.cm.get_cmap('jet')
    bar = m.colorbar(cs)
    bar.set_ticks(range(minval, maxval, 40))
    bar.set_ticklabels(range(minval, maxval, 40))
    clip = maskout.shp2clip(cs, ax, 'png/country1', 'China')
    plt.title(v)  # , fontproperties=font, fontsize=40)
    lon1, lon2 = ax.set_xlim(70, 140)
    lat1, lat2 = ax.set_ylim(15, 55)
    #signature=u"by 平流层的萝卜"
    # plt.text(lon2-(lon2-lon1)*3.0/10,lat2+(lat2-lat1)*0.1/10,signature,fontproperties=font1,fontsize=25)
    # plt.show()
    plt.savefig('png/'+v+'_new.png')


vlists = ['biasERA5', 'biasSolarChina',
          'rmseERA5', 'rmseSolarChina']
# vlists = ['r2ERA5', 'r2SolarChina']

for v in vlists:
    print('processing %s' % v)
    myplot(v)
