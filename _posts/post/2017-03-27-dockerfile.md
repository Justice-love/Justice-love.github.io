---
layout: post
title:  "Docker镜像制作"
date:   2017-03-27
excerpt: "docker相关：制作自己的Docker镜像"
tag:
- docker
- 运维
comments: true
---

## 使用 Dockerfile 来创建镜像
我们可以使用 docker build 来创建一个新的镜像。为此，首先需要创建一个 Dockerfile，包含一些如何创建镜像的指令。<br/>
**Dockerfile 基本的语法**
* 使用#来注释
* FROM 指令告诉 Docker 使用哪个镜像作为基础
* 接着是维护者的信息
* RUN开头的指令会在创建中运行，比如安装一个软件包，在这里使用 apt-get 来安装了一些软件

### 构建镜像的步骤
**新建一个目录和一个 Dockerfile**

```shell

$ mkdir new_folder
$ cd new_folder
$ touch Dockerfile

```

**编写Dockerfile，Dockerfile中每一条指令都创建镜像的一层，例如：**

```docker
# 这里是注释
# 设置继承自哪个镜像
FROM ubuntu:14.04
# 下面是一些创建者的基本信息
MAINTAINER justice-love (eddyxu1213@126.com)
# 在终端需要执行的命令
RUN apt-get install -y openssh-server
RUN mkdir -p /var/run/sshd
```
**编写完成 Dockerfile 后可以使用 docker build 来生成镜像。**

```docker

$ sudo docker build -t="justice-love/ubuntu:v1" .
# 下面是一堆构建日志信息

############
我是日志
############

# 参数：
# -t 标记来添加 tag，指定新的镜像的用户和镜像名称信息。 
# “.” 是 Dockerfile 所在的路径（当前目录），也可以替换为一个具体的 Dockerfile 的路径。

# 以交互方式运行docker
$ docker run -it justice-love/ubuntu:v1 /bin/bash

# 运行docker时指定配置
$ sudo docker run -d -p 10.211.55.4:9999:22 ubuntu:tools '/usr/sbin/sshd' -D

# 参数：
# -i：表示以“交互模式”运行容器，-i 则让容器的标准输入保持打开
# -t：表示容器启动后会进入其命令行，-t 选项让Docker分配一个伪终端（pseudo-tty）并绑定到容器的标准输入上
# -v：表示需要将本地哪个目录挂载到容器中，格式：-v <宿主机目录>:<容器目录>，-v 标记来创建一个数据卷并挂载到容器里。在一次 run 中多次使用可以挂载多个数据卷。
# -p：指定对外80端口
# 不一定要使用“镜像 ID”，也可以使用“仓库名:标签名”

```