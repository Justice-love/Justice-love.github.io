---
layout: post
title:  "记录遇到的一个问题"
date:   2019-07-10
excerpt: "如题"
feature: https://static.justice-love.com/image/jpg/bjfj1.jpg
tag:
- classloader
comments: true
---

今天遇到了一个因class类多实例而导致的类型匹配失败的问题，现在记录一下这个问题的排查过程。

### 问题表象：spring未自动注入

在某个spring bean中维护了CustomizeTemplates数组，依赖spring的自动注入，如下：
```java
	@Autowired(required = false)
	private CustomizeTemplate[] customizeTemplates;
```
在运行时发现，某一个自定义的CustomizeTemplate实例未注入进来，以下是自定义实例的初始化方式：
```java
    @Bean("mineInitTemplate")
    public CustomizeTemplate template() {
        addApplication(contents, application);
        addApplication(modules, application);
        return new MineInitTemplate(contents, modules);
    }
```
通过断点确定，该Bean的确已初始化

### 问题排查

通过ApplicationContext来主动获取bean实例，发现，通过名称可以正常获取自定义的bean，而限定了类型，则会获取失败。通过`instanceof`判断，也返回False，查看类的接口信息，从类信息上来看和其他CustomizeTemplate没有差别。

猜想：CustomizeTemplate的class类存在多实例<br/>
验证：查看对应的类信息，以下截图是class类信息
<figure>
    <img src="{{ site.staticUrl }}/image/jpg/mutiinstance1.jpg?imageMogr2/auto-orient" />
    <img src="{{ site.staticUrl }}/image/jpg/mutiinstance2.jpg?imageMogr2/auto-orient" />
</figure>
通过上图可以发现，的确CustomizeTemplate class具有不同的两个实例。

### 问题解决

查看初始化线程对应的Classloader，发现使用了spring-boot-devtools的RestartClassLoader，将devtools依赖去掉，问题暂时解决。这几天对devtools有更深入的了解之后，在做出更合适的处理。
