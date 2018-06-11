---
layout: post
title:  "netty listener机制"
date:   2018-06-11
excerpt: "netty listener相关学习整理"
feature: https://i.imgur.com/Ds6S7lJ.png
tag:
- netty
comments: true
---

channelFuture：异步future，可添加listener，监听状态的变化。
channelPromise：继承了channelFuture，新增了setSuccess，trySuccess，setFailure方法，用来后期定义某一个异步流程的最终结果。
listener：为一个异步流程配置监听。

