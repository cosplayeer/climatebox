import numpy as numpy
import Nio
import Ngl

# fname = "data/SeasonalDaily20190101to5160.grib"
fname = "data/MonthlyWaveEnsemble201901_201906.grib"
f = Nio.open_file(fname, mode='r',\
    options = None, format='grib')
# Significant wave height
mwheight = f.variables['SWH_GDS0_MSL_S123_1']
# Mean wave direction
mwdirection = f.variables['MWD_GDS0_MSL_S123_1']
mwperiod =f.variables['MWP_GDS0_MSL_S123_1']
# Mean wave period

var = mwheight
# Access the temperature arrays for the first 6 time steps.
# 6 x 4
nplots = 6
# 8 x 6
# nplots = 48

#Save lat and lon to numpy arrays
lat = f.variables["g0_lat_4"][:]
lon = f.variables["g0_lon_5"][:]
print(type(lon))
lon = numpy.append(lon,[360.0])
print(lon)

#
# Define a color map.
#
cmap = numpy.array([[1.00,.000,.000],\
                    [.950,.010,.000],[.870,.050,.000],[.800,.090,.000],\
                    [.700,.090,.000],[.700,.120,.000],[.700,.180,.000],\
                    [.700,.260,.000],[.700,.285,.000],[.680,.330,.000],\
                    [.570,.420,.000],[.560,.530,.000],[.550,.550,.000],\
                    [.130,.570,.000],[.060,.680,.000],[.000,.690,.000],\
                    [.000,.700,.100],[.000,.600,.300],[.000,.500,.500],\
                    [.000,.400,.700],[.000,.300,.700],[.000,.200,.700],\
                    [.000,.100,.700],[.000,.000,.700],[.100,.100,.700],\
                    [.200,.200,.700],[.300,.300,.700],[.420,.400,.700],\
                    [.560,.500,.700],[.610,.600,.700],[.700,.700,.700]],
                    'f')

#--- Indicate where to send graphics
rlist = Ngl.Resources()
wks_type = "png"
wks = Ngl.open_wks(wks_type,"panel1",rlist)

# Turn off draw for the individual plots, since we are going to
# panel them later.
#
resources          = Ngl.Resources()
resources.nglDraw  = False
resources.nglFrame = False

# Loop through the timesteps and create each plot, titling each
# one according to which timestep it is.
#
plot = []
#resources.cycle
resources.cnFillOn            = True    # Turn on contour fill.
resources.cnFillPalette       = "MPL_viridis"
resources.cnLineLabelsOn      = False   # Turn off contour labels

#
# Set some font heights to make them slightly bigger than the default.
# Turn off nglScale, because this resource wants to set the axes font
# heights for you.
#
resources.nglScale               = False
resources.tiMainFontHeightF      = 0.037
resources.lbLabelFontHeightF     = 0.032
resources.tmXBLabelFontHeightF   = 0.030
resources.tmYLLabelFontHeightF   = 0.030

for i in range(0,nplots):
  resources.tiMainString  = "Significant wave height at time = {}".format(i)
  # plot.append(Ngl.contour(wks,Ngl.add_cyclic(mwheight[i,:,:]),resources))
  # plot.append(Ngl.contour(wks,mwheight[i,:,:],resources))

var_cycle = Ngl.add_cyclic(var[3,:,:])
print(var[3,:,:].shape)
print(var_cycle.shape)
# Ngl.panel(wks,plot[0:4],[2,2])    # Draw 2 rows/2 columns of plots.

# Now add some extra white space around each plot.
#

panelres                            = Ngl.Resources()
panelres.nglPanelYWhiteSpacePercent = 5.
panelres.nglPanelXWhiteSpacePercent = 5.
# Ngl.panel(wks,plot[0:4],[2,2],panelres)    # Draw 2 rows/2 columns of plots.

# This section will set resources for drawing contour plots over a map.
#
del resources.tiMainString  # Don't set a main title.

# resources.cnFillPalette  = cmap # Set color map using RGB values
resources.sfXArray       = lon  # Portion of map on which to overlay
resources.sfYArray       = lat  # contour plot.

resources.cnLineLabelsOn = False   # Turn off contour line labels.
resources.cnLinesOn      = False   # Turn off contour lines.
resources.cnFillOn       = True    # Turn on contour fill.
 #dyp
# resources.cnLevelSelectionMode = "ManualLevels"  # Select contour levels.
# resources.cnMinLevelValF       = 0.
# resources.cnMaxLevelValF       = 8
# resources.cnLevelSpacingF      =   0.5

resources.tmXBLabelFontHeightF   = 0.020
resources.tmYLLabelFontHeightF   = 0.020

resources.mpLimitMode    = "LatLon"  # Limit portion of map that is viewed.
resources.mpMinLatF      = float(min(lat))
resources.mpMaxLatF      = float(max(lat))
resources.mpMinLonF      = float(min(lon))
resources.mpMaxLonF      = float(max(lon))

resources.pmLabelBarDisplayMode = "Never"   # Turn off labelbar, since we
                                            # will use a global labelbar
                                            # in the panel.

resources.mpPerimOn       = True            # Turn on map perimeter.
resources.mpGridAndLimbOn = False           # Turn off map grid.

plot = []
for i in range(0,nplots):
  plot.append(Ngl.contour_map(wks,Ngl.add_cyclic(var[i,:,:]),resources))
  # plot.append(Ngl.contour_map(wks,mwheight[i,:,:],resources))

# Set some resources for the paneled plots.
#
del panelres
panelres          = Ngl.Resources()

#
# Set up some labelbar resources.  Set nglPanelLabelBar to True to
# indicate you want to draw a common labelbar at the bottom of the
# plots. 
#
panelres.nglPanelLabelBar                 = True     # Turn on panel labelbar
panelres.nglPanelLabelBarLabelFontHeightF = 0.015    # Labelbar font height
panelres.nglPanelLabelBarHeightF          = 0.10   #0.1750   # Height of labelbar
panelres.nglPanelLabelBarWidthF           = 0.700    # Width of labelbar
panelres.lbLabelFont                      = "helvetica-bold" # Labelbar font
panelres.nglPanelTop                      = 0.935
panelres.nglPanelFigureStrings            = ["01","02","03","04","05","06","G","H","I","J","K","L","M","N",
                                             "O","P","Q","R","S","T","U","V","W","X"]
panelres.nglPanelFigureStringsJust        = "BottomRight"

#
# You can have PyNGL selection the best paper orientation for
# the shape of plots you are drawing.  This resource is for PDF or
# PS output only.
#
if(wks_type == "ps" or wks_type == "pdf"):
  panelres.nglPaperOrientation = "Auto"   

#
# Draw 3 rows and 2 columns of plots.
Ngl.panel(wks,plot[0:nplots],[3,2],panelres)  
#
# Draw 6 rows and 4 columns of plots.
# Ngl.panel(wks,plot[0:nplots],[6,4],panelres)  
#
# Draw 8 rows and 6 columns of plots.
# Ngl.panel(wks,plot[0:nplots],[8,6],panelres)  

Ngl.end()

print(var)

