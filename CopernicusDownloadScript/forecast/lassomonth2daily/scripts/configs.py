import os
from configparser import ConfigParser


def getconfig():
    config_object = ConfigParser()
    configfile = os.path.join("scripts", "arima.conf")
    config_object.read(configfile, encoding='UTF-8')
    arima_conf = config_object["arima"]
    outname = str(arima_conf["outname"])
    year2 = str(arima_conf["year2"])
    wdays = int(arima_conf["wdays"])
    fmonth = int(arima_conf["fmonth"])

    return outname, year2, wdays, fmonth


def getconfigProphet():
    config_object = ConfigParser()
    configfile = os.path.join("scripts", "arima.conf")
    config_object.read(configfile, encoding='UTF-8')
    arima_conf = config_object["prophet"]
    outname = str(arima_conf["outname"])
    year = str(arima_conf["year"])
    fmonth = int(arima_conf["fmonth"])

    return outname, year, fmonth


def getobsconfig():
    config_object = ConfigParser()
    configfile = os.path.join("scripts", "arima.conf")
    config_object.read(configfile, encoding='UTF-8')
    arima_conf = config_object["obs"]
    fname = str(arima_conf["filename"])
    return fname
