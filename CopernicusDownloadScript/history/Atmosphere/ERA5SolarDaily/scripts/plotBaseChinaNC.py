# coding=utf-8
import netCDF4 as nc
import numpy
from matplotlib.font_manager import FontProperties
import matplotlib.pyplot as plt
import maskout
# conda install pyproj
from mpl_toolkits.basemap import Basemap
# python3 -m pip install basemap
# font = FontProperties(fname=r"C:\\Windows\\Fonts\\impact.ttf")
# font1 = FontProperties(fname=u"C:\\Windows\\Fonts\\simkai.ttf")
fig = plt.figure(figsize=(16, 9.6))
ax = fig.add_subplot(111)
# ncdata=nc.Dataset(r'2004_500_grtuvw.nc')
ncdata = nc.Dataset('png/pres.mon.ltm.nc')
# data=ncdata.variables['t'][0,:,:]
data = ncdata.variables['pres'][0, :, :]
# ｄａｔａ是二维的，不是线性插值的
# lat=ncdata.variables['latitude'][:]
# lon=ncdata.variables['longitude'][:]
lat = ncdata.variables['lat'][:]
lon = ncdata.variables['lon'][:]
lon1, lon2 = lon[0], lon[-1]
lat1, lat2 = lat[-1], lat[0]
nx = data.shape[1]
ny = data.shape[0]
m = Basemap(llcrnrlon=lon1, llcrnrlat=lat1, urcrnrlon=lon2,
            urcrnrlat=lat2, projection='cyl')
xx, yy = m.makegrid(nx, ny)
yy = yy[::-1]
m.readshapefile('png/country1', 'whatevername', color='gray')
minval, maxval = int(numpy.amin(data)), int(numpy.amax(data))+1
cs = m.contourf(xx, yy, data, range(minval, maxval),
                cmap=plt.cm.get_cmap('jet'))
bar = m.colorbar(cs)
bar.set_ticks(range(minval-1, maxval, 40))
bar.set_ticklabels(range(minval-1, maxval, 40))
clip = maskout.shp2clip(cs, ax, 'png/country1', 'China')
plt.title(u'Python Super Mask')  # , fontproperties=font, fontsize=40)
lon1, lon2 = ax.set_xlim(70, 140)
lat1, lat2 = ax.set_ylim(15, 55)
#signature=u"by 平流层的萝卜"
# plt.text(lon2-(lon2-lon1)*3.0/10,lat2+(lat2-lat1)*0.1/10,signature,fontproperties=font1,fontsize=25)
plt.show()
# plt.savefig('111.png')
