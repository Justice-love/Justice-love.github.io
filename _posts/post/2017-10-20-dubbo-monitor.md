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

1. 按照[文档](https://dubbo.gitbooks.io/dubbo-dev-book/impls/monitor.html)扩展自定义的monitor（并没有增加```<dubbo:monitor>```节点，仅新增自定义monitor扩展）。
2. 在<provider>节点上配置增加parameter，如：
    * ```<dubbo:parameter key="monitor" value="myProtocol://"/>```，注意myProtocol必须和SPI扩展里设置的MonitorFactory实现name一致，因为dubbo通过自定义协议来查找相应扩展。
3. 在MonitorService.collect方法实现里实现性能数据上报即可，```URL statistics```已采集性能数据并作为参数传递。
4. 当前版本如果在provider侧增加了默认URL参数，会被合并拷贝到consumer层，致使provider侧开启的监控上报在consumer层同样生效，这点需要注意。

## 后记

通过阅读代码发现，并非是```<dubbo:monitor>```节点无效，而是由于provider侧如果不配置**scope**的话，默认会除了开启远程服务外，同时在本地使用**injvm**协议导出一份，
而使用**injvm**协议的链接，则不会添加**monitor**参数，具体代码见```serviceConfig.doExportUrlsFor1Protocol```：
``` java
        //配置为none不暴露
        if (!Constants.SCOPE_NONE.toString().equalsIgnoreCase(scope)) {

            //配置不是remote的情况下做本地暴露 (配置为remote，则表示只暴露远程服务)
            if (!Constants.SCOPE_REMOTE.toString().equalsIgnoreCase(scope)) {
                exportLocal(url);
            }
            //如果配置不是local则暴露为远程服务.(配置为local，则表示只暴露本地服务)
            if (!Constants.SCOPE_LOCAL.toString().equalsIgnoreCase(scope)) {
                if (logger.isInfoEnabled()) {
                    logger.info("Export dubbo service " + interfaceClass.getName() + " to url " + url);
                }
                if (registryURLs != null && registryURLs.size() > 0
                        && url.getParameter("register", true)) {
                    for (URL registryURL : registryURLs) {
                        url = url.addParameterIfAbsent("dynamic", registryURL.getParameter("dynamic"));
                        URL monitorUrl = loadMonitor(registryURL);
                        if (monitorUrl != null) {
                            url = url.addParameterAndEncoded(Constants.MONITOR_KEY, monitorUrl.toFullString());
                        }
                        if (logger.isInfoEnabled()) {
                            logger.info("Register dubbo service " + interfaceClass.getName() + " url " + url + " to registry " + registryURL);
                        }
                        Invoker<?> invoker = proxyFactory.getInvoker(ref, (Class) interfaceClass, registryURL.addParameterAndEncoded(Constants.EXPORT_KEY, url.toFullString()));

                        Exporter<?> exporter = protocol.export(invoker);
                        exporters.add(exporter);
                    }
                } else {
                    Invoker<?> invoker = proxyFactory.getInvoker(ref, (Class) interfaceClass, url);

                    Exporter<?> exporter = protocol.export(invoker);
                    exporters.add(exporter);
                }
            }
        }
```
不知道这么设计出于什么原因，但我想应该也会有很多人和我一样，在本地测试自定义性能数据采集协议的时候感到困扰。