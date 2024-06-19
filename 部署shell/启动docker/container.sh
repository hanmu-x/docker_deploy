#!/bin/bash

# 这个shell脚本用于启动,重启,暂停 docker容器的脚本:

# 输入容器名称
container_name="ttt"

# 匹配参数:执行设个shell脚本后需要添加如下三个参数:-start|-stop|-restart
if [ $# -ne 1 ]; then
    echo "Usage: $0 [-start|-stop|-restart]"
    exit 1
fi

action=$1

case $action in
    "-start")
        sudo docker start $container_name
        if [ $? -eq 0 ]; then
            echo "Container $container_name started successfully."
        else
            echo "Failed to start container $container_name."
        fi
        ;;
    "-stop")
        sudo docker stop $container_name
        if [ $? -eq 0 ]; then
            echo "Container $container_name stopped successfully."
        else
            echo "Failed to stop container $container_name."
        fi
        ;;
    "-restart")
        sudo docker restart $container_name
        if [ $? -eq 0 ]; then
            echo "Container $container_name restarted successfully."
        else
            echo "Failed to restart container $container_name."
        fi
        ;;
    *)
        echo "Invalid action. Usage: $0 [-start|-stop|-restart]"
        exit 1
        ;;
esac
wait
exit 0







