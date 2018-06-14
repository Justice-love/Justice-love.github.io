---
layout: post
title:  "netty NioEventLoop线程模型初探"
date:   2018-06-14
excerpt: "netty NioEventLoop线程模型相关学习整理"
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

## selector

NioEventLoop中管理的selector是netty在NioEventLoop初始化是新建的SelectedSelectionKeySetSelector，为一个代理的target。这个selector和EventLoop间的交互使用的是共同持有的selectionKeys引用。