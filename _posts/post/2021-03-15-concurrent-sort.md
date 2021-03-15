---
layout: post
title:  "并发->有序"
date:   2021-03-15
excerpt: "请求从并发到有序的一些方案思考"
feature: https://cdn.justice-love.com/image/jpg/bjfj1.jpg
tag:
- concurrent
- sort
comments: true
---

## 背景

并发请求，且每个请求带有序号，需对请求按照序号进行排序并且尽量保证并发的效率
<figure>
    <img src="{{ site.staticUrl }}/image/png/yuanti.png" />
</figure>

## 方案

### 锁方案

<figure>
    <img src="{{ site.staticUrl }}/image/png/lock_fangan.png" />
</figure>
1. 拥有一个锁对象池，结构为序号：锁对象的映射关系
2. 所有请求都根据当前序号申请对应的锁对象
3. 请求执行
    1. 如果当前序号=请求序号-1，则存储数据并判断锁池是否拥有下一序号对应的锁对象，如果有，则唤醒
    2. 如果当前序号!=请求序号-1，则线程等待，直到被正常唤醒
4. 该方案不需要轮询请求当前序号，上一个节点可以直接查找到当前序号对应的请求并唤醒
       
### 数据结构方案

<figure>
    <img src="{{ site.staticUrl }}/image/png/link_buffer_fangan.png" />
</figure>
1. 构造一个link_buffer数据结构
   1. link_buffer长度为L
   2. 每个数据节点有对应的下标
   3. 请求并发存储，存储的节点为 请求序号%L
   4. link_buffer拥有一个tail指针，tail指针指向最后一个连续的节点，如1-2，4下标存储了数据，则tail指针指向2
   5. 当line_buffer的tail指针指向最后一个节点，则数据接受结束

### 存在的问题

两个方案都是尽量保持并发的效果，但都存在因为请求是无序，所以通常情况下，都需要等待数据的间隙的填充。
1. 锁方案如果存在数据间隙，则后续请求都会被挂起，但后续请求不用自旋去查询，当前序号请求可以直接找到对应的后续请求
2. 数据结构方案所有请求都可以并发的落到对应的数据节点上，但同样上报数据需要等待所有请求都执行完毕，即tail指针指向末尾节点