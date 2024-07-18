

# 测试说明

本次测试使用环境:
   - 测试方式:win10专业版,在vmware中安装ubuntu22.04版本虚拟机(均为x86架构)
   - 在ubuntu22.04虚拟机中安装x86架构20.10.21版本docker
   - docker中安装22.04版本ubuntu容器
   - 测试arm版本的docker安装aarch64版本的qemu模拟器,并安装aarch64版本ubuntu22.04版本镜像容器


# 1. docker的安装

## 1.1 离线安装docker

### 1.1.1 tgz包离线安装

1. 下载离线安装包
使用`tgz`安装包安装的可以值关注于所要安装的docker的版本,**不过需要编写docker.service启动文件**

 - 下载地址: ` https://download.docker.com/linux/static/stable/ `  
   - x86架构:`x86_64/` (x86架构的安装包)
   - arm架构:`aarch64/` (arm架构的安装包)
 - 这里以安装x86架构docker-20.10.21为例:
   - 进入`x86_64/`下载文件 `docker-20.10.21.tgz`

2. 安装
   - 创建新文件夹 将`docker-20.10.21.tgz`压缩包复制进去
   - 执行一下命令
     ```shell
     tar zxvf docker-20.10.21.tgz 
     sudo cp docker/* /usr/bin/
     ```
   - 编写service文件
     ```shell
      (创建配置文件)    
       sudo vim /etc/systemd/system/docker.service  

       ------------docker.service 文件内容如下----------------

       [Unit] 
       Description=Docker Application Container Engine 
       Documentation=https://docs.docker.com 
       After=network-online.target firewalld.service 
       Wants=network-online.target 
       [Service] 
       Type=notify 
       ExecStart=/usr/bin/dockerd --selinux-enabled=false --insecure-registry=127.0.0.1 
       ExecReload=/bin/kill -s HUP $MAINPID 
       LimitNOFILE=infinity 
       LimitNPROC=infinity 
       LimitCORE=infinity 
       TimeoutStartSec=0 
       Delegate=yes 
       KillMode=process 
       Restart=on-failure 
       StartLimitBurst=3 
       StartLimitInterval=60s 
       [Install] 
       WantedBy=multi-user.target 
     ```

   - 启动docker

     ```shell
     sudo chmod +x /etc/systemd/system/docker.service
     sudo systemctl daemon-reload
     sudo systemctl start docker
     sudo systemctl enable docker
     docker --version


     ------------------实操如下---------------------
     [wop@bogon dockeris]$ sudo chmod +x /etc/systemd/system/docker.service
     [wop@bogon dockeris]$ sudo systemctl daemon-reload
     [wop@bogon dockeris]$ sudo systemctl start docker
     [wop@bogon dockeris]$ sudo systemctl enable docker
     Created symlink /etc/systemd/system/multi-user.target.wants/docker.service → /etc/systemd/system/docker.service.
     [wop@bogon dockeris]$ docker --version
     Docker version 20.10.21, build baeda1f
     ```

     - 配置加速器加速下载docker镜像
     
     ```shell
     sudo vim /etc/docker/daemon.json

      文件内容
{
    "registry-mirrors": ["https://gg3gwnry.mirror.aliyuncs.com"]
}

     重启服务：
     sudo systemctl daemon-reload
     sudo systemctl restart docker

     ```
### 1.1.2 deb包离线安装

使用deb安装包的方式安装需要自己确定所安装系统版本所需的deb安装包型号,**优点是不用自己编写docker.service**

- 确定linux版本
  
   ```shell
   cat /etc/lsb-release 

   DISTRIB_ID=Ubuntu
   DISTRIB_RELEASE=22.04
   DISTRIB_CODENAME=jammy
   DISTRIB_DESCRIPTION="Ubuntu 22.04.1 LTS"
   ````

- 确定dpkg版本
  ```shell
  sudo dpkg  --print-architecture

  amd64
  ```

- 下载地址

  ```shell
  https://download.docker.com/linux/ubuntu/dists/jammy/pool/stable
  ```

- 需要下载以下三个文件
  ```shell
  containerd.io_1.6.9-1_amd64.deb
  docker-ce-cli_20.10.21~3-0~ubuntu-jammy_amd64.deb
  docker-ce_20.10.21~3-0~ubuntu-jammy_amd64.deb
  ```

- 安装命令

  ```shell
  sudo dpkg -i containerd.io_1.6.9-1_amd64.deb && apt-get -f install
  sudo dpkg -i docker-ce-cli_20.10.21~3-0~ubuntu-jammy_amd64.deb && apt-get -f install
  sudo dpkg -i docker-ce_20.10.21~3-0~ubuntu-jammy_amd64.deb && apt-get -f install
  ```

- 启动docker

  ```shell
  systemctl start docker
  ```

- 设置开机自动启动
  ```
  systemctl enable docker.service
  ```




## 1.2 在线安装docker


### 1.2.1 官方安装脚本 (推荐使用+方便快捷)

- 下面以ubuntu系统为例

    ```shell
    curl -fsSL https://test.docker.com -o test-docker.sh
    sudo sh test-docker.sh
    ```

### 1.2.2 手动安装

- 下面以ubuntu系统为例

1. 更新软件包列表：使用以下命令更新软件包列表：

    ```shell
    sudo apt update
    ```

2. 安装依赖软件包：安装Docker所需的依赖软件包：

    ```shell
        sudo apt-get install \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg-agent \
        software-properties-common
    ```

3. 添加Docker官方GPG密钥：通过以下命令添加Docker官方的GPG密钥：

    ```shell
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    ```

4. 添加Docker官方APT源：添加Docker官方的APT源到Ubuntu的软件包管理器中：

    ```shell
    echo "deb [signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    ```

5. 更新软件包列表：再次更新软件包列表以获取Docker：

    ```shell
    sudo apt update
    ```

6. 安装Docker引擎：使用以下命令来安装Docker引擎：

    ```shell
    sudo apt install docker-ce docker-ce-cli containerd.io
    ```

7. 启动Docker服务：使用以下命令启动Docker服务：

    ```shell
    sudo systemctl start docker
    ```

至此，已经完成了在线安装Docker的步骤。

## 1.3 检验docker是否安装成功

