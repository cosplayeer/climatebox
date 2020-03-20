netcdf ERA5-all-month-average {
dimensions:
	g0_lat_1 = 721 ;
	g0_lon_2 = 1440 ;
variables:
	float Speed(g0_lat_1, g0_lon_2) ;
		Speed:_FillValue = 1.e+20f ;
		Speed:center = "European Center for Medium-Range Weather Forecasts (RSMC)" ;
		Speed:long_name = "wind speed" ;
		Speed:units = "m/s" ;
		Speed:level_indicator = 1 ;
		Speed:gds_grid_type = 0 ;
		Speed:parameter_table_version = 128 ;
		Speed:parameter_number = 207 ;
		Speed:forecast_time = 0 ;
		Speed:forecast_time_units = "hours" ;
		Speed:statistical_process_descriptor = "average of N uninitialized analyses" ;
		Speed:statistical_process_duration = "instantaneous (beginning at reference time at intervals of 1 hours)" ;
		Speed:N = 744, 672, 744, 720, 744, 720, 744, 744, 720, 744, 720, 744 ;
		Speed:average_op_ncl = "dim_avg_n over dimension(s): initial_time0_hours" ;
	float g0_lat_1(g0_lat_1) ;
		g0_lat_1:long_name = "latitude" ;
		g0_lat_1:GridType = "Cylindrical Equidistant Projection Grid" ;
		g0_lat_1:units = "degrees_north" ;
		g0_lat_1:Dj = 0.25f ;
		g0_lat_1:Di = 0.25f ;
		g0_lat_1:Lo2 = 359.75f ;
		g0_lat_1:La2 = -90.f ;
		g0_lat_1:Lo1 = 0.f ;
		g0_lat_1:La1 = 90.f ;
	float g0_lon_2(g0_lon_2) ;
		g0_lon_2:long_name = "longitude" ;
		g0_lon_2:GridType = "Cylindrical Equidistant Projection Grid" ;
		g0_lon_2:units = "degrees_east" ;
		g0_lon_2:Dj = 0.25f ;
		g0_lon_2:Di = 0.25f ;
		g0_lon_2:Lo2 = 359.75f ;
		g0_lon_2:La2 = -90.f ;
		g0_lon_2:Lo1 = 0.f ;
		g0_lon_2:La1 = 90.f ;
}
