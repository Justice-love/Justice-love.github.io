---
layout: post
title:  "dubbo自定义监控"
date:   2017-10-15
excerpt: "dubbo监控扩展，自定义dubbo监控"
tag:
- dubbo
- monitor
comments: true
---

1. 按照[文档](https://dubbo.gitbooks.io/dubbo-dev-book/impls/monitor.html)扩展自定义的monitor（并没有增加<monitor>节点，仅新增自定义monitor扩展)。
2. 在<provider>节点上配置增加parameter，如：
    * ```<dubbo:parameter key="monitor" value="myProtocol://"/>```，注意myProtocol必须和SPI扩展里设置的MonitorFactory实现name一致，因为dubbo通过自定义协议来查找相应扩展。
3. 在MonitorService.collect方法实现里实现性能数据上报即可，```URL statistics```已采集性能数据并作为参数传递。
4. 