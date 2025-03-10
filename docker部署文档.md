
[TOC]


# 环境说明

本次测试使用环境:
   - 测试方式:win10专业版,在vmware中安装ubuntu22.04版本虚拟机(均为x86架构)
   - 在ubuntu22.04虚拟机中安装x86架构20.10.21版本docker
   - docker中安装22.04版本ubuntu容器
   - 测试arm版本的docker安装aarch64版本的qemu模拟器,并安装aarch64版本ubuntu22.04版本镜像容器


# Docker 的常用命令

以下是一些常用的 Docker 命令：


1. **拉取镜像**：
   ```bash
   docker pull <镜像名>
   ```
   例如：`docker pull nginx`（拉取Nginx镜像）。

2. **查看容器**：
   - 正在运行的容器： 
   ```bash
   docker ps
   ```
   - 所有的容器：
   ```bash
   docker ps -a
   ```

3. **(启动/停止/重启)容器**:
   - 启动容器：
   ```bash
   docker start <容器名/容器ID>
   ```
    - 停止容器：
   ```bash
   docker stop <容器名/容器ID>
   ```
    - 重启容器：
   ```bash
   docker restart <容器名/容器ID>
   ```

4. **命令行进入容器内部**:
   ```bash
   docker exec -it <容器名/容器ID> /bin/bash
   ```

5. **删除容器**：
   ```bash
   docker rm <容器ID>
   ```

6.  **查看镜像**：
   ```bash
   docker images
   ```

7.  **删除镜像**：
   ```bash
   docker rmi <镜像名>
   ```

8.  **容器和宿主机之间复制传输文件**：
   ```bash
   docker cp <宿主机文件路径> <容器名/容器ID>:<容器内路径>
   docker cp <容器名/容器ID>:<容器内路径> <宿主机文件路径>
   ```

9.  **查看容器日志**：
   ```bash
   docker logs <容器名/容器ID>
   ```

10. **查看容器信息**：
   ```bash
   docker inspect <容器名/容器ID>
   ```

11. **实例化容器**：

  - 创建容器：
   ```bash
   docker run -it  --name ublink  ubuntu:22.04  /bin/bash
   ```

   - 创建容器并创建端口映射
   ```bash
   docker run -it -p <宿主机端口>:<容器内端口> --name 容器名称  <镜像名称>  /bin/bash

    docker run -it -p 10020:9090 -p 10021:9091  --name ublink  ubuntu:22.04  /bin/bash
   ```

   - 创建容器并创建端口映射并挂载目录

   ```bash
    docker run -it -v  宿主机目录:容器目录 --name 容器名称 <镜像名称> /bin/bash

    docker run -it --name ublink -v /home/ublink:/home/ublink  ubuntu:22.04  /bin/bash
   ```

12. **设置/关闭容器开机自启动**：

  - 设置容器开机自启动：
   ```bash
   docker update --restart=always <容器名/容器ID>
   ```

  - 关闭容器开机自启动：
   ```bash
   docker update --restart=no <容器名/容器ID>
   ```


13. **官方镜像的导入导出**

  - 导出容器：
  ```bash
  docker save -o <导出文件名>.tar <官方容器名/官方容器ID>
  ```

  - 导入容器：
  ```bash
  docker load -i <导出文件名>.tar
  ```

14. **自制容器的导入导出**
  - 导出容器：
  ```bash
  docker export (自制容器名/自制容器ID) > (<导出文件名>.tar )
  ```

  - 导入容器：
  ```bash
  docker import <导出文件名>.tar <自制容器名>
  ```


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

- 查看镜像是否存在即ID

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

2. 启动这个虚拟机

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


- 使用 `docker run` 命令来启动容器并进行端口映射。例如，将容器内部的端口 5000 映射到主机 B 的端口 8081：

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


-----

docker容器启动后的流程顺序

当你执行 `docker start <container-name>` 命令时，Docker 会尝试启动一个已经存在的容器，而不是创建一个新的容器。这里的“容器已经存在”意味着容器之前已经被创建，并且它的文件系统、网络设置等都已经存在。

### `docker start <container-name>` 的执行步骤

执行 `docker start` 后，容器的启动过程可以分为以下几个关键阶段：

### 1. **Docker守护进程检查容器的状态**
   - 当你执行 `docker start <container-name>` 时，Docker 守护进程会先检查容器的当前状态。
     - 如果容器已停止（但没有被删除），Docker 会将其标记为“已启动”并将其状态更新为“正在运行”。
     - 如果容器处于运行状态，则不会有任何变化。
     - 如果容器不存在，Docker 会提示错误。

