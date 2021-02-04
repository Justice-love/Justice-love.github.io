---
layout: post
title:  "NoClassDefFoundError问题分析"
date:   2018-09-19
excerpt: "记录一下昨天自己代码原因产生的一个错误"
feature: https://cdn.justice-love.com/image/jpg/bjfj1.jpg
tag:
- NoClassDefFoundError
comments: true
---

昨天写代码遇到了一个错误`java.lang.NoClassDefFoundError: Could not initialize class `，看错误信息，是由于class无法初始化，说实话还是第一次遇到class初始化失败，一般都是类实例化出错。看代码，不出意外，有一个static属性，对其进行一些处理，顺利修复这个错误。
