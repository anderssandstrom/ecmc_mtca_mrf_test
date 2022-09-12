# Start dummy IOC

```
iocsh shm_ioc.script
```
Basically this ioc just loads two record that can be written to:
```
record(ai,"${P}ShmTimeDiff"){
  field(DESC, "Shm time diff [ns]")
  field(EGU,  "ns")
}

record(bi,"${P}ShmValid"){
  field(DESC, "Shm segment valid")
}

```
# Log data

```

camonitor -n IOC_TEST:ShmValid IOC_TEST:ShmTimeDiff
```


# Start readNtpShm that writes to PV in dummy IOC

```
./readNtpShm 2 1 | awk '{if($1=="DIFF") {print "DIFF== "$4; system("pvput IOC_TEST:ShmTimeDiff.VAL " $4);} if($1=="VALID"){system("pvput IOC_TEST:ShmValid.VAL " $4); } }'
```

 
# Compile ./readNtpShm
cc readNtpShm.c -o readNtpShm

