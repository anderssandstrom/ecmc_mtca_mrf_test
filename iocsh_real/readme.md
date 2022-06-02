# mrf
```
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

## time_realtime_2*

mrf ioc:
- iocsh.bash --realtime

ecmc ioc:
- CLOCK_REALTIME

chrony (/etc/chrony.conf):
- filtersize=10

## time_realtime__mono_0*.log

Test just to see if data is lost also with CLOCK_MONOTONIC.
Conclusion is that data also is lost with CLOCK_MONOTONIC so not related to clock source

mrf ioc:
- iocsh.bash --realtime

ecmc ioc
- CLOCK_MONOTONIC

chrony (/etc/chrony.conf):
- filtersize=64