要验证Docker是否成功安装，请按照以下步骤执行：

1. 检查Docker版本：在终端中运行以下命令来检查Docker版本：

    ```shell
    docker --version
    ```

如果成功安装，将看到Docker的版本信息。


## 1.4 彻底卸载docker

以下是离线和在线安装Docker的卸载步骤：

**在线安装的卸载步骤**：

1. 停止Docker服务：使用以下命令停止Docker服务：

    ```shell
    sudo systemctl stop docker
    ```

2. 卸载Docker软件包：执行以下命令以卸载Docker软件包：

    ```shell
    sudo apt-get autoremove docker docker-ce docker-engine  docker.io  containerd runc
    ```

3. 查看docker是否卸载干净

    ```shell
    dpkg -l | grep docker
    dpkg -l |grep ^rc|awk '{print $2}' |sudo xargs dpkg -P        ## 删除无用的相关的配置文件
    ```

4. 删除没有删除的相关插件

    ```shell
    sudo sapt-get autoremove docker-ce-*
    ```

5. 删除docker的相关配置&目录

    ```shell
    sudo rm -rf /etc/systemd/system/docker.service.d

    sudo rm -rf /var/lib/docker
    ```

6. 确定docker卸载完毕
   
    ```shell
    docker --version
    ```

**离线安装的卸载步骤**：

1. 停止Docker服务：执行以下命令停止Docker服务：

    ```shell
    sudo systemctl stop docker
    ```

2. 卸载Docker软件包：使用以下命令卸载Docker软件包：

    ```shell
    sudo dpkg -r docker-ce
    ```

3. 删除Docker配置和数据：执行以下命令删除Docker的配置文件和数据：

    ```shell
    sudo rm -rf /var/lib/docker
    ```

4. 删除Docker用户组（如果没有其他使用该组的进程）：使用以下命令删除Docker用户组：

    ```shell
    sudo groupdel docker
    ```

请注意，在卸载Docker之后，容器、镜像和卷将被删除，并且无法恢复。如果希望保留它们，请先备份。此外，如果在安装过程中使用了不同的方法（如使用脚本或其他自定义方式安装的Docker），卸载步骤可能会有所不同。


## 1.5 x86下安装arm版docker

### 1.5.1 安装qemu模拟器

如果想再x86下安装arm版docker,可以借助qemu模拟器模拟arm框架

1. 获取QEMU

 - 下载地址：https://github.com/multiarch/qemu-user-static/releases
 - 下载网站中: `qemu-arm-static`:arm架构 , `qemu-aarch64-static`:aarch64架构
 - 下载: `qemu-aarch64-static` 文件 (**这里以aarch64架构为例**)


2. 安装 
    ```shell
    sudo cp qemu-aarch64-static /usr/bin/
    sudo chmod +x /usr/bin/qemu-aarch64-static
    ```

3. 注册QEMU虚拟机 (**每次重启都要重新注册**)

    ```shell
    sudo docker run --rm --privileged multiarch/qemu-user-static:register
    ```

**注:安装完qemu的模拟器就可以使用x86版本的docker来安装arm版本的docker镜像,在x86架构下实例化一个arm版本的ubuntu的docker镜像**

### 1.5.2 qemu中安装arm版本ubuntu

**注: 安装完qemu的模拟器后确保电脑安装了docker(x86版本)进行一下操作**

1. 在线拉取ubuntu Arm镜像

    ```shell
    sudo docker pull arm64v8/ubuntu:22.04
    ```

**注: 如果是离线的安装ubuntu镜像,请见: 2.2章离线安装ubuntu**

2. 创建Arm容器

    ```shell
    sudo docker run  -it \  
    --name arm_ub\  
    -v /usr/bin/qemu-aarch64-static:/usr/bin/qemu-aarch64-static \  
    -v /etc/timezone:/etc/timezone:ro \  
    -v /etc/localtime:/etc/localtime:ro \  
    arm64v8/ubuntu:22.04 /bin/bash  
    ```

3. 开启这个容器

    ```shell
    sudo docker start arm_ub
    ```

4. 进入容器

    ```shell
    sudo docker exec -it arm_ub /bin/bash
    ```

5. 测试容器的架构

    ```shell
    uname -m

    ---------返回值为-------------
    aarch64
    ```


6. 导出容器

    ```shell
    sudo docker export arm_ub > arm_ub.tar
    ```

7. 导入容器


    ```shell
    sudo docker import arm_ub.tar arm_ub_image
    ```

**注:这里导入导出容器和 第3章导入导出容器的方式相同**

8. 实例化这个镜像

注: 这里在x86架构下实例化arm架构的容器和直接实例化x86架构的容器不相容需要保证,除指令不同外还需要保证:启动QEMU虚拟机,方法请见: 1.5.1 安装qemu模拟器中 3.注册QEMU虚拟机

    ```shell

    sudo docker run -it  --name aaaa -v /usr/bin/qemu-aarch64-static:/usr/bin/qemu-aarch64-static -v /etc/timezone:/etc/timezone:ro -v /etc/localtime:/etc/localtime:ro  arm_ub_cout  /bin/bash

    -----------------------如果上面命令有问题运行下面命令---------------------------

    sudo docker run -it  --name aaaa -v /usr/bin/qemu-aarch64-static:/usr/bin/qemu-aarch64-static   arm_ub_cout  /bin/bash
    ```

9. 启动运行容器

    ```shell
    sudo docker start aaaa

    sudo docker exec -it aaaa /bin/bash
    ```


# 2. docker安装ubuntu

## 2.1 在线安装ubuntu

1. 在线拉取ubuntu镜像

    ```shell
    docker pull ubuntu
    ```

注: 

2. 运行容器，并且可以通过 exec 命令进入 ubuntu 容器


    ```shell
    docker run -itd --name ubuntu-test ubuntu /bin/bash
    ```

3. 启动这个虚拟机

    ```shell
    sudo docker exec -it ubuntu-test /bin/bash
    ```


## 2.2 离线安装ubuntu(导入导出官方镜像 )

1. 从 Docker Hub 或其他镜像仓库下载要导出的 Ubuntu 镜像。可以使用以下命令：

   ```shell
   sudo docker pull ubuntu
   ```


