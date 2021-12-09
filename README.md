# ecmc_mtca_mrf_test

## Host
https://csentry.esss.lu.se/network/hosts/view/lab-mot-ctrl-cpu-1

## MCH

https://csentry.esss.lu.se/network/hosts/view/lab-mot-ctrl-mch-1


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

