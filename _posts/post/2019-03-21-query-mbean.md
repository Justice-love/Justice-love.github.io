---
layout: post
title:  "查询Mbean"
date:   2019-03-21
excerpt: "依据设置的条件查询Mbean"
feature: https://i.imgur.com/Ds6S7lJ.png
tag:
- Mbean
comments: true
---

## Mbean
Mbean，management bean的简写，可以暴露出接口，用以对应用运行时进行管理，比如对JVM实例的监控。DynamicMBean，动态Mbean，对应用的动态信息进行管理，比如Tomcat请求的管理，实际的管理需依赖端口。下面主要是根据Tomcat来举例如何对动态Mbean进行查询。

## 准备工作

