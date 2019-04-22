---
layout: post
title:  "Tomcat Classloader"
date:   2019-04-22
excerpt: "学习Tomcat的类加载模式"
feature: https://static.justice-love.com/image/jpg/bjfj1.jpg
tag:
- Tomcat Classloader
comments: true
---

## 简述

Tomcat作为单独服务部署的web服务器，能够同时部署多个App在其中。这些App运行于同一个jvm进程中，首先要解决的是App之间的隔离，比如不同的App之间加载类的隔离，从而防止因App引入不同版本的jar导致的类冲突的发生。

## Classloader

Java默认的classloader的行为是双亲委培，即会