### 2. **恢复容器的网络设置**
   - Docker 会恢复容器的网络配置，重新将容器连接到 Docker 网络。如果在创建容器时指定了自定义网络，则会将其连接到该网络。
   - 如果你使用了端口映射（例如 `-p` 参数），这些端口映射仍然保持有效。

   在启动过程中，Docker 会重新配置以下内容：
   - 容器的网络接口。
   - 容器与主机或其他容器之间的端口映射。
   - 容器的 DNS 配置和主机名设置。

### 3. **恢复容器挂载的卷**
   - 如果容器使用了 Docker 卷（`-v` 或 `--mount` 选项），Docker 会恢复卷的挂载，确保容器能够访问存储在卷中的数据。
   - 卷通常用于存储容器的持久化数据，它与容器的生命周期是分开的。

### 4. **重新启动容器内的主进程**
   - 容器启动时，Docker 会检查容器是否已经运行。如果容器之前处于停止状态，Docker 会重新启动容器内的主进程。
   - 主进程是由镜像中定义的 `ENTRYPOINT` 或 `CMD` 指令启动的，通常是容器内应用程序的执行文件。
   - 如果容器已停止，`docker start` 会启动主进程并运行应用程序。

### 5. **容器的标准输出和错误输出**
   - 启动后，容器会开始执行应用程序。容器的标准输出（stdout）和错误输出（stderr）将被发送到 Docker 的日志系统，开发者可以使用 `docker logs <container-name>` 来查看日志。
   
   如果是交互式容器，用户可以附加到容器的终端，通过 `docker attach <container-name>` 来查看容器的实时输出。

### 6. **容器运行时的资源分配与管理**
   - 在容器启动后，Docker 会继续管理容器的资源，包括：
     - **CPU、内存、网络等资源的限制**：如果在创建容器时指定了资源限制（如 `--memory`、`--cpus`），这些资源限制会在容器启动后生效。
     - **容器日志**：Docker 会持续收集容器的日志信息。
   
   Docker 会保持容器在后台运行，直到容器内的主进程退出或用户手动停止容器。

### 7. **容器停止与退出**
   - 一旦容器的主进程（通常是运行的应用程序）退出，容器会停止。如果容器是以交互模式启动的，用户可以手动停止容器（例如通过发送 `exit` 命令或按 `Ctrl+C`）。

### 8. **容器的退出状态**
   - 容器在停止后会保存退出状态码，可以通过 `docker ps -a` 查看容器的退出状态。
   - 容器退出时，Docker 会显示容器退出的状态和退出代码，通常会告诉你容器正常结束、崩溃或发生错误。

### 举个例子：
假设你有一个名为 `my_container` 的容器，并且它已经停止了，现在你执行 `docker start my_container`。

1. Docker 检查容器的状态，确认容器处于停止状态。
2. Docker 恢复容器的网络设置（如果有指定网络）。
3. 恢复挂载的卷和共享目录（如果有）。
4. 启动容器中的主进程（例如 `CMD` 或 `ENTRYPOINT` 中指定的应用程序）。
5. 容器开始运行，你可以通过 `docker logs my_container` 来查看它的输出日志。

如果容器内的应用程序停止了，容器将退出。

### 总结：
`docker start` 命令启动一个已经创建但处于停止状态的容器，整个流程包括恢复容器的网络配置、挂载的卷以及启动容器内的主进程。在启动过程中，容器会按照镜像中的 `ENTRYPOINT` 或 `CMD` 指令运行应用程序，并继续管理容器的资源直到容器退出。

-----


# MySQL容器

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
sudo mkdir /home/l/mysql_83/conf/conf.d
sudo docker run -itd --name mysql_83 -p 13309:3306  --restart=always -v /home/l/mysql_83/data:/var/lib/mysql -v /home/l/mysql_83/log:/var/log/mysql -v /home/l/mysql_83/conf:/etc/mysql/ -e MYSQL_ROOT_PASSWORD=123456 -e TZ=Asia/Shanghai mysql:8.3.0

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


# sql server 容器部署

## 1. 创建容器

docker pull mcr.microsoft.com/mssql/server:2022-latest
docker pull mcr.microsoft.com/mssql/server:2012-latest

```bash
-e "ACCEPT_EULA=Y" 	将 ACCEPT_EULA 变量设置为任意值，以确认接受最终用户许可协议。 SQL Server 映像的必需设置。
-e "MSSQL_SA_PASSWORD=<YourStrong@Passw0rd>" 	指定至少包含 8 个字符且符合密码策略的强密码。 SQL Server 映像的必需设置。
-e "MSSQL_COLLATION=<SQL_Server_collation>" 	指定自定义 SQL Server 排序规则，而不使用默认值 SQL_Latin1_General_CP1_CI_AS。
-p 1433:1433 	将主机环境中的 TCP 端口（第一个值）映射到容器中的 TCP 端口（第二个值）。 在此示例中，SQL Server 侦听容器中的 TCP 1433，此容器端口随后会对主机上的 TCP 端口 1433 公开。
--name sql1 	为容器指定一个自定义名称，而不是使用随机生成的名称。 如果运行多个容器，则无法重复使用相同的名称。
--hostname sql1 	用于显式设置容器主机名。 如果未指定主机名，则主机名默认为容器 ID，这是随机生成的系统 GUID。
-d 	在后台运行容器（守护程序）。
mcr.microsoft.com/mssql/server:2022-latest

```

