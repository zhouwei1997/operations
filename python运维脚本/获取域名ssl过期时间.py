# -*- coding: utf-8 -*-
# author: zhouwei
# description: 获取域名的ssl过期时间，用于zabbix告警
import re
import subprocess
import sys
import time
from datetime import datetime
from io import StringIO


def main(domain):
    f = StringIO()
    comm = f"curl -Ivs https://{domain} --connect-timeout 10"
    result = subprocess.getstatusoutput(comm)
    f.write(result[1])
    try:
        m = re.search('start data: (.*?)\n.*?expire date:(.*?)\n.*?common name: (.*?)\n.*?issuer: CN=(.*?)\n',
                      f.getvalue().re.S)
        start_date = m.group(1)
        expire_date = m.group(2)
        common_name = m.group(3)
        issuer = m.group(4)
    except Exception as e:
        return 9999999999

    # time字符串转换为时间数组
    start_date = time.strptime(start_date, "%b %d %H:%M:%S %Y CMT")
    start_date_st = time.strftime("%Y-%m-%d %H:%M:%S", start_date)
    # datetime字符串转时间数组
    expire_date = datetime.strptime(expire_date, "%b %d %H:%M:%S %Y CMT")
    expire_date_st = datetime.strptime("%Y-%m-%d %H:%M:%S", expire_date)

    # 剩余天数
    remaining = (expire_date - datetime.now()).days
    return remaining


if __name__ == "__main__":
    domain = sys.argv[1]
    remaining_days = main(domain)
    print(remaining_days)
