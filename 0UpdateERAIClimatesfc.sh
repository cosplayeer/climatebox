#!/bin/bash 
input_start=$1  # year
input_end=$2

# d1 & d2 must be formart string
startdate=$(date -I -d "$input_start") || exit -1
enddate=$(date -I -d "$input_end")     || exit -1
pydir="./temp"
pyfile=${pydir}/climate_sfc_erai.py
downloaddir="${HOME}/DYP/scripts/secret/Climate/data"

test -d $pydir || mkdir -p $pydir
test -d $downloaddir || mkdir -p $downloaddir
rm -rf ${pyfile}

cat > ${pyfile} <<EOF
#!/usr/bin/env python
# -*- coding: utf-8 -*-
from ecmwfapi import ECMWFDataServer
import sys
YYYY=sys.argv[1]

 
server = ECMWFDataServer()
server.retrieve({
#    "dataset": "interim_moda",  #"interim"/"era5"
    "dataset": "interim",
    "class": "ei",      #"ei"/"ea"
    "expver": "1",      # dont change
    "stream": "moda",   # dont change monthly mean of daily means.
    "type": "an",       # dont change add ["origin" : all] in era-interim sfc
#----levtype: surface option:
    "date": YYYY+"0101/"+YYYY+"0201/"+YYYY+"0301/"+YYYY+"0401/"+YYYY+"0501/"+YYYY+"0601/"+YYYY+"0701/"+YYYY+"0801/"+YYYY+"0901/"+YYYY+"1001/"+YYYY+"1101/"+YYYY+"1201", #----dyp add
    "repres": "sh",  
    "padding": "0",
    "expect": "any",
#    "resol": "auto",
    "domain": "G",
#----dyp add ended
    "levtype": "sfc",
#----param for test
    "param"   : "165.128/166.128/207.128",
#    "param"   : "134.128/151.128/235.128/167.128/165.128/166.128/168.128/34.128/31.128/141.128/139.128/170.128/183.128/236.128/39.128/40.128/41.128/42.128/33.128",
#    "number": "all",  in interim dataset
#----levtype: pressure lever option:
##    "levtype": "pl",
##    "levelist": "10/20/30/50/70/100/125/150/200/250/300/350/400/450/500/550/600/650/700/750/800/850/900/925/950/975/1000",
##    "param": "129.128/130.128/131.128/132.128/133.128/157.128",
#    "format": "netcdf",
    "grid":  "0.75/0.75", #Optional.The horizontal resolution indecimal degrees. Necessary if you specify "format" as "netcdf",otherwise, GRIB tonetCDF conversion will fail.
    "target": "${downloaddir}/ERA-InterimMonthlySFC_"+ YYYY +".grb",
 })
EOF

# d1 must be less than d2
d1="$startdate" 
while [ "$(date -d "$d1" +%Y%m%d)" -le "$(date -d "$enddate" +%Y%m%d)" ]; do {
	echo $d1
#        python  ${pyfile} $d1
        python  ${pyfile} $(date -d "$d1" +%Y)
	d1=$(date -I -d "$d1 + 1 year")
	sleep 1
}  done

#rm -rf ${pyfile}
