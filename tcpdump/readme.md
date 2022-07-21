


sudo tcpdump -i eth0 -ttt | tee test.log


cat test.log | grep "00:00:00" | tr ":" " " | awk '{print $3}' | python ~/sources/ecmccomgui/pyDataManip/plotData.py 

