#!/bin/bash

# author: zhouwei
# description: linux上的应用自启动,本脚本使用的是root用户进行启动的

# 在指定目录中如果没有当前日期的文件夹，则生成一个，如果有，则跳过
# 指定logs的目录
Logs_Dir=/home/logs
DATE=$(date "-1 d" +%Y%m%d)
echo "==========检查今天日志目录是否存在开始==========" >> $Logs_Dir/$DATE/$DATE.logs

ll $Logs_Dir | grep $DATE | wc -l
if [ $? -eq 0  ]; then
    mkdir -p $Logs_Dir/$DATE
else
    echo "Today's file is ready" >> $Logs_Dir/$DATE/$DATE.logs
fi

echo "==========检查今天日志目录是否存在结束==========" >> $Logs_Dir/$DATE/$DATE.logs

echo "==========检查Nginx进程是否存在==========" >> $Logs_Dir/$DATE/$DATE.logs

# 判断Nginx程序是否启动
# nginx使用root启动
nginx_pross=$(ps aux | grep nginx | grep -v grep | wc -l)
if [ $nginx_pross -eq 0 ]; then
    echo  $(date "+%y-%m-%d %H:%M:%S") nginx的进程不存在，现在开始启动nginx >> $Logs_Dir/$DATE/$DATE.logs
    # nginx的进程不存在，使用while循环进行重启，直到重启成功，则跳出while循环
    while [ $nginx_pross -eq 0 ]; do
            cd /usr/local/nginx/sbin
            ./nginx
  done
    echo  $(date "+%y-%m-%d %H:%M:%S") nginx 启动成功 >> $Logs_Dir/$DATE/$DATE.logs
else
    echo  $(date "+%y-%m-%d %H:%M:%S") nginx is ready   >> $Logs_Dir/$DATE/$DATE.logs
fi

echo "==========检查FastDFS进程是否存在==========" >> $Logs_Dir/$DATE/$DATE.logs

# 检查trackerd是否存在
fdfs_trackerd=$(ps aux | grep fdfs_trackerd | grep -v grep | wc -l)
fdfs_storaged=$(ps aux | grep fdfs_trackerd | grep -v grep | wc -l)
if [ $fdfs_trackerd -eq 0 ] && [ $fdfs_trackerd -eq 0 ]; then
    # tracker和storage进程都不存在的情况
    echo  $(date "+%y-%m-%d %H:%M:%S") FastDFS的tracker进程不存在，现在开始启动tracker服务 >> $Logs_Dir/$DATE/$DATE.logs
    while [ $fdfs_trackerd -eq 0 ]; do
            cd /etc/init.d/
            ./fdfs_trackerd start
  done
    echo  $(date "+%y-%m-%d %H:%M:%S") tracker 启动成功 >> $Logs_Dir/$DATE/$DATE.logs
    echo  $(date "+%y-%m-%d %H:%M:%S") FastDFS的storage进程不存在，现在开始启动storage服务 >> $Logs_Dir/$DATE/$DATE.logs
    while [ $fdfs_storaged -eq 0 ]; do
            cd /etc/init.d/
            ./fdfs_storaged start
  done
    echo  $(date "+%y-%m-%d %H:%M:%S") storage 启动成功 >> $Logs_Dir/$DATE/$DATE.logs
elif [ $fdfs_trackerd -ne 0 ] && [ $fdfs_trackerd -eq 0 ]; then
    # tracker进程存在，但storage进程都不存在的情况
    echo  $(date "+%y-%m-%d %H:%M:%S") FastDFS的storaged进程不存在，现在开始启动storaged服务 >> $Logs_Dir/$DATE/$DATE.logs
    while [ $fdfs_storaged -eq 0 ]; do
            cd /etc/init.d/
            ./fdfs_storaged start
  done
    echo $(date "+%y-%m-%d %H:%M:%S") storaged 启动成功 >> $Logs_Dir/$DATE/$DATE.logs
