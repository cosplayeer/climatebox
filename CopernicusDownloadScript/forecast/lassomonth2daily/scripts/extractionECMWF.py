import os
import subprocess
from datetime import date
import shutil
from datetime import datetime, timedelta, tzinfo
import json


def month_add2(mytime: str, months=2):  # 20170101
    from dateutil.relativedelta import relativedelta
    _year = int(mytime[:4])
    _month = int(mytime[4:6].lstrip('0'))
    _day = int(mytime[6:].lstrip('0'))
    resultdate = datetime(year=_year, month=_month,
                          day=_day) + relativedelta(months=months)
    return resultdate.strftime('%Y%m%d')


cur_dir = os.path.split(os.path.realpath(__file__))[0]
pa_dir = cur_dir + "/.."
# print(pa_dir)


class ExtractionECMWFTask(object):
    def __init__(self, fromdate: str, datatype: str, xlon: float, ylat: float):
        self.fromdate = fromdate
        self.targetmonth = month_add2(fromdate)
        self.datatype = datatype
        self.xlon = xlon
        self.ylat = ylat
        self.cancelflag = None

    # nclFile = os.path.join(cur_dir, 'nclscripts', f"{varName}_gama.ncl")

    def run(self):
        nclFile = os.path.join(cur_dir, f"extractionECMWF.ncl")
        shell_cmd = [
            'ncl', '-Q', '-n',  nclFile, f'fromdate="{self.fromdate}"', f'targetmonth="{self.targetmonth}"', f'datatype="{self.datatype}"',
            f'xlon={self.xlon}', f'ylat={self.ylat}'
        ]
        print("hi begin to run subprocess ncl")
        print(shell_cmd)
        p = subprocess.Popen(shell_cmd,
                             shell=False,
                             stdout=subprocess.PIPE,
                             stderr=subprocess.STDOUT,
                             cwd=pa_dir,
                             preexec_fn=os.setpgrp)
        while p.poll() is None:
            line = p.stdout.readline()
            line = line.strip().decode('utf-8')
            print(line)
            if self.cancelflag:
                break

    def stop(self):
        self.cancelflag = True
        print("Use cancel process time series.")
        # 手动删除能不能退出？


class ExtractionECMWFTaskwithPressure(object):
    def get_alpha(self):
        afile = "text/alpha" + self.datatype[6:] + ".txt"
        # print(afile)
        with open(afile, "r") as f:
            s = f.read()
        data_json = json.loads(s)
        # print(dict(data_json))
        print(self.targetmonth)
        _mumberId = dict(data_json).get(self.targetmonth).get('max_id')
        _multiWind = dict(data_json).get(self.targetmonth).get('alpha')
        return _multiWind, _mumberId

    def __init__(self, fromdate: str, datatype: str, xlon: float, ylat: float):
        self.fromdate = fromdate
        self.targetmonth = month_add2(fromdate)
        self.datatype = datatype
        self.xlon = xlon
        self.ylat = ylat
        # self.multiWind = 1.56
        # self.mumberId = 45
        self.cancelflag = None

        self.multiWind, self.mumberId = self.get_alpha()

    def run(self):
        nclFile = os.path.join(cur_dir, f"extractionECMWFwithPressure.ncl")
        shell_cmd = [
            'ncl', '-Q', '-n',  nclFile, f'fromdate="{self.fromdate}"', f'targetmonth="{self.targetmonth}"', f'datatype="{self.datatype}"',
            f'xlon={self.xlon}', f'ylat={self.ylat}', f'multiWind={self.multiWind}', f'mumberId={self.mumberId}'
        ]
        print("hi begin to run subprocess ncl")
        print(shell_cmd)
        p = subprocess.Popen(shell_cmd,
                             shell=False,
                             stdout=subprocess.PIPE,
                             stderr=subprocess.STDOUT,
                             cwd=pa_dir,
                             preexec_fn=os.setpgrp)
        while p.poll() is None:
            line = p.stdout.readline()
            line = line.strip().decode('utf-8')
            # print(line)
            if self.cancelflag:
                break

    def stop(self):
        self.cancelflag = True
        print("Use cancel process time series.")
        # 手动删除能不能退出？


def main(fromyear=20211101, toyear=20211101, id="ECMWF_xinjiangsantanghu1qi"):
    if id == "ECMWF_xinjiangsantanghu1qi":
        _xlon = 93.2372
        _ylat = 44.1552
    elif id == "ECMWF_Naomaohu":
        _xlon = 94.9144
        _ylat = 43.6945
    elif id == "ECMWF_NewHuadiankushui":
        _xlon = 95.2555
        _ylat = 42.5754

    i = fromyear
    while i <= toyear:
        print(i)
        t1 = ExtractionECMWFTask(fromdate=str(i),
                                 datatype=id, xlon=_xlon, ylat=_ylat)
        t1.run()
        i = int(month_add2(str(i), months=1))


def main2(fromyear=20201101, toyear=20211101, id="ECMWF_xinjiangsantanghu1qi"):
    if id == "ECMWF_xinjiangsantanghu1qi":
        _xlon = 93.2372
        _ylat = 44.1552
    elif id == "ECMWF_Naomaohu":
        _xlon = 94.9144
        _ylat = 43.6945
    elif id == "ECMWF_NewHuadiankushui":
        _xlon = 95.2555
        _ylat = 42.5754

    i = fromyear
    while i <= toyear:
        print(i)
        t1 = ExtractionECMWFTaskwithPressure(fromdate=str(i),
                                             datatype=id, xlon=_xlon, ylat=_ylat)
        t1.run()
        i = int(month_add2(str(i), months=1))


if __name__ == '__main__':
    # apply
    # main2(fromyear=20200301, toyear=20211101, id="ECMWF_xinjiangsantanghu1qi")
    # main2(fromyear=20200301, toyear=20211101, id="ECMWF_Naomaohu")
    # main2(fromyear=20200301, toyear=20211101, id="ECMWF_NewHuadiankushui")

    main2(fromyear=20211101, toyear=20220601, id="ECMWF_Naomaohu")
    main2(fromyear=20211101, toyear=20220601, id="ECMWF_xinjiangsantanghu1qi")
    main2(fromyear=20211101, toyear=20220601, id="ECMWF_NewHuadiankushui")

    # train
    # main(fromyear=20211101, toyear=20211101, id="ECMWF_Naomaohu")
    # main(fromyear=20211101, toyear=20211101, id="ECMWF_xinjiangsantanghu1qi")
    # main(fromyear=20211101, toyear=20211101, id="ECMWF_NewHuadiankushui")
