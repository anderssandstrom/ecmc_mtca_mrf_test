# ecmc_mtca_mrf_test


# mrf


```
cd iocsh_real
./epics/....setenv

iocsh st.ioc_nanos.cmd -l  ~/sources/e3-mrfioc2/cellMods/

Go to GUI and set univ output TCKLA tp Pulser 0

# ecmc
```
cd iocsh_real
./epics/....setenv
iocsh ecmc_lean.cmd
```
# Log data
```
camonitor IOC_MTCA:m0s002-BI01-TimeRise IOC_MTCA:m0s002-BI01-TimeRiseTS IOC_MTCA:m0s002-BI02-TimeRise IOC_MTCA:m0s002-BI02-TimeRiseTS
```





## Host
https://csentry.esss.lu.se/network/hosts/view/lab-mot-ctrl-cpu-1

if in mcag lab: 172.30.41.13

ethercat is currentlly configurated on lower ethernet port of cpu


## MCH

https://csentry.esss.lu.se/network/hosts/view/lab-mot-ctrl-mch-1


Ethernet connection is routed through the MCH. The network cable should be connected to the center RJ45 on the MCH (the upper of teh grouped two lower ports).
The conenction only works in socket 2 in CSLab-Motion-05 since thsi port is configured to allow 2 ips to be connected (other ports on switch defaults to 1 connection).

So to conclude: Ethernet cable between center RJ45 socket on MCU to socket 2 on switch.

## MRF

14Hz Output is configured to "OUT0"

## IOC
The controller is configured to autostart default mrf-ioc. To kill:
```
sudo systemctl stop ts@*
```

## Start wokring IOC

First stop any running ts IOC:
```
sudo systemctl stop ts@*
```

Source environment:
```
. /epics/base-7.0.5/require/3.4.1/bin/setE3Env.bash 

```

Start ioc:
```
iocsh.bash st.loopback.cmd
```

Monitor timestamps from output (and Time):
```
camonitor IOC_MRF_ECMC:Time-I IOC_MRF_ECMC:F14HzCnt-I

pvmonitor -v -M json IOC_MRF_ECMC:F14HzCnt-I
IOC_MRF_ECMC:F14HzCnt-I {"value": 3830,"alarm": {"severity": 0,"status": 0,"message": "NO_ALARM"},"timeStamp": {"secondsPastEpoch": 1648471518,"nanoseconds": 721392498,"userTag": 0},"display": {"limitLow": 0,"limitHigh": 0,"description": "","units": "","precision": 0,"form": {"index": 0,"choices": ["Default","String","Binary","Decimal","Hex","Exponential","Engineering"]}},"control": {"limitLow": 0,"limitHigh": 0,"minStep": 0},"valueAlarm": {"active": false,"lowAlarmLimit": nan,"lowWarningLimit": nan,"highWarningLimit": nan,"highAlarmLimit": nan,"lowAlarmSeverity": 0,"lowWarningSeverity": 0,"highWarningSeverity": 0,"highAlarmSeverity": 0,"hysteresis": 0}}

```

## Config Chrony
add line to /etc/chrony.conf:
```
refclock SHM 2:perm=0777 poll 4 precision 1e-9 filter 64 prefer refid EVR2
```
Some intressting settings:
```
poll:
Timestamps produced by refclock drivers are not used immediately, but they are stored and processed by a median filter in the polling interval specified by this option. This is defined as a power of 2 and can be negative to specify a sub-second interval. The default is 4 (16 seconds). A shorter interval allows chronyd to react faster to changes in the frequency of the system clock, but it might have a negative effect on its accuracy if the samples have a lot of jitter.

dpoll
Some drivers do not listen for external events and try to produce samples in their own polling interval. This is defined as a power of 2 and can be negative to specify a sub-second interval. The default is 0 (1 second).

