---
layout: post
title:  "shell脚本技巧"
date:   2020-04-09
excerpt: "脚本场景绕过等待标准输入的小技巧"
feature: https://static.justice-love.com/image/jpg/bjfj1.jpg
tag:
- shell tips
comments: true
---

## 背景

有些指令需要等待标准输入，比如redis串联集群，yum install（不讨论-y参数，只是举例指代这种场景）等，正常情况下输入指令没什么问题，但是如果在自动化脚本中有这类的指令，就会非常麻烦。

## 解决方案

通过echo模拟标准输入，配合管道将起传递给等待标准输入的指令，如：

**echo "yes" | /redis/src/redis-cli --cluster create  --cluster-replicas 0 173.17.0.2:7000 173.17.0.3:7001 173.17.0.4:7002**
**echo "y" | yum install telnet**

## 注意事项

标准输入和密码输入对于linux来说是不同类型，也就是说在等待密码输入场景，这种方式不使用，如：

**echo "root" | mysql -uroot -p (无法达到无需键入密码的目的)**