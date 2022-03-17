#!/bin/bash

i=100
while [ $i -le 254 ]
do
  ping -c2 -i0.3 -w1 192.168.31.$1 &>/dev/null
  if [ $? -eq 0 ];then
    echo "192.168.31.$i is up"
  else
    echo "192.168.31.$i is down"
  fi
  let i++
done
