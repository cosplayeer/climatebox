
#!/bin/bash

testncl="test.ncl"
monthlist="01 02 03 04 05 06 07 08 09 10 11 12"
for imonth in $monthlist; do
cat>${testncl}<<EOF
file_list = systemfunc("ls ./data2/seasonal-monthly-sfc-ensemble-avg*" + $imonth + ".nc")
systemfunc("echo ./data2/seasonal-monthly-sfc-ensemble-avg*"$imonth".nc"
f = addfiles(file_list,"r")

ListSetType(f, "join")
var = f[:]->Wind10_avg
print(getvardimnames(var))
printVarSummary(var)
var2 = dim_avg_n_Wrap((var), 0)
printVarSummary(var2)
; print(min(var2))
; print(max(var2))

;write to nc
system("test -d ./data2/12month || mkdir -p ./data2/12month")
outname = "./data2/12month/seasonal-monthly-sfc-month" + $imonth + ".nc"
system("/bin/rm -f " + outname)
ncdf = addfile(outname,"c")

; filedimdef(ncdf, "time", -1, True)
var2@long_name = "wind speed"
var2@units     = "m/s"
ncdf->Speed = var2

EOF
ncl ${testncl}
rm ${testncl}

done