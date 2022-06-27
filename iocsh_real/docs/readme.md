
# System time offset
ethercat -p2  reg_read 0x920 8 --type uint64
0x09d2fef4449f47a3 707908416527353763

# System time delay

```
ethercat -p2  reg_read 0x928 4 --type uint32
0x00000127 295
```
# System time diff

NOTE:

Bit 31: 
0: Local copy of System Time less than 
received System Time  
1: Local copy of System Time greater than 
or equal to received System Time

```
[anderssandstrom@lab-mot-ctrl-cpu-1 ecmc_mtca_mrf_test]$ ethercat -p2  reg_read 0x92C 4 --type uint32
0x80000058 2147483736
[anderssandstrom@lab-mot-ctrl-cpu-1 ecmc_mtca_mrf_test]$ ethercat -p2  reg_read 0x92C 4 --type uint32
0x8000006e 2147483758
[anderssandstrom@lab-mot-ctrl-cpu-1 ecmc_mtca_mrf_test]$ ethercat -p2  reg_read 0x92C 4 --type uint32
0x8000002b 2147483691
[anderssandstrom@lab-mot-ctrl-cpu-1 ecmc_mtca_mrf_test]$ ethercat -p2  reg_read 0x92C 4 --type uint32
0x80000051 2147483729
[anderssandstrom@lab-mot-ctrl-cpu-1 ecmc_mtca_mrf_test]$ ethercat -p2  reg_read 0x92C 4 --type uint32
0x8000003f 2147483711
[anderssandstrom@lab-mot-ctrl-cpu-1 ecmc_mtca_mrf_test]$ ethercat -p2  reg_read 0x92C 4 --type uint32
0x00000007 7
[anderssandstrom@lab-mot-ctrl-cpu-1 ecmc_mtca_mrf_test]$ ethercat -p2  reg_read 0x92C 4 --type uint32
0x800000b0 2147483824
[anderssandstrom@lab-mot-ctrl-cpu-1 ecmc_mtca_mrf_test]$ ethercat -p2  reg_read 0x92C 4 --type uint32
0x80000081 2147483777
[anderssandstrom@lab-mot-ctrl-cpu-1 ecmc_mtca_mrf_test]$ ethercat -p2  reg_read 0x92C 4 --type uint32
0x80000050 2147483728
[anderssandstrom@lab-mot-ctrl-cpu-1 ecmc_mtca_mrf_test]$ ethercat -p2  reg_read 0x92C 4 --type uint32
0x80000059 2147483737
```
watch -n0 "ethercat reg read -p4 -tsm32 0x92c
