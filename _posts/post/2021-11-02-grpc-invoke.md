---
layout: post
title:  "Grpc接口跨集群调用"
date:   2021-11-02
excerpt: "基于腾讯云，两个不同的k8s集群间接口调用配置"
feature: https://cdn.justice-love.com/image/jpg/bjfj1.jpg
tag:
- grpc
- kubernetes
comments: true
---

# 背景

Kubernetes集群内部间接口调用是直接且便捷的，但跨集群的Gprc接口调用就需要做一定的配置才能实现

# 暴露IP

服务端通过Service来暴露一个IP，该IP要求客户端所在的集群可见，对应的简化版的配置如下：
```yaml
apiVersion: v1
kind: Service
metadata:
  name: kubia-loadbalancer
spec:
  type: LoadBalancer
  ports:
    - port: 80
      targetPort: 8080
  selector:
    app: kubia
```

## 关于网络
服务端暴露的ip有两种方案来实现网络的联通
1. 提供公网ip并配置好白名单
2. 通过vpn打通两端的网络，使其内网联通

# 客户端使用
客户端目前可直接在grpc客户端初始化时使用Ip，但为了更好的代码风格，可以在k8s中配置对外链接的service，其简化配置如下：
```yaml
apiVersion: v1
kind: Service
metadata:
  name: external-service
spec:
  ports:
  - port: 80
  
---
apiVersion: v1
kind: Endpoints
metadata:
  name: external-service
subsets:
  - addresses:
      - ip: 11.11.11.11
      - ip: 22.22.22.22
    ports:
      - port: 80 
```
这样，就能带代码中通过external-service链接到远程的`11.11.11.11,22.22.22.22`了

客户端初始化：
1. https://github.com/sercand/kuberesolver 添加该k8s name resolver
2. 通过后面方式初始化客户端：`grpc.Dial("kubernetes:///service.namespace:portname", opts...)`