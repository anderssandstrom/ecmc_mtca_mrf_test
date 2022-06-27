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