refid refid
This option is used to specify the reference ID of the refclock, as up to four ASCII characters. The default reference ID is composed from the first three characters of the driver name and the number of the refclock. Each refclock must have a unique reference ID.
```

if poll is set to 1 the update will be quicker.

## Restart chrony
Just restart the service:
```
sudo systemctl restart chronyd

```
## Check chrony
```
[anderssandstrom@ccpu-33584-004 ~]$ chronyc sources
210 Number of sources = 1
MS Name/IP address         Stratum Poll Reach LastRx Last sample               
===============================================================================
#* EVR2                          0   4   377    15  -2377ns[  +65us] +/-  860ns
```

```
[anderssandstrom@ccpu-33584-004 ~]$    chronyc tracking
Reference ID    : 45565232 (EVR2)
Stratum         : 1
Ref time (UTC)  : Wed Dec 08 13:10:26 2021
System time     : 0.000000002 seconds slow of NTP time
Last offset     : +0.000080329 seconds
RMS offset      : 0.000078696 seconds
Frequency       : 0.013 ppm slow
Residual freq   : +2.944 ppm
Skew            : 0.043 ppm
Root delay      : 0.000000001 seconds
Root dispersion : 0.000055503 seconds
Update interval : 16.0 seconds
Leap status     : Normal

```
```
watch -n 0.1 "chronyc tracking | grep System"
Will give:

Every 0.1s: chronyc tracking | grep System                                                     Wed Dec  8 15:01:45 2021

System time     : 0.000000001 seconds slow of NTP time

```
## time2ntp()
```
/*************************************************************************\
* Copyright (c) 2013 Brookhaven Science Associates, as Operator of
*     Brookhaven National Laboratory.
* mrfioc2 is distributed subject to a Software License Agreement found
* in file LICENSE that is included with this distribution.
\*************************************************************************/
/*
 * Serve up EVR time to the shared memory driver (#28) of the NTP daemon.
 *
 * cf. http://www.eecis.udel.edu/~mills/ntp/html/drivers/driver28.html
 *
 * Author: Michael Davidsaver <mdavidsaver@gmail.com>
 *
 * To use, add to init script.  Where 0<=N<=4.  To use 0 or 1 the IOC
 * must run as root.
 *
 *   time2ntp("evrname", N)
 *
 * Add to NTP daemon config.  Replace 'prefer' with 'noselect' when testing
 *
 *   server 127.127.28.N minpoll 1 maxpoll 2 prefer
 *   fudge 127.127.28.N refid EVR
 *
 * Order of execution in this file.
 * 1) User calls time2ntp() before iocInit()
 * 2) ntpshmhooks() is called during iocInit()
 * 3) ntpsetup() is called periodically until it succeeds
 * 4) ntpshmupdate() is called once per second.
 */