```bash
sudo docker run -itd --name sqlserver_1 -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=test123456~" -p 11433:1433  mcr.microsoft.com/mssql/server:2019-latest

sudo docker run -itd --name sqlserver_1 -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=test123456~" -p 11433:1433 -v /usr/local/TzxProject/Dats/sqlserver_2019_1:/var/opt/mssql -d mcr.microsoft.com/mssql/server:2019-latest

```










------------------------------------------------------------------------------------------------------------

# oracle 容器

1. 下载镜像

```shell
# 下载镜像
docker pull registry.cn-hangzhou.aliyuncs.com/zhuyijun/oracle:19c

l@t490s:~$ sudo docker images
REPOSITORY                                          TAG                                 IMAGE ID       CREATED         SIZE
registry.cn-hangzhou.aliyuncs.com/zhuyijun/oracle   19c                                 7b5eb4597688   4 years ago     6.61GB

```

2. 创建容器
```
sudo docker run -itd  \
-p 11521:1521  \
-e ORACLE_SID=ORCLCDB \
-e ORACLE_PDB=ORCLPDB1 \
-e ORACLE_PWD=123456 \
-e ORACLE_EDITION=standard \
-e ORACLE_CHARACTERSET=AL32UTF8 \
--name oracle_test \
registry.cn-hangzhou.aliyuncs.com/zhuyijun/oracle:19c


sudo docker run -itd  \
-p 11522:1521  \
-e ORACLE_SID=helowin \
-e ORACLE_PDB=ORCLPDB1 \
-e ORACLE_PWD=123456 \
-e ORACLE_EDITION=standard \
-e ORACLE_CHARACTERSET=AL32UTF8 \
--name oracle_11 \
registry.cn-hangzhou.aliyuncs.com/helowin/oracle_11g:latest
```

sudo docker restart oracle_test

// 19c
[oracle@7df79352801e ~]$ echo $ORACLE_BASE                                                                   
/opt/oracle
[oracle@7df79352801e ~]$ cd /opt/oracle/admin/ORCLCDB/pfile/ 
cp /opt/oracle/admin/ORCLCDB/pfile/init.ora /opt/oracle/product/19c/dbhome_1/dbs/initORCLCDB.ora

navicate 连接

服务名:ORCLCDB
用户名:system
密码:123456

// 11g
[oracle@7e0f40606b15 /]$ cd /home/oracle/app/oracle/admin/helowin/pfile
[oracle@7e0f40606b15 pfile]$ cp init.ora.72320146402  /home/oracle/app/oracle/product/11.2.0/dbhome_2/dbs/initORCLCDB.ora

服务名:helowin
用户名:system
密码:system





[oracle@f602e8cec3bb ~]$ echo $ORACLE_HOME
/opt/oracle/product/19c/dbhome_1
[oracle@f602e8cec3bb ~]$ echo $ORACLE_SID
ORCLCDB
[oracle@7df79352801e ~]$ echo $ORACLE_BASE
/opt/oracle
[oracle@7df79352801e ~]$ 
[oracle@7df79352801e ~]$ cd /opt/oracle/        
[oracle@7df79352801e oracle]$ ls
admin        checkDBStatus.sh  dbca.rsp       fast_recovery_area  product                runUserScripts.sh  startDB.sh
audit        checkpoints       dbca.rsp.tmpl  oraInventory        relinkOracleBinary.sh  scripts
cfgtoollogs  createDB.sh       diag           oradata             runOracle.sh           setPassword.sh


CREATE USER C##TZX_TEST IDENTIFIED BY 123456;
GRANT UNLIMITED TABLESPACE TO C##TZX_TEST;

CREATE USER TZX_TEST IDENTIFIED BY 123456;
GRANT UNLIMITED TABLESPACE TO TZX_TEST;
oracle_11g

使用 SYS 或 SYSTEM 用户登录
sqlplus / as sysdba
连接到数据库：
SQL> connect / as sysdba
授予 CREATE SESSION 权限：
SQL> grant create session to TZX_TEST;



