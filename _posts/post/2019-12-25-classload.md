---
layout: post
title:  "关于类加载的一个问题"
date:   2019-12-25
excerpt: "threadContextClassLoader的必要性"
feature: https://static.justice-love.com/image/jpg/bjfj1.jpg
tag:
- classLoader
comments: true
---
> 今天老婆生日，生日快乐

## ThreadContextClassLoader

threadContextClassLoader是java Thread类提供的方法，用来获取ClassLoader，具体API如下：
```java
java.lang.Thread#getContextClassLoader
```

## JVM类初始化机制

jvm加载并初始化class的时机简单来说是使用时加载，即需要用到这个类时再进行，由引用类的ClassLoader来完成这一操作
```java
public class A {

    public static void main(String[] args) {
        new B();
    }
}
```
上例中，类B的加载是在new时由类A的classLoader进行加载的。

## 问题

上面可以看到，java已经有一套比较完整的类加载初始化机制了，为什么需要暴露threadContextClassLoader，从线程中获取ClassLoader，这个ClassLoader的用处是什么。

## 解释

要解答这个问题，需要比较深入的了解java类加载的双亲委派机制
1. classloader会将类的加载层层委托给更上一级的classlaoder进行加载，只有在上级classloader无法加载的情况下下级classloader才会进行加载
2. class由名称和加载他的classloader来唯一限定
3. class的加载可以由任意层级的classloader为基准往上进行，这个基准classloader一般情况下是引用类的classlaoder，如上例中加载类A的classloader
4. java提供的API是使用bootstrapClassLoader进行加载，而我们自定义的类一般是由AppClassLoader进行加载。

通过上述可以发现，按照正常的类加载双亲委派机制，如果由底层class引用上层class可能会产生问题，比如SPI场景，ServiceLoader需要加载用户自定义的class，但由于ServiceLoader是由BootstrapClassLoader进行加载，所有正常流程依然由
BootstrapClassLoader加载用户自定义的类肯定无法找到，这时候就需要打破双亲委派，由appClassloader来负责加载，而threadContextClassLoader就是用来打破类加载机制，由自定义的classloader来进行加载，以保证类能够被正确加载。