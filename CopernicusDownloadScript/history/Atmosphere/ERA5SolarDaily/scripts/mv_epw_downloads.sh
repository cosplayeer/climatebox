fromdir="/home/meteodyn/下载"
fdir="/home/meteodyn/DYP/climatebox/CopernicusDownloadScript/history/Atmosphere/ERA5SolarDaily/data/epwdata/epwdir/"
mv ${fromdir}"/CHN*zip" $fdir 
flists=$(ls ${fdir}CHN*zip)
echo $flists
#unzip
#for f in $flists
#do 
#unzip $f
#done
#No overwrite
# mv
cp $fdir*epw $fdir"../"
