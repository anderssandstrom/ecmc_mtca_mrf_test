# EtherCAT diagnostics commands

```
 1062  2022-06-22 12:15:35 ethercat -p2  reg_read 0x9A4 2
 1063  2022-06-22 12:15:39 ethercat -p2  reg_read 0x9A0 2
 1064  2022-06-22 12:19:14 ethercat -p2  reg_read 0x900 2
 1065  2022-06-22 12:19:27 ethercat -p2  reg_read 0x900 4
 1066  2022-06-22 12:20:33 ethercat -p2  reg_read 0x920 4
 1067  2022-06-22 12:22:45 ethercat -p2  reg_read 0x920 8
 1068  2022-06-22 12:22:59 ethercat -p2  reg_read 0x920 8 --type uint64
 1069  2022-06-22 12:23:08 ethercat master
 1070  2022-06-22 12:27:13 ethercat -p2  reg_read 0x928 4 --type uint32
 1071  2022-06-22 12:30:52 ethercat -p2  reg_read 0x920 8 --type uint64
 1072* 2022-06-22 12:31:27 ethercat -p2  reg_read 0x928 4 --type uint64
 1073  2022-06-22 12:31:39 ethercat -p2  reg_read 0x928 4 --type uint32
 1074  2022-06-22 12:32:41 ethercat -p2  reg_read 0x92C 4 --type uint32
 1075  2022-06-22 12:43:05 watch -n0 "ethercat reg read -p4 -tsm32 0x92c
 1076  2022-06-22 12:43:10 watch -n0 "ethercat reg read -p4 -tsm32 0x92c"
 1077  2022-06-22 12:43:19 watch -n0 "ethercat reg_read -p4 -tsm32 0x92c"
 1078  2022-06-22 12:43:23 watch -n0 "ethercat reg_read -p2 -tsm32 0x92c"

```

## System time
ethercat -p2  reg_read 0x910 8 --type uint64

## Recivie time ECAT
[anderssandstrom@lab-mot-ctrl-cpu-1 ecmc_mtca_mrf_test]$ ethercat -p2  reg_read 0x918 8 --type uint64
0x00022fe77090a34b 615621025899339

[anderssandstrom@lab-mot-ctrl-cpu-1 ecmc_mtca_mrf_test]$ ethercat -p2  reg_read 0x918 4 --type uint32
0x7090a34b 1888527179


## System time offset
[anderssandstrom@lab-mot-ctrl-cpu-1 ecmc_mtca_mrf_test]$ ethercat -p2  reg_read 0x920 8 --type uint64
0x09d2fef4449f47a3 707908416527353763

anderssandstrom@lab-mot-ctrl-cpu-1 ecmc_mtca_mrf_test]$ ethercat -p2  reg_read 0x920 4 --type uint32
0x449f47a3 1151289251

## System time delay
[anderssandstrom@lab-mot-ctrl-cpu-1 ecmc_mtca_mrf_test]$ ethercat -p2  reg_read 0x928 4 --type uint32
0x00000127 295
