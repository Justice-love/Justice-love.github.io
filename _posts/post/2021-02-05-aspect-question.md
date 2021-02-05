---
layout: post
title:  "记录一个AOP的问答"
date:   2021-02-05
excerpt: "回复一个群友的问题"
feature: https://cdn.justice-love.com/image/jpg/bjfj1.jpg
tag:
- aop
comments: true
---

问：使用AOP是否可以切org.slf4j.Logger.error，不生效
{: .notice}
答：spring aop只对spring托管的bean生效。
{: .notice}
问：那这个方法需要怎么切，使用aspectj吗
{: .notice}
答：aspectj是编译时编制，slf4j是通过jar包引入，是编译后文件，无法生效
{: .notice}
问：那能使用什么方式？
{: .notice}
答：可以使用javaagent
{: .notice}
