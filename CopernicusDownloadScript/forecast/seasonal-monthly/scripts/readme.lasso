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
    20201205
    20201206
    diff lassoTest202012.py lassoTest202012-02.py:
    <     varSpeed = circle2021(imonth=1)
    ---
    >     varSpeed = circle2021(imonth=2)
    326c326
    <     outputnc(varSpeed, imonth=1, year=2021)
    ---
    >     outputnc(varSpeed, imonth=2, year=2021)
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
    
9.未训练的减去训练过的：
    ReadGribandNCPlotNGLmonth2021.py :after
    ReadGribandNCPlotNGLmonth2021noLasso.py : before
    ReadGribandNCPlotNGLmonth2021plot2.py : minus

二　单点
    结合实际测风数据
    1.	修改模型为时间序列模型，可以输出逐小时的时间切片图谱。（3周）


    2.	MCP模型训练  从半年/9个月预报- 推测一年的预报 （3周）
        2.1 Csrf 9个月预报：/home/meteodyn/DYP/climatebox/csfv2/scripts
        2.2 阅读相关ＭＣＰ文献


    
    3.	辐射变量的6个月预报订正（2-3周）
        3.1 下载辐射变量

    4.	点到面：将多点观测应用到模型中，对一片区域进行订正（3周）
        4.1 单点应用订正
       
        



