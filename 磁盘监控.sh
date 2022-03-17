#! /bin/bash

# 实时监控本机内存和硬盘剩余空间，剩余内存小于 500M、根分区剩余空间小于 1000M时，发送报警邮件给 root 管理员

# 提取根分区剩余空间
disk_size=$(df / | awk '/\//{print $4}')

# 提取内存剩余空间
mem_size=$(free | awk '/Mem/{print $4}')
while :
do
# 内存和磁盘的提取的空间大小都是以kb为单位
if [ $disk_size -le 512000 -a $mem_size -le 104000 ];then
  mail -s Warning root <<EOF
Insufficient resource,资源不足
EOF
fi
done