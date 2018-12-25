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

和绝大多数的spring组件一样，JPA的启动是从spring.factories开始的，初始化配置类是JpaRepositoriesAutoConfiguration.factories文件是在spring-boot-autoconfigure包中。

## 接口扫描

spring默认的通过包扫描初始化Bean的方式对接口类型是无效的，所以对于像JPA，Mybatis这类的通过动态代理实现数据查询映射功能的框架，都需要定义自己的包扫描逻辑并实例话Bean然后注册到BeanFactory中。

JPA是通过@Import注解来注入ImportBeanDefinitionRegistrar实现自定义规则的扫描注入。Registrar实现：JpaRepositoriesAutoConfigureRegistrar。

AbstractRepositoryConfigurationSourceSupport实现了registerBeanDefinitions，用以扫描并注册Repository的实例。
