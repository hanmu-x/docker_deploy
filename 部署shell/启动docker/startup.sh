#!/bin/bash

# 这个脚本用于执行指定目录下的所有shell脚本

# 检查目录是否存在
scripts_dir="/home/wub/shell_test/dir"
if [ ! -d "$scripts_dir" ]; then
    echo "error：$scripts_dir directory does not exist"
    exit 1
fi

# 切换到脚本目录
cd "$scripts_dir" || exit

# 查找并异步执行所有的.sh脚本
sh_scripts=$(ls *.sh)
if [ -z "$sh_scripts" ]; then
    echo "No shell script files found under $scripts_dir"
    exit 1
fi

for script in $sh_scripts; do
    bash "$script" &
done

# 等待所有后台任务完成
wait

echo "All shell started"
