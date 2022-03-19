#!/bin/bash

# DOS攻击防范
# 自动屏蔽攻击IP

DATE=$(date +%d/%b/%Y:%H:%M)
#nginx日志
LOG_FILE=/usr/local/nginx/logs/access.logs
# 分析ip的访问情况
ABNORMAL_IP=$(tail -n5000 $LOG_FILE | grep $DATE | awk '{a[$1]++}END{for(i in a)if(a[i]>10)print i}')

for IP in $ABNORMAL_IP;do
    if [ $(iptables -vnL | grep -c "$IP") -eq 0 ];then
        iptables -I INPUT -s $IP -j DROP
        echo "$(date +'%F_%T') $IP" >> /tmp/drop_ip.log
    fi
done