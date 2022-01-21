; goal:
; step 1 : read in forecast 1x1
; step 2 : forecast 1x1 to 0.25p (regrid)
; step 3 : read in historical 0.25p 10m uv
    ; preprocess
; step 4 : forecast - historical
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/esmf/ESMF_regridding.ncl"
;------------------month May-------------------------------
monthname = "May"
fromyear = "2020"
fromonth = "06"
fromtime = "202006"
tomonth1="6monthly"

function test(monthname:string)
begin
    ;readin forecast 1x1
    file1 = "ncdata/Seasonal-forecast-rad-202006-0.25p-6monthly.nc"

    a1 = addfile(file1,"r")

    radiation = a1->Speed10m ;51x721x1440

    radiation_leadtime1_forecast_regrid = dim_avg_n_Wrap(radiation,0)

    ;b1
    fileSea1 = "ncdata/Seasonal-forecast-rad-20year-6monthly.nc"
    b1 = addfile(fileSea1,"r")
    radiation_6monthly = b1->Speed10m
    radiation_6monthly =mask(radiation_6monthly, radiation_6monthly .le. 0.0001, False)
    radiation_6monthly@_FillValue = 0.0001
    printVarSummary(radiation_leadtime1_forecast_regrid)
    printVarSummary(radiation_6monthly)
    radiation_leadtime1_forecast_percent = (radiation_leadtime1_forecast_regrid - radiation_6monthly) / radiation_6monthly * 100
    print("radiation_6monthly:")
    printMinMax(radiation_6monthly,True)

    ;output percent to csv
    lat1d_org=b1->lat
    lon1d_org=b1->lon
    lat1d = tofloat(lat1d_org)
    lon1d = tofloat(lon1d_org)

    numlat = 721
    numlon = 1440
    do k = 0, numlon -1
        if (lon1d(k) .ge. 180) then
            lon1d(k) = lon1d(k) - 360.0
        end if
    end do
    ; printMinMax(lon1d, True)
    lon2d = new((/numlat, numlon/), float)
    lat2d = new((/numlat, numlon/), float)
    ;do loop
    do n = 0, numlon -1
        lon2d(:,n) = lon1d(n)
    end do
    do n = 0, numlat -1
        lat2d(n,:) = lat1d(n)
    end do
    ;---
    ; wind 10m 2020 minus Seasonal-history(%) leadtime1
    foutf = "./text/Seasonal-forecast-rad-" + fromtime + "-regrid-minus-Seasonalhistory-" + tomonth1 + ".csv"
    header = ("longitude,   latitude,    windspeed-10m")
    hlist = [/header/]
    alist = [/lon2d, lat2d, radiation_leadtime1_forecast_percent/]
    system("/bin/rm -f " + foutf)
    write_table(foutf, "w", hlist, "%s")
    write_table(foutf, "a", alist, "%9.4f, %9.4f, %9.4f")

    return 1
end

;----main----
begin
s = test("6monthly")
end