2. 导出 Docker 镜像到一个文件中，可以使用以下命令：

   ```shell
   sudo docker save -o ubuntu_image.tar ubuntu
   ```

   这将把 Ubuntu 镜像保存到 `ubuntu_image.tar` 文件中。

在没有网络连接的机器上：

1. 将 `ubuntu_image.tar` 文件拷贝到没有网络连接的机器上，比如使用 U 盘或其他外部存储设备。

2. 在没有网络连接的机器上，使用以下命令加载已保存的 Docker 镜像：

   ```shell
   sudo docker load -i ubuntu_image.tar
   ```

   这将加载 `ubuntu_image.tar` 文件中的 Docker 镜像到本地 Docker 环境中。

现在，已经将 Ubuntu 镜像成功导入可以在没有网络连接的机器上使用了。请确保文件拷贝过程中保持镜像文件完整性，并确保目标机器上已经安装了 Docker。

需要注意的是，如果有其他依赖项（比如基础镜像或软件包）未被导入的机器上，可能需要手动满足这些依赖关系，以确保镜像的正常运行。


### 2.21 导入镜像后验证

查看镜像是否存在即ID

   ```shell
   wub@wub:~/Downloads$ sudo docker images
   REPOSITORY   TAG       IMAGE ID       CREATED       SIZE
   ubuntu       latest    01f29b872827   3 weeks ago   77.8MB

   ```

然后安装Ubuntu系统

1. 运行容器，并且可以通过 exec 命令进入 ubuntu 容器

    ```shell
    sudo docker run -itd --name docker_ub ubuntu

    ---------
    wub@wub:~/Downloads$ sudo docker run -itd --name docker_ub ubuntu
    ba84659d5b8e6c3c3ced4f6caf65ff1f6bc5f981028a426955b08bbe50c87676

    ```

1. 启动这个虚拟机

    ```shell
    sudo docker exec -it docker_ub /bin/bash

    ---------
    wub@wub:~/Downloads$ sudo docker ps -a
    CONTAINER ID   IMAGE     COMMAND       CREATED         STATUS         PORTS     NAMES
    ba84659d5b8e   ubuntu    "/bin/bash"   2 minutes ago   Up 2 minutes             docker_ub
    wub@wub:~/Downloads$ sudo docker start ba84659d5b8e
    ba84659d5b8e
    wub@wub:~/Downloads$ sudo docker exec -it docker_ub /bin/bash

    ```


# 3. 导出导入容器

## 3.1 容器导出

在 Docker 中，可以使用导入（import）和导出（export）操作来迁移和共享容器。

- 导出容器：使用 `docker export` 命令将一个正在运行的容器导出为一个可传输的 tar 归档文件。命令格式为 `docker export <容器ID或名称> > <输出文件路径>`。例如：
    ```shell
    sudo docker export mycontainer > mycontainer.tar
    ```

这将将容器 `mycontainer` 导出为 `mycontainer.tar` 归档文件。导出的文件包含容器的文件系统和元数据，但不包含容器状态或相关的镜像信息。

## 3.2 容器导入

- 导入容器：使用 `docker import` 命令将一个导出的 tar 归档文件导入为一个新的镜像。命令格式为 `docker import <输入文件路径> <新镜像名称>:<标签>`。例如：

    ```shell
    sudo docker import mycontainer.tar aaa
    ```

这将导入 `mycontainer.tar` 归档文件为名为 `aaa`的新镜像。

- 可以通过`sudo docker images` 查看是否有myimage镜像的存在

请注意以下几点：

- 导出的容器归档文件只包含容器当前的文件系统状态，不包括容器内正在运行的进程、网络配置等状态。
- 导入后的镜像只包含初始文件系统状态，不包含容器的运行时环境、启动命令等配置。需要在创建容器时自行配置这些信息。
- 导入导出的操作适用于单个容器，而不是整个容器编排和服务。

如果需要迁移或共享整个应用程序栈，建议使用 Docker Compose 或其他容器编排工具来管理整个应用程序的容器集合。这样可以更方便地管理和迁移整个应用程序。

### 脑洞

- docker save和docker export的区别
  docker save保存的是镜像（image），docker export保存的是容器（container）；
  docker load用来载入镜像包，docker import用来载入容器包，但两者都会恢复为镜像；
  docker load不能对载入的镜像重命名，而docker import可以为镜像指定新名称。
  docker load不能载入容器包。
  docker import虽可以载入镜像包,但是无法启动等价于不能启动改容器


## 3.3 容器镜像实例化

- 可以通过`sudo docker images` 查看是否有 mycontainer.tar包导出的镜像名称如:aaa

```shell
wub@wub:~/Downloads$ sudo docker images
REPOSITORY   TAG       IMAGE ID       CREATED          SIZE
aaa          latest    baa55ebfbd94   36 minutes ago   155MB
ubuntu       latest    01f29b872827   3 weeks ago      77.8MB
```

- 创建镜像为一个实例容器

```shell
sudo docker run -it  --name bbb  aaa  /bin/bash

----------------

wub@wub:~/Downloads$ sudo docker run -it  --name bbb aaa  /bin/bash
root@e87db5c5413c:/## cd home/docker_test/cout/
root@e87db5c5413c:/home/docker_test/cout## ls
libasan.so.5  libltdl.so.7  libodbc.so.2  libtool_lib_name.a  pro_main
root@e87db5c5413c:/home/docker_test/cout## ./pro_main 
Start tool_class
Hello: 0
Hello: 1
Hello: 2
Hello: 3
^C
root@e87db5c5413c:/home/docker_test/cout## exit
exit
wub@wub:~/Downloads$ sudo docker ps -a
CONTAINER ID   IMAGE     COMMAND       CREATED          STATUS                            PORTS                                         NAMES
e87db5c5413c   aaa       "/bin/bash"   31 seconds ago   Exited (130) 3 seconds ago                                                      bbb

```

## 3.4 创建容器端口映射


