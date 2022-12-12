# coding=utf-8
import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
from scipy.interpolate import Rbf
import maskout

fig = plt.figure(figsize=(17, 8.85), dpi=80)  # figsize=(16,9.6)
filename = 'text/statistics_solarR2_new.csv'
df = pd.read_csv(filename)
ax = plt.axes()
lon = df['lon']
lat = df['lat']
biasERA5 = df['biasERA5']

# 73°33′E至135°05′E；纬度范围：3°51′N至53°33′N
olat = np.linspace(3, 54, 51)
olon = np.linspace(73, 136, 63)
olon, olat = np.meshgrid(olon, olat)
func = Rbf(lon, lat, biasERA5, function='linear')
bias_new = func(olon, olat)
cs = ax.contourf(olon, olat, bias_new,
                 levels=np.arange(-10, 100, 10), extend='both')
# 画图
# clip = maskout.shp2clip(
#     cs, ax, 'png/Mainland+HN+TW+NearSea.shp', 420000)
clip = maskout.shp2clip(cs, ax, 'png/country1', 'China')  # 'China')
plt.show()
# plt.savefig('png/biasERA5.png')
