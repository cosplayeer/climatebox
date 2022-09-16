#!/usr/bin/env python
#################################################################
# Python Script to retrieve 12 online Data files of 'ds094.1',
# total 510.7M. This script uses 'requests' to download data.
#
# Highlight this script by Select All, Copy and Paste it into a file;
# make the file executable and run it on command line.
#
# You need pass in your password as a parameter to execute
# this script; or you can set an environment variable RDAPSWD
# if your Operating System supports it.
#
# Contact rdahelp@ucar.edu (RDA help desk) for further assistance.
#################################################################


import sys
import os
import requests


def check_file_status(filepath, filesize):
    sys.stdout.write('\r')
    sys.stdout.flush()
    size = int(os.stat(filepath).st_size)
    percent_complete = (size/filesize)*100
    sys.stdout.write('%.3f %s' % (percent_complete, '% Completed'))
    sys.stdout.flush()


# Try to get password
pswd = '7vMG8OCj'
url = 'https://rda.ucar.edu/cgi-bin/login'
values = {'email': 'duanyapeng1@163.com', 'passwd': pswd, 'action': 'login'}
# Authenticate
ret = requests.post(url, data=values)
if ret.status_code != 200:
    print('Bad Authentication')
    print(ret.text)
    exit(1)
dspath = 'https://rda.ucar.edu/dsrqst/DUAN587874/'
filelist = [
    'dswsfc.cdas1.201801.grb2',
    'dswsfc.cdas1.201802.grb2',
    'dswsfc.cdas1.201803.grb2',
    'dswsfc.cdas1.201804.grb2',
    'dswsfc.cdas1.201805.grb2',
    'dswsfc.cdas1.201806.grb2',
    'dswsfc.cdas1.201807.grb2',
    'dswsfc.cdas1.201808.grb2',
    'dswsfc.cdas1.201809.grb2',
    'dswsfc.cdas1.201810.grb2',
    'dswsfc.cdas1.201811.grb2',
    'dswsfc.cdas1.201812.grb2']
for file in filelist:
    filename = dspath+file
    file_base = os.path.basename(file)
    print('Downloading', file_base)
    req = requests.get(filename, cookies=ret.cookies,
                       allow_redirects=True, stream=True)
    filesize = int(req.headers['Content-length'])
    with open(file_base, 'wb') as outfile:
        chunk_size = 1048576
        for chunk in req.iter_content(chunk_size=chunk_size):
            outfile.write(chunk)
            if chunk_size < filesize:
                check_file_status(file_base, filesize)
    check_file_status(file_base, filesize)
    print()