使用 `docker run` 命令来启动容器并进行端口映射。例如，将容器内部的端口 5000 映射到主机 B 的端口 8081：

 ```shell
# 单个端口
 sudo docker run -it -p 8081:5000 --name link_ub   ub_sql /bin/bash
# 多个端口
 sudo docker run -it -p 10020:9090 -p 10021:9091  --name ublink  ubuntu:22.04  /bin/bash
# 连续端口映射
 sudo docker run -d -p 8000-8010:8000-8010 --name ublink  ubuntu:22.04  /bin/bash # 容器内部的8000到8010端口将依次映射到宿主机的相同范围的端口上
 --------------
 wub@wub:~/Downloads$ sudo docker run -it -p 0.0.0.0:8081:5000 --name link_ub   ub_sql /bin/bash
  root@e352b1e281f3:/# exit
  exit
  wub@wub:~/Downloads$ sudo docker ps -a
  CONTAINER ID   IMAGE     COMMAND       CREATED          STATUS                      PORTS                                         NAMES
  e352b1e281f3   ub_sql    "/bin/bash"   13 seconds ago   Exited (0) 2 seconds ago                                                  link_ub
  e87db5c5413c   aaa       "/bin/bash"   6 hours ago      Up 2 hours                                                                bbb
  wub@wub:~/Downloads$ sudo docker start e352b1e281f3
  e352b1e281f3
  wub@wub:~/Downloads$ sudo docker ps -a
  CONTAINER ID   IMAGE     COMMAND       CREATED          STATUS                      PORTS                                         NAMES
  e352b1e281f3   ub_sql    "/bin/bash"   42 seconds ago   Up 1 second                 0.0.0.0:8081->5000/tcp                        link_ub
  ```

数据库密码: Abc.123456


### 3.4.1 修改容器的端口映射

1. 查询容器的完整ID
 ```shell
 
 ```
 ```shell
wub@wub:~$ sudo docker inspect silly_utils_1 |grep Id
        "Id": "e13796630166625b69ee492a2e29176677e3b239668a9b57acdab492d77f917d",
wub@wub:~$ 
 ```

2. 关闭容器和docker


 ```shell
 sudo docker stop silly_utils_1
 sudo systemctl stop docker
 ```


3. 进到/var/lib/docker/containers 目录下找到与 Id 相同的目录，修改 hostconfig.json 和 config.v2.json文件：

  1. hostconfig.json文件中添加 `"PortBindings": {"8081/tcp": [{"HostIp": "","HostPort": "5001"}],"8085/tcp": [{"HostIp": "","HostPort": "5005"}]},`,如下,下面仅hostconfig.json文件部分(8081/tcp:表示容器的端口,"HostPort": "5001":表示宿主机的端口)
   ```json
    "Binds": [
        "/usr/bin/qemu-aarch64-static:/usr/bin/qemu-aarch64-static"
    ],
    "ContainerIDFile": "",
    "LogConfig": {
        "Type": "json-file",
        "Config": {}
    },
    "NetworkMode": "default",
    "PortBindings": {
        "8081/tcp": [
            {
                "HostIp": "",
                "HostPort": "5001"
            }
        ],
        "8085/tcp": [
            {
                "HostIp": "",
                "HostPort": "5005"
            }
        ]
    },
    "PortBindings": {},
    "RestartPolicy": {
        "Name": "no",
        "MaximumRetryCount": 0
    },
    ```

    1. config.v2.json文件中添加`"ExposedPorts": {"8081/tcp": {},"8085/tcp": {}},`,如下,下面仅config.v2.json文件部分  这里的端口为容器的开放端口
     ```json
    "Managed": false,
    "Path": "/bin/bash",
    "Args": [],
    "Config": {
        "Hostname": "e13796630166",
        "Domainname": "",
        "User": "",
        "AttachStdin": true,
        "AttachStdout": true,
        "AttachStderr": true,
        "ExposedPorts": {
            "8081/tcp": {},
            "8082/tcp": {}
        },
        "Tty": true,

      ```


4. 重启容器和docker

 ```shell
 sudo systemctl restart docker
 sudo docker start silly_utils_1

 wub@wub:~$ sudo docker ps -a
CONTAINER ID   IMAGE                  COMMAND       CREATED          STATUS                        PORTS                NAMES
3f2797b1863c   ubuntu                 "/bin/bash"   35 minutes ago   Exited (0) 35 minutes ago                          aaaa
e13796630166   arm_ub_cout            "/bin/bash"   45 minutes ago   Up 12 seconds                 0.0.0.0:5001->8081/tcp, :::5001->8081/tcp, 0.0.0.0:5005->8085/tcp, :::5005->8085/tcp   silly_utils_1

 ```



## 3.5 容器之间的互通

### 3.5.1 network连接容器

#### 3.5.1.1 创建网络随机ip地址
- 新建 Docker 网络

```shell
sudo docker network create -d bridge my-net
```

- 运行两个容器并加入到 my-net 网络

```shell
sudo docker run -it --name nnn --network my-net net /bin/bash
sudo docker run -it --name mmm --network my-net net /bin/bash
```

- 验证两个容器是否联通

这里在nnn容器中ping一下mmm容器

```shell
root@87df6a3b26b4:/# ping mmm
PING mmm (172.18.0.3) 56(84) bytes of data.
64 bytes from mmm.my-net (172.18.0.3): icmp_seq=1 ttl=64 time=0.160 ms
64 bytes from mmm.my-net (172.18.0.3): icmp_seq=2 ttl=64 time=0.188 ms
64 bytes from mmm.my-net (172.18.0.3): icmp_seq=3 ttl=64 time=0.149 ms
```

用 ping 来测试连接 mmm 容器，它会解析成 172.18.0.3。

这个网络是docker虚拟出来的一个内部网络


mmm容器可以直接通过172.18.0.3这个IP地址与nnn进行通讯,以链接mysql为例(nnn链接mmm的mysql):

```shell
root@87df6a3b26b4:/# mysql -h 172.18.0.3  -P 3306 -u root -p
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 18
Server version: 8.0.34-0ubuntu0.22.04.1 (Ubuntu)

Copyright (c) 2000, 2023, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> 
```

#### 3.5.1.2 创建网络并固定IP地址

在 Docker 中，要为容器固定 IP 地址，并将其添加到网络中，有几种方法可以实现：

1. 创建一个自定义网络并指定子网范围以及网关地址：
```bash
docker network create --subnet=<subnet> --gateway=<gateway> my-network
# 将 `<subnet>` 替换为所需的子网地址和范围（例如，172.18.0.0/16），将 `<gateway>` 替换为所需的网关地址（例如，172.18.0.1）。
 
---------------实例------------------------
sudo docker network create --subnet=188.20.0.0/16 --gateway=188.20.0.1 ip_net

```