```

## Not sure what this is
```
caput -a LAB-MOT:Ctrl-EVR-1:SoftSeq-0-Timestamp-SP 15 0 100 200 300 400 500 600 700 800 900 1000 1100 1200 1300 71428
```
## Change pulse length
```
caput LAB-MOT:Ctrl-EVR-1:DlyGen-0-Width-SP 3000
```

## Monitor timestamps
```
camonitor LAB-MOT:Ctrl-EVR-1:F14HzCnt-I
LAB-MOT:Ctrl-EVR-1:F14HzCnt-I  2021-12-09 16:16:39.285996 36556  
LAB-MOT:Ctrl-EVR-1:F14HzCnt-I  2021-12-09 16:16:39.357425 36557  
LAB-MOT:Ctrl-EVR-1:F14HzCnt-I  2021-12-09 16:16:39.428853 36558  
LAB-MOT:Ctrl-EVR-1:F14HzCnt-I  2021-12-09 16:16:39.500282 36559  
LAB-MOT:Ctrl-EVR-1:F14HzCnt-I  2021-12-09 16:16:39.571710 36560  
LAB-MOT:Ctrl-EVR-1:F14HzCnt-I  2021-12-09 16:16:39.643139 36561  
LAB-MOT:Ctrl-EVR-1:F14HzCnt-I  2021-12-09 16:16:39.714568 36562  
LAB-MOT:Ctrl-EVR-1:F14HzCnt-I  2021-12-09 16:16:39.785996 36563  
LAB-MOT:Ctrl-EVR-1:F14HzCnt-I  2021-12-09 16:16:39.857425 36564  
LAB-MOT:Ctrl-EVR-1:F14HzCnt-I  2021-12-09 16:16:39.928853 36565  
LAB-MOT:Ctrl-EVR-1:F14HzCnt-I  2021-12-09 16:16:39.999999 36566  
LAB-MOT:Ctrl-EVR-1:F14HzCnt-I  2021-12-09 16:16:40.070689 36567  
LAB-MOT:Ctrl-EVR-1:F14HzCnt-I  2021-12-09 16:16:40.142118 36568  
LAB-MOT:Ctrl-EVR-1:F14HzCnt-I  2021-12-09 16:16:40.213546 36569  
LAB-MOT:Ctrl-EVR-1:F14HzCnt-I  2021-12-09 16:16:40.284975 36570  
LAB-MOT:Ctrl-EVR-1:F14HzCnt-I  2021-12-09 16:16:40.356403 36571  
LAB-MOT:Ctrl-EVR-1:F14HzCnt-I  2021-12-09 16:16:40.427832 36572  
LAB-MOT:Ctrl-EVR-1:F14HzCnt-I  2021-12-09 16:16:40.499260 36573  
LAB-MOT:Ctrl-EVR-1:F14HzCnt-I  2021-12-09 16:16:40.570689 36574  
LAB-MOT:Ctrl-EVR-1:F14HzCnt-I  2021-12-09 16:16:40.642118 36575 
```
```
pvmonitor -v -M json IOC_MRF_ECMC:F14HzCnt-I
IOC_MRF_ECMC:F14HzCnt-I {"value": 3830,"alarm": {"severity": 0,"status": 0,"message": "NO_ALARM"},"timeStamp": {"secondsPastEpoch": 1648471518,"nanoseconds": 721392498,"userTag": 0},"display": {"limitLow": 0,"limitHigh": 0,"description": "","units": "","precision": 0,"form": {"index": 0,"choices": ["Default","String","Binary","Decimal","Hex","Exponential","Engineering"]}},"control": {"limitLow": 0,"limitHigh": 0,"minStep": 0},"valueAlarm": {"active": false,"lowAlarmLimit": nan,"lowWarningLimit": nan,"highWarningLimit": nan,"highAlarmLimit": nan,"lowAlarmSeverity": 0,"lowWarningSeverity": 0,"highWarningSeverity": 0,"highAlarmSeverity": 0,"hysteresis": 0}}
```

# !!!!!!!!!!!!!!!!!OLD NOT WORKING BELOW!!!!



## Run mrf IOC
Seems to work when running new st.cmd from Jerzy with added "time2ntp".

```
#!/usr/bin/env iocsh.bash

epicsEnvSet "PEVR" "LAB-MOT:Ctrl-EVR-1"

# [common]
epicsEnvSet "IOCNAME" "$(PEVR)"
epicsEnvSet "IOCDIR" "./"
epicsEnvSet "AS_TOP" "./"
epicsEnvSet "LOG_SERVER_NAME" "172.16.107.59"

require essioc
iocshLoad("$(essioc_DIR)/common_config.iocsh")

# [module]
require "mrfioc2" "2.3.1+1"
iocshLoad "$(mrfioc2_DIR)/evrEss.iocsh"     "P=$(PEVR),PCIID=08:00.0,INTPPS=,EXTPPS=#"
iocshLoad "$(mrfioc2_DIR)/seq0Ess.r.iocsh"  "P=$(PEVR)"
iocshLoad "$(mrfioc2_DIR)/evrGenericEss.load.r.iocsh" "P=$(PEVR)"