elif [ $fdfs_trackerd -eq 0 ] && [ $fdfs_storaged -ne 0 ]; then
    # tracker进程不存在，但storage进程都存在的情况
    # 需要将storage先停止，然后启动tracker和storage
    cd /etc/init.d/
    ./fdfs_storaged stop
    if [ $fdfs_trackerd -eq 0 ] && [ $fdfs_storaged -eq 0 ]; then
        echo $(date "+%y-%m-%d %H:%M:%S") FastDFS的进程已经全部kill了，现在开始启动FastDFS服务 >> $Logs_Dir/$DATE/$DATE.logs
        echo $(date "+%y-%m-%d %H:%M:%S") 开始启动FastDFS的tracker进程
        while [ $fdfs_trackerd -eq 0 ]; do
            cd /etc/init.d
            ./fdfs_trackerd start
    done
        echo $(date "+%y-%m-%d %H:%M:%S") 启动FastDFS的tracker进程成功
        echo $(date "+%y-%m-%d %H:%M:%S") 开始启动FastDFS的storage进程
        while [ $fdfs_storaged -eq 0 ]; do
            cd /etc/init.d
            ./fdfs_storaged start
    done
        echo $(date "+%y-%m-%d %H:%M:%S") 启动FastDFS的storage进程成功
  fi
else
    echo  $(date "+%y-%m-%d %H:%M:%S") FastDFS is ready   >> $Logs_Dir/$DATE/$DATE.logs
fi

echo "==========检查Redis进程是否存在==========" >> $Logs_Dir/$DATE/$DATE.logs

# 判断Redis程序是否启动
# 切换到普通用户执行操作
su - hcicloud
redis_pross=$(ps aux | grep redis | grep -v grep | wc -l)
if [ $redis_pross -eq 0 ]; then
    echo $(date "+%y-%m-%d %H:%M:%S") Redis进程不存在，现在开始启动Redis >> $Logs_Dir/$DATE/$DATE.logs
    while [ $redis_pross -eq 0 ]; do
        cd ~/redis
        ./redis-servr ./redis.conf
  done
    echo $(date "+%y-%m-%d %H:%M:%S") Redis启动成功 >> $Logs_Dir/$DATE/$DATE.logs
else
    echo  $(date "+%y-%m-%d %H:%M:%S") redis is ready   >> $Logs_Dir/$DATE/$DATE.logs
fi
logout

echo "==========检查ES进程是否存在==========" >> $Logs_Dir/$DATE/$DATE.logs

# 判断ES服务是否启动
su - hcicloud
ES_pross=$(ps aux | grep elasticsearch | grep -v grep | wc -l)
if [ $ES_pross -eq 0 ]; then
    echo $(date "+%y-%m-%d %H:%M:%S") ES进程不存在，现在开始启动ES >> $Logs_Dir/$DATE/$DATE.logs
    while [ $ES_pross -eq 0 ]; do
        cd ~/elasticsearch-6.6.2/bin || exit
        ./elasticsearch -d
  done
    echo $(date "+%y-%m-%d %H:%M:%S") ES启动成功 >> $Logs_Dir/$DATE/$DATE.logs
else
    echo  $(date "+%y-%m-%d %H:%M:%S") ES is ready   >> $Logs_Dir/$DATE/$DATE.logs
fi
logout

echo "==========检查MQ进程是否存在==========" >> $Logs_Dir/$DATE/$DATE.logs

# 判断ActiveMQ是否启动
su - hcicloud
MQ=$(ps aux | grep activemq | grep -v grep | wc -l)
if [ $MQ -eq 0 ]; then
    echo $(date "+%y-%m-%d %H:%M:%S") ActiveMQ进程不存在，现在开始启动ActiveMQ >> $Logs_Dir/$DATE/$DATE.logs
    while [ $MQ -eq 0 ]; do
        cd apache-activemq-5.16.2/bin/
        ./activemq start
  done
    echo $(date "+%y-%m-%d %H:%M:%S") ActiveMQ启动成功 >> $Logs_Dir/$DATE/$DATE.logs
else
    echo  $(date "+%y-%m-%d %H:%M:%S") MQ is ready   >> $Logs_Dir/$DATE/$DATE.logs
fi
logout

echo "==========检查ZK进程是否存在==========" >> $Logs_Dir/$DATE/$DATE.logs

