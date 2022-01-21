import numpy as np
import Nio
import Ngl

# forecast
fname1 = "data_0.25_2022/wind202101.nc"
fname2 = "data_0.25_2022/wind202102.nc"
fname3 = "data_0.25_2022/wind202103.nc"
fname4 = "data_0.25_2022/wind202104.nc"
fname5 = "data_0.25_2022/wind202105.nc"
fname6 = "data_0.25_2022/wind202106.nc"

fname1Era5 = "data_0.25_2021/ERA5Wind202101.nc"
fname2Era5 = "data_0.25_2021/ERA5Wind202102.nc"
fname3Era5 = "data_0.25_2021/ERA5Wind202103.nc"
fname4Era5 = "data_0.25_2021/ERA5Wind202104.nc"
fname5Era5 = "data_0.25_2021/ERA5Wind202105.nc"
fname6Era5 = "data_0.25_2021/ERA5Wind202106.nc"
# fname3 = "data2/12month/seasonal-monthly-sfc-month03.nc"
# fname4 = "data2/12month/seasonal-monthly-sfc-month04.nc"
# fname5 = "data2/12month/seasonal-monthly-sfc-month05.nc"
# fname6 = "data2/12month/seasonal-monthly-sfc-month06.nc"
# fname7 = "data2/12month/seasonal-monthly-sfc-month07.nc"
# fname8 = "data2/12month/seasonal-monthly-sfc-month08.nc"
# forecast f
f1 = Nio.open_file(fname1, mode='r',
                   options=None, format='nc')

# Wind10_forecast =f.variables['10SI_GDS0_SFC']
Wind10_forecast1 = f1.variables['windspeed']
print(Wind10_forecast1.shape)
# f2
f2 = Nio.open_file(fname2, mode='r',
                   options=None, format='nc')
Wind10_forecast2 = f2.variables['windspeed']
# f3
f3 = Nio.open_file(fname3, mode='r',
                   options=None, format='nc')
Wind10_forecast3 = f3.variables['windspeed']
# f4
f4 = Nio.open_file(fname4, mode='r',
                   options=None, format='nc')
Wind10_forecast4 = f4.variables['windspeed']
# f5
f5 = Nio.open_file(fname5, mode='r',
                   options=None, format='nc')
Wind10_forecast5 = f5.variables['windspeed']
# f6
f6 = Nio.open_file(fname6, mode='r',
                   options=None, format='nc')
Wind10_forecast6 = f6.variables['windspeed']

# f**
f12 = Nio.open_file(fname1Era5, mode='r',
                    options=None, format='nc')
Wind10_era5_01 = f12.variables['windspeed']
f22 = Nio.open_file(fname2Era5, mode='r',
                    options=None, format='nc')
Wind10_era5_02 = f22.variables['windspeed']
f32 = Nio.open_file(fname3Era5, mode='r',
                    options=None, format='nc')
Wind10_era5_03 = f32.variables['windspeed']
f42 = Nio.open_file(fname4Era5, mode='r',
                    options=None, format='nc')
Wind10_era5_04 = f42.variables['windspeed']
f52 = Nio.open_file(fname5Era5, mode='r',
                    options=None, format='nc')
Wind10_era5_05 = f52.variables['windspeed']
f62 = Nio.open_file(fname6Era5, mode='r',
                    options=None, format='nc')
Wind10_era5_06 = f62.variables['windspeed']


# 处理资料, 初始化

print(type(Wind10_forecast1))
wind10_result_percent1 = Wind10_forecast1
wind10_result_percent2 = Wind10_forecast2
wind10_result_percent3 = Wind10_forecast3
wind10_result_percent4 = Wind10_forecast4
wind10_result_percent5 = Wind10_forecast5
wind10_result_percent6 = Wind10_forecast6
# for i in range(6):
# commended dyp 4 lines
wind10_result_percent1 = np.subtract(
    Wind10_forecast1, Wind10_era5_01)
wind10_result_percent1 = np.divide(
    wind10_result_percent1, Wind10_era5_01)

wind10_result_percent2 = np.subtract(
    Wind10_forecast2, Wind10_era5_02)