# added by anders sandström
time2ntp("EVR", 2)
```

## Run IOC:
```
iocsh.bash mrf.script 
```

## Workaround FIX to get the ioc running
Seems large part of the IOC is using dbpf before iocinit() which results in error.
Managed to get the IOC running by executing all the scripts again in the running IOC:
```
iocshLoad "$(mrfioc2_DIR)/evrEss.iocsh"     "P=$(PEVR),PCIID=08:00.0,INTPPS=,EXTPPS=#"
epicsThreadSleep 1

iocshLoad "$(mrfioc2_DIR)/seq0Ess.r.iocsh"  "P=$(PEVR)"
epicsThreadSleep 1

iocshLoad "$(mrfioc2_DIR)/evrGenericEss.load.r.iocsh" "P=$(PEVR)"
epicsThreadSleep 1

# added by anders sandström
time2ntp("EVR", 2)
# caput -a LAB-MOT:Ctrl-EVR-1:SoftSeq-0-Timestamp-SP 15 0 100 200 300 400 500 600 700 800 900 1000 1100 1200 1300 71428

```

I also executed the last row in a separte terminal:
```
caput -a LAB-MOT:Ctrl-EVR-1:SoftSeq-0-Timestamp-SP 15 0 100 200 300 400 500 600 700 800 900 1000 1100 1200 1300 71428
```

# OLD test with old config Below!

## Notes from call with Jerzy
In the call with Jerzy we concluded that one maybe better way would be to syncronize the 1kHz cloc (to get timestamps directlly from evr in 1khz).
So basically there are two solutions:

1. time2ntp, shared memory, chrony, CLOCK_REALTIME (could also be used with ptp)

2. direct (would be best). Callbacks direct from mrf (over epics or direct from mrf)

Test both!

Jerzy could help to setup system in end of aug if I give him the host name.

New repo for mrf test ioc:
https://gitlab.esss.lu.se/hwcore/ts/examples-ioc
Then look at ./examples-ioc/evrlb-simple-ess


The PCI id needs to be checked withn lspci command.

```
modprobe mrf (need mrf kernel module)
lsmod | grep mrf to check
```

todo to get working:

```
$ history
2021-08-24 15:27:28 ip addr

   # Prepare system
    2  2021-08-24 15:27:33 lspci
    7  2021-08-24 15:28:48 mkdir sources
    8  2021-08-24 15:28:51 cd sources/   
   12  2021-08-25 08:44:08 git clone https://gitlab.esss.lu.se/hwcore/ts/e3-mrfioc2.git
   17  2021-08-25 08:45:12 git clone https://github.com/anderssandstrom/ecmc_mtca_mrf_test.git
   18  2021-08-25 08:45:17 ls
   19  2021-08-25 08:45:22 cd e3-mrfioc2/
   21  2021-08-25 08:45:30 git tag
   22  2021-08-25 08:45:42 git checkout 2.2.1
   24  2021-08-25 08:46:13 sudo yum install nano
   # Add /epics NFS
   26  2021-08-25 08:46:40 sudo nano /etc/fstab    
   28  2021-08-25 08:47:00 sudo reboot
   
   # add row to /etc/chrony.conf "refclock SHM 2:perm=0666 poll 4 precision 1e-9 filter 64 prefer refid EVR2"
   # and comment out the first row "# pool ntp-relay-cslab01.cslab.esss.lu.se iburst"
   28 sudo nano /etc/chrony.conf
   # restart chronyd and check status
   28 sudo systemctl restart chronyd
   28 sudo systemctl status chronyd
   
   check chrony status with:
   chronyc sources
   chronyc tracking
   
   # Check Xilinx address
   29  2021-08-25 08:50:02 lspci | grep Xilinx
   30  2021-08-25 08:55:52 ls
   31  2021-08-25 08:55:54 cd sources/ecmc_mtca_mrf_test/iocsh
   
   # Must use this old version otherwise script will not work
   33  2021-08-25 08:56:07 . /epics/base-7.0.5/require/3.4.1/bin/setE3Env.bash 
 
   # Test ioc (PCI adress is hardcoded aswell as prefix)
   39  maybe need root access?!      sudo su
   40  2021-08-25 08:58:29 iocsh.bash st.cmd

