---
layout: post
title:  "NioEventLoop线程模型初探"
date:   2018-06-14
excerpt: "NioEventLoop线程模型相关学习整理"
feature: https://i.imgur.com/Ds6S7lJ.png
tag:
- netty
comments: true
---

## 概述

netty的NioEventLoop继承了Java的ExecutorService，提供了多线程的能力，但是具体的实现，则是将NioEventLoop限制为单线程，用以维护一个selector实例以及向其中注册的channel。

## 线程启动

向EventLoop中提交待执行的task时会进行判断线程是否启动，如果未启动，则调用startThread方法启动线程。

## 单线程保证

EventLoop拥有一个task队列，用以暂存提交上来的task。

## 定时任务

EventLoop允许提交定时任务，定时任务会被提交到一个单独的队列，每次执行任务时，将会判断是否有定时任务需要被执行，如果有，则会将定时任务加入到task队列中待执行。

## 任务的执行

NioEventLoop实现了一个run()方法，这个方法的实现是一个无限循环的，该方法的大致逻辑：
1. 执行一次selector的select方法，用以选择已就绪健。
2. 如果存在已选择键集，则处理selectionKey
3. 执行所有task

## 读和写

netty的所有读都是在EventLoop线程中完成的，而在netty3中，写请求是允许由其他线程来进行，以通过多线程读写分离来提升效率。而在netty4中，改有读写需由EventLoop线程来处理，这样是为了解决handler中临界变量可能会面临的多线程问题。具体代码见下方。
``` java
    io.netty.channel.AbstractChannelHandlerContext#write(java.lang.Object, boolean, io.netty.channel.ChannelPromise)
    
    private void write(Object msg, boolean flush, ChannelPromise promise) {
        AbstractChannelHandlerContext next = findContextOutbound();
        final Object m = pipeline.touch(msg, next);
        EventExecutor executor = next.executor();
        if (executor.inEventLoop()) {
            if (flush) {
                next.invokeWriteAndFlush(m, promise);
            } else {
                next.invokeWrite(m, promise);
            }
        } else {
            AbstractWriteTask task;
            if (flush) {
                task = WriteAndFlushTask.newInstance(next, m, promise);
            }  else {
                task = WriteTask.newInstance(next, m, promise);
            }
            safeExecute(executor, task, promise, m);
        }
    }
```

## selector

NioEventLoop中管理的selector是netty在NioEventLoop初始化是新建的SelectedSelectionKeySetSelector，为一个代理的target。这个selector和EventLoop间的交互使用的是共同持有的selectionKeys引用。

## 总结

NioEventLoop使用的是task队列和schedule队列来保证提交任务无需启动新的线程，而NioEventLoop线程会永久不停的去尝试poll任务队列中的待执行的任务并执行。并且，每次循环同样会尝试获取已准备就绪键集用以数据的读取。