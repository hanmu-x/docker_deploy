FROM centos:7.9.2009

# 设置 LANG 环境变量
ENV LANG zh_CN.UTF-8

# 安装必要的软件包
RUN yum -y update \
    && yum -y install epel-release \
    && yum -y install vim  \
    && yum -y install gcc gcc-c++ \
    && yum -y install unixODBC unixODBC-devel \
    && yum -y install  libtool-ltdl \
    && yum -y install libtool-ltdl-devel \
    && yum -y install nginx \
	&& yum -y install curl 

RUN  yum -y install mysql-connector-odbc \ 
    #&& curl https://packages.microsoft.com/config/rhel/7/prod.repo > /etc/yum.repos.d/mssql-release.repo \
    #&& yum -y install msodbcsql17 \
    #&& yum -y install mssql-tools  \
    #&& echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bash_profile  \
    #&& echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc  \
    && yum clean all 

# 设置系统时区
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# 设置语言环境
RUN localedef -c -f UTF-8 -i zh_CN zh_CN.UTF-8

# 配置 SSH 允许 root 登录
#RUN sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config

# 创建测试目录
RUN mkdir /home/radar

CMD ["/bin/bash"]