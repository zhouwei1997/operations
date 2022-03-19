#!/bin/bash

# 按照日期切割Nginx的日志

# 安装目录下日志文件
base_log_path='/usr/local/nginx/logs/access.log'
bass_error_log_path='/usr/local/nginx/logs/error.log'

# 需要保存的目录位置
log_path='/data_logs/nginx/logs'

# 获取月份
log_month=$(date -d yesterday +"%Y%m")

# 获取前一天日期（第二天凌晨备份，即保存的日志就是当天时间的日志）
log_day=$(date -d yesterday +"%d")

# 在指定路径下创建文件夹
mkdir -p $log_path/$log_month

# 将安装路径下的日志文件移动到指定的存储位置
mv $base_log_path $log_path/$log_month/access_$log_day.log
mv $bass_error_log_path $log_path/$log_month/error_$log_day.log

# 使用信号控制切割日志
# USR1表示nginx信号控制，切割日志
kill -USR1 `cat /usr/local/nginx/logs/nginx.pid`

# 每天凌晨1点切割日志
* 1 * * * /usr/local/nginx/logs/log_rotate.sh

