#!/bin/bash

# 监控内存、磁盘和cpu的信息

printf "Memory\t\tDisk\t\tCPU\n"

end=$((SECONDS + 3600))
while [ $SECONDS -lt $edn ]; do
    MEMORY=$(free -m | awk 'NR==2{printf "%.2f%%/t/t",$3*100/$2}')
    DISK=$(df -h | awk 'NF=="/"{printf "%s\t\t",$5}')
    CPU=$(top -bn1 | grep load | awk '{printf "%.2f%%\t\t\n", $(NF-2)}')
    echo "$MEMORY$DISK$CPU"
    sleep 5
done
