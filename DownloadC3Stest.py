#!/usr/bin/env python

from ecmwfapi import ECMWFDataServer

  

server = ECMWFDataServer()          

server.retrieve({

    "dataset":   "c3s_seasonal",          

    "date":      "2017-09-01",

    "levelist":  "10",

    "levtype":   "pl",

    "number":    "0/to/50",

    "origin":    "ecmf",

    "param":     "130.128",

    "step":      "12",

    "stream":    "mmsf",

    "time":      "00:00:00",

    "type":      "fc",

    "area":      "75/-20/10/60",

    "grid":      "1.0/1.0",

    "format":    "netcdf",

    "target":    "test.nc"

 })