2. 启动容器时，使用 `--network` 参数将容器连接到自定义网络，并使用 `--ip` 参数指定容器的 IP 地址：
```bash
docker run -d --network=my-network --ip=<ip_address> --name container1 <image1>
# 将 `<ip_address>` 替换为所需的固定 IP 地址。

---------------实例------------------------
sudo  docker run -it --name ip_5 --network=ip_net --ip=188.20.0.5  net /bin/bash
sudo  docker run -it --name ip_6 --network=ip_net --ip=188.20.0.6  net /bin/bash
```

3. 验证

```shell

# ip_5容器----------------------------------

wub@wub:~$ sudo docker exec -it ip_5 /bin/bash
root@40ee057073be:/# ifconfig 
eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 188.20.0.5  netmask 255.255.0.0  broadcast 188.20.255.255
        ether 02:42:bc:14:00:05  txqueuelen 0  (Ethernet)
        RX packets 26  bytes 3116 (3.1 KB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

# ip_6容器----------------------------------

wub@wub:~$ sudo docker exec -it ip_6 /bin/bash
[sudo] password for wub: 
root@b8e4e5e8e847:/# ifconfig 
eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 188.20.0.6  netmask 255.255.0.0  broadcast 188.20.255.255
        ether 02:42:bc:14:00:06  txqueuelen 0  (Ethernet)
        RX packets 27  bytes 3180 (3.1 KB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

lo: flags=73<UP,LOOPBACK,RUNNING>  mtu 65536
        inet 127.0.0.1  netmask 255.0.0.0
        loop  txqueuelen 1000  (Local Loopback)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

root@b8e4e5e8e847:/# ping 188.20.0.5
PING 188.20.0.5 (188.20.0.5) 56(84) bytes of data.
64 bytes from 188.20.0.5: icmp_seq=1 ttl=64 time=111 ms
64 bytes from 188.20.0.5: icmp_seq=2 ttl=64 time=0.150 ms
64 bytes from 188.20.0.5: icmp_seq=3 ttl=64 time=0.103 ms
```


### 3.5.2 link连接容器

同一台宿主机上的多个docker容器之间如果想进行通信，可以通过使用容器的ip地址来通信，也可以通过宿主机的ip加上容器暴露出的端口来通信，前者会导致ip址址的硬编码，不方便迁移，并且容器重启后ip地址会改变，除非使用固定的ip，后都的通信方式比较单一，只能依靠监听在暴露出的端口的进程来进来有限通信。通信docker的link机制可以通过一个name来和另一个容器通信，link机制方便了容器去发现其它的容器并且可以安全的传递一些连接信息给其它的容器

使用--link参数可以让容器之间安全地进行交互

- 创建两个容器并连接他们

```shell
sudo docker run -it --name vvv  net /bin/bash

sudo docker start vvv   # 连接的容器必须要启动

sudo docker run -it --name ccc --link vvv  net /bin/bash

```

- 测试连接

```shell
root@5c97110084fa:/# ping vvv
PING vvv (172.17.0.2) 56(84) bytes of data.
64 bytes from vvv (172.17.0.2): icmp_seq=1 ttl=64 time=0.192 ms
64 bytes from vvv (172.17.0.2): icmp_seq=2 ttl=64 time=0.096 ms
64 bytes from vvv (172.17.0.2): icmp_seq=3 ttl=64 time=0.073 ms

# -------------------------
# vvv容器连接ccc的数据库
root@6a6d7099b850:/# mysql -h 172.17.0.3  -P 3306 -u root -p
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 11
Server version: 8.0.34-0ubuntu0.22.04.1 (Ubuntu)

Copyright (c) 2000, 2023, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> show databases;


```


### 3.5.3 绑定宿主机端口连接两个容器


- 创建两个容器分别绑定宿主机的8086和8085端口

```shell
sudo docker run -it -p 8085:3306 --name ppp1  net  /bin/bash
sudo docker run -it -p 8086:3306 --name ppp2  net  /bin/bash
```

- 绑定宿主机的8086和8085端口

```shell
sudo iptables -A INPUT -p tcp --dport 8085 -j ACCEPT
sudo iptables -A OUTPUT -p tcp --sport 8085 -j ACCEPT
sudo iptables -A INPUT -p tcp --dport 8086 -j ACCEPT
sudo iptables -A OUTPUT -p tcp --sport 8086 -j ACCEPT

sudo ufw allow 8085
sudo ufw allow 8086
```

- 测试

   1. 在ppp1中数据库添加一个ppp1的库

```shell
mysql> CREATE DATABASE ppp1;
Query OK, 1 row affected (0.00 sec)

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| aaaa               |
| information_schema |
| mysql              |
| performance_schema |
| ppp1               |
| sys                |
+--------------------+
6 rows in set (0.00 sec)

```
   2. 在ppp2中访问宿主机的IP地址,端口为ppp2绑定的端口

```shell
root@83b1e83476b7:/# mysql -h 172.17.0.1  -P 8085 -u root -p
Enter password: 
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 11
Server version: 8.0.34-0ubuntu0.22.04.1 (Ubuntu)

Copyright (c) 2000, 2023, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| aaaa               |
| information_schema |
| mysql              |
| performance_schema |
| ppp1               |
| sys                |
+--------------------+
6 rows in set (0.00 sec)

```


## 3.6 容器与宿主机的目录挂载
 
目录挂载即容器的目录A挂载到宿主机的B目录下,容器的A目录会显示宿主机B目录下的所有文件

### 3.6.1 创建容器是设定挂载目录


```shell
sudo docker run -it --name 容器名称  -v v /宿主机目录:/容器目录   镜像  /bin/bash

# 例如:
sudo docker run -it --name ub2204_v2  -v /home/wkl/code:/home/mount_dir ubuntu:22.04 /bin/bash

# 新创建的ub2204_v2容器就会自动生成/home/mount_dir目录,在该目录下会显示宿主机/home/wkl/code目录下的文件

```

