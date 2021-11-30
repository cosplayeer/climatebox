import os
import subprocess

date1="202111"
date2="202202"

def getmonthlist(year=2021,month=11,day=1):
    import os
    from datetime import datetime, timedelta
    fromdate=datetime(year,month,day)
    fromdate1=fromdate+timedelta(days=32)
    print(fromdate1.strftime('%Y%m'))
    frecastmonthlist=[]
    i=1
    while i < 10:
        frecastmonthlist.append((fromdate+timedelta(days=i*31)).strftime('%Y%m'))
        i+=1
    return frecastmonthlist

# os.system('ncl scripts/plot1month.ncl' 'fromdate={date1}' 'todate={date2}')
def plot(date1,date2list):
    for date2 in date2list:
        cur_dir = os.path.split(os.path.realpath(__file__))[0]
        nclFile = os.path.join(cur_dir,'plot1month.ncl')
        print(nclFile)
        shell_cmd = ['ncl', '-Q', '-n',
                    f'fromdate="{date1}"',
                    f'todate="{date2}"',
                    nclFile]


        p = subprocess.run(shell_cmd,
                            # shell=True,
                            # stdout=subprocess.PIPE,
                            # stderr=subprocess.STDOUT,
                            )


if __name__ == '__main__':
    mlists=getmonthlist(year=2021,month=11,day=1)
    print(mlists)
    plot(date1="202111",date2list=mlists)