wind10_result_percent2 = np.divide(
    wind10_result_percent2, Wind10_era5_02)

wind10_result_percent3 = np.subtract(
    Wind10_forecast3, Wind10_era5_03)
wind10_result_percent3 = np.divide(
    wind10_result_percent3, Wind10_era5_03)

wind10_result_percent4 = np.subtract(
    Wind10_forecast4, Wind10_era5_04)
wind10_result_percent4 = np.divide(
    wind10_result_percent4, Wind10_era5_04)

wind10_result_percent5 = np.subtract(
    Wind10_forecast5, Wind10_era5_05)
wind10_result_percent5 = np.divide(
    wind10_result_percent5, Wind10_era5_05)

wind10_result_percent6 = np.subtract(
    Wind10_forecast6, Wind10_era5_06)
wind10_result_percent6 = np.divide(
    wind10_result_percent6, Wind10_era5_06)


# Access the temperature arrays for the first 6 time steps.
# 6 x 4
nplots = 6
# 8 x 6
# nplots = 48

# Save lat and lon to numpy arrays
lat = f1.variables["lat"][:]
lon = f1.variables["lon"][:]
#
# Define a color map.
#
cmap = np.array([[1.00, .000, .000],
                 [.950, .010, .000], [.870, .050, .000], [.800, .090, .000],
                 [.700, .090, .000], [.700, .120, .000], [.700, .180, .000],
                 [.700, .260, .000], [.700, .285, .000], [.680, .330, .000],
                 [.570, .420, .000], [.560, .530, .000], [.550, .550, .000],
                 [.130, .570, .000], [.060, .680, .000], [.000, .690, .000],
                 [.000, .700, .100], [.000, .600, .300], [.000, .500, .500],
                 [.000, .400, .700], [.000, .300, .700], [.000, .200, .700],
                 [.000, .100, .700], [.000, .000, .700], [.100, .100, .700],
                 [.200, .200, .700], [.300, .300, .700], [.420, .400, .700],
                 [.560, .500, .700], [.610, .600, .700], [.700, .700, .700]],
                'f')

# --- Indicate where to send graphics
rlist = Ngl.Resources()
wks_type = "png"
#wks = Ngl.open_wks(wks_type,"pic/Wind10_ensemble_forecast_minus_average",rlist)
wks = Ngl.open_wks(
    wks_type, "pic/Wind10_forecast_minus_ERA5_percent_test", rlist)

# Turn off draw for the individual plots, since we are going to
# panel them later.
#
resources = Ngl.Resources()
resources.nglDraw = False
resources.nglFrame = False

# Loop through the timesteps and create each plot, titling each
# one according to which timestep it is.
#
plot = []
# resources.cycle
resources.cnFillOn = True    # Turn on contour fill.
resources.cnFillPalette = "MPL_viridis"
resources.cnLineLabelsOn = False   # Turn off contour labels

#
# Set some font heights to make them slightly bigger than the default.
# Turn off nglScale, because this resource wants to set the axes font
# heights for you.
#
resources.nglScale = False
resources.tiMainFontHeightF = 0.037
resources.lbLabelFontHeightF = 0.032
resources.tmXBLabelFontHeightF = 0.030
resources.tmYLLabelFontHeightF = 0.030

# for i in range(0, nplots):
#     resources.tiMainString = "WindSpeed in forecast lead month = {}".format(i)
#     # plot.append(Ngl.contour(wks,Ngl.add_cyclic(Wind10[i,0,:,:]),resources))
#     # plot.append(Ngl.contour(wks, Ngl.add_cyclic(
#     #     wind10_result_percent[i, :, :]), resources))
#     plot.append(Ngl.contour(wks,
#                             wind10_result_percent1, resources))
# resources.tiMainString = "WindSpeed in forecast lead month = 1"
# plot.append(Ngl.contour(wks,
#                         wind10_result_percent1, resources))


# Now add some extra white space around each plot.
#

panelres = Ngl.Resources()
panelres.nglPanelYWhiteSpacePercent = 5.
panelres.nglPanelXWhiteSpacePercent = 5.
# Ngl.panel(wks,plot[0:4],[2,2],panelres)    # Draw 2 rows/2 columns of plots.