可以使用: `docker inspect` 指令来参看某个容器的详细例如 `sudo docker inspect ub2204_v2`,获得一个 JSON 格式的输出，其中包含有关指定 Docker 对象的各种属性和配置信息。
如下是关于挂载的信息
```shell

"Mounts": [
  {
      "Type": "bind",
      "Source": "/home/wkl/code",
      "Destination": "/home/mount_dir",
      "Mode": "",
      "RW": true,
      "Propagation": "rprivate"
  }
]

```

### 3.6.1 修改已有容器的挂载目录

分为两种:
1. 容器已经有挂载的目录需要修改
2. 容器已经有挂载的目录需要再添加
3. 容器没有挂载目录需要新建

上面三种的做法相同

1. 查询需要修改容器的容器id

```shell
[root@bogon test]# sudo docker ps -a
CONTAINER ID   IMAGE             COMMAND       CREATED             STATUS                        PORTS     NAMES
834f04a42137   ubuntu:22.04      "/bin/bash"   3 hours ago         Up 10 minutes                           ub2204_v1
```

2. 先关闭docker服务

```shell
sudo systemctl stop docker
```

3. 修改容器的config.v2.json配置文件

config.v2.json文件地址:` /var/lib/docker/containers/"container-ID"/config.v2.json` :container-ID为我们查询到的容器id 在`/var/lib/docker/containers`目录下的目录id会比我们查到的要长,匹配前几位
内容如下:
```json
{
    "StreamConfig": {},
    "State": {
        "Running": false,
        "Paused": false,
        "Restarting": false,
        "OOMKilled": false,
        "RemovalInProgress": false,
        "Dead": false,
        "Pid": 0,
        "ExitCode": 137,
        "Error": "",
        "StartedAt": "2024-01-11T03:42:33.354943872Z",
        "FinishedAt": "2024-01-11T05:26:14.177822542Z",
        "Health": null
    },
    "ID": "834f04a42137492a5118af8a5aa283d4ba2c70bb38a032b13f3084e0c902b573",
    "Created": "2024-01-11T03:42:32.750450669Z",
    "Managed": false,
    "Path": "/bin/bash",
    "Args": [],
    "Config": {
        "Hostname": "834f04a42137",
        "Domainname": "",
        "User": "",
        "AttachStdin": false,
        "AttachStdout": false,
        "AttachStderr": false,
        "Tty": true,
        "OpenStdin": true,
        "StdinOnce": false,
        "Env": [
            "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
        ],
        "Cmd": [
            "/bin/bash"
        ],
        "Image": "ubuntu:22.04",
        "Volumes": null,
        "WorkingDir": "",
        "Entrypoint": null,
        "OnBuild": null,
        "Labels": {}
    },
    "Image": "sha256:9d28ccdc1fc782ec635c98e55ff68b05e6de1df2c7fcbbb4385f023368eec716",
    "NetworkSettings": {
        "Bridge": "",
        "SandboxID": "a4c9a52cb61038d00f97c79ad98e25f4840ec01d5ddafa205e0d71cfe873c1f0",
        "HairpinMode": false,
        "LinkLocalIPv6Address": "",
        "LinkLocalIPv6PrefixLen": 0,
        "Networks": {
            "bridge": {
                "IPAMConfig": null,
                "Links": null,
                "Aliases": null,
                "NetworkID": "f445283fee5aa0b8dc236a2b54992c62826ebc77eab20913649196b8c1ee14f8",
                "EndpointID": "",
                "Gateway": "",
                "IPAddress": "",
                "IPPrefixLen": 0,
                "IPv6Gateway": "",
                "GlobalIPv6Address": "",
                "GlobalIPv6PrefixLen": 0,
                "MacAddress": "",
                "DriverOpts": null,
                "IPAMOperational": false
            }
        },
        "Service": null,
        "Ports": null,
        "SandboxKey": "/var/run/docker/netns/a4c9a52cb610",
        "SecondaryIPAddresses": null,
        "SecondaryIPv6Addresses": null,
        "IsAnonymousEndpoint": false,
        "HasSwarmEndpoint": false
    },
    "LogPath": "/var/lib/docker/containers/834f04a42137492a5118af8a5aa283d4ba2c70bb38a032b13f3084e0c902b573/834f04a42137492a5118af8a5aa283d4ba2c70bb38a032b13f3084e0c902b573-json.log",
    "Name": "/ub2204_v1",
    "Driver": "overlay2",
    "OS": "linux",
    "MountLabel": "",
    "ProcessLabel": "",
    "RestartCount": 0,
    "HasBeenStartedBefore": true,
    "HasBeenManuallyStopped": true,
    "MountPoints": {},
    "SecretReferences": null,
    "ConfigReferences": null,
    "AppArmorProfile": "",
    "HostnamePath": "/var/lib/docker/containers/834f04a42137492a5118af8a5aa283d4ba2c70bb38a032b13f3084e0c902b573/hostname",
    "HostsPath": "/var/lib/docker/containers/834f04a42137492a5118af8a5aa283d4ba2c70bb38a032b13f3084e0c902b573/hosts",
    "ShmPath": "",
    "ResolvConfPath": "/var/lib/docker/containers/834f04a42137492a5118af8a5aa283d4ba2c70bb38a032b13f3084e0c902b573/resolv.conf",
    "SeccompProfile": "",
    "NoNewPrivileges": false,
    "LocalLogCacheMeta": {
        "HaveNotifyEnabled": false
    }
}
```

文件中"MountPoints": {},为空表示没有设定过目录挂载

如果是如下表示: 容器目录:`/home/mount_dir`映射到宿主机目录:`/home/wkl/code`
```json
"MountPoints": {
        "/home/mount_dir": {
            "Source": "/home/wkl/code",
            "Destination": "/home/mount_dir",
            "RW": true,
            "Name": "",
            "Driver": "",
            "Type": "bind",
            "Propagation": "rprivate",
            "Spec": {
                "Type": "bind",
                "Source": "/home/wkl/code",
                "Target": "/home/mount_dir"
            },
            "SkipMountpointCreation": false
        }
    },
```
修改仅需吧需要的修改的容器目录和宿主机目录修改即可

