fromdir="/home/meteodyn/下载"
fromdir="/home/meteodyn/DYP/climatebox/CopernicusDownloadScript/history/Atmosphere/ERA5SolarDaily/data/epwdata/epw_scripts_download"
fdir="/home/meteodyn/DYP/climatebox/CopernicusDownloadScript/history/Atmosphere/ERA5SolarDaily/data/epwdata/epwdir/"
mv -f ${fromdir}"/CHN*zip" $fdir 
flists=$(ls ${fdir}CHN*zip)
echo $flists
#unzip
for f in $flists
do 
unzip $f
echo $f
done
#No overwrite
# mv
cp $fdir*epw $fdir"../"
