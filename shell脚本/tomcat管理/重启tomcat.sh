#!/bin/bash

# author: zhouwei
# description: 重启tomcat

# 获取tomcat的进程号
pidlist = `ps -ef | grep apache-tomcat-8.5.59 | grep -v "grep" | awk '{print $2}'`

echo "tomcat Id list :$pidlist"

# 杀掉进程
kill -9 $pidlist

echo "KILL $pidlist:"

echo "tomcat stop succss"

echo "start tomcat"

cd /hcicloud/apache-tomcat-8.5.59/bin

./startup.sh