# This section will set resources for drawing contour plots over a map.
#
# del resources.tiMainString  # Don't set a main title.

resources.cnFillPalette = cmap  # Set color map using RGB values
resources.sfXArray = lon  # Portion of map on which to overlay
resources.sfYArray = lat  # contour plot.

resources.cnLineLabelsOn = False   # Turn off contour line labels.
resources.cnLinesOn = False   # Turn off contour lines.
resources.cnFillOn = True    # Turn on contour fill.

# resources.cnLevelSelectionMode = "AutomaticLevels"   # Select contour levels. dyp
resources.cnLevelSelectionMode = "ManualLevels"
resources.cnMinLevelValF = -1
resources.cnMaxLevelValF = 10
resources.cnLevelSpacingF = 1

resources.tmXBLabelFontHeightF = 0.020
resources.tmYLLabelFontHeightF = 0.020

resources.mpLimitMode = "LatLon"  # Limit portion of map that is viewed.
resources.mpMinLatF = float(min(lat))
resources.mpMaxLatF = float(max(lat))
resources.mpMinLonF = float(min(lon))
resources.mpMaxLonF = float(max(lon))

resources.pmLabelBarDisplayMode = "Never"   # Turn off labelbar, since we
# will use a global labelbar
# in the panel.

resources.mpPerimOn = True            # Turn on map perimeter.
resources.mpGridAndLimbOn = False           # Turn off map grid.

plot = []
# for i in range(0, nplots):
#     # plot.append(Ngl.contour_map(wks,Ngl.add_cyclic(Wind10[i,0,:,:]),resources))
#     # plot.append(Ngl.contour_map(wks, Ngl.add_cyclic(
#     #     wind10_result_percent[i, :, :]), resources))
#     plot.append(Ngl.contour_map(wks,
#                                 wind10_result_percent+str(i+1), resources))
plot.append(Ngl.contour_map(wks,
                            wind10_result_percent1, resources))
plot.append(Ngl.contour_map(wks,
                            wind10_result_percent2, resources))
plot.append(Ngl.contour_map(wks,
                            wind10_result_percent3, resources))
plot.append(Ngl.contour_map(wks,
                            wind10_result_percent4, resources))
plot.append(Ngl.contour_map(wks,
                            wind10_result_percent5, resources))
plot.append(Ngl.contour_map(wks,
                            wind10_result_percent6, resources))


# Set some resources for the paneled plots.
#
del panelres
panelres = Ngl.Resources()

#
# Set up some labelbar resources.  Set nglPanelLabelBar to True to
# indicate you want to draw a common labelbar at the bottom of the
# plots.
#
panelres.nglPanelLabelBar = True     # Turn on panel labelbar
panelres.nglPanelLabelBarLabelFontHeightF = 0.015    # Labelbar font height
panelres.nglPanelLabelBarHeightF = 0.0750  # 0.1750   # Height of labelbar
panelres.nglPanelLabelBarWidthF = 0.700    # Width of labelbar
panelres.lbLabelFont = "helvetica-bold"  # Labelbar font
panelres.nglPanelTop = 0.935
panelres.nglPanelFigureStrings = ["1", "2", "3", "4", "5", "6", "G", "H", "I", "J", "K", "L", "M", "N",
                                  "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X"]
panelres.nglPanelFigureStringsJust = "BottomRight"

#
# You can have PyNGL selection the best paper orientation for
# the shape of plots you are drawing.  This resource is for PDF or
# PS output only.
#
if(wks_type == "ps" or wks_type == "pdf"):
    panelres.nglPaperOrientation = "Auto"

#
# Draw 3 rows and 2 columns of plots.
Ngl.panel(wks, plot[0:nplots], [3, 2], panelres)
#
# Draw 6 rows and 4 columns of plots.
# Ngl.panel(wks,plot[0:nplots],[6,4],panelres)
#
# Draw 8 rows and 6 columns of plots.
# Ngl.panel(wks,plot[0:nplots],[8,6],panelres)

Ngl.end()

print(wind10_result_percent1.shape)
