---
layout: post
title:  "索引表"
date:   2020-06-14
excerpt: "索引表使用场景和介绍"
feature: https://cdn.justice-love.com/image/jpg/bjfj1.jpg
tag:
- index table
comments: true
---

## 简介

正常使用数据库时，我们都是使用主键来做数据的聚合，查询时带有主键能够大大提升查询效率。但有些查询场景，并不能够带主键，这时，可以通过创建二级索引来增加查询效率。
有些场景是无法创建二级索引，比如像NoSQL，数据分片（不带分片主键），这时候可以通过创建索引表来模拟二级索引。

所以，概括来说，索引表是在不适合使用数据库二级索引的场景，通过自建索引表来模拟二级索引。

## 索引表介绍

### 复制原表中所有数据

将原表数据复制到每个索引表中，这种方式可以快速的查询返回数据，但同时如果数据变更频繁，这种方式的处理开销也会很大。

### 仅存储主键

索引表仅存储事实表主键，这种方式更加灵活，但同时也需要额外的一次查询才可以获取实际数据

### 混合方式

前两种方式的混合，所以表缓存频繁读取的字段，用以减少数据的查询次数。

### 分片+主键索引表

这种方式主要是用在数据库分片的场景，由原来的存储主键改为存储分片主键和数据库主键，用来快速定位分片和快速定位数据。