---
layout: post
title:  "数据库事务管理实现"
date:   2018-07-26
excerpt: "基于spring，简述事务的管理方式"
feature: https://i.imgur.com/Ds6S7lJ.png
tag:
- transaction
comments: true
---
## 数据库事务管理需求

* 事务是可嵌套可重入的，如以下案例：

``` java
// 准备
@Transactional
public void methodA(){}

@Transactional
public void methodB(){
    methodA();
}

// 场景1
methodA()

//场景2
methodB()

//以上两个场景，均需对事务进行管理。场景一，只调用了methodA，由methodA来管理事务；场景二，同时调用了methodA和methodB，两个方法都可以进行事务管理，但此处methodB范围更广，由methodB管理事务。
```
* 事务范围自由选择，开发者根据实际业务需求限定事务的范围。
* 同一个请求可指定多个事务管理器，每一个事务管理器相互隔离，方便多数据源或者嵌套隔离，比如：

``` java
@Transactional(transactionManager = "transactionManagerA")
public void methodA(){}

@Transactional(transactionManager = "transactionManagerB")
public void methodB(){
    methodA();
}

//以上两个方法使用不同事务，遵从事务的4个特性
```

## Spring数据库事务的实现

* 使用`TransactionAspectSupport`对添加了`@Transactional`注解的切入点进行管理，他主要做两件事情：
    1. 根据注解的配置获取相应的`TransactionManager`实例，他仅是事务的处理类，比如是commit还是rollback又或者不处理（因为事务嵌套），而事务具体应该如何处理，由当前事务切面的`TransactionInfo`决定。
    2. 收集打包当前事务切面的`TransactionInfo`
* `TransactionInfo`数据打包
    1. 创建`TransactionObject`，同时尝试从当前线程上下文中获取`ConnectionHolder`，如果获取不到，则初始化一个并从相应的`DataSource`中获取链接，设置当前`ConnectionHolder`为Active状态。
    2. 创建`TransactionStatus`，根据当前线程上下文中的`ConnectionHolder`是否存在和其状态来定义`TransactionStatus`的状态，如果`ConnectionHolder`是新建的，则`TransactionStatus`状态也为新建的。
* 事务结束时，由`TransactionManager`判断`TransactionStatus`是否为new状态，以决定是否commit操作。通过`TransactionObject`中持有的`ConnectionHolder`，对数据库链接执行相应操作。
* 执行结束，对数据进行回收清理操作，主要是对`ConnectionHolder`中的事务的状态，比如savePoint和active状态等。
* 注意，事务是不负责对连接进行释放的。
