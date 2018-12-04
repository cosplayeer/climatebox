#!/bin/bash
#goal: extract time series file for one given point

# goal: entered a direction, and
# extract wind profile time series files
# one file for one point

direction=$1
if [ $# != 1 ]; then
   echo "Usage: ./vertical_integration.sh Direction (0.0 - 360.0)"
   exit -1
fi
ncltempfile="verticalversion2.ncl"
cat > ${ncltempfile}<<EOF
load "/usr/ncl/lib/ncarg/nclscripts/csm/gsn_code.ncl"    
load "/usr/ncl/lib/ncarg/nclscripts/wrf/WRFUserARW.ncl"

dirname = "~/MSP/Shell/WORKSPACE/huanghewei/outdata/WrfOut/d01/"
;files = systemfunc("ls  " + dirname + "wrfout_d01_2014-01-*" + "| head -n 300")
files = systemfunc("ls  " + dirname + "wrfout_d01_2014-01-*")
a = addfiles(files, "r")
filetime = wrf_user_list_times(a)
lat2d = wrf_user_getvar(a,"XLAT",0)
lon2d = wrf_user_getvar(a,"XLONG",0)
ter2d = wrf_user_getvar(a,"ter",0)

z  = wrf_user_getvar(a, "z", -1)   ; grid point height
u  = wrf_user_getvar(a, "ua", -1)  ; U component of wind on mass point 
v  = wrf_user_getvar(a, "va", -1)  ; V component of wind on mass point 
uvmet = wrf_user_getvar(a,"uvmet", -1)
umet  = uvmet(0,:,:,:,:)
vmet  = uvmet(1,:,:,:,:)

; for horizontal interpolation    
dim1=dimsizes(z(:,0,0,0))
dim2=dimsizes(z(0,:,0,0))
dim3=dimsizes(z(0,0,:,0))
dim4=dimsizes(z(0,0,0,:))
z0  = new((/dim1,dim2,dim3,dim4/),float)
do ii = 0,dim1-1
        do jj = 0,dim2-1
                z0(ii,jj,:,:)= ter2d
        end do
end do
; changed the vertical axis from z to z1 so we extract a plane at a height above the ground,
; not above the sea level.
z1  = z 
z1  = z - z0

;generate the list of points to interpolate to
dims = dimsizes(lat2d)
plane = (/ dims(1)/2, dims(0)/2 /)  ; pivot point (x,y) through center of domain
angle = ${direction}
opts = False                        
lon_plane = wrf_user_intrp2d(lon2d, plane, angle, opts)
lat_plane = wrf_user_intrp2d(lat2d, plane, angle, opts)
lonlist = (/lon_plane/)
latlist = (/lat_plane/)
u_plane100 = wrf_user_intrp3d(umet,z1,"h",100,0,False)
v_plane100 = wrf_user_intrp3d(vmet,z1,"h",100,0,False)
u_plane200 = wrf_user_intrp3d(umet,z1,"h",200,0,False)
v_plane200 = wrf_user_intrp3d(vmet,z1,"h",200,0,False)
u_plane300 = wrf_user_intrp3d(umet,z1,"h",300,0,False)
v_plane300 = wrf_user_intrp3d(vmet,z1,"h",300,0,False)
u_plane400 = wrf_user_intrp3d(umet,z1,"h",400,0,False)
v_plane400 = wrf_user_intrp3d(vmet,z1,"h",400,0,False)

; cycle to output
i = 0
n = dimsizes(lonlist)
do while (i .lt. n - 1)
    lon = lonlist(i)
    lat = latlist(i)
    
    u_plane100_mx = rcm2points(lat2d(:,:), lon2d(:,:), u_plane100, lat, lon, 0) 
    v_plane100_mx = rcm2points(lat2d(:,:), lon2d(:,:), v_plane100, lat, lon, 0) 
    u_plane200_mx = rcm2points(lat2d(:,:), lon2d(:,:), u_plane200, lat, lon, 0) 
    v_plane200_mx = rcm2points(lat2d(:,:), lon2d(:,:), v_plane200, lat, lon, 0) 
    u_plane300_mx = rcm2points(lat2d(:,:), lon2d(:,:), u_plane300, lat, lon, 0) 
    v_plane300_mx = rcm2points(lat2d(:,:), lon2d(:,:), v_plane300, lat, lon, 0) 
    u_plane400_mx = rcm2points(lat2d(:,:), lon2d(:,:), u_plane400, lat, lon, 0) 
    v_plane400_mx = rcm2points(lat2d(:,:), lon2d(:,:), v_plane400, lat, lon, 0) 
    
    foutf = "ProfileTimeSeries_" + lon + "_" + lat + ".csv"
    alist = [/filetime, u_plane100_mx, v_plane100_mx, u_plane200_mx, v_plane200_mx, u_plane300_mx, v_plane300_mx, u_plane400_mx, v_plane400_mx/]
    header = ("Time Stamps, u-component-100, v-component-100, u-component-200, v-component-200, u-component-300, v-component-300, u-component-400, v-component-400")
    hlist = [/header/]
    system("/bin/rm -f " + foutf)
    write_table(foutf, "w", hlist, "%s")
    write_table(foutf,"a", alist, "%s, %9.3f, %9.3f, %9.3f, %9.3f, %9.3f, %9.3f, %9.3f, %9.3f")
    print("outputing file : " + foutf)
    i = i + 1
end do
EOF

ncl ${ncltempfile}
rm -f ${ncltempfile}