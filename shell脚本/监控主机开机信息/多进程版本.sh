#!/bin/bash

# 多进程版本
# 将进程在后台运行，不使用前台资源，好处在于第一台没有给回应的时候不需要一直等待，可以进行执行第二台等


# 定义函数，ping某台主机，并检测主机的存活状态
myping(){
  ping -c2 -i0.3 -w1 $1 &>/dev/null
  if [ $? -eq 0 ];then
    echo "$i is up"
  else
    echo "$i is down"
  fi
}

for i in {1..254}
do
  myping 192.168.4.$i &
done
