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
