#!/bin/bash
input_start=$1
input_end=$2


function run_demo(){
    year=`echo ${timetemp} | cut -c 1-4`
    monthlist="01 02 03 04 05 06 07 08 09 10 11 12"
    #monthlist="01 02"
    for imonth in $monthlist; do
    echo "Download ${timetemp} ${imonth}..."
    python DownloadERA5sfcMonthlytemp.py --year $year --month $imonth
    done
}

function run(){
    timetemp=$input_start
    while [ $timetemp -le $input_end ]; do {
    run_demo
    timetemp=`expr $timetemp + 1`
    }  done
}


#main
    run