# 判断zookeeper是否启动
su - hcicloud
ZK=$(ps aux | grep zookeeper | grep -v grep | wc -l)
if [ $ZK -eq 0 ]; then
    echo $(date "+%y-%m-%d %H:%M:%S") ZooKeeper进程不存在，现在开始启动ZooKeeper >> $Logs_Dir/$DATE/$DATE.logs
    while [ $ZK -eq 0 ]; do
    cd ~/zookeeper-3.4.9/bin/
    ./zkStart.start
  done
else
  echo $(date "+%y-%m-%d %H:%M:%S") ZK is ready  >> $Logs_Dir/$DATE/$DATE.logs
fi
logout

echo "==========检查NLU进程是否存在==========" >> $Logs_Dir/$DATE/$DATE.logs
su - hcicloud
for i in servicefx_license_server servicefx_slb servicefx_http_server servicefx_nlu servicefx_nlu_sync; do
  cloud_num=$(ps aux | grep -v grep | grep -w $i | wc -l)
  if [ $cloud_num -eq 0 ]; then
    cd ~/cloud/$i/bin
    ./$i -d
  fi
done
echo $(date "+%y-%m-%d %H:%M:%S") NLU is ready  >> $Logs_Dir/$DATE/$DATE.logs
logout

echo "==========检查TA和ROS进程是否存在==========" >> $Logs_Dir/$DATE/$DATE.logs
su - hcicloud_ta
TA=$(ps aux | grep -v grep | grep -w servicefx_text_analyze | wc -l)
ROS=$(ps aux | grep -v grep | grep -w servicefx_ros | wc -l)
if [ $TA -eq 0 ] && [ $ROS -eq 0 ]; then
    # ROS和TA都不存在的
    # 先启动ROS然后sleep 30s 确保ROS正常
    while [ $ROS -eq 0 ]; do
        cd ~/ros/ros/bin
        ./servicefx_ros -d
        sleep 30
  done
    while [ $TA -eq 0 ]; do
        cd ~/cloud/text_analyze/bin
        ./servicefx_text_analyze -d
        sleep 60
  done
elif [ $TA -eq 0 ] && [ $ROS -ne 0 ]; then
    # ROS存在，TA不存在
    while [ $TA -eq 0 ]; do
        cd ~/cloud/text_analyze/bin
        ./servicefx_text_analyze -d
        sleep 60
  done
elif [ $TA -ne 0 ] && [ $ROS -eq 0 ]; then
    # ROS不存在，TA存在
    # 这种情况几乎没有
    # 获取TA进程的pid，然后kill掉
    TA_PID=$(ps aux | grep servicefx | grep -v grep | awk '{print $2}')
    kill -9 $TA_PID
    while [ $ROS -eq 0 ]; do
        cd ~/ros/ros/bin
        ./servicefx_ros -d
        sleep 30
  done
    while [ $TA -eq 0 ]; do
        cd ~/cloud/text_analyze/bin
        ./servicefx_text_analyze -d
        sleep 60
  done
else
  echo $(date "+%y-%m-%d %H:%M:%S") TA AND ROS is ready  >> $Logs_Dir/$DATE/$DATE.logs
fi

logout

echo "==========检查ASR和TTS进程是否存在==========" >> $Logs_Dir/$DATE/$DATE.logs
su - hcicloud
for i in aicp_apigw aicp_license aicp_tts aicp_asr_ft aicp_asr_mrcp aicp_tts_mrcp; do
  aicp_num=$(ps aux | grep -v grep | grep -w $i | wc -l)
  if [ $aicp_num -eq 0 ]; then
    cd ~/aicp/bin
    ./$i -d
  fi
done
echo $(date "+%y-%m-%d %H:%M:%S") AICP is ready  >> $Logs_Dir/$DATE/$DATE.logs
logout

echo "==========检查方案层进程是否存在==========" >> $Logs_Dir/$DATE/$DATE.logs

for i in aicc-config-server aicc-fileserver aicc-system-server aicc-robot-service aicc-robot-server aicc-znkf-server; do
  aicc_num=$(ps -ef | grep -v grep | grep -w $i | wc -l)
  if [ $aicc_num -eq 0 ]; then
    cd ~/aicc/$i
    sh startup.sh
    while true; do
      sleep 10
      tail -f logs/*.log
      tail -f 300 logs/*.log | grep 'Started Successfully'
      if [ $? -eq 0 ]; then
        break
      fi
    done
  fi
done
sleep 10