db_name='TZX_TEST'
memory_target=500M
processes=150
audit_file_dest='$ORACLE_BASE/admin/TZX_TEST/adump'
audit_trail='db'
compatible='19.3.0' 
control_files=('$ORACLE_BASE/oradata/TZX_TEST/control01.ctl','$ORACLE_BASE/fast_recovery_area/TZX_TEST/control02.ctl')
db_block_size=8192
db_domain=''
db_recovery_file_dest='$ORACLE_BASE/fast_recovery_area'
db_recovery_file_dest_size=4G
diagnostic_dest='$ORACLE_BASE'
open_cursors=300
undo_tablespace='UNDOTBS1'


startup nomount pfile='$ORACLE_HOME/dbs/initTZX_TEST.ora';


mkdir -p $ORACLE_BASE/admin/TZX_TEST/adump

SQL> startup;
ORA-01081: cannot start already-running ORACLE - shut it down first
SQL> SHUTDOWN IMMEDIATE;
Database closed.
Database dismounted.
ORACLE instance shut down. " - rest of line ignored.
SQL> startup;
ORACLE instance started.

Total System Global Area 1603411968 bytes
Fixed Size		    2213776 bytes
Variable Size		  452986992 bytes
Database Buffers	 1140850688 bytes
Redo Buffers		    7360512 bytes
Database mounted.
Database opened.







```
test =
(DESCRIPTION =
    (ADDRESS_LIST =
        (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.0.237)(PORT = 11521))
    )
    (CONNECT_DATA =
        (SERVICE_NAME = ORCLCDB)
    )
)

```


如何创建一个名为TZX_TEST 的数据库

sqlplus / as sysdba

CREATE DATABASE TZX_TEST \
   USER SYS IDENTIFIED BY 123456 \
   USER SYSTEM IDENTIFIED BY 123456 \
   LOGFILE GROUP 1 ('/opt/oracle/oradata/TZX_TEST/redo01.log') SIZE 50M, \
           GROUP 2 ('/opt/oracle/oradata/TZX_TEST/redo02.log') SIZE 50M, \
           GROUP 3 ('/opt/oracle/oradata/TZX_TEST/redo03.log') SIZE 50M \
   DATAFILE '/opt/oracle/oradata/TZX_TEST/system01.dbf' SIZE 500M \
   EXTENT MANAGEMENT LOCAL \
   UNDO TABLESPACE undotbs1 \
   DEFAULT TEMPORARY TABLESPACE temp \
   CHARACTER SET AL32UTF8 \
   NATIONAL CHARACTER SET AL16UTF16;



1. 进入容器
2. 启动容器
3. 配置环境变量
4. 配置监听
5. 配置网络




```
```

# 达梦数据库(dm8) 


可以直接从达梦数据库官网下载 dm8的容器包

下载地址:https://eco.dameng.com/download/


## 创建指令

参数名 	参数描述
-d 	-detach 的简写，在后台运行容器，并且打印容器 id。
-p 	指定容器端口映射，比如 -p 30236:5236 是将容器里数据库的 5236 端口映射到宿主机 30236 端口，外部就可以通过宿主机 ip 和 30236 端口访问容器里的数据库服务。
--restart 	指定容器的重启策略，默认为 always，表示在容器退出时总是重启容器。
--name 	指定容器的名称。
--privileged 	指定容器是否在特权模式下运行。
-v 	指定在容器创建的时候将宿主机目录挂载到容器内目录，默认为/home/mnt/disks

使用 -e 命令指定数据库初始化参数时，需要注意的是目前只支持预设以下九个 DM 参数。
参数名 	参数描述 	备注
PAGE_SIZE 	页大小，可选值 4/8/16/32，默认值：8 	设置后不可修改
EXTENT_SIZE 	簇大小，可选值 16/32/64，默认值：16 	设置后不可修改
CASE_SENSITIVE 	1:大小写敏感；0：大小写不敏感，默认值：1 	设置后不可修改
UNICODE_FLAG 	字符集选项；0:GB18030;1:UTF-8;2:EUC-KR，默认值：0 	设置后不可修改
INSTANCE_NAME 	初始化数据库实例名字，默认值：DAMENG 	可修改
SYSDBA_PWD 	初始化实例时设置 SYSDBA 的密码，默认值：SYSDBA001 	可修改
BLANK_PAD_MODE 	空格填充模式，默认值：0 	设置后不可修改
LOG_SIZE 	日志文件大小，单位为：M，默认值：256 	可修改
BUFFER 	系统缓存大小，单位为：M，默认值：1000 	可修改


服务器端部署

```bash
sudo docker run -itd -p 13308:5236 --restart=always  --name=dm8_test --privileged=true -e SYSDBA_PWD=123456789  -e LD_LIBRARY_PATH=/opt/dmdbms/bin  -e PAGE_SIZE=16 -e EXTENT_SIZE=32 -e LOG_SIZE=1024 -e UNICODE_FLAG=1  -v /usr/local/TzxProject/Dats/dm8:/opt/dmdbms/data dm8_single:dm8_20240715_rev232765_x86_rh6_64
```
暂时我对这个数据库的初始化设置 是设置了 

