---
layout: post
title:  "Spring AOP"
date:   2018-11-21
excerpt: "简述Spring AOP相关代码"
feature: https://i.imgur.com/Ds6S7lJ.png
tag:
- aop
comments: true
---

## AOP的核心组件

AOP的实现依赖两个核心组件，`AdvisorAutoProxyCreator`和`Advisor`

* Advisor：包含了切面，切入点以及切入点扩展方式（前置，后置，环绕等）
* AdvisorAutoProxyCreator：bean的aop代理生成器

## AOP的配置方式

1. 通过xml进行配置
``` xml
    <aop:config>
        <aop:aspect id="print" ref="testAspect">
            <aop:pointcut id="addAllMethod" expression="execution(* org.eddy.rest.aop.TestService.*(..))" />
            <aop:before method="print" pointcut-ref="addAllMethod"/>
            <aop:around method="aroundPrint" pointcut-ref="addAllMethod"/>
        </aop:aspect>
    </aop:config>
```

2. 通过注解进行配置
``` java
@Aspect
public class AnnAspect {

    @Pointcut("execution(* org.eddy.rest.aop.TService.*(..))")
    public void t(){}

    @Around("t()")
    public Object check(ProceedingJoinPoint point) throws Throwable {
        System.out.println("today");
        return point.proceed();
    }
}
```

## AOP XML实现

AOP的XML实现，主要是基于spring的xml扩展来实现的，打开`spring-aop`包，可以看到`META-INF`文件夹下的`spring.schemas`和`spring.handlers`，其中的`spring.handlers`就是对AOP的XML进行的解析。