# mrf
```
./epics/....setenv

iocsh st.ioc_nanos.cmd -l  ~/sources/e3-mrfioc2/cellMods/

# ecmc
```
./epics/....setenv
iocsh ecmc_lean.cmd
```
# Log data
```
camonitor IOC_MTCA:m0s002-BI01-TimeRise IOC_MTCA:m0s002-BI01-TimeRiseTS IOC_MTCA:m0s002-BI02-TimeRise IOC_MTCA:m0s002-BI02-TimeRiseTS
```

# old way BELOW, not working...

conda activate mrfconda
iocsh.bash st.cmd
```
# ecmc
```
./epics/....setenv
iocsh ecmc_lean.cmd
```
Note: Always restart ecmc ioc if mrf ioc is restarted (to get the correct start time)

# Log data
```
$ camonitor IOC_MTCA:m0s002-BI01-TimeRiseTS MCAG:TS-EVR-01:1hzCnt-I MCAG:TS-EVR-01:UnivIn-14-Label-I | tee time_0x.log
```

# Analyse 
```
conda activate ecmccomgui_py36


cat time_realtime_3*.log | grep m0 | awk '{print($1 " " $2 " " $3 " " $4-999999999); }' | python ~/sources/ecmccomgui/pyDataManip/plotCaMonitor.py

cat time_0* | grep m0 | awk '{print($4-999999999); }' | python ~/sources/ecmccomgui/pyDataManip/plotData.py 
```