测试

```bash
sudo docker run -itd -p 13308:5236  --name=dm8_test --privileged=true -e LD_LIBRARY_PATH=/opt/dmdbms/bin  -e PAGE_SIZE=16 -e EXTENT_SIZE=32 -e LOG_SIZE=1024 -e UNICODE_FLAG=1 -v /usr/local/TzxProject/Dats/dm8:/opt/dmdbms/data dm8_single:dm8_20240715_rev232765_x86_rh6_64
```

```bash
sudo docker run -itd -p 13309:5236  --name=dm8_test_2 --privileged=true -e SYSDBA_PWD=123456789 -e LD_LIBRARY_PATH=/opt/dmdbms/bin  -e PAGE_SIZE=16 -e EXTENT_SIZE=32 -e LOG_SIZE=1024 -e UNICODE_FLAG=1 -e LENGTH_IN_CHAR=1  -v /usr/local/TzxProject/Dats/dm8_2:/opt/dmdbms/data dm8:dm8_20240613_rev229704_x86_rh6_64

```


156 部署

```bash
sudo docker run -itd -p 15236:5236  --name=dm8_svr --privileged=true -e SYSDBA_PWD=3edc9ijn~ -e LD_LIBRARY_PATH=/opt/dmdbms/bin  -e PAGE_SIZE=16 -e EXTENT_SIZE=32 -e LOG_SIZE=1024 -e UNICODE_FLAG=1 -v /usr/local/TzxProject/Dats/dm8_svr_data:/opt/dmdbms/data dm8_single:dm8_20240715_rev232765_x86_rh6_64


./disql SYSDBA/3edc9ijn~

telnet 192.168.0.156 15236
telnet 192.168.0.156 22

```



检验测试

默认用户名密码为 SYSDBA/SYSDBA001

```bash
./disql SYSDBA/SYSDBA001


查询表空间
SELECT tablespace_name, status, extent_management FROM dba_tablespaces;


root@b828c5dbb125:/# disql SYSDBA/SYSDBA001

Server[LOCALHOST:5236]:mode is normal, state is open
login used time : 2.967(ms)
disql V8
SQL> SELECT tablespace_name, status, extent_management FROM dba_tablespaces;

LINEID     TABLESPACE_NAME STATUS      EXTENT_MANAGEMENT
---------- --------------- ----------- -----------------
1          SYSTEM          0           NULL
2          ROLL            0           NULL
3          TEMP            0           NULL
4          MAIN            0           NULL
5          MAIN            NULL        NULL

used time: 8.249(ms). Execute id is 65101.


```


添加环境变量

```bash
输入命令 vim /etc/profile 
在文件末尾添加以下行：
   export PATH=$PATH:/opt/dmdbms/bin
```


### 达梦数据库 添加用户和密码

1. 创建表空间

```
create tablespace TEST datafile '/opt/dmdbms/data/DAMENG/TEST.DBF' size 128 ;
create tablespace TZX datafile '/opt/dmdbms/data/DAMENG/TZX.DBF'  size 128 ;
```

2.创建用户：使用以下 SQL 命令来创建新用户：

   CREATE USER your_username IDENTIFIED BY your_password;
   CREATE USER <用户名> IDENTIFIED BY <口令> DEFAULT TABLESPACE <表空间名>
   CREATE USER GIN IDENTIFIED BY 123456789 DEFAULT TABLESPACE MAIN;
   CREATE USER tzx IDENTIFIED BY 123456789 DEFAULT TABLESPACE TZX;
   
    CREATE USER "user" IDENTIFIED BY "pwd" DEFAULT TABLESPACE "ts_data" DEFAULT INDEX TABLESPACE "ts_idx";
    GRANT create table,select table,update table,insert table TO "user";
    GRANT resource，public TO "user";
    GRANT dba TO "user";



替换 your_username 和 your_password 为你想要的用户名和密码。

3.赋予权限：创建用户后，通常需要赋予一些权限。例如，可以赋予基本的连接和操作权限：

   GRANT CONNECT, RESOURCE TO tzx;


4.确认用户创建：可以通过以下查询来确认用户是否创建成功：

   SELECT * FROM user_users WHERE username = 'YOUR_USERNAME';

替换 YOUR_USERNAME 为你刚才创建的用户名。
这样，你就可以成功添加达梦数据库的用户和密码了。如果需要更多权限，可以根据需求继续使用 GRANT 语句。


