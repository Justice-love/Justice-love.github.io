---
layout: post
title:  "python中文SyntaxError"
date:   2018-10-12
excerpt: "记录一下python中遇到的中文环境异常"
feature: https://cdn.justice-love.com/image/jpg/bjfj1.jpg
tag:
- python chinese
comments: true
---

在Python中运行时出现SyntaxError: Non-ASCII character ‘\xe9’ 错误

### 解决方案：文件开头加入 \# \-\- coding: UTF\-8 \-\- 或者 \#coding=utf-8 