如需添加的话,会设置两个目录挂载
```json
    "MountPoints": {
        "/home/ub_doc_test": {
            "Source": "/home/wkl/test",
            "Destination": "/home/ub_doc_test",
            "RW": true,
            "Name": "",
            "Driver": "",
            "Type": "bind",
            "Propagation": "rprivate",
            "Spec": {
                "Type": "bind",
                "Source": "/home/wkl/test",
                "Target": "/home/ub_doc_test"
            },
            "SkipMountpointCreation": false
        },
        "/home/ub_doc_2": {
            "Source": "/home/wkl/test2",
            "Destination": "/home/ub_doc_2",
            "Name": "",
            "Driver": "",
            "Type": "bind",
            "Propagation": "rprivate",
            "Spec": {
                "Type": "bind",
                "Source": "/home/wkl/test2",
                "Target": "/home/ub_doc_2"
            },
            "SkipMountpointCreation": false
        }
    },
```

映射文件

```json
"/etc/odbc.ini": {
    "Source": "/usr/local/TzxProject/Conf/odbc.ini",
    "Destination": "/etc/odbc.ini",
    "RW": true,
    "Name": "",
    "Driver": "",
    "Type": "bind",
    "Propagation": "rprivate",
    "Spec": {
        "Type": "bind",
        "Source": "/usr/local/TzxProject/Conf/odbc.ini",
        "Target": "/etc/odbc.ini"
    },
    "SkipMountpointCreation": false
},
```

1. 修改完之后重启docker

```shell
sudo systemctl restart docker
```


## 3.7 docker容器设置开机自启动

### 3.7.1 创建是设置

```shell
docker run -d --restart=always --name 设置容器名 使用的镜像
（上面命令  --name后面两个参数根据实际情况自行修改）
 
# Docker 容器的重启策略如下：
 --restart具体参数值详细信息：
       no　　　　　　　 // 默认策略,容器退出时不重启容器；
       on-failure　　  // 在容器非正常退出时（退出状态非0）才重新启动容器；
       on-failure:3    // 在容器非正常退出时重启容器，最多重启3次；
       always　　　　  // 无论退出状态是如何，都重启容器；
       unless-stopped  // 在容器退出时总是重启容器，但是不考虑在 Docker 守护进程启动时就已经停止了的容器。

```

### 3.7.2 创建后修改

```shell
# 设置开机自启动
[root@localhost ~]# sudo docker ps -a
CONTAINER ID   IMAGE             COMMAND       CREATED      STATUS                       PORTS     NAMES
02d043707227   ubuntu:22.04      "/bin/bash"   6 days ago   Exited (137) 6 days ago                ub2204_v2
[root@localhost ~]# sudo docker update --restart=always  ub2204_v2
ub2204_v2

取消开机自启动
# docker update --restart=no 容器名或容器ID
docker update --restart=no <CONTAINER ID>


--------重启后----------
[root@localhost ~]# sudo docker ps -a
CONTAINER ID   IMAGE             COMMAND       CREATED      STATUS                        PORTS     NAMES
02d043707227   ubuntu:22.04      "/bin/bash"   6 days ago   Up 32 seconds                           ub2204_v2

```


## 3.8 docker容器存储位置移动


1. 查看当前docker的默认存储目录

```shell
[root@localhost ~]# sudo docker info
...
Storage Driver: overlay
...
Docker Root Dir: /var/lib/docker
```
默认地址为:`/var/lib/docker`

2. 先关闭docker服务

```shell
sudo systemctl stop docker
```

3. 操作


```shell
# 创建一个新目录
[root@localhost wkl]# mkdir /mnt/docker
[root@localhost docker]# pwd
/home/wkl/mnt/docker

# 复制文件
[root@localhost docker]# sudo rsync -avz /var/lib/docker/ /home/wkl/mnt/docker

# 修改系统文件
[root@localhost docker]# sudo vim /etc/docker/daemon.json

{
   "data-root": "/home/wkl/mnt/docker",
   "registry-mirrors": ["https://gg3gwnry.mirror.aliyuncs.com"]
}



```

4. 修改完之后重启docker

```shell
sudo systemctl daemon-reload
sudo systemctl restart docker
```

5. 检查

```shell
[root@bogon ~]# sudo docker info
....
 Docker Root Dir: /home/wkl/mnt/docker

[root@bogon ~]# sudo docker inspect ub2204_v2
[
    {
        "Id": "02d043707227df7795125ac04c2e40f4d9eb36cdbd3b9c5bd0d7bb14ccff6130",
        "Created": "2024-01-11T05:46:30.046730575Z",
        "Path": "/bin/bash",
        "Args": [],
        "State": {
            "Status": "running",
            "Running": true,
            "Paused": false,
            "Restarting": false,
            "OOMKilled": false,
            "Dead": false,
            "Pid": 6759,
            "ExitCode": 0,
            "Error": "",
            "StartedAt": "2024-01-18T06:46:17.341623116Z",
            "FinishedAt": "2024-01-18T14:46:15.971959559+08:00"
        },
        "Image": "sha256:9d28ccdc1fc782ec635c98e55ff68b05e6de1df2c7fcbbb4385f023368eec716",
        "ResolvConfPath": "/home/wkl/mnt/docker/containers/02d043707227df7795125ac04c2e40f4d9eb36cdbd3b9c5bd0d7bb14ccff6130/resolv.conf",
        "HostnamePath": "/home/wkl/mnt/docker/containers/02d043707227df7795125ac04c2e40f4d9eb36cdbd3b9c5bd0d7bb14ccff6130/hostname",
        "HostsPath": "/home/wkl/mnt/docker/containers/02d043707227df7795125ac04c2e40f4d9eb36cdbd3b9c5bd0d7bb14ccff6130/hosts",
        "LogPath": "/home/wkl/mnt/docker/containers/02d043707227df7795125ac04c2e40f4d9eb36cdbd3b9c5bd0d7bb14ccff6130/02d043707227df7795125ac04c2e40f4d9eb36cdbd3b9c5bd0d7bb14ccff6130-json.log",


```

## 3.10 docker容器的CPU和内存使用限制




```shell


```


# 4. docker常用指令

## 4.1 宿主机和容器间互传文件

```bash

```

要在Docker容器和宿主机之间传输文件，你可以使用Docker的`docker cp`命令。以下是传输文件的步骤：

1. 首先，确定你的容器名称或ID。
   - 使用`docker ps`命令来查找正在运行的容器，并记录下容器的名称或ID。

