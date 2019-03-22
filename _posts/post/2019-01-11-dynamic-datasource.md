---
layout: post
title:  "动态数据源"
date:   2019-01-11
excerpt: "基于spring和mybatis实现动态切换数据源"
feature: https://static.justice-love.com/image/jpg/bjfj1.jpg
tag:
- dynamic datasource
comments: true
---

> 昨天和朋友讨论，基于配置中心，如何实现数据源切换，虽然需求或许有点难以理解，但这里今讨论下可行性

## 流程剖析

**首先要明确一点，数据库访问`Datasource`之上是基于`Spring`和`Mybatis`来做的，因为这个上层建设会明确的规定使用流程从而限制改造方案。**

* 对于`Mybatis`，数据库的操作是通过`SqlSession`来进行的，而实际的物理连接，则是通过`TransactionFactory`构造的`Transaction`来建立的。
* 对于`Spring`，默认情况下，`Spring`是不会操作数据库连接的，但是如果当你开启了事物，`Spring`则会在最外层事物来建立连接。
* 需要注意一点，`Mybatis`默认提供了`SpringManagedTransactionFactory`用来和`Spring`事物进行协同，所以如果你需要创建自己的`TransactionFactory`并且你使用了`Spring`，则需要借鉴默认实现来防治事物失效。

所以，如果需要实现动态数据源，在保证未使用`Spring`事物的情况下，实现自定义的`TransactionFactory`，在其中关闭原数据源，建立新的数据源即可。如归你同时使用了`Spring`的事物，则需要同时在`Spring`的事物管理逻辑`AbstractPlatformTransactionManager#doBegin`中做到数据源的切换。

