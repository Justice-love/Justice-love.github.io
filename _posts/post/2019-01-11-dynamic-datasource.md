---
layout: post
title:  "动态数据源"
date:   2019-01-11
excerpt: "基于spring和mybatis实现动态切换数据源"
feature: https://i.imgur.com/Ds6S7lJ.png
tag:
- dynamic datasource
comments: true
---

> 昨天和朋友讨论，基于配置中心，如何实现数据源切换，虽然需求或许有点难以理解，但这里今讨论下可行性

## 流程剖析

**首先要明确一点，数据库访问Datasource之上是基于Spring和Mybatis来做的，因为这个上层建设会明确的规定使用流程从而限制改造方案。**

* 对于Mybatis，数据库的操作是通过SqlSession来进行的，而实际的物理连接，则是通过TransactionFactory构造的Transaction来建立的。
* 对于Spring，默认情况下，spring是不会操作数据库连接的，但是如果当你开启了事物，spring则会在最外层事物来建立连接。
* 需要注意一点，Mybatis默认提供了SpringManagedTransactionFactory用来和spring事物进行协同，所以如果你需要创建自己的TransactionFactory并且你使用了spring，则需要借鉴默认实现来防治事物失效。

所以，如果需要实现动态数据源，在保证未使用spring事物的情况下，实现自定义的TransactionFactory，在其中关闭原数据源，建立新的数据源即可。如归你同时使用了spring的事物，则需要同时在spring的事物管理逻辑AbstractPlatformTransactionManager#doBegin中做到数据源的切换。