2. 在宿主机上将文件复制到容器中：
   - 使用以下命令将文件从宿主机复制到容器中：
     ```bash
     docker cp <本地文件路径> <容器名称或ID>:<目标容器路径>
     ```
     例如，如果文件位于宿主机的`/path/to/file.txt`路径下，容器名称为`my-container`，要将文件复制到容器的`/container/path/`路径下，可以运行以下命令：
     ```bash
     docker cp /path/to/file.txt my-container:/container/path/
     ```

3. 在容器中将文件复制到宿主机：
   - 使用以下命令将文件从容器复制到宿主机中：
     ```bash
     docker cp <容器名称或ID>:<容器内文件路径> <本地文件路径>
     ```
     例如，如果文件位于容器的`/container/path/file.txt`路径下，要将文件复制到宿主机的`/path/to/`路径下，可以运行以下命令：
     ```bash
     docker cp my-container:/container/path/file.txt /path/to/
     ```

 ```bash
 示例
 wub@wub:~/docker_file$ sudo docker cp ./1.txt docker_ub:/home
 [sudo] password for wub: 
 wub@wub:~/docker_file$ sudo docker exec -it docker_ub /bin/bash
 root@ba84659d5b8e:/# cd home/
 root@ba84659d5b8e:/home# ls
 1.txt
 root@ba84659d5b8e:/home# 

 ```


## 4.1 查看docker各个容器的大小

```bash
sudo docker system df -v
```

## 4.2 限制容器的cpu和内存使用率

### 4.2.1 限制内存使用

让我们将容器可以使用的内存限制为512mb

```bash
docker run -m 512m --name ubtest ub2204_env:v1  /bin/bash
```


### 4.2.2 限制CPU的使用


```bash
sudo docker run -it --name temp_cpu_m_1 --cpus=2 ubuntu:22.04 /bin/bash
```






```bash

```

# 5. Dockerfile定制镜像

通过Dockerfile的方式定制镜像,Dockerfile就类似于shell脚本一样的存在,直接对一个原始的镜像进项部署定制


创建一个单独的文件夹create_docker
在这个文件夹下创建一个名为Dockerfile的文件:`touch Dockerfile`

将下面文件复制到Dockerfile文件中,可添加自己需要的安装指令
```bash
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
    && rm -rf /var/lib/apt/lists/*

# 将达梦数据库的bin目录复制到Dockerfile的同级目录下
COPY ./bin /opt/dmdbms/
COPY ./Shanghai /etc/localtime


CMD ["/bin/bash"]
```

保存后sudo chmod 777 Dockerfile 赋予这个文件权限

在Dockerfile所在的目录中执行以下命令来构建镜像：
```bash
sudo docker build -t ub2204_env:v1  .
```
创建出名为ub2204_env,标签为v1的镜像,然后再根据该镜像实例化容器

```bash
sudo docker run -it --name ubtest ub2204_env:v1  /bin/bash
```

```bash
sudo docker run -it -p 10020:9090 -p 10021:9091 -v /home/wkl/test2:/home/test_shard_2 -v /home/wkl/test:/home/test_shard_2 --name ubtest ub2204_env:v1  /bin/bash
```


# 创建MySQL容器

- 拉取镜像

```shell
```

```bash
    docker pull mysql	    #下载最新版Mysql镜像 (其实此命令就等同于 : docker pull mysql:latest )
    docker pull mysql:xxx	#下载指定版本的Mysql镜像 (xxx指具体版本号)
```

-  创建容器指令

```shell
sudo docker run \
-it \
--name mysql \
-p 3306:3306 \
--restart=always \
-v /mydata/mysql/data:/var/lib/mysql \
-v /mydata/mysql/log:/var/log/mysql \
-v /mydata/mysql/conf:/etc/mysql \
-e MYSQL_ROOT_PASSWORD=123456 \
-e TZ=Asia/Shanghai \
mysql:5.7
```

```shell
sudo docker run -itd --name mysql_test -p 3306:3306 -e MYSQL_ROOT_PASSWORD=123456 -e TZ=Asia/Shanghai mysql:5.7

sudo docker run -it --name mysql_test -p 3306:3306  --restart=always -v /mydata/mysql/data:/var/lib/mysql -v /mydata/mysql/log:/var/log/mysql -v /mydata/mysql/conf:/etc/mysql -e MYSQL_ROOT_PASSWORD=123456 -e TZ=Asia/Shanghai mysql:5.7

sudo docker run -itd --restart=always --name mysql_svr -v /usr/local/TzxProject/Dats/mysql/log:/var/log/mysql -v /usr/local/TzxProject/Dats/mysql/data:/var/lib/mysql  -p 3306:3306 -e MYSQL_ROOT_PASSWORD=123456 -e TZ=Asia/Shanghai mysql:latest

# mysql8.3.0
sudo mkdir /home/wub/mysql_83/conf/conf.d
sudo docker run -itd --name mysql_83 -p 13309:3306  --restart=always -v /home/wub/mysql_83/data:/var/lib/mysql -v /home/wub/mysql_83/log:/var/log/mysql -v /home/wub/mysql_83/conf:/etc/mysql/ -e MYSQL_ROOT_PASSWORD=123456 -e TZ=Asia/Shanghai mysql:8.3.0

```


### 修改用户密码

- 修改root用户密码
  进入mysql后执行下面sql语句
```sql
ALTER USER 'root'@'localhost' IDENTIFIED BY 'new_password';
```

### 新加用户

```sql
CREATE USER 'new_user'@'%' IDENTIFIED BY 'new_pass';  -- 创建新用户 new_user 及密码 new_pass
GRANT ALL ON 库名.* TO `wub`@`%`; -- 为 new_user 用户设置 new_db 库的权限
flush privileges; -- 刷新用户权限
exit; -- 退出
```


# 部署挂载指令

## svr类型容器部署

```shell
sudo docker run -itd --name ~~~_svr -p 8000-8010:8000-8010 -v /usr/local/(TzxProjet/tzx_pro)/~~ :/tzx/PROJ_ROOT ubuntu:22.04 /bin/bash

```

-----

查看系统架构的指令
uname -m
查看系统版本
cat /etc/centos-release

















