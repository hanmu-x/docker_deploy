FROM ubuntu:22.04

# 设置 DEBIAN_FRONTEND 环境变量
ENV DEBIAN_FRONTEND noninteractive
 
RUN apt-get update \
    && apt-get install -y apt-utils \
    && apt-get upgrade -y \
    && apt-get install -y tzdata  \
    && apt-get install -y vim  \
    && apt-get install -y openssh-server \
    && apt-get install -y gcc g++  \
    && apt-get install -y unixodbc unixodbc-dev \
    && apt-get install -y nginx  \
    && apt-get install -y language-pack-zh-hans \
    && update-locale LANG=zh_CN.UTF-8 \
    && echo 'export LANG=zh_CN.utf8' |  tee -a /etc/profile  \
    && echo 'export LC_CTYPE="zh_CN.utf8"' |  tee -a /etc/profile \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*  \
    && mkdir /home/test_shard_1    \
    && mkdir /home/test_shard_2

# 将达梦数据库的bin目录复制到Dockerfile的同级目录下
COPY ./Shanghai /etc/localtime

CMD ["/bin/bash"]
