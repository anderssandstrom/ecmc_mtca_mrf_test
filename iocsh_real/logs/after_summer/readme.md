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



Now its prov en that the call to get theEVR timestamp fails
```
2022-09-21T06:25:41.785 Undecipherable message (bad response type 4) from 172.30.41.13:35145.
2022-09-21T06:25:43.758 Undecipherable message (bad response type 4) from 172.30.41.13:35145.
2022-09-21T09:03:44.048 Undecipherable message (bad response type 4) from 172.30.41.13:35145.
2022-09-21T09:03:44.291 Undecipherable message (bad response type 4) from 172.30.41.13:35145.
2022-09-21T09:03:44.778 Undecipherable message (bad response type 4) from 172.30.41.13:35145.
2022-09-21T09:03:45.752 Undecipherable message (bad response type 4) from 172.30.41.13:35145.
2022-09-21T09:03:47.699 Undecipherable message (bad response type 4) from 172.30.41.13:35145.
2022-09-21T17:34:22.066 Undecipherable message (bad response type 4) from 172.30.41.13:35145.
2022-09-21T17:34:22.298 Undecipherable message (bad response type 4) from 172.30.41.13:35145.
2022-09-21T17:34:22.762 Undecipherable message (bad response type 4) from 172.30.41.13:35145.
2022-09-21T17:34:23.690 Undecipherable message (bad response type 4) from 172.30.41.13:35145.
2022-09-21T17:34:25.546 Undecipherable message (bad response type 4) from 172.30.41.13:35145.
EVR TIMESTAMP FAIL
incFail
EVR TIMESTAMP FAIL
incFail
EVR TIMESTAMP FAIL
incFail
EVR TIMESTAMP FAIL
incFail
EVR TIMESTAMP FAIL
incFail
EVR TIMESTAMP FAIL
incFail
EVR TIMESTAMP FAIL
incFail
EVR TIMESTAMP FAIL
incFail
2022-09-22T05:04:59.097 Undecipherable message (bad response type 4) from 172.30.41.13:35145.
2022-09-22T05:04:59.334 Undecipherable message (bad response type 4) from 172.30.41.13:35145.
2022-09-22T05:04:59.807 Undecipherable message (bad response type 4) from 172.30.41.13:35145.
2022-09-22T05:05:00.752 Undecipherable message (bad response type 4) from 172.30.41.13:35145.
2022-09-22T05:05:02.644 Undecipherable message (bad response type 4) from 172.30.41.13:35145.
2022-09-22T06:05:08.043 Undecipherable message (bad response type 4) from 172.30.41.13:35145.
2022-09-22T06:05:08.289 Undecipherable message (bad response type 4) from 172.30.41.13:35145.
2022-09-22T06:05:08.781 Undecipherable message (bad response type 4) from 172.30.41.13:35145.
2022-09-22T06:05:09.766 Undecipherable message (bad response type 4) from 172.30.41.13:35145.
2022-09-22T06:05:11.735 Undecipherable message (bad response type 4) from 172.30.41.13:35145.
2022-09-22T11:24:15.097 Undecipherable message (bad response type 4) from 172.30.41.13:35145.
2022-09-22T11:24:15.341 Undecipherable message (bad response type 4) from 172.30.41.13:35145.
2022-09-22T11:24:15.828 Undecipherable message (bad response type 4) from 172.30.41.13:35145.
2022-09-22T11:24:16.802 Undecipherable message (bad response type 4) from 172.30.41.13:35145.
2022-09-22T11:24:18.750 Undecipherable message (bad response type 4) from 172.30.41.13:35145.
2022-09-22T12:48:26.062 Undecipherable message (bad response type 4) from 172.30.41.13:35145.
2022-09-22T12:48:26.310 Undecipherable message (bad response type 4) from 172.30.41.13:35145.
2022-09-22T12:48:26.806 Undecipherable message (bad response type 4) from 172.30.41.13:35145.
2022-09-22T12:48:27.798 Undecipherable message (bad response type 4) from 172.30.41.13:35145.
2022-09-22T12:48:29.781 Undecipherable message (bad response type 4) from 172.30.41.13:35145.
2022-09-22T14:39:07.084 Undecipherable message (bad response type 4) from 172.30.41.13:35145.
2022-09-22T14:39:07.332 Undecipherable message (bad response type 4) from 172.30.41.13:35145.
2022-09-22T14:39:07.828 Undecipherable message (bad response type 4) from 172.30.41.13:35145.
2022-09-22T14:39:08.820 Undecipherable message (bad response type 4) from 172.30.41.13:35145.
2022-09-22T14:39:10.804 Undecipherable message (bad response type 4) from 172.30.41.13:35145.
EVR TIMESTAMP FAIL
incFail
EVR TIMESTAMP FAIL
incFail
EVR TIMESTAMP FAIL
incFail
EVR TIMESTAMP FAIL
incFail
EVR TIMESTAMP FAIL
incFail
EVR TIMESTAMP FAIL
incFail
EVR TIMESTAMP FAIL
incFail
EVR TIMESTAMP FAIL
incFail
2022-09-22T22:42:50.055 Undecipherable message (bad response type 4) from 172.30.41.13:35145.
2022-09-22T22:42:50.296 Undecipherable message (bad response type 4) from 172.30.41.13:35145.
2022-09-22T22:42:50.780 Undecipherable message (bad response type 4) from 172.30.41.13:35145.
2022-09-22T22:42:51.748 Undecipherable message (bad response type 4) from 172.30.41.13:35145.
2022-09-22T22:42:53.683 Undecipherable message (bad response type 4) from 172.30.41.13:35145.
2022-09-23T02:34:06.046 Undecipherable message (bad response type 4) from 172.30.41.13:35145.
2022-09-23T02:34:06.272 Undecipherable messag
```

For some reaon this line fails: https://github.com/anderssandstrom/mrfioc2/blob/3becf41dae9b9edab371aeecd1d821041bc148e8/evrApp/src/ntpShm.cpp#L146

# Problem 1: form 2022-09-21T17:34:25.546 to 2022-09-22T05:04:59.097

Sep 21 21:56:58 lab-mot-ctrl-cpu-1.cslab.esss.lu.se chronyd[868]: Can't synchronise: no selectable sources
Sep 21 21:59:24 lab-mot-ctrl-cpu-1.cslab.esss.lu.se chronyd[868]: Selected source EVR

# Problem 2: from 2022-09-22T14:39:10.804 to 2022-09-22T22:42:50.055

Sep 22 17:37:19 lab-mot-ctrl-cpu-1.cslab.esss.lu.se chronyd[868]: Can't synchronise: no selectable sources
Sep 22 17:39:47 lab-mot-ctrl-cpu-1.cslab.esss.lu.se chronyd[868]: Selected source EVR
Sep 22 17:39:47 lab-mot-ctrl-cpu-1.cslab.esss.lu.se chronyd[868]: System clock wrong by -1.006621 seconds, adjustment started


# Data 2x.log
Added more printoust in mrf code.

# Data 30.log 
EVG was restarted several times so should be spikes.
