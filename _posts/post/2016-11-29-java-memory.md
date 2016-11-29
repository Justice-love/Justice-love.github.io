---
layout: post
title:  "记一次java native memory增长问题的排查"
date:   2016-11-29
excerpt: "排查了一个比较灵异的线上jvm内存持续增长的问题，排查过程异常艰辛，但是最后竟然是用最简单的办法搞定了……"
tag:
- java
- heap
- memory
comments: true
---
[作者@蛋疼的axb, 文章源连接](http://blog.2baxb.me/archives/918)

# 1.摘要

最近排查了一个比较灵异的线上jvm内存持续增长的问题，排查过程异常艰辛，但是最后竟然是用最简单的办法搞定了……


# 2.现象

线上机器部署了两个java实例，在运行几天后java开始吃swap空间，java实例的内存占用接近7G，程序响应很慢，重启后又恢复正常。线上配置的堆内存为3600M，栈大小为512k。

# 3.排查

首先怀疑是java heap的问题，查看heap占用内存，没有什么特殊。

`$ jmap -heap pid`

然后又怀疑是directbuffer的问题，jdk1.7之后对directbuffer监控的支持变得简单了一些，使用如下脚本：

```
import java.io.File;
import java.util.*;
import java.lang.management.BufferPoolMXBean;
import java.lang.management.ManagementFactory;
import javax.management.MBeanServerConnection;
import javax.management.ObjectName;
import javax.management.remote.*;

import com.sun.tools.attach.VirtualMachine; // Attach API

/**
 * Simple tool to attach to running VM to report buffer pool usage.
 */

public class MonBuffers {
    static final String CONNECTOR_ADDRESS =
          "com.sun.management.jmxremote.localConnectorAddress";

    public static void main(String args[]) throws Exception {
        // attach to target VM to get connector address
        VirtualMachine vm = VirtualMachine.attach(args[0]);
        String connectorAddress = vm.getAgentProperties().getProperty(CONNECTOR_ADDRESS);
        if (connectorAddress == null) {
            // start management agent
            String agent = vm.getSystemProperties().getProperty("java.home") +
                    File.separator + "lib" + File.separator + "management-agent.jar";
            vm.loadAgent(agent);
            connectorAddress = vm.getAgentProperties().getProperty(CONNECTOR_ADDRESS);
            assert connectorAddress != null;
        }

        // connect to agent
        JMXServiceURL url = new JMXServiceURL(connectorAddress);
        JMXConnector c = JMXConnectorFactory.connect(url);
        MBeanServerConnection server = c.getMBeanServerConnection();

        // get the list of pools
        Set<ObjectName> mbeans = server.queryNames(
            new ObjectName("java.nio:type=BufferPool,*"), null);
        List<BufferPoolMXBean> pools = new ArrayList<BufferPoolMXBean>();
        for (ObjectName name: mbeans) {
            BufferPoolMXBean pool = ManagementFactory
                .newPlatformMXBeanProxy(server, name.toString(), BufferPoolMXBean.class);
            pools.add(pool);
        }

        // print headers
        for (BufferPoolMXBean pool: pools)
            System.out.format("         %8s             ", pool.getName());
        System.out.println();
        for (int i=0; i<pools.size(); i++)
            System.out.format("%6s %10s %10s  ",  "Count", "Capacity", "Memory");
        System.out.println();

        // poll and print usage
        for (;;) {
            for (BufferPoolMXBean pool: pools) {
                System.out.format("%6d %10d %10d  ",
                    pool.getCount(), pool.getTotalCapacity(), pool.getMemoryUsed());
            }
            System.out.println();
            Thread.sleep(2000);
        }
    }
}

```

发现directbuffer虽然在增长，但是也只有百兆左右。full gc之后缩小到十几兆，可以忽略。

查看java线程的情况，虽然线程数很多，但是内存增长时线程数基本没有什么变化。

`$ jstack pid |grep 'java.lang.Thread.State' |wc -l`

或者

`$ cat /proc/pid/status |grep Thread`

对java做了一次heap dump，使用eclipse的MAT查看堆内使用情况，没有发现明显有哪个对象数量有明显异常，heap的大小也只有几百兆。

`$ jmap -dump:file=/tmp/heap.bin`

发现stack dump里的global jni reference一直在增长，怀疑是jni调用存在内存溢出。

`$ jstack pid |grep JNI`

查找了jar包里的.so/.h等c文件，发现jruby、jthon等jar包里有jni相关的文件。

`$ wtool jarfind *.so .`

上网发现确实有不少[jruby内存溢出的issue](https://github.com/jruby/jruby/issues/1888)。把这些jar包直接删掉之后观察global jni reference数量还是在涨，内存增长情况也没有改善。

之后突然想到full gc的问题，对增长中的java进程做了一次full gc，global jni reference数量由几千个下降到几十个，但是占用内存还是没有变化，排除掉global reference的可能性。

用pmap查看进程内的内存情况，发现java的heap和stack大小都没啥变化，但是定期会多出来一个64M左右的内存块。

`$ pmap -x pid |less`

![pmap截图](http://blog.2baxb.me/wp-content/uploads/2014/11/64m.jpg)

使用gdb观察内存块里的内容，发现里面有一些接口的返回值、mc的返回值、还有一些类名等等

`gdb: dump memory /tmp/memory.bin 0x7f6b38000000 0x7f6b38000000+65535000`

`$ hexdump -C /tmp/memory.bin`或`$ strings /tmp/memory.bin |less`

![hexdump截图](http://blog.2baxb.me/wp-content/uploads/2014/11/hexdump.jpg)

上网搜索后发现有人遇到过这个问题，在[这个网页里](https://www.ibm.com/developerworks/community/blogs/kevgrig/entry/linux_glibc_2_10_rhel_6_malloc_may_show_excessive_virtual_memory_usage?lang=en)有ibm对64M问题的研究。依照网站上说的办法，把MALLOC_ARENA_MAX参数调成1，发现virtual memory正常了，res也小了1G左右。同时[hadoop的issue里](https://issues.apache.org/jira/browse/HADOOP-7154)也有一些性能方面的测试，发现MALLOC_ARENA_MAX=4的时候性能会提升，但是他们也说不清楚为什么。

修改之后程序启动时的virtual memory明显降低，res也降低到了3.2g： ![memory](http://blog.2baxb.me/wp-content/uploads/2014/11/max.jpg)

本来以为到这里应该算是解决了，但是这个程序跑了几天之后内存依然在上涨,只是内存块由很多64M变成了一个2g+的普通native heap。

继续寻找线索，在一些关于MALLOC_ARENA_MAX这个参数的讨论里也发现一些关于glibc的其它参数。比如[M_TRIM_THRESHOLD和M_MMAP_THRESHOLD](http://mqzhuang.iteye.com/blog/1014287)或者[MALLOC_MMAP_MAX_](https://www.ibm.com/developerworks/community/blogs/kevgrig/entry/linux_native_memory_fragmentation_and_process_size_growth?lang=en)，试用之后发现依然没有效果。

试着从glibc的malloc实现上找问题，比如[这里](https://sourceware.org/bugzilla/show_bug.cgi?id=14581)和[这里](https://sourceware.org/bugzilla/show_bug.cgi?id=11261)，同样没有什么进展。

尝试用strace和ltrace查找malloc调用，发现定期有32k的内存申请，但是无法确定是从哪调用的。

尝试用valgrind查找内存泄露，但是jvm跑在valgrind上几分钟就crash了。

在网上查到了一个关于thread pool用法错误有可能导致内存溢出的问题，可以写一个小程序重现：

但是用btrace挂了一天也没有发现有错误的调用，源代码里也没找到类似的用法。

重新用MAT在heap dump里查找是否有native reference，发现finalizer队列里有很多java.util.zip.Deflater的实例，上网搜索发现这个类有可能导致native内存溢出，使用的jesery框架里有[这个问题导致gzip异常的issue](https://www.google.com/url?sa=t&amp;rct=j&amp;q=&amp;esrc=s&amp;source=web&amp;cd=1&amp;cad=rja&amp;uact=8&amp;ved=0CCAQFjAA&amp;url=https://java.net/jira/browse/JERSEY-1647&amp;ei=ikNYVNinJo72igKBvIGQAQ&amp;usg=AFQjCNF5iKZPZZgVhs4pMAYJjvkZrogfKg&amp;sig2=lFm6sK_rGlTsggZzz0B-gA)；用btrace监视发现有大量这个类的构造函数被调用，但是经过几次full gc的观察，每次full gc后finalizer队列里的Deflater数量都会减少到个位数，但是内存依然在上涨；同时排查了线上配置，发现没有开启gzip。

也发现了有人说[SunPKCS11](https://bugzilla.redhat.com/show_bug.cgi?id=1028966)有可能导致内存泄露，但是也没发现有相关java对象。

尝试把Xss参数调到256k，运行几天后发现内存维持在5.7g左右，比较稳定，但是从各种角度都无法解释为什么xss调小会影响native heap的大小。

怀疑是JIT的问题，用-Xint或者-XX:-Inline方式启动之后发现内存依然增长。

本来排查到这里已经绝望了，但是最后想到是不是JDK本身有什么bug？

查看jdk的changelog，发现线上使用的1.7-b15的版本比较老，之后有一些对native memory leak的修复。尝试用新的jdk1.7-u71启动应用，内存竟然稳定下来了！

在升级jdk、限制directbuffer大小为256M、调整MALLOC_ARENA_MAX=1后，4倍流量的tcpcopy运行几天后内存占用稳定在5G；只升级了jdk，其它参数不变，运行一天后内存为5.4G，是否上涨还有待观察。对比之前占用6.8G左右，效果还是比较明显的。

# 4.其它参考资料

1. java 的堆外内存溢出最近也碰到过几次，有一次是jdk6的一个directbuffer不释放，有jdk6的String.intern 非fullgc不释放。还有就是gzip流不显式关闭也会导致Deflater内存溢出。 找起来 都真是难啊
2. directbuffer在jdk7之后监控变得简单一些了，native的内存确实比较难查。
