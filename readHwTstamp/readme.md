gcc  readNicTs.c -o readNicTs

sudo ./readNicTs <ifname> <hw 1/0> 

sudo ./readNicTs eno1 0 


 1209  2022-07-07 10:50:33 cat log.log | grep SW | awk '{print $4}'
 1210  2022-07-07 10:52:07 cat log.log | grep SW | awk '{print $4}' | awk 'BEGIN{first=1;} {if(first){first=0;old=$1;} print $1-old+0; old=$1;  }'



 1267  2022-07-07 12:36:55 gcc  test.c -o test
 1268  2022-07-07 12:36:59 cat log_3.log | grep SW | grep 1657189966 | awk 'BEGIN{ first=1} {if(first) {first=0;old=$4;} if($4 != old){print $4; old=$4;} }' | wc -l
 1269  2022-07-07 12:37:11 sudo ./test eno1 | tee log_3.log
 1270  2022-07-07 12:37:54 cat log_3.log | grep SW | grep 1657189966 | awk 'BEGIN{ first=1} {if(first) {first=0;old=$4;} if($4 != old){print $4; old=$4;} }' | wc -l
 1271  2022-07-07 12:38:08 cat log_3.log | grep SW | grep 1657190269 | awk 'BEGIN{ first=1} {if(first) {first=0;old=$4;} if($4 != old){print $4; old=$4;} }' | wc -l
 1272  2022-07-07 12:38:14 cat log_3.log | grep SW | grep 1657190268 | awk 'BEGIN{ first=1} {if(first) {first=0;old=$4;} if($4 != old){print $4; old=$4;} }' | wc -l
 1273  2022-07-07 12:38:21 cat log_3.log | grep SW | grep 1657190267 | awk 'BEGIN{ first=1} {if(first) {first=0;old=$4;} if($4 != old){print $4; old=$4;} }' | wc -l
 1274  2022-07-07 12:38:29 cat log_3.log | grep SW | grep 1657190266 | awk 'BEGIN{ first=1} {if(first) {first=0;old=$4;} if($4 != old){print $4; old=$4;} }' | wc -l
 1275  2022-07-07 12:38:38 cat log_3.log | grep SW | grep 1657190265 | awk 'BEGIN{ first=1} {if(first) {first=0;old=$4;} if($4 != old){print $4; old=$4;} }' | wc -l
 1276  2022-07-07 12:38:48 cat log_3.log | grep SW | grep 1657190264 | awk 'BEGIN{ first=1} {if(first) {first=0;old=$4;} if($4 != old){print $4; old=$4;} }' | wc -l
 1277  2022-07-07 12:38:56 cat log_3.log | grep SW | grep 1657190263 | awk 'BEGIN{ first=1} {if(first) {first=0;old=$4;} if($4 != old){print $4; old=$4;} }' | wc -l
 1278  2022-07-07 12:39:04 cat log_3.log | grep SW | grep 1657190262 | awk 'BEGIN{ first=1} {if(first) {first=0;old=$4;} if($4 != old){print $4; old=$4;} }' | wc -l
 1279  2022-07-07 12:39:13 cat log_3.log | grep SW | grep 1657190261 | awk 'BEGIN{ first=1} {if(first) {first=0;old=$4;} if($4 != old){print $4; old=$4;} }' | wc -l
 1280  2022-07-07 12:39:42 cat log_3.log | grep SW | grep 1657190260 | awk 'BEGIN{ first=1} {if(first) {first=0;old=$4;} if($4 != old){print $4; old=$4;} }' | wc -l




# ecmc
cat ecmc_send.log   | awk '{print substr($2,4)}' | python ~/sources/ecmccomgui/pyDataManip/plotData.py
cat send_05.log  | grep 165 | grep -v ">"| awk '{print $2}' | rev | awk '{print substr($1,0,6)}' | rev  | python ~/sources/ecmccomgui/pyDataManip/plotData.py 

# readNicTs
cat test_sw_04.log | awk 'BEGIN{ first=1} {if(first) {first=0;old=$4;} if($4 != old){print $4; old=$4;} }'  |rev |awk '{ print " " substr($1,0,6);}' | rev |  python ~/sources/ecmccomgui/pyDataManip/plotData.py 

conclusion is that all data in rec_ts.log starting at 0.7ms is send of frames. Frames are then recived approx 300us after. So all data accessible from 

# ethercat tool
(ecmccomgui_py36) (7.0.6.1-4.0.0)[anderssandstrom@mcag-dev-asm-02 ecmc_mtca_mrf_test]$  ethercat -p0  reg_read 0x900  -tsm32
0x4e023133 1308766515
(ecmccomgui_py36) (7.0.6.1-4.0.0)[anderssandstrom@mcag-dev-asm-02 ecmc_mtca_mrf_test]$  ethercat -p0  reg_read 0x904  -tsm32
0x4e023db3 1308769715
(ecmccomgui_py36) (7.0.6.1-4.0.0)[anderssandstrom@mcag-dev-asm-02 ecmc_mtca_mrf_test]$  ethercat -p0  reg_read 0x908  -tsm32
0x00000000 0
(ecmccomgui_py36) (7.0.6.1-4.0.0)[anderssandstrom@mcag-dev-asm-02 ecmc_mtca_mrf_test]$  ethercat -p0  reg_read 0x90C  -tsm32
0x6c726556 1819436374

