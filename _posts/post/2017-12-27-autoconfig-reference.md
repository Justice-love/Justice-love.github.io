---
layout: post
title:  "dubbo reference autoconfig"
date:   2017-12-27
excerpt: "dubbo开启注解自动扫描reference篇"
tag:
- dubbo
- autoconfig
comments: true
---

## 需求

对添加了```@Reference```注解的属性和方法依赖注入通过动态代理生成的接口实例。


## Reference注入

1. 通过```ImportBeanDefinitionRegistrar```注册一个```InstantiationAwareBeanPostProcessorAdapter```的子类。
2. 重写```InstantiationAwareBeanPostProcessorAdapter#postProcessPropertyValues```方法，spring会在初始化了java bean之后回调这个方法，在这个方法里我们可以来实现依赖注入。
3. 构造一个```InjectionMetadata```，传入bean class以及```InjectedElement```。
4. 自定义```ReferenceInjectedElement```，继承```InjectedElement```，重写```InjectedElement#getResourceToInject```方法，通过```@Reference```构造一个```ReferenceBean```，通过其```getObject```方法获取动态代理生成的实例。
4. 解析java bean的属性和方法，

## [代码地址](https://github.com/justice-code/dubbo-spring-boot-autoconfig)