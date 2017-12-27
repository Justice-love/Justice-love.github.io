---
layout: post
title:  "dubbo service autoconfig"
date:   2017-12-27
excerpt: "dubbo开启注解自动扫描service篇"
tag:
- dubbo
- autoconfig
comments: true
---

## 需求

对于实现service注解的自动扫描然后托管，需要实现两个方面的需求：

1. 托管被添加了```@Service```注解的Impl实例。
2. 构建并注册```ServiceBean```，并关联Impl的引用。
    
## 扫描```@Service```注解

spring提供了一个```@Import```注解，可以import一个```ImportBeanDefinitionRegistrar```实现，在添加了```@Import```的Bean构建了之后会回调```ImportBeanDefinitionRegistrar#registerBeanDefinitions```方法，以用来实现自定义```BeanDefinition```的注册管理。