修改用户密码
disql SYSDBA/SYSDBA001
alter user SYSDBA identified by 123456789;
disql SYSDBA/123456789

\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\

IA_A_NOWFHTB 库

ALTER TABLE "TZX_FloodDisaster_XJ_FWQ"."IA_A_NOWFHTB" MODIFY "STATUS" VARCHAR(20) NULL;


ST_STBPRP_B 库

ALTER TABLE "TZX_FloodDisaster_XJ_FWQ"."ST_STBPRP_B" MODIFY "LOCALITY" VARCHAR(40) NULL;
ALTER TABLE "TZX_FloodDisaster_XJ_FWQ"."ST_STBPRP_B" MODIFY "ADMAUTH" VARCHAR(30) NULL;
ALTER TABLE "TZX_FloodDisaster_XJ_FWQ"."ST_STBPRP_B" MODIFY "STLC" VARCHAR(70) NULL;
ALTER TABLE "TZX_FloodDisaster_XJ_FWQ"."ST_STBPRP_B" MODIFY "RVNM" VARCHAR(60) NULL;



SELECT AID, ADCD, ADNM, LGTD, LTTD, PTCOUNT, LDAREA, "LEFT", "TOP", "RIGHT", BOTTOM, VERTEX
FROM "TZX_FloodDisaster_XJ_FWQ"."AD_CD_B";

SELECT count(*) FROM "TZX_FloodDisaster_XJ_FWQ"."ST_STBPRP_B" ;

DELETE FROM "TZX_FloodDisaster_XJ_FWQ"."AD_Plan_Data_Poly";
DROP FROM "TZX_FloodDisaster_XJ_FWQ"."AD_Plan_Data_Poly";
DROP TABLE "TZX_FloodDisaster_XJ_FWQ"."Dzwl_MessageSend_R";


## 导出,导入数据库

#### 全部库导出,导出

- 导出
dexp SYSDBA/SYSDBA001\@0.0.0.0:5236 GRANTS=Y FILE=TZX_FloodDisaster_XJ_FWQ_backup.dmp DIRECTORY=/opt/dmdbms/data/ FULL=Y
dexp SYSDBA/SYSDBA001\@0.0.0.0:5236 GRANTS=Y FILE=XJ_XJ_FWQ_backup.dmp DIRECTORY=/opt/dmdbms/data/ FULL=Y

- 导入
dimp SYSDBA/123456789@0.0.0.0:5236 GRANTS=Y FILE=TZX_FloodDisaster_XJ_FWQ_backup.dmp DIRECTORY=/opt/dmdbms/data/ FULL=Y
dimp SYSDBA/123456789@0.0.0.0:5236 GRANTS=Y FILE=XJ_XJ_FWQ_backup.dmp DIRECTORY=/opt/dmdbms/data/ FULL=Y




#### 表级导出

- 导出

dexp  SYSDBA/SYSDBA001\@0.0.0.0:5236 GRANTS=Y  DIRECTORY=/opt/dmdbms/data/  FILE=AD_Plan_Data_Line.dmp tables=TZX_FloodDisaster_XJ_FWQ.AD_Plan_Data_Line


dexp SYSDBA/SYSDBA001@0.0.0.0:5236  GRANTS=Y DIRECTORY=/opt/dmdbms/data/ FILE=AD_Plan_Data_Line.dmp tables="AD_Plan_Data_Line"


- 导入



## 导入数据 指令


[root@ncc-61-19 bin]# ./dexp help
dexp V7.6.1.52-Build(2020.03.17-119193)ENT
格式: ./dexp  KEYWORD=value 或 KEYWORD=(value1,value2,...,valueN)
 
例程: ./dexp  SYSDBA/SYSDBA GRANTS=Y TABLES=(SYSDBA.TAB1,SYSDBA.TAB2,SYSDBA.TAB3)
 
USERID 必须是命令行中的第一个参数
 
关键字              说明（默认值）
--------------------------------------------------------------------------------
USERID              用户名/口令 格式:USER/PWD*MPP_TYPE@SERVER:PORT#SSLPATH@SSLPWD
FILE                导出文件 (dexp.dmp)
DIRECTORY           导出文件所在目录
FULL                整库导出 (N)
OWNER               以用户方式导出 格式 (user1,user2,...)
SCHEMAS             以模式方式导出 格式 (schema1,schema2,...)
TABLES              以表方式导出 格式 (table1,table2,...)
FUZZY_MATCH         TABLES选项是否支持模糊匹配 (N)
QUERY               用于导出表的子集的select 子句
PARALLEL            用于指定导出的过程中所使用的线程数目
TABLE_PARALLEL      用于指定导出的过程中表内的并发线程数目,MPP模式下会转换成单线程
TABLE_POOL          用于指定表的缓冲区个数
EXCLUDE             忽略指定的对象
                       格式 EXCLUDE=(CONSTRAINTS,INDEXES,ROWS,TRIGGERS,GRANTS) or
                            EXCLUDE=TABLES:table1,table2 or
                            EXCLUDE=SCHEMAS:sch1,sch2
