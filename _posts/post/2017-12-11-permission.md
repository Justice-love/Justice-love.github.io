---
layout: post
title:  "spring context沙箱环境"
date:   2017-12-11
excerpt: "利用java安全机制实现沙箱隔离环境"
tag:
- sandbox
comments: true
---
## 背景
Java应用调用某些脚本语言，默认情况拥有和java代码相同的上下文，使得可以在脚本中直接调用java代码，甚至包括核心的数据变更的接口。所以，希望为脚本语言构建一个沙箱环境，使其与java核心代码隔离，无法调用。

## 实现
利用java安全机制实现，使用```pro-grade```扩展实现```deny```节点。