ufile = addfile("http://iridl.ldeo.columbia.edu/SOURCES/.Models/.NMME/.CanCM4i/.FORECAST/.MONTHLY/.ugrd/dods","r")
;print(ufile)
;
;Dimensions and sizes:	[S | 60] x [P | 2] x [M | 10] x [L | 12] x [Y | 181] x [X | 360]
;Coordinates: 
;            S: [683..742]
;            P: [200..850]
;            M: [ 1..10]
;            L: [0.5..11.5]
;            Y: [-90..90]
;            X: [ 0..359]
;
ugrd = ufile->ugrd(59,1,0,0,:,:)
;printVarSummary(ugrd)

vfile=addfile("http://iridl.ldeo.columbia.edu/SOURCES/.Models/.NMME/.CanCM4i/.FORECAST/.MONTHLY/.vgrd/dods","r")
;print(vfile)
vgrd = vfile->vgrd(59,1,0,0,:,:)

spd = sqrt(ugrd*ugrd + vgrd*vgrd)
printVarSummary(spd)

;output nc
  nc_fname = "spd1.nc"
  if (fileexists(nc_fname)) then
    system("rm -rf " + nc_fname)
  end if
  f = addfile("spd1.nc","c")

  spd@long_name  = "Wind Speed"
  spd@short_name = "Speed"
  spd@units = "m/s"          ; update appropriate attribute
  f->U = ugrd                          ; write to file (overwrite)
  f->V = vgrd
                                    ; define appropriate information
  filevardef(f, "SPD", typeof(ugrd), getvardims(ugrd))
  f->SPD = spd                      ; write new variable

