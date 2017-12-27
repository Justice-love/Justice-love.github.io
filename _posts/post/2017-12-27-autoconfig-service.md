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
    
## Service托管

spring提供了一个```@Import```注解，可以import一个```ImportBeanDefinitionRegistrar```实现，在添加了```@Import```的Bean构建了之后会回调```ImportBeanDefinitionRegistrar#registerBeanDefinitions```方法，以用来实现自定义```BeanDefinition```的注册管理。

1. 通过```AutoConfigurationPackages```获取spring boot所扫描的包路径。
2. 自定义一个BeanDefinitionScanner，继承```ClassPathBeanDefinitionScanner```，添加IncludeFilter，值扫描添加了```@Service```注解的类。
3. 调用父类的```doScan```方法，获取所有添加了```@Service```注解的Impl的```BeanDefinition```。
4. 通过```BeanDefinitionBuilder```来构建```ServiceBean```的```RootBeanDefinition```并添加实现类的引用。
5. 通过```@Service```实例的数据来向ServiceBean的```RootBeanDefinition```中添加配置引用。
6. 向registry中注册```ServiceBean```的```RootBeanDefinition```以实现Service的管理。