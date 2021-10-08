'# ecmc_mtca_mrf_test

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
