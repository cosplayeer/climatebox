#input parameters:
# fromdate="20220701"
# targetmonth="20220901" ; target  =  fromdate add 2 months
# ; datatype="ECMWF_NewHuadiankushui"
# ; xo = (/ 95.2555 /)
# ; yo = (/ 42.5754 /)
# ncl scripts/extractionECMWF.ncl 'fromdate="20220701"' \
# 'targetmonth="20220901"' \
# 'datatype="ECMWF_xinjiangsantanghu1qi"' \
# 'xlon=93.2372' \
# 'ylat=44.1552'

ncl -Q -n '/home/meteodyn/DYP/climatebox/CopernicusDownloadScript/forecast/lassomonth2daily/scripts/extractionECMWFwithPressure.ncl'\
 'fromdate="20201101"'\
  'targetmonth="20210101"'\
   'datatype="ECMWF_xinjiangsantanghu1qi"'\
    'xlon=93.2372'\
     'ylat=44.1552'\
      'multiWind=2.106338977919363'\
       'mumberId=25'

