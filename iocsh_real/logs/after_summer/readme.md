# Analyse 1 second pulse
cat log02.log | grep "BI02" |awk '{print $1 " " $2 " " $3 " " $4-1000000000}'| python ~/sources/ecmccomgui/pyDataManip/plotCaMonitor.py 

# Analyze shm

cat log02.log | grep "Shm" | python ~/sources/ecmccomgui/pyDataManip/plotCaMonitor.py 


# Data 0x.log
mrfioc2 anders_add_nanos

BI01 not woking?

Strange 1s jump in BI02 time ad shm time, see logs...

These printouts in /var/log/messages:
```
# Nothing intresting before

Sep 14 13:25:19 lab-mot-ctrl-cpu-1.cslab.esss.lu.se chronyd[868]: Can't synchronise: no selectable sources
Sep 14 13:27:51 lab-mot-ctrl-cpu-1.cslab.esss.lu.se chronyd[868]: Selected source EVR
Sep 14 13:27:51 lab-mot-ctrl-cpu-1.cslab.esss.lu.se chronyd[868]: System clock wrong by 1.007312 seconds, adjustment started

# Nothing intresting after
```

Also got "incFail" in mrfioc2 console at that time:
```
2022-09-14T12:40:00.728 Undecipherable message (bad response type 4) from 172.30.41.13:50020.
2022-09-14T12:40:02.661 Undecipherable message (bad response type 4) from 172.30.41.13:50020.
incFail
incFail
incFail
incFail
incFail
incFail
2022-09-14T13:53:00.045 Undecipherable message (bad response type 4) from 172.30.41.13:50020.
2022-09-14T13:53:00.276 Undecipherable message (bad response type 4) from 172.30.41.13:50020.
```

The "Undecipherable message" seems to be releated to pvput script.. Most likely not relate to issue

# Data 1x.log

test branch nanos of mrfioc2 and add some printouts to incfail() in time2ntp()

