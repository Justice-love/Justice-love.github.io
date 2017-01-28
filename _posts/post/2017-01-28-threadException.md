---
layout: post
title:  "java线程特性之一，异常"
date:   2017-01-28
excerpt: "java线程的设计思想中关于线程中异常的处理方式"
tag:
- java
- thread
- 设计原则
comments: true
---
> 原来很少关注过java线程的异常处理方式，今天了解了一下java线程设计思想中关于异常处理的方式

# 检查异常
这个比较简单，java中不允许在线程代码片段中向外抛出检查异常给
{% highlight java %}
{% raw %}
public interface Runnable {
    /**
     * When an object implementing interface <code>Runnable</code> is used
     * to create a thread, starting the thread causes the object's
     * <code>run</code> method to be called in that separately executing
     * thread.
     * <p>
     * The general contract of the method <code>run</code> is that it may
     * take any action whatsoever.
     *
     * @see     java.lang.Thread#run()
     */
    public abstract void run();
}
{% endraw %}
{% endhighlight %}

# 运行时异常
java线程的设计思想是：__线程是独立运行的代码片段，相互之间不应该相互影响。__

即线程A抛出的异常是不会影响到线程B，即使线程B是线程A的父线程。

当抛出一个未捕获的运行时异常时，线程会被停止，对应线程状态中的 __死亡状态__。

# 跨线程处理异常
Thead类中提供了一种跨线程处理异常的方式，可以用java.lang.Thread#setUncaughtExceptionHandler来设置线程异常的回调函数。

值得注意的是，回调函数仍然实在抛出异常的线程中被调用。