
#!/bin/bash

# 批量在目录目录下源目录中所有文件的软连接,已存在的不创建为源目录中的文件创建符号链接

# 源路径
source_dir="/home/wkl/ln_test/aaa/"
# 目的路径
target_dir="/home/wkl/ln_test/bbb/"

# 函数在符号链接不存在的情况下创建符号链接
create_symlink() {
    source_file="$1"
    target_file="$2"
    absolute_source=$(realpath "$source_file")  # 获取源文件的绝对路径
    relative_source="${absolute_source#$source_dir}"  # 去除源目录的绝对路径前缀
    if [ ! -e "$target_file" ]; then
        ln -s "$source_file" "$target_file"
        echo "Created link: $target_file"
    else
        echo "Exist: $target_file"
    fi
}



# 在目标目录中创建目录以镜像源目录结构
cd "$source_dir" || exit 1 # 更改到源目录以获取相对路径
find . -type d -exec mkdir -p "$target_dir"{} \;

# 为源目录中的文件创建符号链接
find . -type f | while read -r file; do
    rel_path="${file#./}" # Remove leading "./" from file path
    create_symlink "$source_dir$rel_path" "$target_dir$rel_path"
done