# Log files
Issues with not all triggers latched by ethercat I/O (EL1252-0050) probably due to disturbances. Mrf and ecmc box connected to different power supplies in the wall (far from eachother so maybe that's the issue)

## time_0*.log  

mrf ioc:
- iocsh.bash  (without --realtime)

ecmc ioc:
- CLOCK_REALTIME

chrony (/etc/chrony.conf):
- filtersize=64

## time_realtime_0*

mrf ioc:
- iocsh.bash --realtime

ecmc ioc:
- CLOCK_REALTIME

chrony (/etc/chrony.conf):
- filtersize=64

## time_realtime_1*

same settings as time_realtime_0* but ecmc ioc restarted for small test

mrf ioc:
- iocsh.bash --realtime

ecmc ioc:
- CLOCK_REALTIME
- restarted for small test

chrony (/etc/chrony.conf):
- filtersize=64

## time_realtime__mono_0*.log

Test just to see if data is lost also with CLOCK_MONOTONIC.
Conclusion is that data also is lost with CLOCK_MONOTONIC so not related to clock source

mrf ioc:
- iocsh.bash --realtime

ecmc ioc
- CLOCK_MONOTONIC

chrony (/etc/chrony.conf):
- filtersize=64

## time_realtime_2*

mrf ioc:
- iocsh.bash --realtime

ecmc ioc:
- CLOCK_REALTIME

chrony (/etc/chrony.conf):
- filtersize=10

### reniced chrony at approx 14:50 (in middle of time_realtime_2* test)
time 14:50
```
ps -elf | grep chrony
0 S anderss+  3305 24502  0  80   0 - 28202 pipe_w 14:45 pts/1    00:00:00 grep --color=auto chrony
5 S chrony   14733     1  0  80   0 -  5635 poll_s 11:58 ?        00:00:02 /usr/sbin/chronyd
sudo renice -15 --pid 14733
```
time 15:00
```
[anderssandstrom@lab-mot-ctrl-cpu-1 iocsh_real]$ sudo renice -20 --pid 14733
[sudo] password for anderssandstrom: 
14733 (process ID) old priority -15, new priority -20
```


## time_realtime_3*

Test with affinity..
Needed to use NFS instead of conda:
- req 4.0.0
- base 7.0.6

mrf ioc:
- iocsh.bash --realtime
- EVRFIFO on core 2 (mcoreutils)

ecmc ioc:
- CLOCK_REALTIME
- ecmc_rt on core 1 (mcoreutils)

chrony (/etc/chrony.conf):
- filtersize=10

## time_realtime_4*

30 motion axes!!

Test with affinity..
Needed to use NFS instead of conda:
- req 4.0.0
- base 7.0.6

mrf ioc:
- iocsh.bash --realtime
- EVRFIFO on core 2 (mcoreutils)

ecmc ioc:
- CLOCK_REALTIME
- ecmc_rt on core 1 (mcoreutils)

chrony (/etc/chrony.conf):
- filtersize=10


## time_realtime_5*

Restarted chrony with log files (/etc/chrony.conf):
```
log measurements statistics tracking
```

Can also analyze test 4* data since just restarted chrony:
```
 cat time_realtime_4*.log  time_realtime_5*.log | grep m0 | awk '{print($1 " " $2 " " $3 " " $4-999999999); }' | python ~/sources/ecmccomgui/pyDataManip/plotCaMonitor.py
```
30 motion axes!!

Test with affinity..
Needed to use NFS instead of conda:
- req 4.0.0
- base 7.0.6

mrf ioc:
- iocsh.bash --realtime
- EVRFIFO on core 2 (mcoreutils)

ecmc ioc:
- CLOCK_REALTIME
- ecmc_rt on core 1 (mcoreutils)

chrony (/etc/chrony.conf):
- filtersize=10


## time_realtime_6*

Changed filter to 128 in /etc/chrony.conf

moved ecmc_domain_ call to before time calls in ecmc (brach ecmc_mrf)

Restarted chrony with log files (/etc/chrony.conf):
```
log measurements statistics tracking
```

Can also analyze test 4* data since just restarted chrony:
```
 cat time_realtime_4*.log  time_realtime_5*.log | grep m0 | awk '{print($1 " " $2 " " $3 " " $4-999999999); }' | python ~/sources/ecmccomgui/pyDataManip/plotCaMonitor.py
```
30 motion axes!!

Test with affinity..
Needed to use NFS instead of conda:
- req 4.0.0
- base 7.0.6

mrf ioc:
- iocsh.bash --realtime
- EVRFIFO on core 2 (mcoreutils)

ecmc ioc:
- CLOCK_REALTIME
- ecmc_rt on core 1 (mcoreutils)
- moved ecmc_domain_ call to before time calls in ecmc (brach ecmc_mrf)

chrony (/etc/chrony.conf):
- filtersize=128

## time_mono_8*
Test  logging mrf event 125 (1Hz) on ch 1 and raw output from oscillator on ch2.

## time_mono_9*
Disabled chronyd..
Test logging mrf event 125 (1Hz) on ch 1 and raw output from oscillator on ch2.

## time_mono_10*
Disabled chronyd..
Test logging mrf event 125 (1Hz) on ch 1 and raw output from oscillator on ch2.

plot diff:
```
cat time_mono_10*.log | grep BI01 | awk 'BEGIN{ f=1;} {if(f) {f=0;old=$4;}; diff=$4+0-old; old=$4;print $1 " " $2 " " $3 " " diff; }' | python ~/sources/ecmccomgui/pyDataManip/plotCaMonitor.py 
```


## time_mono_11*
Enabled chronyd..
no filter in chrony
Test logging mrf event 125 (1Hz) on ch 1 and raw output from oscillator on ch2.
```
cat time_mono_11*.log | grep m0 | awk '{print($1 " " $2 " " $3 " " $4-999999999); }' | grep BI01 | python ~/sources/ecmccomgui/pyDataManip/plotCaMonitor.py
```

## time_mono_12*
Disaable chrony again...

plot diff:
```
cat time_mono_12*.log | grep BI01 | awk 'BEGIN{ f=1;} {if(f) {f=0;old=$4;}; diff=$4+0-old; old=$4;print $1 " " $2 " " $3 " " diff; }' | python ~/sources/ecmccomgui/pyDataManip/plotCaMonitor.py 
```


## time_mono_13*
add support for nanoseconds in time2ntp:
https://github.com/anderssandstrom/mrfioc2/tree/asm_add_nanos

Enable chrony again...

## time_mono_14*
restarted mrf ioc 12:49...

add support for nanoseconds in time2ntp:
https://github.com/anderssandstrom/mrfioc2/tree/asm_add_nanos

Enable chrony again...

## time_mono_15*
new measurement with log of shm in mrf.log (mrf ioc iocsh log)

## time_mono_16*
removed printouts from time2ntp
renice chrony to -20
chrony filter 20
resteed chrony, so some spike in begining

2022-06-10 07:49: restared chrony with filter 0 approx. 

2022-06-10 08:12: restared chrony with filter 8 and prec 5e-8 

2022-06-10 08:42:16: Stable since last change but stop chrony to see raw signals over weekend instead. still same logfile


# test 200
Enable chrony
log also shm output from SHM with https://github.com/anderssandstrom/ecmc_mtca_mrf_test/tree/master/readshm

```
iocsh ecmc_lean_test_mono.script -l ~/sources/e3-ecmc/cellMods/ -l ~/sources/e3-ecmccfg/cellMods/
```

/etc/chrony.conf
```
# pool ntp-relay-cslab01.cslab.esss.lu.se iburst

allow 127/8

driftfile /var/lib/chrony/chrony.drift
logdir /var/log/chrony
rtcsync

log rawmeasurements statistics tracking refclocks

# Allow the system clock to be stepped in the first three updates
# if its offset is larger than 1 second.
makestep 1.0 3

refclock SHM 2:perm=0777 poll 1 precision 1e-9 filter 64 prefer refid EVR
```

# Test 220

same as above but new printout in readNtpShm
```
cat ../readshm/shm_220.log | grep DIFF | python ~/sources/ecmccomgui/pyDataManip/plotCaMonitor.py

```

```
iocsh ecmc_lean_test.script -l ~/sources/e3-ecmc/cellMods/ -l ~/sources/e3-ecmccfg/cellMods/ | tee test.log

iocsh --realtime st.mrfioc_nanos.cmd -l ~/sources/e3-mrfioc2/cellMods/  | tee mrf_02.log
```

# test 250
new electrical connection, no missed pulses

chrony off

use older version of mrfioc but with nano support. Help from Gabriel Fedel:

https://gitlab.esss.lu.se/gabrielfedel/mrfioc2.git branch nano

# test 260

start chrony again

also log shm

Seems readNtpShm is not always finding a valid value in 1s.. Removed check. Will loop untill valid is high


Conenction to EVR crashed.. Seems to have double mrf ioc running..

# test 270
Same as 260.. 
MAde alot of tests at this time of teh spike on the local cpu..

IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-06-27 08:17:55.999980 999979853  

# test 280
same as 270
rebooted EVG so rubbish

# test 290
Same as 270

