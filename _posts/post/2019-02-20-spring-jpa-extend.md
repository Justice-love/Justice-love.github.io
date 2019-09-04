---
layout: post
title:  "spring jpa扩展改造"
date:   2019-02-20
excerpt: "对spring jpa的扩展改造"
feature: https://static.justice-love.com/image/jpg/bjfj1.jpg
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
    * 对`JpaQueryMethod`的改造，主要是添加`Query String`的生成逻辑，使其能够通过配置中心获取SQL脚本。
3. `JpaQueryLookupStrategy`和`JpaQueryFactory`，是`JpaQuery`的查询和生成类，对其的改造很直接，则是在`JpaQueryLookupStrategy`解析`JpaQuery`的最后，添加一段`JpaQueryFactory`尝试通过配置中心方式生成对应`JpaQuery`的代码。
4. 定义新的`JpaQuery`，比如我基于`NativeJpaQuery`扩展的`AutoJpaQuery`，定义好需要的`Query`生成逻辑，这里需要使用相应的模版语言对SQL脚本进行解析，并且，可能需要依据需要定义一下`ParameterBinder`的生成逻辑，因为默认情况下，是依据查询SQL来生成`ParameterBinder`的，如果一开始只能获取到SQL脚本，可能导致生成`ParameterBinder`失败，就需要对`ParameterBinder`生成方式进行修改。
5. `ParameterBinder`改造，因为默认情况下SQL中的参数和方法传参是一一对应的，如果无法保证对应，比如我这种情况，就需要修改`ParameterBinder`的bing逻辑，对不匹配的参数直接舍弃。

当然，改造完成之后，不要忘记跑一边原来的单元测试，并且添加新功能的单元测试。