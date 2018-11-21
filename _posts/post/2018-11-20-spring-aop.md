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
对于其中核心的`config`节点解析类`ConfigBeanDefinitionParser`，首先会尝试通过registry注册`AspectJAwareAdvisorAutoProxyCreator`，然后则是解析xml配置。
最终，会将其封装成`AspectJPointcutAdvisor`并注册。

`AspectJAwareAdvisorAutoProxyCreator`实现了`InstantiationAwareBeanPostProcessor`接口，调用`postProcessBeforeInstantiation`方法尝试得到bean的实例。

尝试生成动态代理的实例，首先通过调用`findCandidateAdvisors`方法来获取所有`Advisor bean`，然后通过`findAdvisorsThatCanApply`方法和`AopUtils#findAdvisorsThatCanApply`进行匹配，我们一般是通过Pointcut进行过滤，还有一种方式是通过`IntroductionAdvisor`进行过滤，只不过我并没有用过。

最终，如果获取到匹配的`Advisor`，则对其进行排序，和调用字节码依赖生成动态代理实例。

## AOP注解实现

注解实现和XML实现基本逻辑大致相同，但也有几点不一样，
1. `AdvisorAutoProxyCreator`注册方式，是通过`EnableAspectJAutoProxy`注解来import的，注册的是`AnnotationAwareAspectJAutoProxyCreator`
2. `Advisor`并不是在初始化的时候注册到BeanFactory中，而是`AnnotationAwareAspectJAutoProxyCreator`重写了`findCandidateAdvisors`方法，在尝试生成实例时，通过`aspectJAdvisorsBuilder`解析生成所有的`Advisor`，并且和xml实现不同，生成的advisor不会注册到beanFactory中。

``` java
	protected List<Advisor> findCandidateAdvisors() {
		// Add all the Spring advisors found according to superclass rules.
		List<Advisor> advisors = super.findCandidateAdvisors();
		// Build Advisors for all AspectJ aspects in the bean factory.
		if (this.aspectJAdvisorsBuilder != null) {
			advisors.addAll(this.aspectJAdvisorsBuilder.buildAspectJAdvisors());
		}
		return advisors;
	}
	
```

后面的流程则和xml实现大同小异，获取匹配的`Advisor`，通过字节码工具生成动态代理实例。