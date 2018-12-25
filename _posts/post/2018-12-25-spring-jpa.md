---
layout: post
title:  "Spring JPA"
date:   2018-12-25
excerpt: "简述Spring JPA相关代码"
feature: https://i.imgur.com/Ds6S7lJ.png
tag:
- jpa
comments: true
---

## JPA配置启动类

和绝大多数的spring组件一样，JPA的启动是从`spring.factories`开始的，初始化配置类是`JpaRepositoriesAutoConfiguration`.factories文件是在`spring-boot-autoconfigure`包中。

## 接口扫描

spring默认的通过包扫描初始化Bean的方式对接口类型是无效的，所以对于像JPA，Mybatis这类的通过动态代理实现数据查询映射功能的框架，都需要定义自己的包扫描逻辑并实例话Bean然后注册到BeanFactory中。

JPA是通过@Import注解来注入`ImportBeanDefinitionRegistrar`实现自定义规则的扫描注入。Registrar实现：`JpaRepositoriesAutoConfigureRegistrar`。

`AbstractRepositoryConfigurationSourceSupport`实现了`registerBeanDefinitions`，用以扫描并注册Repository的实例。

## 动态代理

默认情况下，所有的接口实例均为`JpaRepositoryFactoryBean`，这是一个FactoryBean，而对于调用`getObject`方法获取的实际对象实例，则最终通过`JpaRepositoryFactory`的`getRepository`方法来生成。

实际的Repository，是通过`ProxyFactory`生成的一个动态代理类，目标对象是最基本的`SimpleJpaRepository`。对于JPA中的查询的自动扩展，则是以来一个重要的拦截器`QueryExecutorMethodInterceptor`，这个拦截器负责初始化方法对应的查询和当前代理类方法调用判断，是否使用生成的查询语句来执行查询逻辑。

当然，对应的查询语句的生成也在`QueryExecutorMethodInterceptor`里面，这个类会在初始化是将接口的方法根据需要生成对应的`RepositoryQuery`。

## 整体流程

对于像JPA或者Mybatis这样的框架，具体的执行逻辑都是通过动态代理来实现，而如果要运行在`spring context`之上，则需要实现自己的`scanner`逻辑来进行接口类的扫描和动态代理类的注册，从而可以使用spring ioc的方式来进行Repository的注入和调用。
