---
layout: post
title:  "shadowsocks docker镜像"
date:   2017-05-27
excerpt: "制作了一个shadowsocks docker镜像，欢迎大家pull"
tag:
- shadowsocks
- docker
- 镜像
comments: true
---
## docker hub地址

``` shell
docker pull justicelove/shadowsocks:1.0
```

## dockerfile
``` shell
FROM centos:7
MAINTAINER justice-love (eddyxu1213@126.com)
RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN echo 'Asia/Shanghai' > /etc/timezone
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8
ENV LC_ALL en_US.UTF-8
EXPOSE 1988
EXPOSE 2001
WORKDIR /usr/local/shadowsocks/
RUN curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
RUN python get-pip.py
RUN pip install --upgrade pip
RUN pip install shadowsocks
RUN curl  https://cdn.justice-love.com/etc/conf/shadowsocks.json -o shadowsocks.json
CMD ssserver -c ./shadowsocks.json
```

## 运行
``` shell
docker run --name mine_shadowsocks -it -d -p 1988:1988 justicelove/shadowsocks:1.0
```

## 启动/停止
``` shell
docker start/stop/restart mine_shadowsocks
```