INCLUDE             包含指定的对象
                       格式 INCLUDE=(CONSTRAINTS,INDEXES,ROWS,TRIGGERS,GRANTS) or
                            INCLUDE=TABLES:table1,table2
CONSTRAINTS         导出约束 (Y)
TABLESPACE          导出对象带有表空间 (N)
GRANTS              导出权限 (Y)
INDEXES             导出索引 (Y)
TRIGGERS            导出触发器 (Y)
ROWS                导出数据行 (Y)
LOG                 屏幕输出的日志文件
NOLOGFILE           不使用日志文件(N)
NOLOG               屏幕上不显示日志信息(N)
LOG_WRITE           日志信息实时写入文件: 是(Y),否(N)
DUMMY               交互信息处理: 打印(P), 所有交互都按YES处理(Y),NO(N)
PARFILE             参数文件名
FEEDBACK            每 x 行显示进度 (0)
COMPRESS            导出数据是否压缩 (N)
ENCRYPT             导出数据是否加密 (N)
ENCRYPT_PASSWORD    导出数据的加密密钥
ENCRYPT_NAME        加密算法的名称
FILESIZE            每个转储文件的最大大小
FILENUM             一个模板可以生成的文件数
DROP                导出后删除原表，但不级联删除 (N)
DESCRIBE            导出数据文件的描述信息，记录在数据文件中
LOCAL               MPP模式下登录使用MPP_LOCAL方式(N)
HELP                打印帮助信息


[root@ncc-61-19 bin]# ./dimp help
dimp V7.6.1.52-Build(2020.03.17-119193)ENT
格式: ./dimp KEYWORD=value 或 KEYWORD=(value1,value2,...,vlaueN)
 
例程: ./dimp SYSDBA/SYSDBA IGNORE=Y ROWS=Y FULL=Y
 
USERID 必须是命令行中的第一个参数
 
关键字                 说明（默认值）
--------------------------------------------------------------------------------
USERID                 用户名/口令 格式:USER/PWD*MPP_TYPE@SERVER:PORT#SSLPATH@SSLPWD
FILE                   导入文件名称 (dexp.dmp)
DIRECTORY              导入文件所在目录
FULL                   整库导入 (N)
OWNER                  以用户方式导入 格式 (user1,user2,...)
SCHEMAS                以模式方式导入 格式 (schema1,schema2,...)
TABLES                 以表名方式导入 格式(table1,table2,...)
PARALLEL               用于指定导入的过程中所使用的线程数目
TABLE_PARALLEL         用于指定导入的过程中每个表所使用的子线程数目,在FAST_LOAD为Y时有效
IGNORE                 忽略创建错误 (N)
TABLE_EXISTS_ACTION    需要的导入表在目标库中存在时采取的操作[SKIP | APPEND | TRUNCATE | REPLACE]
FAST_LOAD              是否使用dmfldr来导数据(N)
FLDR_ORDER             使用dmfldr是否需要严格按顺序来导数据(Y)
COMMIT_ROWS            批量提交的行数(5000)
EXCLUDE                忽略指定的对象 格式
                           格式 EXCLUDE=(CONSTRAINTS,INDEXES,ROWS,TRIGGERS,GRANTS)
GRANTS                 导入权限 (Y)
CONSTRAINTS            导入约束 (Y)
INDEXES                导入索引 (Y)
TRIGGERS               导入触发器 (Y)
ROWS                   导入数据行 (Y)
LOG                    指定日志文件
NOLOGFILE              不使用日志文件(N)
NOLOG                  屏幕上不显示日志信息(N)
LOG_WRITE              日志信息实时写入文件(N): 是(Y),否(N)
DUMMY                  交互信息处理(P): 打印(P), 所有交互都按YES处理(Y),NO(N)
PARFILE                参数文件名
FEEDBACK               每 x 行显示进度 (0)
COMPILE                编译过程, 程序包和函数... (Y)
INDEXFILE              将表的索引/约束信息写入指定的文件
INDEXFIRST             导入时先建索引(N)
REMAP_SCHEMA           格式(SOURCE_SCHEMA:TARGET_SCHEMA)
                       将SOURCE_SCHEMA中的数据导入到TARGET_SCHEMA中
