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

## time_0*.log  

First test without option "--realtime" when running mrf ioc

## time_realtime_0*

First test with option "--realtime" when running mrf ioc


## time_realtime_1*

Second test with option "--realtime" when running mrf ioc.
Ethercat ioc restarted just for a small test.


## time_realtime_2*

Third test with option "--realtime" when running mrf ioc.
Test with filter size 10 in  /etc/chrony.conf





