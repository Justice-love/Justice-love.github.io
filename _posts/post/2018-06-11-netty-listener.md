---
layout: post
title:  "netty 异步listener机制"
date:   2018-06-11
excerpt: "netty异步回调机制相关学习整理"
feature: https://static.justice-love.com/image/jpg/bjfj1.jpg
tag:
- netty
comments: true
---

**netty中异步触发机制相关类介绍**
* channelFuture：异步future，可添加listener，监听状态的变化。
* channelPromise：继承了channelFuture，新增了setSuccess，trySuccess，setFailure方法，用来后期定义某一个异步流程的最终结果。
* listener：为一个异步流程配置监听。

**在netty中，每个异步流程都会添加一个Promise，用来管理当前异步流程的状态，以向channel中写数据为例：**

1. 如果写数据没有主动传入promise，netty会默认生成一个。
    ``` java
    io.netty.channel.AbstractChannelHandlerContext#newPromise
    ```
2. 所有对写请求添加的listener都由该promise来管理。
3. 在channel将数据都写完之后，会调用promise的setSuccess方法，如果发生错误，则会调用setFailure方法。
    * 个人认为不应该主动调用promise的setSuccess或者setFailure方法，netty会在各个环节完结之后主动调用。
4. 当setSuccess发生了调用之后，则会将异步调用的结果写到future的data，默认情况下会set一个默认值。
5. set data之后，则会notify该promise的所有listeners。

    ``` java
    io.netty.util.concurrent.DefaultPromise#notifyListeners
    ```
6. 如果发生错误，同样会notify listeners，需客户端自行进行判断成功与否。