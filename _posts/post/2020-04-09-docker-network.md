---
layout: post
title:  "docker网络理解"
date:   2020-04-09
excerpt: "对docker容器网络理解的一些东西的整理"
feature: https://static.justice-love.com/image/jpg/bjfj1.jpg
tag:
- docker network
comments: true
---

## docker网络

docker网络驱动分成五种不同的类型，分别是`bridge, host, overlay, macvlan, none`，用于定义docker容器不同的网络配置。
* bridge：默认网络驱动，容器拥有独立的网络环境并允许容器间进行通信
* host：使用docker宿主机的网络环境，docker容器和宿主机之间不再拥有隔离的网络环境
* overlay：分布式网络，允许多台docker宿主机间的容器通过该类型的网络进行加密传输，默认在创建swarm环境是会创建该类型的网络，名称是`ingress`
* macvlan：允许分配一个MAC地址给到容器，使得该容器看起来像是一台物理机，但是这种方式非常容易损坏现有的宿主机的网络环境，同时需要网络硬件的支持
* none：无指定网络配置，使用自定义的网络驱动

## 创建网络

> 使用说明：docker network create [OPTIONS] NETWORK

一般自定义网络使用的是`bridge`驱动，所以我们不会再去特意指定网络驱动。而自定义网络具有自己的优势：
1. 可以指定不同类型的网络驱动
2. 更灵活的配置，比如开启ipv6
3. 自定义网段，容器自定义IP可控
4. 拥有内部dns，同网络环境下无需link即可通过域名访问
5. 关联普通容器和swarm容器

## 链接网络

### 普通容器
普通容器有两种方式使用自建网络：
1. 通过命令行：如果容器已经创建并启动，可以通过命令行来将运行时容器关联到特定网络`docker network connect [OPTIONS] NETWORK CONTAINER`
2. 创建容器时指定：docker run 时通过`--network`参数来指定加入的网络
 
### docker-compse
在docker-compse.yml文件中，通过networks配置项来设置网络相关属性，默认情况下会创建网络，添加`external: true`配置，使用外部网络
```
version: '3.7'
networks:
  app-network:
    external: true
```
