---
layout: post
title:  "spring jpa扩展改造"
date:   2019-02-20
excerpt: "对spring jpa的扩展改造"
feature: https://i.imgur.com/Ds6S7lJ.png
tag:
- spring jpa
comments: true
---

> 改造的目标，是能够通过配置中心统一对SQL进行管理，并且支持利用模版语言依据传参进行简单的逻辑判断，生成不同的SQL。

## 改造范围

1. 目前仅对`@Query`注解进行改造。
2. 仅支持`native`SQL，不支持使用`HQL`。

## 改造流程

1. 对`@Query`改造，增加通过配置中心查询SQL脚本的属性。
2. 对`JpaQueryMethod`改造，`JpaQueryMethod`是对具体的查询方法属性的封装，比如判断是否添加了`@Query`注解，是否是`Native Query`，获取`Query String`，获取`JpaParameters`等。
    * 对`JpaQueryMethod`的改造，主要是添加`Query String`的生成逻辑，使其能够通过配置中心获取SQL脚本，在依赖模版语言生成相应的SQL。
3. `JpaQueryLookupStrategy`和`JpaQueryFactory`，是`JpaQuery`的查询和生成类，对其的改造很直接，则是在`JpaQueryLookupStrategy`解析`JpaQuery`的最后，添加一段`JpaQueryFactory`尝试通过注册中心方式生成对应`JpaQuery`的代码。
4. 