ENCRYPT_PASSWORD       数据的加密密钥
ENCRYPT_NAME           加密算法的名称
SHOW/DESCRIBE          打印出指定文件的信息(N)
LOCAL                  MPP模式下登录使用MPP_LOCAL方式(N)
TASK_THREAD_NUMBER     用于设置dmfldr处理用户数据的线程数目
BUFFER_NODE_SIZE       用于设置dmfldr读入文件缓冲区大小
TASK_SEND_NODE_NUMBER  用于设置dmfldr发送节点个数[16,65535]
LOB_NOT_FAST_LOAD      如果一个表含有大字段，那么不使用dmfldr，因为dmfldr是一行一行提交的
PRIMARY_CONFLICT       主键冲突的处理方式[IGNORE|OVERWRITE],默认报错
TABLE_FIRST            是否先导入表(N):是(Y),否(N)
HELP                   打印帮助信息








- 要查看 DM8 数据库中的所有表，可以使用以下 SQL 查询：
SELECT TABLE_NAME FROM USER_TABLES;



- 查询检查表的所有者（即当前用户）：
SELECT USER FROM DUAL;



- 检查权限
如果您认为表可能不属于您，您可以运行以下查询查看您当前用户的所有权限：

SELECT * FROM USER_TAB_PRIVS;

SELECT * FROM USER_TABLES;


修改参数

vim /opt/dmdbms/data/DAMENG/dm.ini



CREATE DATABASE TEST;


-- 使用 dba_tables 视图（需要具有 DBA 权限）
SELECT 
    OWNER AS schema_name,
    TABLE_NAME AS table_name
FROM 
    dba_tables
WHERE 
    TABLE_NAME = 'ST_PPTN_R';

-- 使用 all_tables 视图（当前用户有访问权限）
SELECT 
    OWNER AS schema_name,
    TABLE_NAME AS table_name
FROM 
    all_tables
WHERE 
    TABLE_NAME = 'ST_PPTN_R';



# ftp

```bash
# 必须要绑定端口
sudo docker run -itd -p 18020-18022:8020-8022 -v /usr/local/TzxProject/Ftp/ftp_svr_1:/home/test_1_ftp --name ftp_svr_1 centos7_ftp:v1  /bin/bash
```

## 添加新用户

```bash

1. 添加因用户
sudo adduser test_1

2. 修改密码
sudo passwd test_1


3. 添加用户到vsftp用户裂变里
vim /etc/vsftpd/user_list
将test_1添加到user_list中

4. 如果想设置某个用户的权限创建/etc/vsftpd/userconfig目录
然后再这个目录下创建一用户名为文件名的文件
vim /etc/vsftpd/userconfig/test_1
添加以下内容

[root@bc89e199b2f1 vsftpd]# sl
bash: sl: command not found
[root@bc89e199b2f1 vsftpd]# ls
ftpusers  user_list  userconfig  vsftpd.conf  vsftpd_conf_migrate.sh
[root@bc89e199b2f1 vsftpd]# cd userconfig/
[root@bc89e199b2f1 userconfig]# ls
huaxun  tzx
[root@bc89e199b2f1 userconfig]# cat huaxun
local_root=/home/huaxun/


```


vsftpd.conf文件如下

```bash
 with the listen_ipv6 directive.
listen=YES
#
# This directive enables listening on IPv6 sockets. By default, listening
# on the IPv6 "any" address (::) will accept connections from both IPv6
# and IPv4 clients. It is not necessary to listen on *both* IPv4 and IPv6
# sockets. If you want that (perhaps because you want to listen on specific
# addresses) then you must run two copies of vsftpd with two configuration
# files.
# Make sure, that one of the listen options is commented !!
listen_ipv6=NO

pam_service_name=vsftpd
userlist_enable=YES
tcp_wrappers=YES

# self add

userlist_file=/etc/vsftpd/user_list
userlist_deny=NO
tcp_wrappers=YES
listen_port=8021
port_enable=NO
pasv_enable=YES
pasv_min_port=8022
pasv_max_port=8024
local_root=/home
user_config_dir=/etc/vsftpd/userconfig

pasv_address=192.168.2.175

reverse_lookup_enable=NO

```

user_list是允许访问的用户,将t
```bash
[root@bc89e199b2f1 vsftpd]# cat user_list
# vsftpd userlist
# If userlist_deny=NO, only allow users in this file
# If userlist_deny=YES (default), never allow users in this file, and
# do not even prompt for a password.
# Note that the default vsftpd pam config also checks /etc/vsftpd/ftpusers
# for users that are denied.
#root
bin
daemon
adm
lp
sync
shutdown
halt
mail
news
uucp
operator
games
nobody
tzx
huaxun



[root@bc89e199b2f1 vsftpd]# cat ftpusers
# Users that are not allowed to login via ftp
bin
daemon
adm
lp
sync
shutdown
halt
mail
news
uucp
operator
games
nobody
[root@bc89e199b2f1 vsftpd]#


```








