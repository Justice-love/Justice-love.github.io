---
layout: post
title:  "Maven仓库理解"
date:   2018-06-06
excerpt: "理解maven拉去jar包仓库配置的优先级"
feature: https://i.imgur.com/Ds6S7lJ.png
tag:
- maven
comments: true
---

> 本文转载自[https://swenfang.github.io/2017/09/03/Maven-Priority/](https://swenfang.github.io/2017/09/03/Maven-Priority/)

## 前言

使用 maven 也有一段时间了，有时候在配置 repository,mirror,profile的时候，总会导致 jar 拉取不到。所以认真的分析了 maven 获取 jar 包时候的优先级。

## Maven 仓库的分类

仓库分类：本地仓库和远程仓库。Maven根据坐标寻找构件的时候，它先会查看本地仓库，如果本地仓库存在构件，则直接使用；如果没有，则从远程仓库查找，找到后，下载到本地。

1. 本地仓库：默认情况下，每个用户在自己的用户目录下都有一个路径名为.m2/repository/的仓库目录。我们也可以在 settings.xml 文件配置本地仓库的地址
2. 远程仓库：本地仓库好比书房，而远程仓库就像是书店。对于Maven来说，每个用户只有一个本地仓库，但是可以配置多个远程仓库。

> 我们可以在 pom 文件配置多个 repository，但是随着项目越来也多我们每次都要在 pom 文件配置比较麻烦，所以我们可以在settings 文件配置 profile （私服）。这样我们每次创建新项目的时候就可以不用配置 repository。

3. 中央仓库：Maven必须要知道至少一个可用的远程仓库，中央仓库就是这样一个默认的远程仓库，Maven 默认有一个 super pom 文件。

``` xml
  ···
  <repositories>
    <repository>
      <id>central</id>
      <name>Central Repository</name>
      <url>https://repo.maven.apache.org/maven2</url>
      <layout>default</layout>
      <snapshots>
        <enabled>false</enabled>
      </snapshots>
    </repository>
  </repositories>
  ···
```

这个时候我们就明白了，我们在 settings 文件配置一个 mirror 的 mirrorOf 为 central 的镜像就会替代 ‘中央仓库’ 的原因了。

## Maven 镜像

镜像（Mirroring）是冗余的一种类型，一个磁盘上的数据在另一个磁盘上存在一个完全相同的副本即为镜像。
为什么配置镜像?

> 1.一句话，你有的我也有，你没有的我也有。（拥有远程仓库的所有 jar，包括远程仓库没有的 jar）

> 2.还是一句话，我跑的比你快。（有时候远程仓库获取 jar 的速度可能比镜像慢，这也是为什么我们一般要配置中央仓库的原因，外国的 maven 仓库一般获取速度比较慢）

如果你配置 maven 镜像不是为了以上两点，那基本就不用配置镜像了。
**注意:当远程仓库被镜像匹配到的，则在获取 jar 包将从镜像仓库获取，而不是我们配置的 repository 仓库, repository 将失去作用**

## 私服

私服是一种特殊的远程Maven仓库，它是架设在局域网内的仓库服务，私服一般被配置为互联网远程仓库的镜像，供局域网内的Maven用户使用。
当Maven需要下载构件的时候，先向私服请求，如果私服上不存在该构件，则从外部的远程仓库下载，同时缓存在私服之上，然后为Maven下载请求提供下载服务，另外，对于自定义或第三方的jar可以从本地上传到私服，供局域网内其他maven用户使用。

优点主要有：
1. 节省外网宽带
2. 加速Maven构建
3. 部署第三方构件：可以将公司项目的 jar 发布到私服上，方便项目与项目之间的调用
4. 提高稳定性、增强控制：原因是外网不稳定
5. 降低中央仓库的负荷：原因是中央仓库访问量太大

## 远程仓库优先级

settings.xml
``` xml
<mirrors> 
  <mirror> 
    <id>localhost</id>  
    <name>Public Repositories</name>  
    <mirrorOf>foo</mirrorOf>   <!--拦截 pom 文件配置的 repository-->
    <url>http://localhost:8081/repository/maven-public/</url> 
  </mirror>  
  
  <mirror> 
    <id>localhost2</id>  
    <name>Public Repositories</name>  
    <mirrorOf>foo2</mirrorOf>   <!--配置一个拦截 foo2 的远程仓库的镜像-->
    <url>http://localhost:8081/repository/maven-snapshots/</url> 
  </mirror>  
  
  <mirror> 
    <id>alimaven</id>  
    <mirrorOf>central</mirrorOf>  <!--覆盖 Maven 默认的配置的中央仓库-->
    <name>aliyun maven</name>  
    <url>http://maven.aliyun.com/nexus/content/groups/public/</url> 
  </mirror> 
 
</mirrors>
<!--配置私服-->
<profiles> 
  <profile> 
    <id>nexus</id>  
    <repositories> 
      <repository> 
        <id>public</id>  
        <name>Public Repositories</name>  
        <url>http://172.16.xxx.xxx:8081/nexus/content/groups/public/</url> 
      </repository> 
    </repositories>  
    <pluginRepositories> 
      <pluginRepository> 
        <id>public</id>  
        <name>Public Repositories</name>  
        <url>http://172.16.xxx.xxx:8081/nexus/content/groups/public</url> 
      </pluginRepository> 
    </pluginRepositories> 
  </profile> 
</profiles>
<activeProfiles>
    <activeProfile>nexus</activeProfile>
</activeProfiles>

```
pom.xml
``` xml
<dependencies>
    <!--xxx-cif-api 存在 172.16.xxx.xxx 仓库-->
    <dependency>
        <groupId>com.xxx.cif</groupId>
        <artifactId>xxx-cif-api</artifactId>
        <version>0.0.1-SNAPSHOT</version>
    </dependency>
    <!--Chapter1 存在 localhost 仓库-->
    <dependency>
        <groupId>com.cjf</groupId>
        <artifactId>Chapter1</artifactId>
        <version>0.0.1-SNAPSHOT</version>
    </dependency>
</dependencies>
<!--配置远程仓库-->
<repositories>
    <repository>
        <id>foo</id>
        <name>Public Repositories</name>
        <url>http://dev.xxx.wiki:8081/nexus/content/groups/public/</url>
    </repository>
</repositories>
```
Maven 拉取包的日志
```xml
······· 省略部分日志信息
[DEBUG] Using local repository at E:\OperSource
[DEBUG] Using manager EnhancedLocalRepositoryManager with priority 10.0 for E:\OperSource
[INFO] Scanning for projects...
// 从这里可以看出我们配置的镜像替代了我们在 pom 配置的远程仓库
[DEBUG] Using mirror localhost (http://localhost:8081/repository/maven-public/) for foo (http://dev.xxx.wiki:8081/nexus/content/groups/public/).
替代了默认的中央仓库
[DEBUG] Using mirror alimaven (http://maven.aliyun.com/nexus/content/groups/public/) for central (https://repo.maven.apache.org/maven2).
// 从这里可以看出 Maven 使用哪些 dependencies 和 plugins 的地址，我们可以看出优先级最高的是 172.16.xxx.xxx,然后就是 localhost 最后才是 maven.aliyun.com
// 注意：alimaven (http://maven.aliyun.com/nexus/content/groups/public/, default, releases) 从这里可以看出中央仓库只能获取 releases 包，所有的 snapshots 包都不从中央仓库获取。（可以看前面 central 的配置信息）
[DEBUG] === PROJECT BUILD PLAN ================================================
[DEBUG] Project:       com.cjf:demo:1.0-SNAPSHOT
[DEBUG] Dependencies (collect): []
[DEBUG] Dependencies (resolve): [compile, runtime, test]
[DEBUG] Repositories (dependencies): [public (http://172.16.xxx.xxx:8081/nexus/content/groups/public/, default, releases+snapshots), localhost (http://localhost:8081/repository/maven-public/, default, releases+snapshots), alimaven (http://maven.aliyun.com/nexus/content/groups/public/, default, releases)]
[DEBUG] Repositories (plugins)     : [public (http://172.16.xxx.xxx:8081/nexus/content/groups/public, default, releases+snapshots), alimaven (http://maven.aliyun.com/nexus/content/groups/public/, default, releases)]
[DEBUG] =======================================================================
// 寻找本地是否有 maven-metadata.xml 配置文件 ，从这里可以看出寻找不到（后面会详细讲该文件作用）
[DEBUG] Could not find metadata com.xxx.cif:xxx-cif-api:0.0.1-SNAPSHOT/maven-metadata.xml in local (E:\OperSource)
// 由于寻找不到 Maven 只能从我们配置的远程仓库寻找，由于 Maven 也不知道那个仓库才有，所以同时寻找两个仓库
[DEBUG] Using transporter WagonTransporter with priority -1.0 for http://172.16.xxx.xxx:8081/nexus/content/groups/public/
[DEBUG] Using transporter WagonTransporter with priority -1.0 for http://localhost:8081/repository/maven-public/
[DEBUG] Using connector BasicRepositoryConnector with priority 0.0 for http://localhost:8081/repository/maven-public/
[DEBUG] Using connector BasicRepositoryConnector with priority 0.0 for http://172.16.xxx.xxx:8081/nexus/content/groups/public/
Downloading: http://172.16.xxx.xxx:8081/nexus/content/groups/public/com/xxx/cif/xxx-cif-api/0.0.1-SNAPSHOT/maven-metadata.xml
Downloading: http://localhost:8081/repository/maven-public/com/xxx/cif/xxx-cif-api/0.0.1-SNAPSHOT/maven-metadata.xml
[DEBUG] Writing tracking file E:\OperSource\com\xxx\cif\xxx-cif-api\0.0.1-SNAPSHOT\resolver-status.properties
// 从这里可以看出在 172.16.xxx.xxx 找到  xxx-cif-api 的 maven-metadata.xml 文件并下载下来
Downloaded: http://172.16.xxx.xxx:8081/nexus/content/groups/public/com/xxx/cif/xxx-cif-api/0.0.1-SNAPSHOT/maven-metadata.xml (781 B at 7.0 KB/sec)
// 追踪文件，resolver-status.properties 配置了 jar 包下载地址和时间
[DEBUG] Writing tracking file E:\OperSource\com\xxx\cif\xxx-cif-api\0.0.1-SNAPSHOT\resolver-status.properties
[DEBUG] Could not find metadata com.xxx.cif:xxx-cif-api:0.0.1-SNAPSHOT/maven-metadata.xml in localhost (http://localhost:8081/repository/maven-public/)
// 在 localhost 远程仓库寻找不到 xxx-cif-api 的 maven-metadata.xml
[DEBUG] Could not find metadata com.xxx.cif:xxx-cif-api:0.0.1-SNAPSHOT/maven-metadata.xml in local (E:\OperSource)
// 跳过的远程请求 
[DEBUG] Skipped remote request for com.xxx.cif:xxx-cif-api:0.0.1-SNAPSHOT/maven-metadata.xml, already updated during this session.
[DEBUG] Skipped remote request for com.xxx.cif:xxx-cif-api:0.0.1-SNAPSHOT/maven-metadata.xml, already updated during this session.
// 默认以后获取 xxx-cif-api 的时候将不在从 localhost 寻找了，除非强制获取才会再次从 localhost 寻找这个包
[DEBUG] Failure to find com.xxx.cif:xxx-cif-api:0.0.1-SNAPSHOT/maven-metadata.xml in http://localhost:8081/repository/maven-public/ was cached in the local repository, resolution will not be reattempted until the update interval of localhost has elapsed or updates are forced
// 将 172.16.xxx.xxx 优先级升为 0 ，并下载 xxx-cif-api 的 pom 文件
[DEBUG] Using transporter WagonTransporter with priority -1.0 for http://172.16.xxx.xxx:8081/nexus/content/groups/public/
[DEBUG] Using connector BasicRepositoryConnector with priority 0.0 for http://172.16.xxx.xxx:8081/nexus/content/groups/public/
Downloading: http://172.16.xxx.xxx:8081/nexus/content/groups/public/com/xxx/cif/xxx-cif-api/0.0.1-SNAPSHOT/xxx-cif-api-0.0.1-20170515.040917-89.pom
Downloaded: http://172.16.xxx.xxx:8081/nexus/content/groups/public/com/xxx/cif/xxx-cif-api/0.0.1-SNAPSHOT/xxx-cif-api-0.0.1-20170515.040917-89.pom (930 B at 82.6 KB/sec)
// _remote.repositories 记录的以后使用那个远程仓库获取 （ps:这个文件作用我要不是很清楚作用，以上观点是自己推测出来的。）
[DEBUG] Writing tracking file E:\OperSource\com\xxx\cif\xxx-cif-api\0.0.1-SNAPSHOT\_remote.repositories
[DEBUG] Writing tracking file E:\OperSource\com\xxx\cif\xxx-cif-api\0.0.1-SNAPSHOT\xxx-cif-api-0.0.1-20170515.040917-89.pom.lastUpdated
// 后面获取 Chapter1 包的流程跟 com.xxx.cif 是一样的，不过最后是在 localhost 寻找到而已，所以这分日志就不贴出来了。
// 最后在下载包的时候，都到对应的仓库下载
[DEBUG] Using transporter WagonTransporter with priority -1.0 for http://172.16.xxx.xxx:8081/nexus/content/groups/public/
[DEBUG] Using connector BasicRepositoryConnector with priority 0.0 for http://172.16.xxx.xxx:8081/nexus/content/groups/public/
Downloading: http://172.16.xxx.xxx:8081/nexus/content/groups/public/com/xxx/cif/xxx-cif-api/0.0.1-SNAPSHOT/xxx-cif-api-0.0.1-20170515.040917-89.jar
Downloading: http://172.16.xxx.xxx:8081/nexus/content/groups/public/com/xxx/util/xxx-util/0.0.1-SNAPSHOT/xxx-util-0.0.1-20170514.091041-31.jar
Downloaded: http://172.16.xxx.xxx:8081/nexus/content/groups/public/com/xxx/util/xxx-util/0.0.1-SNAPSHOT/xxx-util-0.0.1-20170514.091041-31.jar (26 KB at 324.2 KB/sec)
Downloaded: http://172.16.xxx.xxx:8081/nexus/content/groups/public/com/xxx/cif/xxx-cif-api/0.0.1-SNAPSHOT/xxx-cif-api-0.0.1-20170515.040917-89.jar (68 KB at 756.6 KB/sec)
[DEBUG] Writing tracking file E:\OperSource\com\xxx\cif\xxx-cif-api\0.0.1-SNAPSHOT\_remote.repositories
[DEBUG] Writing tracking file E:\OperSource\com\xxx\cif\xxx-cif-api\0.0.1-SNAPSHOT\xxx-cif-api-0.0.1-20170515.040917-89.jar.lastUpdated
[DEBUG] Writing tracking file E:\OperSource\com\xxx\util\xxx-util\0.0.1-SNAPSHOT\_remote.repositories
[DEBUG] Writing tracking file E:\OperSource\com\xxx\util\xxx-util\0.0.1-SNAPSHOT\xxx-util-0.0.1-20170514.091041-31.jar.lastUpdated
[DEBUG] Using transporter WagonTransporter with priority -1.0 for http://localhost:8081/repository/maven-public/
[DEBUG] Using connector BasicRepositoryConnector with priority 0.0 for http://localhost:8081/repository/maven-public/
Downloading: http://localhost:8081/repository/maven-public/com/cjf/Chapter1/0.0.1-SNAPSHOT/Chapter1-0.0.1-20170708.092339-1.jar
Downloaded: http://localhost:8081/repository/maven-public/com/cjf/Chapter1/0.0.1-SNAPSHOT/Chapter1-0.0.1-20170708.092339-1.jar (8 KB at 167.0 KB/sec)
[DEBUG] Writing tracking file E:\OperSource\com\cjf\Chapter1\0.0.1-SNAPSHOT\_remote.repositories
[DEBUG] Writing tracking file E:\OperSource\com\cjf\Chapter1\0.0.1-SNAPSHOT\Chapter1-0.0.1-20170708.092339-1.jar.lastUpdated
[INFO] Installing C:\Users\swipal\Desktop\abc\demo\target\demo-1.0-SNAPSHOT.jar to E:\OperSource\com\cjf\demo\1.0-SNAPSHOT\demo-1.0-SNAPSHOT.jar
[DEBUG] Writing tracking file E:\OperSource\com\cjf\demo\1.0-SNAPSHOT\_remote.repositories
[INFO] Installing C:\Users\swipal\Desktop\abc\demo\pom.xml to E:\OperSource\com\cjf\demo\1.0-SNAPSHOT\demo-1.0-SNAPSHOT.pom
[DEBUG] Writing tracking file E:\OperSource\com\cjf\demo\1.0-SNAPSHOT\_remote.repositories
[DEBUG] Installing com.cjf:demo:1.0-SNAPSHOT/maven-metadata.xml to E:\OperSource\com\cjf\demo\1.0-SNAPSHOT\maven-metadata-local.xml
[DEBUG] Installing com.cjf:demo/maven-metadata.xml to E:\OperSource\com\cjf\demo\maven-metadata-local.xml
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 10.549 s
[INFO] Finished at: 2017-07-09T18:13:20+08:00
[INFO] Final Memory: 26M/219M
[INFO] ------------------------------------------------------------------------
·······
```
好了，看了这么多的配置文件信息和日志信息，我们也总结一下 Maven 远程仓库优先级了。

主要有以下几点：
1. 从日志信息我们得出这几种maven仓库的优先级别为
> 本地仓库 > 私服 （profile）> 远程仓库（repository）和 镜像 （mirror） > 中央仓库 （central）

2. 镜像是一个特殊的配置，其实镜像等同与远程仓库，没有匹配远程仓库的镜像就毫无作用（如 foo2）。
3. 总结上面所说的，Maven 仓库的优先级就是 私服和远程仓库 的对比，没有其它的仓库类型。为什么这么说是因为，镜像等同远程，而中央其实也是 maven super xml 配置的一个repository 的一个而且。所以 maven 仓库真正的优先级为

> 本地仓库 > 私服（profile）> 远程仓库（repository）
