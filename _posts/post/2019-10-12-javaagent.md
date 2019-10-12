---
layout: post
title:  "Java Agent"
date:   2019-10-12
excerpt: "使用bytebuddy创建java agent"
feature: https://static.justice-love.com/image/jpg/bjfj1.jpg
tag:
- thread
comments: true
---
## Java Agent

Java Agent是JVM提供的代理，可以用过添加JVM启动参数指定，也可以通过SUN API运行时attach。它提供了两种能力：
1. Java Agent与JVM应用服务同进程，可以获取到JVM应用服务运行时的状态，比如通过JMX获取运行时线程，堆，GC等信息。
2. Java Agent提供了对class字节码层面上的扩展能力，可以应用到JVM应用服务监控，打点等场景，而对业务开发无入侵。

## Java Agent扩展class

使用bytebuddy快速实现class扩展，屏蔽了asm或者Javassist操作字节码所需的class相关知识，下面直接上代码展示：

```java
        //创建AgentBuilder
        final ByteBuddy byteBuddy = new ByteBuddy()
            .with(TypeValidation.of(Config.Agent.IS_OPEN_DEBUGGING_CLASS));

        new AgentBuilder.Default(byteBuddy)
            .ignore(
                nameStartsWith("net.bytebuddy.")
                    .or(nameStartsWith("org.slf4j."))
                    .or(nameStartsWith("org.apache.logging."))
                    .or(nameStartsWith("org.groovy."))
                    .or(nameContains("javassist"))
                    .or(nameContains(".asm."))
                    .or(nameStartsWith("sun.reflect"))
                    .or(allSkyWalkingAgentExcludeToolkit())
                    .or(ElementMatchers.<TypeDescription>isSynthetic()))
            .type(pluginFinder.buildMatch())
            .transform(new Transformer(pluginFinder))
            .with(new Listener())
            .installOn(instrumentation);
    
    //定义class Transformer
    private static class Transformer implements AgentBuilder.Transformer {
        private PluginFinder pluginFinder;

        Transformer(PluginFinder pluginFinder) {
            this.pluginFinder = pluginFinder;
        }

        @Override
        public DynamicType.Builder<?> transform(DynamicType.Builder<?> builder, TypeDescription typeDescription,
            ClassLoader classLoader, JavaModule module) {
            List<AbstractClassEnhancePluginDefine> pluginDefines = pluginFinder.find(typeDescription);
            if (pluginDefines.size() > 0) {
                DynamicType.Builder<?> newBuilder = builder;
                EnhanceContext context = new EnhanceContext();
                for (AbstractClassEnhancePluginDefine define : pluginDefines) {
                    DynamicType.Builder<?> possibleNewBuilder = define.define(typeDescription, newBuilder, classLoader, context);
                    if (possibleNewBuilder != null) {
                        newBuilder = possibleNewBuilder;
                    }
                }
                if (context.isEnhanced()) {
                    logger.debug("Finish the prepare stage for {}.", typeDescription.getName());
                }

                return newBuilder;
            }

            logger.debug("Matched class {}, but ignore by finding mechanism.", typeDescription.getTypeName());
            return builder;
        }
    }
```

bytebuddy提供的DynamicType.Builder能够方便直观的按照平常的java编码方式进行字节码扩展

```java
//对构造函数扩展
                newClassBuilder = newClassBuilder.constructor(constructorInterceptPoint.getConstructorMatcher()).intercept(SuperMethodCall.INSTANCE
                    .andThen(MethodDelegation.withDefaultConfiguration()
                        .to(new ConstructorInter(constructorInterceptPoint.getConstructorInterceptor(), classLoader))
                    )
                );

//对方法扩展
                    newClassBuilder =
                        newClassBuilder.method(junction)
                            .intercept(
                                MethodDelegation.withDefaultConfiguration()
                                    .to(new InstMethodsInter(interceptor, classLoader))
                    );

//对静态方法扩展
                newClassBuilder = newClassBuilder.method(isStatic().and(staticMethodsInterceptPoint.getMethodsMatcher()))
                    .intercept(
                        MethodDelegation.withDefaultConfiguration()
                            .to(new StaticMethodsInter(interceptor))
                    );
```

## 小节

总的来说，Java Agent提供了一种无侵入式的服务扩展能力，而bytebuddy让开发人员无需使用复杂的asm或者Javassist包就能快速对class字节码进行扩展。