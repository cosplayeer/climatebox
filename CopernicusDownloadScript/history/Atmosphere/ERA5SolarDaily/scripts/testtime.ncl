load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_string.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/contrib/cd_inv_string.ncl"

fil = systemfunc("ls data/cfsv2_rad_1hourly/dswsfc.cdas1.2018*.grb2")

a=addfiles(fil, "r")
ListSetType(a, "cat")

t = a[:]->initial_time0_hours
siymdh = cd_string(t, "%Y%N%D %H:%M:%S")
print(siymdh)