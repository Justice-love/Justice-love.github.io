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

Java默认的classloader的行为是双亲委培，即会优先让parent classloader来进行加载，这么做的好处，是为了保证加载的类的唯一性，但这也同时引入了上面的问题，可能在某种情况下造成类冲突的问题。

## Tomcat Classloader

Tomcat的Classloader是在系统基础上自定义的，默认情况下打破了类加载的双亲委派机制。

* Tomcat Classloader简易模型为：ExtClassloader（Java默认的classlaoder）--》UrlClassloader（common lib包加载器）——》WebAppClassloader（app加载器）

默认情况下，WebAppClassloader会先尝试使用ExtClassloader来加载JDK提供的基础类，并且，对于Servlet API也会进行过滤，所以App中添加Servlet的jar会不起效果。
