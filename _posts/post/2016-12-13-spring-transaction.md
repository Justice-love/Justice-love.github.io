---
layout: post
title:  "spring transaction"
date:   2016-12-13
excerpt: "spring transaction管理流程"
tag:
- spring
- transaction
- datasource
comments: true
---

###spring事物管理流程

1. org.springframework.transaction.interceptor.TransactionAspectSupport.TransactionInfo 获取事物信息

2. org.springframework.transaction.support.AbstractPlatformTransactionManager#isExistingTransaction 判断当前线程已获取线程并且已开启事物

	* org.springframework.jdbc.datasource.JdbcTransactionObjectSupport#getConnectionHolder 获取线程holder

	* org.springframework.jdbc.datasource.ConnectionHolder#isTransactionActive 是否已开启事物

	* org.springframework.transaction.support.AbstractPlatformTransactionManager#handleExistingTransaction 当前线程已开启事物请求新事物处理方法

3. org.springframework.jdbc.datasource.DataSourceTransactionManager#doBegin 如果当前线程没有开启事物

	* org.springframework.jdbc.datasource.ConnectionHolder#setTransactionActive设置当前线程已开启事物

4. org.springframework.transaction.support.AbstractPlatformTransactionManager#processCommit 判断transaction对象状态是否为new，即事物是否该由该transaction对象管理
