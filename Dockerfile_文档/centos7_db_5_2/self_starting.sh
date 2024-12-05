#!/bin/bash

supervisord -c /etc/supervisord.conf

# 检查 vsftpd 是否已经在运行
if pgrep vsftpd > /dev/null; then
    echo "vsftpd is already running."
else
    # 如果没有运行，则启动 vsftpd
    /usr/sbin/vsftpd /etc/vsftpd/vsftpd.conf
    echo "vsftpd started."
fi


