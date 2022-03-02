1. 下载20年era5资料0.25度,下载20年的ecmwf集合预报资料１度
    用lsssoTest.ncl  ?  
2. lasso插值预报资料到0.25度
    lasso_regrid_0p25.sh
    regrid_0p25.ncl
3. 资料选择
    3.1 单点
        近３年的效果比近10年点效果更好

    3.2 整场 
        只提取中国经纬度范围内：
        73E-136E 3-54N
        纬度：93x４ 144x4(372,577)
        经度：73x4 136x4(292,545)
２０２１/01/18
4. lassoTest202012.py 2020年１２月对未来６个月的预报
    20201201
    20201202
    20201203
    20201204
    20201201
    20201201
5. 2021年１－６月ERA5资料　reverseERA5.py
    １．位置
    data_0.25/WindSpeed10mERA5monthly.grib　　９０　to -90,需换成从南到北
    ２．区域

    ３．输出
6. 对５和６的结果做对比　compareEcERA5.py　未完成x
    读入
    输出:
        png nc ｃｓｖ
７．图谱
    ReadGribandNCPlotNGLmonth2021.py
8. 检测未训练的２０２１年１－６月的对比图
    1. ERA5观测位置不变data_0.25_2021/
    2.　预报资料位置　data_0.25/monthly-forecast-wind201912-1-0.25p.nc 
        只提取中国经纬度范围内：　output2021nc.py
    3.  画图　ReadGribandNCPlotNGLmonth2021noLasso.py
    
9.未训练点减去训练过的：
    ReadGribandNCPlotNGLmonth2021.py :after
    ReadGribandNCPlotNGLmonth2021noLasso.py : before
    ReadGribandNCPlotNGLmonth2021plot2.py : minus