NOTE: These 2 lines were added to st.cmd:
mrmEvrLoopback EVR,1,1
time2ntp("EVR", 2)

but still not working.. Error!

```


# Testing conda (info from Nicklas) 20220325
https://confluence.esss.lu.se/display/IS/0.+Installing+and+configuring+Conda+-+Setup+development+machine
Created an env called mrfconda (conda create...)

  - e3-common
  - mrfioc2=2.2.0rc7
  - evr_seq_calc=0.9.3
  - evr_timestamp_buffer=2.6.3

```
conda activate mrfconda

conda install e3-common
conda install mrfioc2=2.2.0rc7
conda install evr_seq_calc=0.9.3
conda install evr_timestamp_buffer=2.6.3
```

# Some data

```
camonitor IOC_MTCA:MCU-ThdLatMax | awk '{print $N; system("./gettime");}'
```

Log data 1 (CLOCK_MONOTONIC):
```
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 11:58:48.472467 7.0722e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 11:58:48.472042 472041964  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 11:58:48.532471 7.0722e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 11:58:48.532105 532105088  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 11:58:48.592468 7.0722e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 11:58:48.592168 592168211  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 11:58:48.652467 7.0722e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 11:58:48.652231 652231335  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 11:58:48.712482 7.0722e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 11:58:48.712294 712294459  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 11:58:48.772480 7.0722e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 11:58:48.772357 772357344  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 11:58:48.832468 7.0722e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 11:58:48.832420 832420468  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 11:58:48.893456 7.0722e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 11:58:48.892484 892483592  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 11:58:48.953489 7.0722e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 11:58:48.952547 952546715  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 11:58:49.013437 7.0722e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 11:58:49.012610 12609720  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 11:58:49.073438 7.0722e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 11:58:49.072673 72672724  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 11:58:49.133438 7.0722e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 11:58:49.132736 132735848  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 11:58:49.193439 7.0722e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 11:58:49.192799 192798972  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 11:58:49.253438 7.0722e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 11:58:49.252862 252862095  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 11:58:49.313437 7.0722e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 11:58:49.312925 312925100  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 11:58:49.373459 7.0722e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 11:58:49.372988 372988104  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 11:58:49.433458 7.0722e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 11:58:49.433051 433051228  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 11:58:49.493459 7.0722e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 11:58:49.493114 493114233  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 11:58:49.553488 7.0722e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 11:58:49.553177 553177118  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 11:58:49.613438 7.0722e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 11:58:49.613240 613240242  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 11:58:49.673438 7.0722e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 11:58:49.673303 673303246  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 11:58:49.733450 7.0722e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 11:58:49.733366 733366250  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 11:58:49.793439 7.0722e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 11:58:49.793429 793429374  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 11:58:49.854438 7.0722e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 11:58:49.853492 853492379  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 11:58:49.914438 7.0722e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 11:58:49.913555 913555383  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 11:58:49.974437 7.0722e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 11:58:49.973618 973618388  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 11:58:50.034438 7.0722e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 11:58:50.033682 33681511  
```

Log data 2 (CLOCK_MONOTONIC):
```
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 12:26:37.919439 7.072215979e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 12:26:37.918702 918701529  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 12:26:37.979456 7.07221598e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 12:26:37.978764 978764295  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 12:26:38.039438 7.07221598e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 12:26:38.038827 38826823  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 12:26:38.099438 7.072215981e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 12:26:38.098889 98889470  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 12:26:38.159456 7.072215982e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 12:26:38.158952 158952116  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 12:26:38.219438 7.072215982e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 12:26:38.219015 219014763  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 12:26:38.279437 7.072215983e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 12:26:38.279077 279077410  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 12:26:38.339438 7.072215983e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 12:26:38.339140 339139938  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 12:26:38.399438 7.072215984e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 12:26:38.399203 399202585  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 12:26:38.459437 7.072215985e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 12:26:38.459265 459265112  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 12:26:38.519438 7.072215985e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 12:26:38.519328 519327759  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 12:26:38.579438 7.072215986e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 12:26:38.579390 579390287  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 12:26:38.640438 7.072215986e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 12:26:38.639453 639453053  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 12:26:38.700458 7.072215987e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 12:26:38.699516 699515700  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 12:26:38.760439 7.072215988e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 12:26:38.759578 759578227  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 12:26:38.820439 7.072215988e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 12:26:38.819641 819640874  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 12:26:38.880437 7.072215989e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 12:26:38.879703 879703402  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 12:26:38.940438 7.072215989e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 12:26:38.939766 939766049  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 12:26:39.000459 7.07221599e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 12:26:38.999829 999828577  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 12:26:39.060502 7.072215991e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 12:26:39.059891 59891343  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 12:26:39.120493 7.072215991e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 12:26:39.119954 119953870  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 12:26:39.180439 7.072215992e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 12:26:39.180017 180016517  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 12:26:39.240459 7.072215992e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 12:26:39.240079 240079045  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 12:26:39.300456 7.072215993e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 12:26:39.300142 300141811  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 12:26:39.360450 7.072215994e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 12:26:39.360204 360204458  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 12:26:39.420507 7.072215994e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 12:26:39.420267 420266985  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 12:26:39.480438 7.072215995e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 12:26:39.480330 480329632  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 12:26:39.540437 7.072215995e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 12:26:39.540392 540392279  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 12:26:39.601437 7.072215996e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 12:26:39.600455 600454926  
```
```
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 12:39:14.406443 7.072223544e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 12:39:14.406246 406246423  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 12:39:14.466459 7.072223545e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 12:39:14.466309 466309189  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 12:39:14.526459 7.072223545e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 12:39:14.526372 526371955  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 12:39:14.586478 7.072223546e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 12:39:14.586435 586434602  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 12:39:14.647462 7.072223546e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 12:39:14.646497 646497249  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 12:39:14.707464 7.072223547e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 12:39:14.706560 706560015  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 12:39:14.767472 7.072223548e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 12:39:14.766623 766622543  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 12:39:14.827463 7.072223548e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 12:39:14.826685 826685190  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 12:39:14.887468 7.072223549e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 12:39:14.886748 886747717  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 12:39:14.947466 7.072223549e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 12:39:14.946810 946810364  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 12:39:15.007464 7.07222355e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 12:39:15.006873 6872773  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 12:39:15.067466 7.072223551e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 12:39:15.066935 66935300  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 12:39:15.127464 7.072223551e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 12:39:15.126998 126997709  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 12:39:15.187463 7.072223552e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 12:39:15.187060 187060117  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 12:39:15.247477 7.072223552e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 12:39:15.247122 247122406  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 12:39:15.307441 7.072223553e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 12:39:15.307185 307185053  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 12:39:15.367467 7.072223554e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 12:39:15.367248 367247700  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 12:39:15.427442 7.072223554e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 12:39:15.427310 427310466  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 12:39:15.487501 7.072223555e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 12:39:15.487373 487373352  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 12:39:15.547464 7.072223555e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 12:39:15.547436 547436118  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 12:39:15.608440 7.072223556e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 12:39:15.607499 607498884  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 12:39:15.668469 7.072223557e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 12:39:15.667562 667561531  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 12:39:15.728460 7.072223557e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 12:39:15.727624 727624058  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 12:39:15.788463 7.072223558e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 12:39:15.787687 787686824  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 12:39:15.848463 7.072223558e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 12:39:15.847749 847749352  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 12:39:15.908520 7.072223559e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 12:39:15.907812 907811999  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 12:39:15.968459 7.07222356e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 12:39:15.967875 967874646  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 12:39:16.028463 7.07222356e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 12:39:16.027937 27937293  
```

```
camonitor -g10 IOC_MTCA:m0s002-BI01-TimeRiseTS IOC_MTCA:m0s002-BI01-TimeRise |awk '{print substr($3,10);}'
```

```
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 15:32:03.136789 136788725  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 15:32:03.197454 7.072327232e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 15:32:03.196849 196848630  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 15:32:03.257439 7.072327233e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 15:32:03.256909 256908535  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 15:32:03.317439 7.072327233e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 15:32:03.316968 316968441  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 15:32:03.377438 7.072327234e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 15:32:03.377028 377028346  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 15:32:03.437438 7.072327234e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 15:32:03.437088 437088251  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 15:32:03.497438 7.072327235e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 15:32:03.497148 497148156  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 15:32:03.557455 7.072327236e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 15:32:03.557208 557208061  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 15:32:03.617440 7.072327236e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 15:32:03.617268 617267966  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 15:32:03.677438 7.072327237e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 15:32:03.677328 677327871  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 15:32:03.737438 7.072327237e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 15:32:03.737388 737387776  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 15:32:03.798438 7.072327238e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 15:32:03.797448 797447681  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 15:32:03.858439 7.072327239e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 15:32:03.857508 857507586  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 15:32:03.918455 7.072327239e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 15:32:03.917567 917567491  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 15:32:03.978438 7.07232724e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 15:32:03.977627 977627396  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 15:32:04.038438 7.07232724e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 15:32:04.037687 37687301  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 15:32:04.098440 7.072327241e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 15:32:04.097747 97747206  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 15:32:04.158467 7.072327242e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 15:32:04.157807 157807111  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 15:32:04.218487 7.072327242e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 15:32:04.217867 217867016  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 15:32:04.278438 7.072327243e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 15:32:04.277927 277926921  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 15:32:04.338438 7.072327243e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 15:32:04.337987 337986826  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 15:32:04.398440 7.072327244e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 15:32:04.398047 398046731  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 15:32:04.458438 7.072327245e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 15:32:04.458107 458106637  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 15:32:04.518455 7.072327245e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 15:32:04.518167 518166661  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 15:32:04.578438 7.072327246e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 15:32:04.578227 578226566  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 15:32:04.638488 7.072327246e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 15:32:04.638286 638286471  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 15:32:04.698438 7.072327247e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 15:32:04.698346 698346495  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 15:32:04.758438 7.072327248e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 15:32:04.758406 758406400  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 15:32:04.819438 7.072327248e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 15:32:04.818466 818466424  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 15:32:04.879438 7.072327249e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 15:32:04.878526 878526329  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 15:32:04.939437 7.072327249e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 15:32:04.938586 938586235  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 15:32:04.999439 7.07232725e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 15:32:04.998646 998646259  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 15:32:05.059438 7.072327251e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 15:32:05.058706 58706164  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 15:32:05.119440 7.072327251e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 15:32:05.118766 118766069  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 15:32:05.179439 7.072327252e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 15:32:05.178826 178825974  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 15:32:05.239439 7.072327252e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 15:32:05.238886 238885879  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 15:32:05.299441 7.072327253e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 15:32:05.298946 298945903  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 15:32:05.359439 7.072327254e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 15:32:05.359006 359005808  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 15:32:05.419440 7.072327254e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 15:32:05.419066 419065952  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 15:32:05.479439 7.072327255e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 15:32:05.479126 479125857  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 15:32:05.539440 7.072327255e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 15:32:05.539186 539185762  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 15:32:05.599457 7.072327256e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 15:32:05.599246 599245786  
IOC_MTCA:m0s002-BI01-TimeRise  2022-05-30 15:32:05.659440 7.072327257e+17  
IOC_MTCA:m0s002-BI01-TimeRiseTS 2022-05-30 15:32:05.659306 659305810  

```
