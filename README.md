# ecmc_mtca_mrf_test

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

