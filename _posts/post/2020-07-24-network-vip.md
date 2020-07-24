---
layout: post
title:  "虚拟IP"
date:   2020-07-24
excerpt: "网络VIP记录简述"
feature: https://static.justice-love.com/image/jpg/bjfj1.jpg
tag:
- network
- vip
comments: true
---

## VIP

vip是网络上的一个概念， 指的是虚拟IP，百度百科上的解释是虚拟IP无需绑定特定的网络硬件如网卡。
vip后端需要绑定一个或多个Ip，在负载均衡场景中，vip服务能够将请求转发到后端绑定的任意一个ip上

在实际配置过程中，不管vip是公网ip还是内网ip，只要是一个ip想要被使用，就需要绑定到一个网络硬件上的（这一点可能和文档定义有点出入），比如说交换机，然后通过交换机的OSPF技术做的hash转发到后端的IP（服务）上。


