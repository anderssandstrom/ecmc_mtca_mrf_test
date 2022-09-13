# Analyse 1 second pulse
cat log02.log | grep "BI02" |awk '{print $1 " " $2 " " $3 " " $4-1000000000}'| python ~/sources/ecmccomgui/pyDataManip/plotCaMonitor.py 

# Analyze shm

cat log02.log | grep "Shm" | python ~/sources/ecmccomgui/pyDataManip/plotCaMonitor.py 

