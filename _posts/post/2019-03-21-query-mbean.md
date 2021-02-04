---
layout: post
title:  "查询Mbean"
date:   2019-03-21
excerpt: "依据设置的条件查询Mbean"
feature: https://cdn.justice-love.com/image/jpg/bjfj1.jpg
tag:
- Mbean
comments: true
---

## Mbean
Mbean，management bean的简写，可以暴露出接口，对应用运行时进行管理，我们可以依据确定的ObjectName查询该Mbean的信息，比如对JVM实例的监控。DynamicMBean，动态Mbean，对应用的动态信息进行管理，比如Tomcat请求的管理，实际需依赖开放端口信息。下面主要是根据Tomcat来举例如何对动态Mbean进行查询。

## 准备工作
我们需要启动一个Tomcat服务，再配合JConsole或者visualvm来查看DynamicMBean的基本信息，用以为查询条件的设置提供依据。

## 查询案例 - Tomcat全局请求处理器
通过visualvm可以看到，对应的Mbean的ObjectName是**Tomcat:type=GlobalRequestProcessor,name="http-nio-8080"**，ClassName是**org.apache.tomcat.util.modeler.BaseModelMBean**，可以看到，ObjectName会依据端口而不同，所以我们只能依据确定的信息来查询。<br/>
具体的代码为：

```queryMBeans(new ObjectName("*:type=GlobalRequestProcessor,*"), Query.isInstanceOf(Query.value("org.apache.tomcat.util.modeler.BaseModelMBean")))```

因为ObjectName中只有Type我们是能确定的，所以domain和name都用*号来进行模糊匹配，而查询表达式则是使用类型匹配，指定`org.apache.tomcat.util.modeler.BaseModelMBean`类型的bean查询。

## 其他查询表达式

* AndQueryExp：关联两个查询表达式，需同时满足
* BetweenQueryExp：判断给定值是否处于最高值和最低值之间
* BinaryRelQueryExp：对数字的比较操作
* InQueryExp：判断给定值是否在给定集合之中
* InstanceOfQueryExp：Mbean的类型是否匹配
* MatchQueryExp：属性值的匹配查询
* NotQueryExp：对查询表达式取非操作
* OrQueryExp：两个查询表达式取或操作



