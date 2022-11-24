import os
import subprocess

from glob import glob

cur_dir = os.path.split(os.path.realpath(__file__))[0]


class testTask(object):
    def __init__(self, lon, lat, year, targetloc):
        self.lon = lon
        self.lat = lat
        self.year = year
        self.targetloc = targetloc
        self.cancelflag = None

    def run(self, dataType: str):
        # readinERA5s.ncl readinSolarChinas.ncl
        nclFile = os.path.join(cur_dir, f"readin{dataType}s.ncl")
        shell_cmd = [
            'ncl', '-Q', '-n', f'lat="{self.lat}"',
            f'lon = "{self.lon}"',
            f'year="{self.year}"',
            f'datatype={dataType}',
            f'targetloc="{self.targetloc}"',
            nclFile
        ]
        print(shell_cmd)
        p = subprocess.Popen(shell_cmd,
                             shell=False,
                             stdout=subprocess.PIPE,
                             stderr=subprocess.STDOUT,
                             #  cwd=self.postdir,
                             preexec_fn=os.setpgrp)
        while p.poll() is None:
            line = p.stdout.readline()
            line = line.strip().decode('utf-8')
            print(line)

        if self.cancelflag:
            print("User cancel the process.")
            p.communicate()
            return

    def stop(self):
        self.cancelflag = True
        print("Use cancel process time series.")


if __name__ == '__main__':
    import json
    with open(os.path.join("text", "location.txt"), "r") as f:
        s = json.load(f)
    for k in s:
        print(s[k])
        # print(s[k]['lat'])
        t = testTask(lat=s[k]['lat'], lon=s[k]['lon'], year=s[k]['year'],
                     targetloc=k)
        t.run(dataType='ERA5')
        t.run(dataType='SolarChina')
