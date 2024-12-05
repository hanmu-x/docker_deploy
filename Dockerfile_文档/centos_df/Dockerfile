FROM centos:7.9.2009

# 设置 LANG 环境变量
ENV LANG zh_CN.UTF-8

# 安装必要的软件包
RUN yum -y update \
    && yum -y install epel-release \
    && yum -y install vim \
	&& yum -y install curl \
	&& yum -y install openssh-server \
	&& yum -y install gcc gcc-c++ \
	&& yum -y install unixODBC unixODBC-devel \
	&& yum -y install libtool-ltdl libtool-ltdl-devel \
	&& yum -y install nginx \
	&& yum -y install langpacks-zh_CN \
	&& curl https://packages.microsoft.com/config/rhel/7/prod.repo > /etc/yum.repos.d/mssql-release.repo
	&& yum -y install msodbcsql17 \
	&& yum -y install mssql-tools \
    && yum clean all \
	&& mkdir /home/txz_radar \
    && mkdir /home/test_shard_2 \
	&& echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile \
	&& echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc 
	
	

# 设置系统时区
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
# 设置语言环境
RUN localedef -c -f UTF-8 -i zh_CN zh_CN.UTF-8
# 配置 SSH 允许 root 登录
RUN sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config


CMD ["/bin/bash"]

